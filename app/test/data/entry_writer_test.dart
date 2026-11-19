// The entry writer (plan 101 tests T3 to T10, T16; D-434 to D-446).
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_queries.dart';
import 'package:wio_app/data/entry_writer.dart';
import 'package:wio_app/data/local_writer.dart';

import '../support/test_data.dart';

const String ws = TestIds.workspace;
const Place inKueche = Place.room(
  siteId: TestIds.alteWohnung,
  roomId: TestIds.kueche,
);
const Place inKeller = Place.room(
  siteId: TestIds.alteWohnung,
  roomId: TestIds.keller,
);

void main() {
  late WioDatabase db;
  late EntryWriter writer;
  var clock = DateTime.utc(2026, 11, 19, 9, 30);

  setUp(() async {
    db = memoryDatabase();
    await seedTestData(db);
    var next = 0;
    clock = DateTime.utc(2026, 11, 19, 9, 30);
    writer = EntryWriter(
      db,
      LocalWriter(db, clock: () => clock),
      ids: () =>
          '01970000-0000-7000-8000-${(0x900 + next++).toRadixString(16).padLeft(12, '0')}',
    );
  });
  tearDown(() => db.close());

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();
  Map<String, Object?> fieldsOf(OutboxData row) =>
      jsonDecode(row.fields) as Map<String, Object?>;
  Future<Entry> entryRow(String id) =>
      (db.select(db.entries)..where((e) => e.id.equals(id))).getSingle();
  Future<String> entry({String? code, Place place = Place.none}) =>
      writer.createEntry(
        workspaceId: ws,
        customerId: TestIds.familieBeispiel,
        code: code,
        place: place,
      );

  group('createEntry (T3, T4)', () {
    test('without a place: one upsert, no place fields', () async {
      final id = await writer.createEntry(
        workspaceId: ws,
        customerId: TestIds.familieBeispiel,
        code: 'WIO-0001',
        title: 'Bücherkiste',
      );
      final rows = await outbox();
      expect(rows, hasLength(1));
      expect(rows.single.op, 'upsert');
      expect(fieldsOf(rows.single), <String, Object?>{
        'workspace_id': ws,
        'customer_id': TestIds.familieBeispiel,
        'code': 'WIO-0001',
        'title': 'Bücherkiste',
      });
      final row = await entryRow(id);
      expect(row.code, 'WIO-0001');
      expect(Place.of(row), Place.none);
      expect(await placeHistory(db, id), isEmpty);
    });

    test('an empty title is no title', () async {
      await writer.createEntry(workspaceId: ws, title: '  ');
      expect(fieldsOf((await outbox()).single), <String, Object?>{
        'workspace_id': ws,
      });
    });

    test('with a place: upsert, then move_entry with seven fields '
        '(D-438)', () async {
      final id = await entry(code: 'WIO-0002', place: inKueche);
      final rows = await outbox();
      expect(rows.map((r) => r.op), <String>['upsert', 'move_entry']);
      expect(rows.map((r) => r.entityId), <String>[id, id]);
      expect(fieldsOf(rows.first).keys, isNot(contains('site_id')));
      expect(fieldsOf(rows.last), inKueche.toFields());
      expect(fieldsOf(rows.last), hasLength(7));
      expect(Place.of(await entryRow(id)), inKueche);

      final history = await placeHistory(db, id);
      expect(history, hasLength(1));
      expect(history.single.from, Place.none);
      expect(history.single.to, inKueche);
      expect(history.single.pending, isTrue);
      expect(history.single.movedAt, '2026-11-19T09:30:00.000Z');
    });

    test('a bad place writes nothing, not even the entry', () async {
      await expectLater(
        entry(
          place: const Place.room(
            siteId: TestIds.fremderOrt,
            roomId: TestIds.kueche,
          ),
        ),
        throwsArgumentError,
      );
      expect(await outbox(), isEmpty);
      expect(await db.select(db.entries).get(), isEmpty);
    });

    test('an unknown or deleted customer is refused', () async {
      await expectLater(
        writer.createEntry(workspaceId: ws, customerId: TestIds.geloescht),
        throwsArgumentError,
      );
      expect(await outbox(), isEmpty);
    });
  });

  group('move (T5)', () {
    test('one move_entry, the local place at once, pending steps', () async {
      final id = await entry(place: inKueche);
      clock = clock.add(const Duration(minutes: 5));
      await writer.move(id, inKeller);

      final rows = await outbox();
      expect(rows.map((r) => r.op), <String>[
        'upsert',
        'move_entry',
        'move_entry',
      ]);
      expect(fieldsOf(rows.last), inKeller.toFields());
      expect(Place.of(await entryRow(id)), inKeller);

      final history = await placeHistory(db, id);
      expect(history.map((s) => (s.from, s.to)), <(Place, Place)>[
        (inKueche, inKeller),
        (Place.none, inKueche),
      ]);
      expect(history.first.movedAt, '2026-11-19T09:35:00.000Z');
    });

    test('to the same place queues nothing', () async {
      final id = await entry(place: inKueche);
      await writer.move(id, inKueche);
      expect(await outbox(), hasLength(2));
    });

    test('back to "not placed" carries seven nulls', () async {
      final id = await entry(place: inKueche);
      await writer.move(id, Place.none);
      final last = (await outbox()).last;
      expect(fieldsOf(last), Place.none.toFields());
      expect(fieldsOf(last).values, everyElement(isNull));
      expect(Place.of(await entryRow(id)), Place.none);
    });

    final refusals = <String, Place>{
      'site without room': const Place(siteId: TestIds.alteWohnung),
      'room of another site': const Place.room(
        siteId: TestIds.neueWohnung,
        roomId: TestIds.kueche,
      ),
      'site of another customer': const Place.room(
        siteId: TestIds.fremderOrt,
        roomId: TestIds.kueche,
      ),
      'deleted room': const Place.room(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.alterRaum,
      ),
      'fixture without room': const Place(fixtureId: 'x'),
      'slot without fixture': const Place(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.kueche,
        level: 1,
      ),
      'unknown fixture': const Place(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.kueche,
        fixtureId: '01970000-0000-7000-8000-000000000fff',
      ),
      'level 0': const Place(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.kueche,
        fixtureId: '01970000-0000-7000-8000-000000000fff',
        level: 0,
      ),
      'half a floor point': const Place(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.kueche,
        floorXCm: 10,
      ),
      'floor point with fixture': const Place(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.kueche,
        fixtureId: '01970000-0000-7000-8000-000000000fff',
        floorXCm: 10,
        floorYCm: 20,
      ),
    };
    for (final MapEntry(:key, :value) in refusals.entries) {
      test('refuses $key', () async {
        final id = await entry();
        await expectLater(writer.move(id, value), throwsArgumentError);
        expect(await outbox(), hasLength(1));
        expect(Place.of(await entryRow(id)), Place.none);
      });
    }

    test('a fixture in that room (server copy) is accepted', () async {
      const fixture = '01970000-0000-7000-8000-000000000ff1';
      await db
          .into(db.serverRecords)
          .insert(
            ServerRecordsCompanion.insert(
              entity: 'fixtures',
              id: fixture,
              revision: 2,
              fields: jsonEncode(<String, Object?>{
                'id': fixture,
                'room_id': TestIds.kueche,
              }),
            ),
          );
      final id = await entry();
      const place = Place(
        siteId: TestIds.alteWohnung,
        roomId: TestIds.kueche,
        fixtureId: fixture,
        level: 2,
        compartment: 1,
      );
      await writer.move(id, place);
      expect(Place.of(await entryRow(id)), place);
    });

    test('a deleted entry is refused', () async {
      final id = await entry();
      await writer.deleteEntry(id);
      await expectLater(writer.move(id, inKueche), throwsArgumentError);
    });

    test('LocalWriter refuses place fields on an upsert', () async {
      final id = await entry();
      expect(
        () => LocalWriter(db).write(
          entity: 'entries',
          id: id,
          fields: <String, Object?>{'room_id': TestIds.kueche},
        ),
        throwsArgumentError,
      );
      expect(
        () => LocalWriter(db).moveEntry(
          id: id,
          place: <String, Object?>{'room_id': TestIds.kueche},
        ),
        throwsArgumentError,
      );
    });
  });

  test('setTarget: one upsert with seven target fields, no history '
      '(T6, D-439)', () async {
    final id = await entry();
    await writer.setTarget(id, inKeller);
    final last = (await outbox()).last;
    expect(last.op, 'upsert');
    expect(fieldsOf(last), inKeller.toFields('target_'));
    final row = await entryRow(id);
    expect(Place.targetOf(row), inKeller);
    expect(Place.of(row), Place.none);
    expect(await placeHistory(db, id), isEmpty);

    await writer.setTarget(id, inKeller);
    expect(await outbox(), hasLength(2));
    await expectLater(
      writer.setTarget(
        id,
        const Place.room(siteId: TestIds.fremderOrt, roomId: TestIds.keller),
      ),
      throwsArgumentError,
    );
  });

  group('codes (T7)', () {
    test('at most 255 UTF-8 bytes', () async {
      await entry(code: 'a' * 255);
      await expectLater(entry(code: 'ä' * 128), throwsArgumentError);
      await expectLater(entry(code: ''), throwsArgumentError);
    });

    test('a live twin is a DuplicateCode with its id (D-428)', () async {
      final first = await entry(code: 'WIO-0001');
      await expectLater(
        entry(code: 'WIO-0001'),
        throwsA(isA<DuplicateCode>().having((d) => d.existingId, 'id', first)),
      );
      expect((await writer.entryWithCode('WIO-0001'))!.id, first);
      final second = await entry(code: 'WIO-0002');
      await expectLater(
        writer.editEntry(second, code: const Value<String?>('WIO-0001')),
        throwsA(isA<DuplicateCode>()),
      );
      expect(await outbox(), hasLength(2));
    });

    test('codes compare byte for byte (D-51)', () async {
      await entry(code: 'Küche');
      await entry(code: 'küche');
      await entry(code: 'Küche ');
      expect(await db.select(db.entries).get(), hasLength(3));
    });

    test('a deleted twin frees the code; restoring it is refused', () async {
      final first = await entry(code: 'WIO-0001');
      await writer.deleteEntry(first);
      expect(await writer.entryWithCode('WIO-0001'), isNull);
      await entry(code: 'WIO-0001');
      await expectLater(
        writer.restoreEntry(first),
        throwsA(isA<DuplicateCode>()),
      );
    });

    test('edit, delete and restore queue their changes', () async {
      final id = await entry(code: 'WIO-0001');
      await writer.editEntry(
        id,
        title: const Value<String?>('Winterkleidung'),
        code: const Value<String?>(null),
      );
      await writer.deleteEntry(id);
      await writer.restoreEntry(id);
      final rows = await outbox();
      expect(rows.map((r) => r.op), <String>[
        'upsert',
        'upsert',
        'delete',
        'restore',
      ]);
      expect(fieldsOf(rows[1]), <String, Object?>{
        'code': null,
        'title': 'Winterkleidung',
      });
      final row = await entryRow(id);
      expect(row.code, isNull);
      expect(row.deletedAt, isNull);
    });
  });

  group('vocabulary (T8, D-441)', () {
    test('a label is found by its name key', () async {
      final kueche = await writer.labelNamed(workspaceId: ws, name: 'Küche');
      expect(
        await writer.labelNamed(workspaceId: ws, name: '  küche '),
        kueche,
      );
      expect(await writer.labelNamed(workspaceId: ws, name: 'KÜCHE'), kueche);
      expect(
        await writer.labelNamed(workspaceId: ws, name: 'Kuche'),
        isNot(kueche),
      );
      expect(
        await writer.labelNamed(workspaceId: ws, name: 'Winter  Kleidung'),
        await writer.labelNamed(workspaceId: ws, name: 'winter kleidung'),
      );
      expect(localNameKey(' Winter \t Kleidung '), 'winter kleidung');
    });

    test('a deleted label is not reused', () async {
      final first = await writer.labelNamed(workspaceId: ws, name: 'Küche');
      await writer.deleteLabel(first);
      expect(
        await writer.labelNamed(workspaceId: ws, name: 'Küche'),
        isNot(first),
      );
    });

    test('names are 1 to 100 chars; units at most 32', () async {
      await expectLater(
        writer.labelNamed(workspaceId: ws, name: ' '),
        throwsArgumentError,
      );
      await expectLater(
        writer.labelNamed(workspaceId: ws, name: 'x' * 101),
        throwsArgumentError,
      );
      await expectLater(
        writer.keyNamed(workspaceId: ws, name: 'Gewicht', unit: 'k' * 33),
        throwsArgumentError,
      );
      expect(await outbox(), isEmpty);
    });

    test('a key keeps its unit', () async {
      final id = await writer.keyNamed(
        workspaceId: ws,
        name: 'Gewicht',
        unit: 'kg',
      );
      expect(
        await writer.keyNamed(workspaceId: ws, name: 'gewicht', unit: 'g'),
        id,
      );
      expect(fieldsOf((await outbox()).single), <String, Object?>{
        'workspace_id': ws,
        'name': 'Gewicht',
        'unit': 'kg',
      });
    });
  });

  group('labels on an entry (T9, D-442)', () {
    test('add, add again, remove, add restores the same link', () async {
      final id = await entry();
      final subject = (type: 'entry', id: id);
      final label = await writer.labelNamed(workspaceId: ws, name: 'Küche');
      final link = await writer.addLabel(subject, label);
      expect(await writer.addLabel(subject, label), link);
      expect(fieldsOf((await outbox()).last), <String, Object?>{
        'workspace_id': ws,
        'customer_id': TestIds.familieBeispiel,
        'entity_type': 'entry',
        'entity_id': id,
        'label_id': label,
      });
      expect((await watchLabelsOf(db, subject).first).single.linkId, link);

      await writer.removeLabel(link);
      expect(await watchLabelsOf(db, subject).first, isEmpty);
      expect(await writer.addLabel(subject, label), link);
      expect((await outbox()).map((r) => r.op).skip(2), <String>[
        'upsert',
        'delete',
        'restore',
      ]);
      expect(await db.select(db.entityLabels).get(), hasLength(1));
    });

    test('a deleted label or subject is refused', () async {
      final id = await entry();
      final label = await writer.labelNamed(workspaceId: ws, name: 'Küche');
      await writer.deleteLabel(label);
      await expectLater(
        writer.addLabel((type: 'entry', id: id), label),
        throwsArgumentError,
      );
      await expectLater(
        writer.addLabel((type: 'job', id: id), label),
        throwsArgumentError,
      );
    });
  });

  group('properties on an entry (T10, D-442)', () {
    test('text and number, one value per key', () async {
      final id = await entry();
      final subject = (type: 'entry', id: id);
      final weight = await writer.keyNamed(
        workspaceId: ws,
        name: 'Gewicht',
        unit: 'kg',
      );
      final link = await writer.setProperty(subject, weight, number: '12.5');
      expect(fieldsOf((await outbox()).last), <String, Object?>{
        'workspace_id': ws,
        'customer_id': TestIds.familieBeispiel,
        'entity_type': 'entry',
        'entity_id': id,
        'key_id': weight,
        'value_text': null,
        'value_number': '12.5',
      });
      expect(await writer.setProperty(subject, weight, text: 'schwer'), link);
      expect(fieldsOf((await outbox()).last), <String, Object?>{
        'value_text': 'schwer',
        'value_number': null,
      });
      final values = await watchPropertiesOf(db, subject).first;
      expect(values.single.value.valueText, 'schwer');
      expect(values.single.key.unit, 'kg');

      final before = (await outbox()).length;
      await writer.setProperty(subject, weight, text: 'schwer');
      expect(await outbox(), hasLength(before));
    });

    test('remove, then set again restores and changes the same row', () async {
      final id = await entry();
      final subject = (type: 'entry', id: id);
      final key = await writer.keyNamed(workspaceId: ws, name: 'Farbe');
      final link = await writer.setProperty(subject, key, text: 'rot');
      await writer.removeProperty(link);
      expect(await watchPropertiesOf(db, subject).first, isEmpty);
      expect(await writer.setProperty(subject, key, text: 'blau'), link);
      expect((await outbox()).map((r) => r.op).skip(2), <String>[
        'upsert',
        'delete',
        'restore',
        'upsert',
      ]);
      expect(await db.select(db.entityProperties).get(), hasLength(1));
    });

    test('bad values are refused', () async {
      final id = await entry();
      final subject = (type: 'entry', id: id);
      final key = await writer.keyNamed(workspaceId: ws, name: 'Gewicht');
      for (final number in <String>['1,5', '1e3', '.5', '1.1234567', '']) {
        await expectLater(
          writer.setProperty(subject, key, number: number),
          throwsArgumentError,
          reason: number,
        );
      }
      await expectLater(writer.setProperty(subject, key), throwsArgumentError);
      await expectLater(
        writer.setProperty(subject, key, text: 'a', number: '1'),
        throwsArgumentError,
      );
      await expectLater(
        writer.setProperty(subject, key, text: ' '),
        throwsArgumentError,
      );
      expect(decimalPattern.hasMatch('-12345678901234.123456'), isTrue);
    });
  });

  test('place_history cannot be written on the device (T16)', () async {
    expect(
      () => LocalWriter(db).write(
        entity: 'place_history',
        id: '01970000-0000-7000-8000-000000000eee',
        fields: <String, Object?>{'workspace_id': ws},
      ),
      throwsArgumentError,
    );
  });

  test('entries of a customer and in a room', () async {
    final placed = await entry(place: inKueche);
    final loose = await entry();
    expect(
      (await watchEntriesOfCustomer(
        db,
        TestIds.familieBeispiel,
      ).first).map((e) => e.id),
      <String>[placed, loose],
    );
    expect(
      (await watchEntriesInRoom(db, TestIds.kueche).first).map((e) => e.id),
      <String>[placed],
    );
    await writer.deleteEntry(placed);
    expect(await watchEntriesInRoom(db, TestIds.kueche).first, isEmpty);
    expect(await watchEntry(db, placed).first, isNull);
  });
}
