import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../data/database.dart';
import '../shell/providers.dart';
import 'sync_engine.dart';
import 'upload_store_native.dart'
    if (dart.library.js_interop) 'upload_store_web.dart';

export 'upload_store_native.dart'
    if (dart.library.js_interop) 'upload_store_web.dart';

/// Most bytes in one chunk (D-186).
const int uploadChunkBytes = 4 * 1024 * 1024;

/// Largest file the server takes (D-186).
const int maxUploadBytes = 100 * 1024 * 1024;

/// How long one chunk may take (D-213); 4 MiB at 1 Mbit/s takes about 34 s.
const Duration uploadChunkTimeout = Duration(seconds: 120);

/// SHA-256 of an empty file. Such a file is never uploaded (D-209).
const String emptyFileSha256 =
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

/// Why an upload failed, shown in "Nicht gesendet" (D-212, D-214).
abstract final class UploadFailure {
  static const String permission = 'permission';
  static const String damaged = 'damaged';
  static const String tooLarge = 'too_large';
  static const String invalid = 'invalid';
}

/// The store of upload copies. Tests override it with a temporary folder.
final uploadStoreProvider = Provider<UploadStore>(
  (ref) => UploadStore.appSupport(),
);

/// Queues the file at [source] for upload and returns its SHA-256 (D-210).
/// An empty file is not queued (D-209). A file over 100 MiB gets a failed
/// row and no copy. The same file twice is one upload. The hash is taken
/// from the app's copy, not from the source (PR 51 review N3).
Future<String> enqueueUpload(
  WioDatabase db,
  UploadStore store,
  String source, {
  required DateTime now,
}) async {
  final sourceSize = await store.size(source);
  if (sourceSize == 0) return emptyFileSha256;
  if (sourceSize > maxUploadBytes) {
    final sha256 = (await store.hash(source)).sha256;
    await _insert(db, sha256, '', sourceSize, now, UploadFailure.tooLarge);
    return sha256;
  }
  final copy = await store.keep(source);
  if (copy.size == 0 || copy.size > maxUploadBytes) {
    // The source changed while it was copied; treat the copy as the file.
    await store.remove(copy.path);
    if (copy.size == 0) return emptyFileSha256;
    await _insert(db, copy.sha256, '', copy.size, now, UploadFailure.tooLarge);
    return copy.sha256;
  }
  await _insert(db, copy.sha256, copy.path, copy.size, now, null);
  return copy.sha256;
}

Future<void> _insert(
  WioDatabase db,
  String sha256,
  String path,
  int size,
  DateTime now,
  String? failedReason,
) => db
    .into(db.uploads)
    .insert(
      UploadsCompanion.insert(
        sha256: sha256,
        path: path,
        size: size,
        createdAt: now.toUtc().toIso8601String(),
        failedReason: Value<String?>(failedReason),
      ),
      mode: InsertMode.insertOrIgnore,
    );

/// How old a file without a row must be before the sweep deletes it: an
/// enqueue running alongside writes its copy before its row (S1). File
/// times can be coarse, so the margin is generous.
const Duration sweepMargin = Duration(minutes: 1);

/// Deletes copies that no upload row names any more (D-215). Runs at start,
/// so "Rückgängig" after "Verwerfen" still finds its copy. Only files older
/// than the sweep's start minus [sweepMargin] go.
Future<void> sweepUploads(
  WioDatabase db,
  UploadStore store, {
  DateTime Function() clock = DateTime.now,
}) async {
  final started = clock();
  final rows = await db.select(db.uploads).get();
  await store.sweep(<String>{
    for (final row in rows) row.sha256,
  }, before: started.subtract(sweepMargin));
}

/// Failed uploads for "Nicht gesendet", newest first (D-214).
final failedUploadsProvider = StreamProvider<List<Upload>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.uploads)
        ..where((u) => u.failedReason.isNotNull())
        ..orderBy(<OrderClauseGenerator<$UploadsTable>>[
          (u) => OrderingTerm.desc(u.createdAt),
          (u) => OrderingTerm.asc(u.sha256),
        ]))
      .watch();
});

/// "Noch einmal senden" for a refused upload (D-214).
Future<void> retryUpload(WioDatabase db, Upload row) =>
    (db.update(db.uploads)..where((u) => u.sha256.equals(row.sha256))).write(
      const UploadsCompanion(failedReason: Value<String?>(null)),
    );

/// "Verwerfen": removes the row and keeps the copy until the next start
/// (D-215); [keepUpload] undoes it.
Future<void> discardUpload(WioDatabase db, Upload row) =>
    (db.delete(db.uploads)..where((u) => u.sha256.equals(row.sha256))).go();

/// "Rückgängig" after "Verwerfen".
Future<void> keepUpload(WioDatabase db, Upload row) =>
    db.into(db.uploads).insertOnConflictUpdate(row);

bool _never() => false;

/// Sends pending uploads one at a time, oldest first, each from the size
/// the server already holds (D-208, D-211, D-212).
class UploadWorker {
  UploadWorker({
    required this.db,
    required this.api,
    required this.store,
    required this.tooOld,
    bool Function()? stopped,
  }) : stopped = stopped ?? _never;

  final WioDatabase db;
  final FilesApi api;
  final UploadStore store;
  final bool Function() tooOld;

  /// True once the run should end before its next chunk (D-375).
  final bool Function() stopped;

  /// Files restarted after a 422 in this worker's life (once each).
  final Set<String> _restarted = <String>{};

  /// Uploads until none is pending. Ends early, with [SyncResult.runAgain],
  /// when new changes wait in the outbox (D-211).
  Future<SyncResult> run() async {
    while (true) {
      if (stopped()) return SyncResult.interrupted;
      final row =
          await (db.select(db.uploads)
                ..where((u) => u.failedReason.isNull())
                ..orderBy(<OrderClauseGenerator<$UploadsTable>>[
                  (u) => OrderingTerm.asc(u.createdAt),
                  (u) => OrderingTerm.asc(u.sha256),
                ])
                ..limit(1))
              .getSingleOrNull();
      if (row == null) return SyncResult.done;
      final result = await _upload(row);
      if (result != null) return result;
      if (await _outboxWaits()) return SyncResult.runAgain;
    }
  }

  Future<bool> _outboxWaits() async =>
      (await (db.select(db.outbox)..limit(1)).get()).isNotEmpty;

  /// One file to its end: done (null), failed (null, row marked) or a
  /// stop of the run.
  Future<SyncResult?> _upload(Upload row) async {
    if (row.size == 0) {
      await _finish(row);
      return null;
    }
    if (!await store.exists(row.path)) {
      await _fail(row, UploadFailure.damaged);
      return null;
    }
    var offset = await _state(row);
    var mismatches = 0;
    while (true) {
      switch (offset) {
        case _Stop(:final result):
          return result;
        case _Failed(:final reason):
          await _fail(row, reason);
          return null;
        case _Complete():
          await _finish(row);
          return null;
        case _At(:final bytes):
          if (bytes > row.size) {
            await _fail(row, UploadFailure.invalid);
            return null;
          }
          // The server keeps what it has; the next run resumes here.
          if (stopped()) return SyncResult.interrupted;
          offset = await _chunk(row, bytes);
          if (offset case _At(bytes: final next) when next <= bytes) {
            // A 409 or 202 that does not move forward; bounded.
            if (++mismatches > 3) return const SyncResult(SyncStop.failed);
          }
      }
    }
  }

  Future<_Offset> _state(Upload row) async {
    if (tooOld()) return const _Stop(SyncResult(SyncStop.tooOld));
    final TonikResult<GetFileStateResponse, http.Response> response;
    try {
      response = await api
          .getFileState(sha256: row.sha256)
          .timeout(syncRequestTimeout);
    } on Object {
      return const _Stop(SyncResult(SyncStop.offline));
    }
    if (tooOld()) return const _Stop(SyncResult(SyncStop.tooOld));
    return switch (response) {
      TonikSuccess(value: GetFileStateResponse200(:final body)) =>
        body.complete ? const _Complete() : _At(body.receivedBytes),
      TonikSuccess(value: GetFileStateResponse403()) => const _Failed(
        UploadFailure.permission,
      ),
      TonikSuccess(value: GetFileStateResponse400()) => const _Failed(
        UploadFailure.invalid,
      ),
      TonikSuccess(value: GetFileStateResponse401(:final body))
          when body.code == 'token_invalid' =>
        const _Stop(SyncResult(SyncStop.signedOut)),
      TonikSuccess(value: GetFileStateResponse426()) => const _Stop(
        SyncResult(SyncStop.tooOld),
      ),
      TonikSuccess(value: GetFileStateResponse503(:final body)) => _Stop(
        SyncResult(SyncStop.offline, retryAfter: _seconds(body.retryAfter)),
      ),
      _ => const _Stop(SyncResult(SyncStop.offline)),
    };
  }

  Future<_Offset> _chunk(Upload row, int start) async {
    final length = row.size - start < uploadChunkBytes
        ? row.size - start
        : uploadChunkBytes;
    final Uint8List bytes;
    try {
      bytes = await store.read(row.path, start, length);
    } on Object {
      return const _Failed(UploadFailure.damaged);
    }
    if (bytes.length != length) return const _Failed(UploadFailure.damaged);
    if (tooOld()) return const _Stop(SyncResult(SyncStop.tooOld));
    final TonikResult<PutFileChunkResponse, http.Response> response;
    try {
      response = await api
          .putFileChunk(
            body: TonikFileBytes(bytes),
            sha256: row.sha256,
            contentRange: 'bytes $start-${start + length - 1}/${row.size}',
          )
          .timeout(uploadChunkTimeout);
    } on Object {
      return const _Stop(SyncResult(SyncStop.offline));
    }
    if (tooOld()) return const _Stop(SyncResult(SyncStop.tooOld));
    switch (response) {
      case TonikSuccess(value: PutFileChunkResponse200()):
        return const _Complete();
      case TonikSuccess(value: PutFileChunkResponse202(:final body)):
        return body.complete ? const _Complete() : _At(body.receivedBytes);
      case TonikSuccess(value: PutFileChunkResponse409(:final body)):
        final received = body.receivedBytes;
        if (received != null) return _At(received);
        return _state(row);
      case TonikSuccess(value: PutFileChunkResponse413()):
        return const _Failed(UploadFailure.tooLarge);
      case TonikSuccess(value: PutFileChunkResponse422()):
        return _hashMismatch(row);
      case TonikSuccess(value: PutFileChunkResponse403()):
        return const _Failed(UploadFailure.permission);
      case TonikSuccess(value: PutFileChunkResponse400()):
        return const _Failed(UploadFailure.invalid);
      case TonikSuccess(value: PutFileChunkResponse401(:final body))
          when body.code == 'token_invalid':
        return const _Stop(SyncResult(SyncStop.signedOut));
      case TonikSuccess(value: PutFileChunkResponse426()):
        return const _Stop(SyncResult(SyncStop.tooOld));
      case TonikSuccess(value: PutFileChunkResponse503(:final body)):
        return _Stop(
          SyncResult(SyncStop.offline, retryAfter: _seconds(body.retryAfter)),
        );
      case _:
        return const _Stop(SyncResult(SyncStop.offline));
    }
  }

  /// 422: an intact copy starts again from 0 once; otherwise the file is
  /// damaged (D-212).
  Future<_Offset> _hashMismatch(Upload row) async {
    final String hash;
    try {
      hash = (await store.hash(row.path)).sha256;
    } on Object {
      return const _Failed(UploadFailure.damaged);
    }
    if (hash != row.sha256 || !_restarted.add(row.sha256)) {
      return const _Failed(UploadFailure.damaged);
    }
    return const _At(0);
  }

  Future<void> _finish(Upload row) async {
    await (db.delete(
      db.uploads,
    )..where((u) => u.sha256.equals(row.sha256))).go();
    if (row.path.isNotEmpty) await store.remove(row.path);
  }

  Future<void> _fail(Upload row, String reason) =>
      (db.update(db.uploads)..where((u) => u.sha256.equals(row.sha256))).write(
        UploadsCompanion(failedReason: Value<String?>(reason)),
      );
}

Duration? _seconds(int? seconds) =>
    seconds == null ? null : Duration(seconds: seconds);

/// Where an upload stands after one answer.
sealed class _Offset {
  const _Offset();
}

/// Send from this byte on.
final class _At extends _Offset {
  const _At(this.bytes);
  final int bytes;
}

final class _Complete extends _Offset {
  const _Complete();
}

final class _Failed extends _Offset {
  const _Failed(this.reason);
  final String reason;
}

final class _Stop extends _Offset {
  const _Stop(this.result);
  final SyncResult result;
}
