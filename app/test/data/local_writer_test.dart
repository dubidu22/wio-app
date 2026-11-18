import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';

import '../support/test_data.dart';

void main() {
  late WioDatabase db;
  late List<String> issuedIds;
  late LocalWriter writer;

  final now = DateTime.utc(2026, 11, 19, 9, 30);

  LocalWriter writerWith(List<String> ids) {
    var next = 0;
    return LocalWriter(
      db,
      clock: () => now,
      changeIds: () {
        final id = ids[next % ids.length];
        next++;
        issuedIds.add(id);
        return id;
      },
    );
  }

  setUp(() {
    db = memoryDatabase();
    issuedIds = <String>[];
    writer = LocalWriter(db, clock: () => now);
  });
  tearDown(() => db.close());

  test('write stores the record and queues only the given fields', () async {
    await seedTestData(db);
    final changeId = await writer.write(
      entity: 'rooms',
      id: TestIds.keller,
      fields: <String, Object?>{'name': 'Kellerraum', 'height_cm': 230},
    );

    final room = await (db.select(
      db.rooms,
    )..where((r) => r.id.equals(TestIds.keller))).getSingle();
    expect(room.name, 'Kellerraum');
    expect(room.heightCm, 230);
    expect(room.siteId, TestIds.alteWohnung);

    final pending = await writer.pending();
    expect(pending, hasLength(1));
    final change = pending.single;
    expect(change.changeId, changeId);
    expect(change.entity, 'rooms');
    expect(change.entityId, TestIds.keller);
    expect(change.fields, <String, Object?>{
      'name': 'Kellerraum',
      'height_cm': 230,
    });
    expect(change.baseRevision, 1, reason: 'revision before the write');
    expect(change.deviceTime, '2026-11-19T09:30:00.000Z');
  });

  test('a new record has no base revision', () async {
    await writer.write(
      entity: 'customers',
      id: TestIds.familieBeispiel,
      fields: <String, Object?>{
        'workspace_id': TestIds.workspace,
        'name': 'Familie Beispiel',
      },
    );
    final change = (await writer.pending()).single;
    expect(change.baseRevision, isNull);
    final customer = await db.select(db.customers).getSingle();
    expect(customer.revision, isNull, reason: 'the server stamps revisions');
  });

  test('change ids are UUID v7 by default', () async {
    await writer.write(
      entity: 'customers',
      id: TestIds.familieBeispiel,
      fields: <String, Object?>{'workspace_id': TestIds.workspace},
    );
    expect(
      (await writer.pending()).single.changeId,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
  });

  test('a failing outbox append leaves no record behind', () async {
    writer = writerWith(<String>['same-change-id']);
    await writer.write(
      entity: 'customers',
      id: TestIds.familieBeispiel,
      fields: <String, Object?>{'workspace_id': TestIds.workspace},
    );

    // The second change reuses the change id, so the outbox insert fails
    // after the record was written; the transaction must undo both.
    await expectLater(
      writer.write(
        entity: 'customers',
        id: TestIds.frauMuster,
        fields: <String, Object?>{'workspace_id': TestIds.workspace},
      ),
      throwsA(anything),
    );

    final customers = await db.select(db.customers).get();
    expect(customers.map((c) => c.id), <String>[TestIds.familieBeispiel]);
    expect(await writer.pending(), hasLength(1));
  });

  test('pending pages hold at most 200 changes in the order made', () async {
    for (var i = 0; i < 205; i++) {
      await writer.write(
        entity: 'customers',
        id: TestIds.familieBeispiel,
        fields: <String, Object?>{
          'workspace_id': TestIds.workspace,
          'name': 'Name $i',
        },
      );
    }
    final page = await writer.pending();
    expect(page, hasLength(200));
    expect(page.first.fields['name'], 'Name 0');
    expect(page.last.fields['name'], 'Name 199');
    expect(await writer.pending(limit: 3), hasLength(3));
    expect(() => writer.pending(limit: 201), throwsRangeError);
    expect(() => writer.pending(limit: 0), throwsRangeError);
  });

  test('edits of one record are not coalesced', () async {
    for (final name in <String>['A', 'B']) {
      await writer.write(
        entity: 'customers',
        id: TestIds.familieBeispiel,
        fields: <String, Object?>{
          'workspace_id': TestIds.workspace,
          'name': name,
        },
      );
    }
    final pending = await writer.pending();
    expect(pending.map((c) => c.fields['name']), <String>['A', 'B']);
  });

  test('confirm removes exactly the confirmed changes', () async {
    writer = writerWith(<String>['c-1', 'c-2', 'c-3']);
    for (var i = 0; i < 3; i++) {
      await writer.write(
        entity: 'customers',
        id: TestIds.familieBeispiel,
        fields: <String, Object?>{'workspace_id': TestIds.workspace},
      );
    }
    expect(await writer.confirm(<String>['c-1', 'c-3', 'unknown']), 2);
    expect((await writer.pending()).map((c) => c.changeId), <String>['c-2']);
    expect(await writer.confirm(<String>[]), 0);
  });

  test('rejects unknown tables, server fields and unknown columns', () {
    Future<String> write(String entity, Map<String, Object?> fields) =>
        writer.write(entity: entity, id: TestIds.keller, fields: fields);

    expect(
      () => write('outbox', <String, Object?>{'entity': 'x'}),
      throwsArgumentError,
    );
    expect(() => write('rooms', <String, Object?>{}), throwsArgumentError);
    for (final field in LocalWriter.serverFields) {
      expect(
        () => write('rooms', <String, Object?>{field: 'x'}),
        throwsArgumentError,
        reason: field,
      );
    }
    expect(
      () => write('rooms', <String, Object?>{'colour': 'red'}),
      throwsArgumentError,
    );
    expect(
      () => write('rooms', <String, Object?>{
        'name': <String>['a'],
      }),
      throwsArgumentError,
    );
  });
}
