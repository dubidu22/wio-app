import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'ids.dart';

/// One unconfirmed change, as it will be pushed (KB sync.md, step 1).
class OutboxChange {
  const OutboxChange({
    required this.changeId,
    required this.entity,
    required this.entityId,
    this.op = 'upsert',
    required this.fields,
    required this.baseRevision,
    required this.deviceTime,
  });

  final String changeId;
  final String entity;
  final String entityId;

  /// One of the contract's ops (D-176, D-192).
  final String op;
  final Map<String, Object?> fields;
  final int? baseRevision;
  final String deviceTime;
}

/// Writes records on the device and queues each change in the outbox (D-66).
///
/// The record and its outbox row are written in one transaction, so a change
/// is either both stored and queued, or neither. Only the changed fields are
/// queued, never the whole record. Edits are not coalesced.
class LocalWriter {
  LocalWriter(
    this._db, {
    this._clock = DateTime.now,
    this._changeIds = newUuidV7,
  });

  final WioDatabase _db;
  final DateTime Function() _clock;
  final IdGenerator _changeIds;

  /// Most changes a single push may carry (KB sync.md, step 2).
  static const int maxPageSize = 200;

  /// Fields the server stamps; the device never sends them.
  static const Set<String> serverFields = <String>{
    'id',
    'created_at',
    'created_by',
    'updated_at',
    'updated_by',
    'revision',
    'deleted_at',
  };

  Map<String, TableInfo<Table, Object?>> get _tables =>
      <String, TableInfo<Table, Object?>>{
        for (final table in <TableInfo<Table, Object?>>[
          _db.customers,
          _db.sites,
          _db.rooms,
          _db.jobs,
        ])
          table.actualTableName: table,
      };

  /// Creates or updates record [id] of [entity] (a table name such as
  /// `rooms`) with [fields] (column names) and queues the change.
  ///
  /// A new record needs every required column, `workspace_id` included.
  /// Returns the change id.
  Future<String> write({
    required String entity,
    required String id,
    required Map<String, Object?> fields,
  }) {
    final table = _tables[entity];
    if (table == null) {
      throw ArgumentError.value(entity, 'entity', 'not a synced table');
    }
    if (fields.isEmpty) {
      throw ArgumentError.value(fields, 'fields', 'no field to change');
    }
    for (final MapEntry(:key, :value) in fields.entries) {
      if (serverFields.contains(key) || !table.columnsByName.containsKey(key)) {
        throw ArgumentError.value(key, 'fields', 'not writable on $entity');
      }
      if (value != null &&
          value is! String &&
          value is! int &&
          value is! double &&
          value is! bool) {
        throw ArgumentError.value(value, key, 'not a plain value');
      }
    }

    // Column names are checked against the table above, so they are safe to
    // put into the statements; values always go in as variables.
    final names = fields.keys.toList();
    final values = <Variable<Object>>[
      for (final name in names) Variable<Object>(fields[name]),
    ];
    final columns = <String>['id', ...names].map((n) => '"$n"').join(', ');
    final marks = List<String>.filled(names.length + 1, '?').join(', ');
    final insertSql = 'INSERT INTO "$entity" ($columns) VALUES ($marks)';
    final assignments = names.map((n) => '"$n" = ?').join(', ');
    final updateSql = 'UPDATE "$entity" SET $assignments WHERE "id" = ?';
    final tables = <TableInfo<Table, Object?>>{table};

    return _db.transaction(() async {
      final current = await _db
          .customSelect(
            'SELECT "revision" FROM "$entity" WHERE "id" = ?',
            variables: <Variable<Object>>[Variable<String>(id)],
            readsFrom: tables,
          )
          .getSingleOrNull();
      if (current == null) {
        await _db.customInsert(
          insertSql,
          variables: <Variable<Object>>[Variable<String>(id), ...values],
          updates: tables,
        );
      } else {
        await _db.customUpdate(
          updateSql,
          variables: <Variable<Object>>[...values, Variable<String>(id)],
          updates: tables,
          updateKind: UpdateKind.update,
        );
      }
      final changeId = _changeIds();
      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              changeId: changeId,
              entity: entity,
              entityId: id,
              fields: jsonEncode(fields),
              baseRevision: Value<int?>(current?.read<int?>('revision')),
              deviceTime: _clock().toUtc().toIso8601String(),
            ),
          );
      return changeId;
    });
  }

  /// Deletes record [id] of [entity]: a tombstone, never a removal, so
  /// [restore] can undo it (UX rule 10, D-176). Returns the change id.
  Future<String> delete({required String entity, required String id}) =>
      _tombstone(entity, id, deleted: true);

  /// Undoes a delete of record [id] of [entity] (D-97). Returns the change id.
  Future<String> restore({required String entity, required String id}) =>
      _tombstone(entity, id, deleted: false);

  Future<String> _tombstone(String entity, String id, {required bool deleted}) {
    final table = _tables[entity];
    if (table == null) {
      throw ArgumentError.value(entity, 'entity', 'not a synced table');
    }
    final tables = <TableInfo<Table, Object?>>{table};
    return _db.transaction(() async {
      final current = await _db
          .customSelect(
            'SELECT "revision" FROM "$entity" WHERE "id" = ?',
            variables: <Variable<Object>>[Variable<String>(id)],
            readsFrom: tables,
          )
          .getSingleOrNull();
      if (current == null) {
        throw ArgumentError.value(id, 'id', 'no such record in $entity');
      }
      final now = _clock().toUtc().toIso8601String();
      await _db.customUpdate(
        'UPDATE "$entity" SET "deleted_at" = ? WHERE "id" = ?',
        variables: <Variable<Object>>[
          Variable<String>(deleted ? now : null),
          Variable<String>(id),
        ],
        updates: tables,
        updateKind: UpdateKind.update,
      );
      final changeId = _changeIds();
      await _db
          .into(_db.outbox)
          .insert(
            OutboxCompanion.insert(
              changeId: changeId,
              entity: entity,
              entityId: id,
              op: Value<String>(deleted ? 'delete' : 'restore'),
              fields: '{}',
              baseRevision: Value<int?>(current.read<int?>('revision')),
              deviceTime: now,
            ),
          );
      return changeId;
    });
  }

  /// The oldest unconfirmed changes, in the order they were made.
  Future<List<OutboxChange>> pending({int limit = maxPageSize}) async {
    if (limit < 1 || limit > maxPageSize) {
      throw RangeError.range(limit, 1, maxPageSize, 'limit');
    }
    final query = _db.select(_db.outbox)
      ..orderBy(<OrderClauseGenerator<$OutboxTable>>[
        (o) => OrderingTerm.asc(o.seq),
      ])
      ..limit(limit);
    final rows = await query.get();
    return <OutboxChange>[
      for (final row in rows)
        OutboxChange(
          changeId: row.changeId,
          entity: row.entity,
          entityId: row.entityId,
          op: row.op,
          fields: (jsonDecode(row.fields) as Map<String, Object?>),
          baseRevision: row.baseRevision,
          deviceTime: row.deviceTime,
        ),
    ];
  }

  /// Removes exactly the changes the server confirmed (KB sync.md, step 3).
  /// Unknown ids are ignored. Returns how many rows were removed.
  Future<int> confirm(Iterable<String> changeIds) {
    final ids = changeIds.toSet();
    if (ids.isEmpty) {
      return Future<int>.value(0);
    }
    return (_db.delete(_db.outbox)..where((o) => o.changeId.isIn(ids))).go();
  }
}
