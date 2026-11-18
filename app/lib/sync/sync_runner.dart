import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wio_api/wio_api.dart';

import '../auth/session_provider.dart';
import '../shell/providers.dart';
import '../update/app_too_old.dart';
import 'sync_engine.dart';
import 'upload_queue.dart';

/// When sync runs by itself (D-201). Tests shorten the times.
class SyncTiming {
  const SyncTiming({
    this.afterWrite = const Duration(seconds: 3),
    this.every = const Duration(minutes: 5),
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

/// Runs sync in the foreground, one run at a time (D-201): after start-up,
/// after local writes, on resume, every few minutes, and again after a
/// failure with growing waits. Never while signed out, without a server or
/// while the app is too old (D-156).
final syncProvider = NotifierProvider<SyncNotifier, SyncActivity>(
  SyncNotifier.new,
);

class SyncNotifier extends Notifier<SyncActivity> {
  Timer? _afterWrite;
  Timer? _retry;
  Timer? _every;
  StreamSubscription<Set<TableUpdate>>? _writes;
  int _failures = 0;
  bool _running = false;
  bool _again = false;

  @override
  SyncActivity build() {
    ref.onDispose(_stop);
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
    }
    return SyncActivity.idle;
  }

  void _stop() {
    _afterWrite?.cancel();
    _retry?.cancel();
    _every?.cancel();
    unawaited(_writes?.cancel());
  }

  void _scheduleAfterWrite(Duration wait) {
    _afterWrite?.cancel();
    _afterWrite = Timer(wait, trigger);
  }

  /// Starts a run when sync may start by itself.
  void trigger() {
    if (ref.read(syncAutoStartProvider)) unawaited(run());
  }

  /// One run: push, then pull (D-201). A run asked for while one is going
  /// follows it.
  Future<void> run() async {
    if (_running) {
      _again = true;
      return;
    }
    final session = ref.read(sessionProvider).value;
    final server = ref.read(apiServerProvider);
    if (session == null ||
        server == null ||
        ref.read(appTooOldProvider) != null) {
      return;
    }
    _running = true;
    _retry?.cancel();
    state = SyncActivity.running;
    final SyncResult result;
    try {
      final db = ref.read(databaseProvider);
      bool tooOld() => ref.mounted && ref.read(appTooOldProvider) != null;
      result = await SyncEngine(
        db: db,
        api: SyncApi(server),
        workspaceId: session.workspace.id,
        tooOld: tooOld,
        clock: ref.read(clockProvider),
        uploads: UploadWorker(
          db: db,
          api: FilesApi(server),
          store: ref.read(uploadStoreProvider),
          tooOld: tooOld,
        ),
      ).run();
    } on Object {
      if (ref.mounted) _failed(null);
      return;
    } finally {
      _running = false;
    }
    if (!ref.mounted) return;
    switch (result.stop) {
      case SyncStop.done:
        _failures = 0;
        state = SyncActivity.idle;
        // New changes came in while files were sent (D-211).
        if (result.more) _again = true;
      case SyncStop.offline || SyncStop.failed:
        _failed(result.retryAfter);
      case SyncStop.tooOld:
        state = SyncActivity.idle;
      case SyncStop.signedOut:
        state = SyncActivity.idle;
        // getMe decides: token_invalid forgets the session, data stays.
        unawaited(ref.read(sessionProvider.notifier).check());
    }
    if (_again) {
      _again = false;
      trigger();
    }
  }

  void _failed(Duration? retryAfter) {
    state = SyncActivity.offline;
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
