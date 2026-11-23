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
