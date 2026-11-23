import 'package:drift/drift.dart';

import 'database.dart';

/// Watches [read] again whenever one of [tables] changes (the "watch the
/// tables, read with several queries" pattern).
///
/// Drift shares one stream between all watchers whose SQL text and variables
/// are equal and keeps the tables of the first one. Several watchers that all
/// said `SELECT 1` therefore listened to the tables of whichever opened first
/// and missed their own changes (issue 115). The SQL text here carries
/// [name], so every watcher has its own stream: [name] must be unique per
/// query, and a name that is used again with other tables throws in debug
/// builds and tests.
Stream<T> watchReads<T>(
  WioDatabase db, {
  required String name,
  required Set<TableInfo<Table, Object?>> tables,
  required Future<T> Function() read,
}) {
  assert(_sameTables(name, tables), 'watchReads name "$name" is not unique');
  return db
      .customSelect("SELECT '$name'", readsFrom: tables)
      .watch()
      .asyncMap((_) => read());
}

final Map<String, Set<String>> _registered = <String, Set<String>>{};

bool _sameTables(String name, Set<TableInfo<Table, Object?>> tables) {
  final names = tables.map((t) => t.actualTableName).toSet();
  final known = _registered.putIfAbsent(name, () => names);
  return known.length == names.length && known.containsAll(names);
}
