import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_provider.dart';
import '../shell/providers.dart';
import '../update/app_too_old.dart';
import 'sync_runner.dart';

/// The app's own channel to the phone's background work (D-372, D-374):
/// WorkManager on Android, BGTaskScheduler on iOS.
const MethodChannel backgroundChannel = MethodChannel('wio/background');

/// Whether this platform has background sync: Android and iOS, never the
/// web (D-383). Tests override it.
final backgroundSyncSupportedProvider = Provider<bool>(
  (ref) =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS),
);

/// What the phone should keep scheduled (D-374, D-376).
@immutable
class BackgroundPlan {
  const BackgroundPlan({
    required this.active,
    required this.pending,
    required this.files,
  });

  /// Signed in, a server set and not too old (D-377); false cancels all.
  final bool active;

  /// Unsent changes wait in the outbox.
  final bool pending;

  /// Uploads wait, or a run on a metered network skipped files (D-378).
  /// Downloads count only through that skip: the hourly pull fetches the
  /// rest on Wi-Fi (PR 87 review N2).
  final bool files;

  Map<String, Object?> toMap() => <String, Object?>{
    'active': active,
    'pending': pending,
    'files': files,
  };

  @override
  bool operator ==(Object other) =>
      other is BackgroundPlan &&
      other.active == active &&
      other.pending == pending &&
      other.files == files;

  @override
  int get hashCode => Object.hash(active, pending, files);

  @override
  String toString() => 'BackgroundPlan$toMap()';
}

/// Connects sync with the phone's background work (plan 052):
/// - answers `run` and `stop` from the phone;
/// - tells the phone what to schedule when the app leaves the front, after
///   every background run, and when the session or the too-old state
///   changes.
final backgroundSyncProvider = Provider<BackgroundSync>((ref) {
  final sync = BackgroundSync(ref);
  ref.onDispose(sync.dispose);
  return sync;
});

class BackgroundSync {
  BackgroundSync(this._ref);

  final Ref _ref;
  bool _started = false;

  bool get _supported => _ref.read(backgroundSyncSupportedProvider);

  /// Starts answering the phone. Call once from the app's root.
  void start() {
    if (_started || !_supported) return;
    _started = true;
    backgroundChannel.setMethodCallHandler(_handle);
    // The phone holds back `run` until Dart listens (PR 87 review S1).
    unawaited(_ready());
    _ref
      ..listen(sessionProvider, (previous, next) {
        if (previous?.value?.token != next.value?.token) {
          unawaited(schedule());
        }
      })
      ..listen(appTooOldProvider, (previous, next) {
        if (previous == null && next != null) unawaited(schedule());
      });
  }

  Future<void> _ready() async {
    try {
      await backgroundChannel.invokeMethod<void>('ready');
    } on Object {
      // No background work on this build.
    }
  }

  void dispose() {
    if (_started) backgroundChannel.setMethodCallHandler(null);
  }

  Future<Object?> _handle(MethodCall call) async {
    final sync = _ref.read(syncProvider.notifier);
    switch (call.method) {
      case 'run':
        final args = (call.arguments as Map<Object?, Object?>?) ?? const {};
        final deadlineMs = args['deadlineMs'] as int?;
        // The phone always sends a deadline; 25 s is the shortest phone
        // budget (an iOS refresh), should one ever be missing.
        final deadline = deadlineMs == null
            ? _ref.read(clockProvider)().add(const Duration(seconds: 25))
            : DateTime.fromMillisecondsSinceEpoch(deadlineMs);
        final outcome = await sync.runInBackground(
          id: args['id'] as String? ?? '',
          deadline: deadline,
          files: args['files'] == true,
        );
        await schedule();
        return outcome.name;
      case 'stop':
        final args = (call.arguments as Map<Object?, Object?>?) ?? const {};
        sync.stopRun(args['id'] as String? ?? '');
        return null;
    }
    throw MissingPluginException('wio/background: ${call.method}');
  }

  /// The app left the front (lifecycle paused): runs no longer start by
  /// themselves, and the phone gets the plan (D-376).
  Future<void> left() async {
    _ref.read(syncProvider.notifier).left();
    await schedule();
  }

  /// What the phone should keep scheduled now.
  Future<BackgroundPlan> plan() async {
    final active =
        _ref.read(sessionProvider).value != null &&
        _ref.read(apiServerProvider) != null &&
        _ref.read(appTooOldProvider) == null;
    if (!active) {
      return const BackgroundPlan(active: false, pending: false, files: false);
    }
    final db = _ref.read(databaseProvider);
    final row = await db
        .customSelect(
          'SELECT (SELECT COUNT(*) FROM outbox) AS outbox, '
          '(SELECT COUNT(*) FROM uploads WHERE failed_reason IS NULL) '
          'AS uploads',
        )
        .getSingle();
    return BackgroundPlan(
      active: true,
      pending: row.read<int>('outbox') > 0,
      files:
          row.read<int>('uploads') > 0 ||
          _ref.read(syncProvider.notifier).filesLeft,
    );
  }

  /// Sends the plan to the phone; a phone without the channel ignores it.
  Future<void> schedule() async {
    if (!_supported) return;
    try {
      final next = await plan();
      await backgroundChannel.invokeMethod<void>('schedule', next.toMap());
    } on Object {
      // No background work on this build; the foreground sync stays.
    }
  }
}
