import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:wio_app/data/database.dart';

/// The invented demo workspace of `tools/demo/demo-workspace.json` (D-78),
/// loaded into the app's local tables for tests (D-82).
///
/// The file uses the server's snake_case column names, which are also the
/// SQL names drift gives the local columns, so rows map one to one. Tables
/// the device does not hold are skipped; a column the local table lacks is an
/// error, so a schema change on either side shows up in a failing test.
class DemoWorkspace {
  DemoWorkspace(this.tables);

  /// Reads the file from the repository, relative to the app package root
  /// (where `flutter test` runs).
  factory DemoWorkspace.fromFile([String path = defaultPath]) {
    final file = File(path);
    if (!file.existsSync()) {
      throw StateError(
        'Demo workspace not found at ${file.absolute.path}; '
        'run the tests from app/.',
      );
    }
    return DemoWorkspace.fromJson(file.readAsStringSync());
  }

  /// Parses the file's content (`{"format": 1, "tables": [...]}`).
  factory DemoWorkspace.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, Object?>;
    if (json['format'] != 1) {
      throw FormatException('Unknown demo workspace format ${json['format']}.');
    }
    final tables = <String, List<Map<String, Object?>>>{};
    for (final entry in json['tables']! as List<Object?>) {
      final table = entry! as Map<String, Object?>;
      tables[table['table']! as String] = <Map<String, Object?>>[
        for (final row in table['rows']! as List<Object?>)
          row! as Map<String, Object?>,
      ];
    }
    return DemoWorkspace(tables);
  }

  static const String defaultPath = '../tools/demo/demo-workspace.json';

  /// Local tables that never come from the server: they are not in the file.
  static const Set<String> localOnlyTables = <String>{
    'outbox',
    'sync_state',
    'server_records',
    'rejected_changes',
    'uploads',
  };

  /// Synced local tables the file does not hold yet. Empty since the demo
  /// pictures came with their image files (D-262).
  static const Set<String> notInFileYet = <String>{};

  /// Local columns the server does not have, per table. Empty today; a
  /// device-only column added by a local migration is listed here.
  static const Map<String, Set<String>> deviceOnlyColumns =
      <String, Set<String>>{};

  /// Rows per table, in the file's insert order.
  final Map<String, List<Map<String, Object?>>> tables;

  /// Highest revision per workspace over every row of the file, also of
  /// tables the device does not hold: the server's counter (D-52).
  Map<String, int> get lastRevisions {
    final result = <String, int>{};
    tables.forEach((table, rows) {
      for (final row in rows) {
        final workspace =
            (table == 'workspaces' ? row['id'] : row['workspace_id'])!
                as String;
        final revision = row['revision']! as int;
        if (revision > (result[workspace] ?? 0)) {
          result[workspace] = revision;
        }
      }
    });
    return result;
  }

  /// Inserts the rows of every local table into [db], as if pulled from the
  /// server. With [withSyncState], `sync_state` records [lastRevisions].
  ///
  /// Throws [StateError] naming the table and column when a row has a
  /// column the local table does not know.
  Future<void> load(WioDatabase db, {bool withSyncState = true}) async {
    final local = <String, TableInfo<Table, Object?>>{
      for (final table in db.allTables) table.actualTableName: table,
    };
    final inserts = <(TableInfo<Table, Object?>, Map<String, Object?>)>[];
    tables.forEach((name, rows) {
      final table = local[name];
      if (table == null) {
        return;
      }
      final columns = <String>{for (final c in table.$columns) c.name};
      for (final row in rows) {
        for (final column in row.keys) {
          if (!columns.contains(column)) {
            throw StateError(
              'Demo workspace column $name.$column is not in the local table.',
            );
          }
        }
        inserts.add((table, row));
      }
    });
    await db.batch((b) {
      for (final (table, row) in inserts) {
        b.insert(
          table,
          RawValuesInsertable<Never>(<String, Expression<Object>>{
            for (final MapEntry(:key, :value) in row.entries)
              key: Variable<Object>(_sqlValue(value)),
          }),
        );
      }
      if (withSyncState) {
        b.insertAll(db.syncState, <SyncStateCompanion>[
          for (final MapEntry(:key, :value) in lastRevisions.entries)
            SyncStateCompanion.insert(workspaceId: key, lastRevision: value),
        ]);
      }
    });
  }

  /// Times and dates stay ISO text; nested JSON is stored as JSON text, as
  /// the local tables keep it (D-64).
  static Object? _sqlValue(Object? value) =>
      value is Map || value is List ? jsonEncode(value) : value;
}
