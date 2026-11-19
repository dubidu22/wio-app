import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wio_api/wio_api.dart';

import '../auth/session_provider.dart';
import '../media/media_presence.dart';
import '../media/media_store.dart';
import '../shell/providers.dart';
import '../update/app_too_old.dart';
import 'download_queue.dart';
import 'sync_engine.dart';
import 'upload_queue.dart';

/// When sync runs by itself (D-201). Tests shorten the times.
class SyncTiming {
  const SyncTiming({
    this.afterWrite = const Duration(seconds: 3),
    this.every = const Duration(minutes: 5),
    this.afterWant = const Duration(seconds: 1),
    this.backOff = const <Duration>[
      Duration(seconds: 30),
      Duration(minutes: 1),
      Duration(minutes: 2),
      Duration(minutes: 4),
      Duration(minutes: 8),
      Duration(minutes: 15),
    ],
  });

  /// Wait after the last local write before pushing.
  final Duration afterWrite;

  /// Runs while the app is open.
  final Duration every;

  /// Wait after a screen showed a missing file before a run fetches it
  /// (D-328).
  final Duration afterWant;

  /// Waits after failed runs, in order; the last one repeats.
  final List<Duration> backOff;
}

final syncTimingProvider = Provider<SyncTiming>((ref) => const SyncTiming());

/// Whether sync starts by itself. Widget tests of other screens turn it off
/// so their fake servers see only the requests they script.
final syncAutoStartProvider = Provider<bool>((ref) => true);

/// What sync is doing, for the status line (D-203).
enum SyncActivity {
  idle,
  running,

  /// The last run got no answer; it runs again later by itself.
  offline,
}

/// True when the engine was started by the phone for background work
/// (`main` got the argument `background`, D-381): no run starts by itself
/// until the app comes to the front.
final startedInBackgroundProvider = Provider<bool>((ref) => false);

/// How a background run ended, as the channel answers it (D-374).
enum BackgroundOutcome {
  /// Nothing left for this kind of run.
  done,

  /// Offline, failed, or stopped with work left: try again later.
  retry,

  /// Signed out, no server, or the app is too old: nothing to do (D-377).
  skip,
}

/// Runs sync one run at a time (D-201): in the foreground after start-up,
/// after local writes, on resume, every few minutes, and again after a
/// failure with growing waits; in the background only when the phone asks
/// for a run (D-376). Never while signed out, without a server or while the
/// app is too old (D-156).
final syncProvider = NotifierProvider<SyncNotifier, SyncActivity>(
  SyncNotifier.new,
);

class SyncNotifier extends Notifier<SyncActivity> {
  Timer? _afterWrite;
  Timer? _retry;
  Timer? _every;
  Timer? _afterWant;
  StreamSubscription<Set<TableUpdate>>? _writes;
  int _failures = 0;
  bool _running = false;
  bool _again = false;
  Completer<void>? _current;
  bool _background = false;
  bool _stopAsked = false;
  DateTime? _deadline;
  bool _filesLeft = false;

  @override
  SyncActivity build() {
    ref.onDispose(_stop);
    _background = ref.read(startedInBackgroundProvider);
    if (ref.read(syncAutoStartProvider)) {
      final timing = ref.read(syncTimingProvider);
      _every = Timer.periodic(timing.every, (_) => trigger());
      final db = ref.read(databaseProvider);
      // Only new outbox rows start a push; sync's own updates and deletes
      // of the outbox do not.
      _writes = db
          .tableUpdates(
            TableUpdateQuery.onTable(
              db.outbox,
              limitUpdateKind: UpdateKind.insert,
            ),
          )
          .listen((_) => _scheduleAfterWrite(timing.afterWrite));
      // A screen shows a file that is not here: fetch it soon (D-328).
      final wants = ref.read(mediaWantsProvider);
      wants.onWanted = (_) => _scheduleAfterWant(timing.afterWant);
      ref.onDispose(() => wants.onWanted = null);
    }
    return SyncActivity.idle;
  }

  void _stop() {
    _afterWrite?.cancel();
    _afterWant?.cancel();
    _retry?.cancel();
    _every?.cancel();
    unawaited(_writes?.cancel());
  }

  void _scheduleAfterWrite(Duration wait) {
    _afterWrite?.cancel();
    _afterWrite = Timer(wait, trigger);
  }

  void _scheduleAfterWant(Duration wait) {
    if (_afterWant?.isActive ?? false) return;
    _afterWant = Timer(wait, () {
      if (!ref.mounted || state != SyncActivity.idle) return;
      final presence = ref.read(mediaPresenceProvider);
      final missing = ref
          .read(mediaWantsProvider)
          .all
          .any((sha) => presence.of(sha) == MediaFileState.missing);
      if (missing) trigger();
    });
  }

  /// Whether the app is in the background now (D-376).
  bool get inBackground => _background;

  /// Whether a run that skipped files left files behind (D-378).
  bool get filesLeft => _filesLeft;

  /// The app went to the background: runs no longer start by themselves;
  /// the phone asks for them (D-376).
  void left() {
    _background = true;
  }

  /// The app is in front again: sync runs by itself again, starting now.
  void resumed() {
    _background = false;
    trigger();
  }

  /// Starts a run when sync may start by itself: in the foreground only.
  void trigger() {
    if (ref.read(syncAutoStartProvider) && !_background) unawaited(run());
  }

  /// Asks the current run to end at its next safe point (D-375).
  void stopRun() {
    _stopAsked = true;
  }

  bool _stopped() {
    if (_stopAsked) return true;
    final deadline = _deadline;
    return deadline != null && !ref.read(clockProvider)().isBefore(deadline);
  }

  bool _mayRun() =>
      ref.read(sessionProvider).value != null &&
      ref.read(apiServerProvider) != null &&
      ref.read(appTooOldProvider) == null;

  /// One run asked for by the phone while the app is in the background
  /// (D-374): joins a run that is going, then runs until nothing is left,
  /// [deadline] passes or [stopRun] is called. Files only when [files]
  /// (D-378).
  Future<BackgroundOutcome> runInBackground({
    required DateTime deadline,
    required bool files,
  }) async {
    for (var current = _current; current != null; current = _current) {
      await current.future;
    }
    _deadline = deadline;
    _stopAsked = false;
    try {
      while (true) {
        if (!ref.mounted || !_mayRun()) return BackgroundOutcome.skip;
        final result = await _runOnce(files: files);
        if (!ref.mounted || result == null) return BackgroundOutcome.skip;
        switch (result.stop) {
          case SyncStop.done:
            if (!result.more) return BackgroundOutcome.done;
            if (_stopped()) return BackgroundOutcome.retry;
          case SyncStop.offline || SyncStop.failed || SyncStop.interrupted:
            return BackgroundOutcome.retry;
          case SyncStop.tooOld || SyncStop.signedOut:
            return BackgroundOutcome.skip;
        }
      }
    } finally {
      _deadline = null;
      _stopAsked = false;
    }
  }

  /// One foreground run: push, then pull (D-201). A run asked for while one
  /// is going follows it.
  Future<void> run() async {
    if (_running) {
      _again = true;
      return;
    }
    final result = await _runOnce(files: true);
    if (result == null || !ref.mounted) return;
    switch (result.stop) {
      case SyncStop.done:
        // New changes came in while files were sent (D-211).
        if (result.more) _again = true;
      case SyncStop.offline || SyncStop.failed:
        _failed(result.retryAfter);
      case SyncStop.interrupted || SyncStop.tooOld:
        break;
      case SyncStop.signedOut:
        // getMe decides: token_invalid forgets the session, data stays.
        unawaited(ref.read(sessionProvider.notifier).check());
    }
    if (_again) {
      _again = false;
      trigger();
    }
  }

  /// Runs the engine once; null when sync may not run now or another run
  /// is going. Sets the status line.
  Future<SyncResult?> _runOnce({required bool files}) async {
    if (_running || !_mayRun()) return null;
    final session = ref.read(sessionProvider).value!;
    final server = ref.read(apiServerProvider)!;
    _running = true;
    final current = _current = Completer<void>();
    _retry?.cancel();
    state = SyncActivity.running;
    SyncResult result;
    try {
      final db = ref.read(databaseProvider);
      bool tooOld() => ref.mounted && ref.read(appTooOldProvider) != null;
      result = await SyncEngine(
        db: db,
        api: SyncApi(server),
        workspaceId: session.workspace.id,
        tooOld: tooOld,
        clock: ref.read(clockProvider),
        files: files,
        stopped: _stopped,
        uploads: UploadWorker(
          db: db,
          api: FilesApi(server),
          store: ref.read(uploadStoreProvider),
          tooOld: tooOld,
          stopped: _stopped,
        ),
        downloads: _downloads(server, tooOld),
      ).run();
    } on Object {
      result = const SyncResult(SyncStop.failed);
    } finally {
      _running = false;
      _current = null;
      current.complete();
    }
    if (!ref.mounted) return result;
    if (result.stop == SyncStop.done) {
      _failures = 0;
      _filesLeft = !files;
      state = SyncActivity.idle;
    } else if (result.stop == SyncStop.offline ||
        result.stop == SyncStop.failed) {
      state = SyncActivity.offline;
    } else {
      state = SyncActivity.idle;
    }
    return result;
  }

  DownloadWorker _downloads(Server server, bool Function() tooOld) {
    final store = ref.read(mediaStoreProvider);
    final presence = ref.read(mediaPresenceProvider.notifier);
    final wants = ref.read(mediaWantsProvider);
    return DownloadWorker(
      db: ref.read(databaseProvider),
      api: FilesApi(server),
      store: store,
      memory: ref.read(downloadMemoryProvider),
      present: () {
        if (!ref.mounted) return null;
        final presence = ref.read(mediaPresenceProvider);
        // Not listed yet, or a phone without a media folder: nothing to
        // compare with, so nothing is fetched now.
        if (!presence.listed) return null;
        if (store.supported && ref.read(mediaFolderProvider).value == null) {
          return null;
        }
        return presence.present;
      },
      markPresent: (sha) {
        if (ref.mounted) presence.markPresent(sha);
      },
      setLoading: (loading) {
        if (ref.mounted) presence.setLoading(loading);
      },
      wanted: () => wants.all,
      tooOld: tooOld,
      // The web fetches only what a screen shows (D-334).
      onlyWanted: !store.supported,
      stopped: _stopped,
    );
  }

  void _failed(Duration? retryAfter) {
    final steps = ref.read(syncTimingProvider).backOff;
    var wait = steps[_failures < steps.length ? _failures : steps.length - 1];
    if (retryAfter != null && retryAfter > wait) wait = retryAfter;
    _failures++;
    _retry?.cancel();
    _retry = Timer(wait, trigger);
  }
}

/// Unsent changes, for the status line (D-203).
final outboxCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final count = countAll();
  return (db.selectOnly(db.outbox)..addColumns(<Expression<Object>>[count]))
      .map((row) => row.read(count) ?? 0)
      .watchSingle();
});

/// Files waiting for upload, for the status line (D-216).
final pendingUploadCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  final count = countAll();
  return (db.selectOnly(db.uploads)
        ..addColumns(<Expression<Object>>[count])
        ..where(db.uploads.failedReason.isNull()))
      .map((row) => row.read(count) ?? 0)
      .watchSingle();
});

/// Changes the server refused plus failed uploads, for the job-list hint
/// (D-197, D-214).
final rejectedCountProvider = StreamProvider<int>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .customSelect(
        'SELECT (SELECT COUNT(*) FROM rejected_changes) + '
        '(SELECT COUNT(*) FROM uploads WHERE failed_reason IS NOT NULL) AS n',
        readsFrom: <ResultSetImplementation<Object?, Object?>>{
          db.rejectedChanges,
          db.uploads,
        },
      )
      .map((row) => row.read<int>('n'))
      .watchSingle();
});
