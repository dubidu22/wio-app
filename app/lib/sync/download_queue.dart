import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../data/database.dart';
import '../data/queries.dart';
import '../media/media_store.dart';
import 'sync_engine.dart';
import 'upload_queue.dart';

/// Bytes asked for in one request (D-329), as uploads (D-186).
const int downloadRangeBytes = uploadChunkBytes;

/// What downloads remember for the life of the app (D-327, D-330, D-331).
/// A restart forgets it, so a skipped file is tried again then.
class DownloadMemory {
  /// Not tried again until the app restarts.
  final Set<String> skipped = <String>{};

  /// Files that already started again from 0 after a wrong hash.
  final Set<String> restartedAfterHash = <String>{};

  /// Files that already started again from 0 after a 416.
  final Set<String> restartedAfterRange = <String>{};
}

final downloadMemoryProvider = Provider<DownloadMemory>(
  (ref) => DownloadMemory(),
);

bool _never() => false;

/// Fetches files that live rows point at but this device lacks, one at a
/// time in ranges of [downloadRangeBytes] (D-326 to D-331, D-336). Files a
/// screen shows go first, then the newest rows (D-328). With [onlyWanted]
/// (the web, D-334) only files a screen shows are fetched.
class DownloadWorker {
  DownloadWorker({
    required this.db,
    required this.api,
    required this.store,
    required this.memory,
    required this.present,
    required this.markPresent,
    required this.setLoading,
    required this.wanted,
    required this.tooOld,
    this.onlyWanted = false,
    bool Function()? stopped,
  }) : stopped = stopped ?? _never;

  final WioDatabase db;
  final FilesApi api;
  final MediaStore store;
  final DownloadMemory memory;

  /// Files on the device now; null while that is not known, and then
  /// nothing is fetched.
  final Set<String>? Function() present;
  final void Function(String sha256) markPresent;

  /// The files queued or coming in now; empty when the step ends (D-333).
  final void Function(Set<String> loading) setLoading;

  /// Files screens show now.
  final Set<String> Function() wanted;
  final bool Function() tooOld;
  final bool onlyWanted;

  /// True once the run should end before its next range (D-375).
  final bool Function() stopped;

  /// Fetches until nothing is left to fetch now. Ends early with
  /// [SyncResult.runAgain] when new changes or uploads wait (D-326).
  Future<SyncResult> run() async {
    final notNow = <String>{};
    try {
      while (true) {
        if (await _othersWait()) return SyncResult.runAgain;
        final todo = await _todo(notNow);
        setLoading(<String>{for (final ref in todo) ref.sha256});
        if (todo.isEmpty) return SyncResult.done;
        final shown = wanted();
        final next = todo.firstWhere(
          (ref) => shown.contains(ref.sha256),
          orElse: () => todo.first,
        );
        final result = await _download(next.sha256, notNow);
        if (result != null) return result;
      }
    } finally {
      setLoading(const <String>{});
    }
  }

  /// Uploads go first, and new changes are pushed first (D-326).
  Future<bool> _othersWait() async {
    if ((await (db.select(db.outbox)..limit(1)).get()).isNotEmpty) return true;
    final uploads =
        await (db.select(db.uploads)
              ..where((u) => u.failedReason.isNull())
              ..limit(1))
            .get();
    return uploads.isNotEmpty;
  }

  Future<List<MediaRef>> _todo(Set<String> notNow) async {
    final here = present();
    if (here == null) return const <MediaRef>[];
    final shown = onlyWanted ? wanted() : null;
    final todo = <MediaRef>[];
    for (final ref in await mediaRefs(db)) {
      final sha = ref.sha256;
      if (here.contains(sha) ||
          notNow.contains(sha) ||
          memory.skipped.contains(sha) ||
          sha == emptyFileSha256) {
        continue;
      }
      if (ref.bytes > maxUploadBytes) {
        // The server never holds such a file (D-186).
        memory.skipped.add(sha);
        continue;
      }
      if (shown != null && !shown.contains(sha)) continue;
      todo.add(ref);
    }
    return todo;
  }

  /// Whether a live row still points at [sha256] (D-336).
  Future<bool> _stillUsed(String sha256) async {
    final row = await db
        .customSelect(
          'SELECT 1 FROM pictures WHERE deleted_at IS NULL AND file_sha256 = ? '
          'UNION ALL SELECT 1 FROM notes WHERE deleted_at IS NULL '
          'AND audio_sha256 = ? LIMIT 1',
          variables: <Variable<Object>>[
            Variable<String>(sha256),
            Variable<String>(sha256),
          ],
        )
        .getSingleOrNull();
    return row != null;
  }

  /// One file to its end (null) or a stop of the run.
  Future<SyncResult?> _download(String sha256, Set<String> notNow) async {
    var offset = 0;
    try {
      offset = await store.partSize(sha256);
    } on Object {
      return const SyncResult(SyncStop.failed);
    }
    var unexpected = 0;
    while (true) {
      if (tooOld()) return const SyncResult(SyncStop.tooOld);
      // The `.part` file keeps what came; the next run resumes there.
      if (stopped()) return SyncResult.interrupted;
      final TonikResult<GetFileResponse, http.Response> response;
      try {
        response = await api
            .getFile(
              sha256: sha256,
              range: 'bytes=$offset-${offset + downloadRangeBytes - 1}',
              ifRange: offset > 0 ? '"$sha256"' : null,
            )
            .timeout(uploadChunkTimeout);
      } on Object {
        return const SyncResult(SyncStop.offline);
      }
      if (tooOld()) return const SyncResult(SyncStop.tooOld);
      final _Step step;
      switch (response) {
        case TonikSuccess(value: GetFileResponse206(:final body)):
          step = _range(body, offset);
        case TonikSuccess(value: GetFileResponse200(:final body)):
          step = _Whole(_wholeBytes(body));
        case TonikSuccess(value: GetFileResponse404()):
          // Not readable, or not complete yet: the other device may still
          // be sending it (D-331). Next run.
          notNow.add(sha256);
          return null;
        case TonikSuccess(value: GetFileResponse416(:final body)):
          step = _RangeRefused(_refusedTotal(body.contentRange));
        case TonikSuccess(value: GetFileResponse400()) ||
            TonikSuccess(value: GetFileResponse403()):
          memory.skipped.add(sha256);
          return null;
        case TonikSuccess(value: GetFileResponse401(:final body))
            when body.code == 'token_invalid':
          return const SyncResult(SyncStop.signedOut);
        case TonikSuccess(value: GetFileResponse426()):
          return const SyncResult(SyncStop.tooOld);
        case TonikSuccess(value: GetFileResponse503(:final body)):
          return SyncResult(
            SyncStop.offline,
            retryAfter: body.retryAfter == null
                ? null
                : Duration(seconds: body.retryAfter!),
          );
        case _:
          return const SyncResult(SyncStop.offline);
      }
      try {
        switch (step) {
          case _Piece(:final bytes, :final first, :final total):
            if (total > maxUploadBytes) {
              await store.deletePart(sha256);
              memory.skipped.add(sha256);
              return null;
            }
            await store.writePart(sha256, bytes, restart: first == 0);
            offset = first + bytes.length;
            if (offset < total) break;
            if (await _finish(sha256)) return null;
            offset = 0;
          case _Whole(:final bytes):
            await store.writePart(sha256, bytes, restart: true);
            if (await _finish(sha256)) return null;
            offset = 0;
          case _Mismatch():
            // The answer does not fit what we hold: start again, bounded.
            if (++unexpected > 3) return const SyncResult(SyncStop.failed);
            await store.deletePart(sha256);
            offset = 0;
          case _RangeRefused(:final total):
            // The part already holds the whole file (the app stopped between
            // the last write and the rename): check and name it, no new
            // download (#82). A wrong hash starts from 0 once, as always.
            if (total != null && total > 0 && total == offset) {
              if (await _finish(sha256)) return null;
              offset = 0;
              break;
            }
            await store.deletePart(sha256);
            // No usable size (a part bigger than the file, a missing or odd
            // header): start from 0 once, then leave the file (D-331).
            if (!memory.restartedAfterRange.add(sha256)) {
              memory.skipped.add(sha256);
              return null;
            }
            offset = 0;
        }
      } on _Done {
        return null;
      } on Object {
        // The device could not write (full storage): back off (D-336).
        return const SyncResult(SyncStop.failed);
      }
      if (await _othersWait()) return SyncResult.runAgain;
      // A row deleted meanwhile: stop, the part stays (D-336).
      if (!await _stillUsed(sha256)) return null;
    }
  }

  /// Names the file when its hash matches (D-330): true when done. A
  /// mismatch starts once more from 0, then the file is left.
  Future<bool> _finish(String sha256) async {
    if (await store.finishPart(sha256)) {
      markPresent(sha256);
      return true;
    }
    await store.deletePart(sha256);
    if (memory.restartedAfterHash.add(sha256)) return false;
    memory.skipped.add(sha256);
    throw const _Done();
  }

  /// The file size of `Content-Range: bytes */<total>`, or null.
  static int? _refusedTotal(FilesSha256Get416Response body) {
    final match = RegExp(r'^bytes \*/(\d{1,15})$')
        .firstMatch(body.contentRange?.trim() ?? '');
    return match == null ? null : int.parse(match[1]!);
  }

  _Step _range(FilesSha256Get206Response body, int offset) {
    final match = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$')
        .firstMatch(body.contentRange.trim());
    if (match == null) return const _Mismatch();
    final first = int.parse(match[1]!);
    final last = int.parse(match[2]!);
    final total = int.parse(match[3]!);
    final bytes = _rangeBytes(body);
    if (first != offset || last < first || bytes.length != last - first + 1) {
      return const _Mismatch();
    }
    return _Piece(bytes, first, total);
  }

  static List<int> _rangeBytes(FilesSha256Get206Response body) =>
      switch (body) {
        FilesSha256Get206ResponseJpeg(:final body) => body.toBytes(),
        FilesSha256Get206ResponsePng(:final body) => body.toBytes(),
        FilesSha256Get206ResponseWebp(:final body) => body.toBytes(),
        FilesSha256Get206ResponseHeic(:final body) => body.toBytes(),
        FilesSha256Get206ResponseMp4(:final body) => body.toBytes(),
        FilesSha256Get206ResponseOctetStream(:final body) => body.toBytes(),
      };

  static List<int> _wholeBytes(FilesSha256Get200Response body) =>
      switch (body) {
        FilesSha256Get200ResponseJpeg(:final body) => body.toBytes(),
        FilesSha256Get200ResponsePng(:final body) => body.toBytes(),
        FilesSha256Get200ResponseWebp(:final body) => body.toBytes(),
        FilesSha256Get200ResponseHeic(:final body) => body.toBytes(),
        FilesSha256Get200ResponseMp4(:final body) => body.toBytes(),
        FilesSha256Get200ResponseOctetStream(:final body) => body.toBytes(),
      };
}

/// What one answer gave.
sealed class _Step {
  const _Step();
}

final class _Piece extends _Step {
  const _Piece(this.bytes, this.first, this.total);
  final List<int> bytes;
  final int first;
  final int total;
}

final class _Whole extends _Step {
  const _Whole(this.bytes);
  final List<int> bytes;
}

final class _Mismatch extends _Step {
  const _Mismatch();
}

final class _RangeRefused extends _Step {
  const _RangeRefused(this.total);

  /// The size the server reported, when it did.
  final int? total;
}

/// The file was left for this app run.
final class _Done implements Exception {
  const _Done();
}
