// watchReads: every watcher has its own drift stream (issue 115).
import 'dart:async';

import 'package:drift/drift.dart' show Table, TableInfo, Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_queries.dart';
import 'package:wio_app/data/queries.dart';
import 'package:wio_app/data/watch_reads.dart';
import 'package:wio_app/planning/place_choices.dart';

import '../support/test_data.dart';

void main() {
  late WioDatabase db;
  setUp(() async {
    db = memoryDatabase();
    await seedWithEntries(db);
  });
  tearDown(() => db.close());

  test('queries that open before it do not take over its tables', () async {
    // The history and the customer view used to say "SELECT 1" as well:
    // drift gave all three one stream, with the tables of the first.
    final history = watchPlaceHistory(db, TestIds.kiste).listen((_) {});
    final customer = watchCustomer(db, TestIds.familieBeispiel).listen((_) {});
    addTearDown(history.cancel);
    addTearDown(customer.cancel);
    final names = StreamIterator<PlaceChoices?>(
      watchPlaceChoices(db, TestIds.familieBeispiel, TestIds.kiste),
    );
    addTearDown(names.cancel);
    Future<PlaceChoices?> next() async {
      expect(await names.moveNext(), isTrue);
      return names.current;
    }

    expect((await next())?.entry.title, 'Kiste Geschirr');
    await (db.update(db.entries)..where((e) => e.id.equals(TestIds.kiste)))
        .write(const EntriesCompanion(title: Value('Neu')));
    expect((await next())?.entry.title, 'Neu');
  });

  test('a query name is not used for other tables', () {
    final tables = <TableInfo<Table, Object?>>{db.rooms};
    Stream<int> watch(Set<TableInfo<Table, Object?>> t) =>
        watchReads<int>(db, name: 'clash', tables: t, read: () async => 1);
    watch(tables).listen((_) {}).cancel();
    expect(
      () => watch(<TableInfo<Table, Object?>>{db.sites}),
      throwsA(anything),
    );
  });
}
