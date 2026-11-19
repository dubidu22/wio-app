import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database.dart';
import '../data/ids.dart';
import '../shell/providers.dart';
import 'local_tables.dart';
import 'rebuild.dart';

/// One refused change with the name of its record, for the list (D-197).
class RejectedEntry {
  const RejectedEntry(this.change, this.name);

  final RejectedChange change;

  /// The record's name where the change, the device or the server copy has
  /// one.
  final String? name;

  Map<String, Object?> get fields =>
      jsonDecode(change.fields) as Map<String, Object?>;

  /// Reasons a new try cannot fix: the value exists, the record is gone or
  /// the change is too large (D-197, D-198, D-199).
  bool get canResend => !const <String>{
    'duplicate',
    'deleted',
    'not_found',
    'too_large',
  }.contains(change.reason);
}

/// The refused changes, newest first.
final rejectedListProvider = StreamProvider<List<RejectedEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.rejectedChanges)
        ..orderBy(<OrderClauseGenerator<$RejectedChangesTable>>[
          (r) => OrderingTerm.desc(r.rejectedAt),
          (r) => OrderingTerm.asc(r.changeId),
        ]))
      .watch()
      .asyncMap(
        (rows) async => <RejectedEntry>[
          for (final row in rows) RejectedEntry(row, await _nameOf(db, row)),
        ],
      );
});

Future<String?> _nameOf(WioDatabase db, RejectedChange row) async {
  final fields = jsonDecode(row.fields) as Map<String, Object?>;
  if (row.entity == 'entries') return _entryName(db, row, fields);
  if (fields['name'] case final String name) return name;
  return _recordName(db, row.entity, row.entityId);
}

/// The `name` of record [id] of [entity] on the device or in its server
/// copy.
Future<String?> _recordName(WioDatabase db, String entity, String id) async {
  final table = typedTableOf(db, entity);
  if (table != null && table.columnsByName.containsKey('name')) {
    final local = await db
        .customSelect(
          'SELECT name FROM "$entity" WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
        )
        .getSingleOrNull();
    if (local?.read<String?>('name') case final String name) return name;
  }
  final copy = await _copyOf(db, entity, id);
  if (copy == null) return null;
  return copy['name'] as String?;
}

Future<Map<String, Object?>?> _copyOf(
  WioDatabase db,
  String entity,
  String id,
) async {
  final copy = await (db.select(
    db.serverRecords,
  )..where((r) => r.entity.equals(entity) & r.id.equals(id))).getSingleOrNull();
  return copy == null ? null : jsonDecode(copy.fields) as Map<String, Object?>;
}

/// An entry's name is its title, else its code. A create answered
/// `duplicate` names the entry it was joined to (D-198, D-444); other
/// changes name their own entry, from the device, its server copy or the
/// change.
Future<String?> _entryName(
  WioDatabase db,
  RejectedChange row,
  Map<String, Object?> fields,
) async {
  String? nameIn(Map<String, Object?>? values) =>
      (values?['title'] as String?) ?? (values?['code'] as String?);
  Future<String?> nameOfEntry(String id) async {
    final local = await (db.select(
      db.entries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    return local?.title ??
        local?.code ??
        nameIn(await _copyOf(db, 'entries', id));
  }

  if (row.existingId case final String existing) {
    if (await nameOfEntry(existing) case final String name) return name;
  }
  return nameIn(fields) ?? await nameOfEntry(row.entityId);
}

/// "Noch einmal senden" (D-197): the same fields as a new change with a new
/// change id, because the old id keeps its answer (D-172). The record shows
/// the change again at once.
Future<void> resendRejected(
  WioDatabase db,
  RejectedChange row, {
  required DateTime now,
  IdGenerator changeIds = newUuidV7,
}) => db.transaction(() async {
  final copy =
      await (db.select(db.serverRecords)..where(
            (r) => r.entity.equals(row.entity) & r.id.equals(row.entityId),
          ))
          .getSingleOrNull();
  await db
      .into(db.outbox)
      .insert(
        OutboxCompanion.insert(
          changeId: changeIds(),
          entity: row.entity,
          entityId: row.entityId,
          op: Value<String>(row.op),
          fields: row.fields,
          baseRevision: Value<int?>(copy?.revision),
          deviceTime: now.toUtc().toIso8601String(),
        ),
      );
  await (db.delete(
    db.rejectedChanges,
  )..where((r) => r.changeId.equals(row.changeId))).go();
  await rebuildRecords(db, <RecordKey>[(entity: row.entity, id: row.entityId)]);
});

/// "Verwerfen": removes the entry; [keepRejected] undoes it (UX rule 10).
Future<void> discardRejected(WioDatabase db, RejectedChange row) => (db.delete(
  db.rejectedChanges,
)..where((r) => r.changeId.equals(row.changeId))).go();

/// "Rückgängig" after "Verwerfen".
Future<void> keepRejected(WioDatabase db, RejectedChange row) =>
    db.into(db.rejectedChanges).insertOnConflictUpdate(row);
