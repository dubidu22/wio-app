import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../data/database.dart';
import '../sync/sync_engine.dart';
import 'media_store.dart';

/// How old a file nothing names must be before the media sweep deletes
/// it (D-419). A keep and its row take seconds; this folder holds the only
/// copy of downloaded files and phone clocks move, so the margin is wide.
const Duration mediaSweepMargin = Duration(hours: 1);

final RegExp _hash = RegExp('[0-9a-f]{64}');

/// Every file hash a row on this device names (D-416): pictures and notes,
/// deleted ones too (D-417), any 64-hex run in the fields of the outbox,
/// the refused changes and the server copies, and the upload rows. Read in
/// one transaction.
Future<Set<String>> namedMediaHashes(WioDatabase db) =>
    db.transaction(() async {
      final names = <String>{};
      final columns = await db.customSelect('''
    SELECT file_sha256 AS sha FROM pictures
    UNION SELECT audio_sha256 FROM notes WHERE audio_sha256 IS NOT NULL
    UNION SELECT sha256 FROM uploads
  ''').get();
      for (final row in columns) {
        names.add(row.read<String>('sha'));
      }
      final fields = await db.customSelect('''
    SELECT fields FROM outbox
    UNION ALL SELECT fields FROM rejected_changes
    UNION ALL SELECT fields FROM server_records
  ''').get();
      for (final row in fields) {
        for (final match in _hash.allMatches(row.read<String>('fields'))) {
          names.add(match.group(0)!);
        }
      }
      return names;
    });

/// Deletes media files nothing on this device names any more (D-415): at
/// app start, before that start's first sync (D-421). Only files changed
/// before the sweep's start minus [mediaSweepMargin] go. When no row names
/// any file, nothing is deleted: an empty database next to a full folder
/// is more likely an error than a wish (D-422). While a 410 resync is
/// unfinished the pulled rows are incomplete, so nothing is deleted either
/// (D-459, #100).
Future<void> sweepMedia(
  WioDatabase db,
  MediaStore store, {
  DateTime Function() clock = DateTime.now,
}) async {
  if (!store.supported) return;
  final started = clock();
  final named = await db.transaction(
    () async => await resyncUnfinished(db) ? null : await namedMediaHashes(db),
  );
  if (named == null || named.isEmpty) return;
  await store.sweep(named, before: started.subtract(mediaSweepMargin));
}

/// How long ago every row naming a file must have been deleted, by the
/// server's `deleted_at` and the device clock, before the file may leave
/// the device (D-430, D-511).
const Duration mediaReleaseAfter = Duration(days: 30);

/// Most files asked about and released in one sync run (D-513).
const int mediaReleasePerRun = 20;

/// A file that may leave the device once the server confirms it holds all
/// of it (D-511): its hash, the bytes its rows name, and the newest
/// server `deleted_at` of those rows.
typedef ReleasableMedia = ({String sha256, int bytes, DateTime deletedAt});

/// Files of pictures and notes deleted more than [mediaReleaseAfter] ago
/// (D-511), oldest first: every picture and note row naming the hash is a
/// tombstone whose server copy is deleted that long ago, no outbox row
/// changes such a row, the rows agree on the size, and nothing else names
/// the hash (live or newer deleted rows, the outbox, refused changes,
/// uploads, or any other server copy). The tombstones' own server copies
/// do not count as naming. Empty while a 410 resync is unfinished (D-459).
/// [namedMediaHashes] stays unchanged for the start-up sweep (D-514).
Future<List<ReleasableMedia>> releasableMediaHashes(
  WioDatabase db,
  DateTime now,
) => db.transaction(() async {
  if (await resyncUnfinished(db)) return const <ReleasableMedia>[];
  final limit = now.toUtc().subtract(mediaReleaseAfter);
  final rows = await db.customSelect('''
    SELECT 'pictures' AS entity, p.id AS id, p.file_sha256 AS sha,
      p.file_bytes AS bytes, p.deleted_at AS local_deleted,
      s.deleted_at AS server_deleted,
      EXISTS (SELECT 1 FROM outbox o
        WHERE o.entity = 'pictures' AND o.entity_id = p.id) AS queued
    FROM pictures p
    LEFT JOIN server_records s ON s.entity = 'pictures' AND s.id = p.id
    UNION ALL
    SELECT 'notes', n.id, n.audio_sha256, n.audio_bytes, n.deleted_at,
      s.deleted_at,
      EXISTS (SELECT 1 FROM outbox o
        WHERE o.entity = 'notes' AND o.entity_id = n.id)
    FROM notes n
    LEFT JOIN server_records s ON s.entity = 'notes' AND s.id = n.id
    WHERE n.audio_sha256 IS NOT NULL
  ''').get();
  final byHash = <String, List<_Tombstone?>>{};
  for (final row in rows) {
    final sha = row.read<String>('sha');
    final bytes = row.read<int?>('bytes');
    final local = row.read<String?>('local_deleted');
    final server = DateTime.tryParse(row.read<String?>('server_deleted') ?? '');
    final old =
        local != null &&
        server != null &&
        bytes != null &&
        !row.read<bool>('queued') &&
        !server.toUtc().isAfter(limit);
    (byHash[sha] ??= <_Tombstone?>[]).add(
      old
          ? (
              entity: row.read<String>('entity'),
              id: row.read<String>('id'),
              bytes: bytes,
              deletedAt: server.toUtc(),
            )
          : null,
    );
  }
  final candidates = <String, List<_Tombstone>>{
    for (final MapEntry(:key, :value) in byHash.entries)
      if (key != _emptyFileSha256 && value.every((t) => t != null))
        key: value.cast<_Tombstone>(),
  };
  if (candidates.isEmpty) return const <ReleasableMedia>[];
  final own = <String>{
    for (final tombstones in candidates.values)
      for (final t in tombstones) '${t.entity}/${t.id}',
  };
  final others = <String>{};
  final uploads = await db.customSelect('SELECT sha256 FROM uploads').get();
  for (final row in uploads) {
    others.add(row.read<String>('sha256'));
  }
  final fields = await db.customSelect('''
    SELECT NULL AS entity, NULL AS id, fields FROM outbox
    UNION ALL SELECT NULL, NULL, fields FROM rejected_changes
    UNION ALL SELECT entity, id, fields FROM server_records
  ''').get();
  for (final row in fields) {
    final entity = row.read<String?>('entity');
    if (entity != null && own.contains('$entity/${row.read<String>('id')}')) {
      continue;
    }
    for (final match in _hash.allMatches(row.read<String>('fields'))) {
      others.add(match.group(0)!);
    }
  }
  final result = <ReleasableMedia>[];
  for (final MapEntry(key: sha, value: tombstones) in candidates.entries) {
    if (others.contains(sha)) continue;
    final bytes = tombstones.first.bytes;
    if (tombstones.any((t) => t.bytes != bytes)) continue;
    var newest = tombstones.first.deletedAt;
    for (final t in tombstones) {
      if (t.deletedAt.isAfter(newest)) newest = t.deletedAt;
    }
    result.add((sha256: sha, bytes: bytes, deletedAt: newest));
  }
  result.sort((a, b) {
    final byTime = a.deletedAt.compareTo(b.deletedAt);
    return byTime != 0 ? byTime : a.sha256.compareTo(b.sha256);
  });
  return result;
});

typedef _Tombstone = ({
  String entity,
  String id,
  int bytes,
  DateTime deletedAt,
});

/// SHA-256 of an empty file, which is never uploaded (D-209).
const String _emptyFileSha256 =
    'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

bool _never() => false;

/// Lets files of long-deleted pictures and notes leave the device (#99,
/// D-511..D-516). For each file [releasableMediaHashes] names that is on
/// this device, oldest first and at most [mediaReleasePerRun], the server
/// is asked with `getFileState`; only `complete` with the row's size lets
/// the file go (D-512). Any other answer, an error or a timeout keeps the
/// file and ends the release for this run; nothing is remembered. Before
/// deleting, the candidates are read again, so a restore or a pull that
/// came in meanwhile keeps its file; a pull after that costs at most one
/// repeated download (D-516). [released] is told each file that went, so
/// the device's file list stays true and a restore fetches it again
/// (D-515). Call it only after a sync run that ended `done` (D-513).
/// Returns how many files went.
Future<int> releaseOldMedia(
  WioDatabase db,
  MediaStore store,
  FilesApi api, {
  required DateTime Function() clock,
  bool Function() stopped = _never,
  bool Function() tooOld = _never,
  void Function(String sha256)? released,
  Duration timeout = syncRequestTimeout,
}) async {
  if (!store.supported) return 0;
  final candidates = await releasableMediaHashes(db, clock());
  final confirmed = <String, int>{};
  var asked = 0;
  for (final candidate in candidates) {
    if (asked >= mediaReleasePerRun) break;
    if (stopped() || tooOld()) return 0;
    if (!await store.has(candidate.sha256)) continue;
    asked++;
    final holds = await _serverHolds(api, candidate, timeout);
    if (holds == null) break;
    if (holds) confirmed[candidate.sha256] = candidate.bytes;
  }
  if (confirmed.isEmpty || stopped()) return 0;
  final still = <String, int>{
    for (final c in await releasableMediaHashes(db, clock())) c.sha256: c.bytes,
  };
  var count = 0;
  for (final MapEntry(key: sha, value: bytes) in confirmed.entries) {
    if (still[sha] != bytes) continue;
    try {
      await store.delete(sha);
    } on Object {
      continue;
    }
    count++;
    released?.call(sha);
  }
  return count;
}

/// True when the server holds all of [candidate]'s file, false when it
/// answers that it does not, null for any other answer or no answer
/// (D-512).
Future<bool?> _serverHolds(
  FilesApi api,
  ReleasableMedia candidate,
  Duration timeout,
) async {
  try {
    final response = await api
        .getFileState(sha256: candidate.sha256)
        .timeout(timeout);
    return switch (response) {
      TonikSuccess(value: GetFileStateResponse200(:final body)) =>
        body.complete &&
            body.size == candidate.bytes &&
            body.receivedBytes == candidate.bytes,
      _ => null,
    };
  } on Object {
    return null;
  }
}
