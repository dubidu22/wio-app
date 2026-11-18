import 'dart:convert';

import 'package:drift/drift.dart';

import '../data/database.dart';
import 'local_tables.dart';

/// One record, by entity and id.
typedef RecordKey = ({String entity, String id});

/// Rebuilds the local rows of [keys] as server copy plus unsent changes
/// (D-193). Call it inside the transaction that changed either side.
///
/// Start from the server copy (or nothing), then apply each outbox change of
/// the record in order: upsert and move_entry set their fields, delete sets
/// `deleted_at` to the change's device time, restore clears it. A record
/// with neither is removed (unless the server confirmed it before server
/// copies existed), and so is one that still lacks a required
/// column (it waits for its server copy). Entities without a typed table
/// have nothing to rebuild (D-194).
Future<void> rebuildRecords(WioDatabase db, Iterable<RecordKey> keys) async {
  for (final key in keys.toSet()) {
    final table = typedTableOf(db, key.entity);
    if (table == null) continue;
    await _rebuild(db, table, localTables[key.entity]!, key.id);
  }
}

Future<void> _rebuild(
  WioDatabase db,
  TableInfo<Table, Object?> table,
  LocalTable info,
  String id,
) async {
  final name = table.actualTableName;
  final columns = table.$columns.map((c) => c.name).toSet();
  final copy = await db
      .customSelect(
        'SELECT revision, deleted_at, fields FROM server_records '
        'WHERE entity = ? AND id = ?',
        variables: <Variable<Object>>[
          Variable<String>(name),
          Variable<String>(id),
        ],
        readsFrom: <TableInfo<Table, Object?>>{db.serverRecords},
      )
      .getSingleOrNull();
  final changes = await db
      .customSelect(
        'SELECT op, fields, device_time FROM outbox '
        'WHERE entity = ? AND entity_id = ? ORDER BY seq',
        variables: <Variable<Object>>[
          Variable<String>(name),
          Variable<String>(id),
        ],
        readsFrom: <TableInfo<Table, Object?>>{db.outbox},
      )
      .get();

  final values = <String, Object?>{};
  var base = copy != null;
  if (copy == null) {
    // A row the server confirmed before server copies existed (schema v1,
    // or the demo loader, D-84) is its own base; only rows the server never
    // confirmed (revision null) disappear without a copy.
    final row = await db
        .customSelect(
          'SELECT * FROM "$name" WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(id)],
          readsFrom: <TableInfo<Table, Object?>>{table},
        )
        .getSingleOrNull();
    if (row != null && row.data['revision'] != null) {
      values.addAll(row.data);
      base = true;
    }
  } else {
    final fields = jsonDecode(copy.read<String>('fields')) as Map;
    for (final MapEntry(:key, :value) in fields.entries) {
      if (columns.contains(key)) values[key as String] = toLocalValue(value);
    }
    values['revision'] = copy.read<int>('revision');
    values['deleted_at'] = copy.read<String?>('deleted_at');
  }
  for (final change in changes) {
    switch (change.read<String>('op')) {
      case 'delete':
        values['deleted_at'] = change.read<String>('device_time');
      case 'restore':
        values['deleted_at'] = null;
      default:
        final fields = jsonDecode(change.read<String>('fields')) as Map;
        for (final MapEntry(:key, :value) in fields.entries) {
          if (columns.contains(key)) values[key as String] = value;
        }
    }
  }
  values['id'] = id;

  final complete = info.requiredColumns.every((c) => values[c] != null);
  if ((!base && changes.isEmpty) || !complete) {
    await db.customUpdate(
      'DELETE FROM "$name" WHERE id = ?',
      variables: <Variable<Object>>[Variable<String>(id)],
      updates: <TableInfo<Table, Object?>>{table},
      updateKind: UpdateKind.delete,
    );
    return;
  }
  final names = columns.toList();
  await db.customInsert(
    'INSERT OR REPLACE INTO "$name" '
    '(${names.map((n) => '"$n"').join(', ')}) '
    'VALUES (${List<String>.filled(names.length, '?').join(', ')})',
    variables: <Variable<Object>>[
      for (final n in names) Variable<Object>(values[n]),
    ],
    updates: <TableInfo<Table, Object?>>{table},
  );
}

/// A contract value as the device keeps it: objects and lists as JSON text,
/// booleans as 0 or 1.
Object? toLocalValue(Object? value) => switch (value) {
  Map<Object?, Object?>() || List<Object?>() => jsonEncode(value),
  final bool flag => flag ? 1 : 0,
  _ => value,
};
