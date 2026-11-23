// The entry lists of the customer and room screens (plan 105): order, first
// picture, labels, rooms, and that the watcher follows its tables.
import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/entry_queries.dart';

import '../support/test_data.dart';

EntriesCompanion _entry(
  String id, {
  String? title,
  String? roomId,
  String? siteId,
  String? createdAt,
  String? deletedAt,
  String customer = TestIds.familieBeispiel,
}) => EntriesCompanion.insert(
  id: id,
  workspaceId: TestIds.workspace,
  customerId: Value<String?>(customer),
  title: Value<String?>(title),
  roomId: Value<String?>(roomId),
  siteId: Value<String?>(siteId),
  createdAt: Value<String?>(createdAt),
  deletedAt: Value<String?>(deletedAt),
  revision: Value<int?>(createdAt == null ? null : 9),
);

String _id(int n) =>
    '01970000-0000-7000-8000-${n.toRadixString(16).padLeft(12, '0')}';

void main() {
  late WioDatabase db;
  setUp(() async {
    db = memoryDatabase();
    await seedWithVocabulary(db);
  });
  tearDown(() => db.close());

  Future<EntryList> customerList() =>
      entryList(db, customerId: TestIds.familieBeispiel);

  test(
    'rows: not placed first, then placed; other customers left out',
    () async {
      final list = await customerList();
      expect(list.rows.map((r) => r.entry.id), <String>[
        TestIds.kisteOhneOrt,
        TestIds.kiste,
      ]);
      expect(list.unplaced, 1);
      expect(list.rooms, <String, String?>{TestIds.kueche: 'Küche'});
      expect(list.isLiveRoom(TestIds.kueche), isTrue);
      expect(list.isLiveRoom(TestIds.keller), isFalse);
      expect(list.roomName(TestIds.kueche), 'Küche');
    },
  );

  test(
    'the first picture is the entry screen\'s first, labels by name',
    () async {
      final list = await customerList();
      final kiste = list.rows.last;
      // The after picture (taken later) never comes before its before picture.
      expect(kiste.picture?.id, TestIds.fotoKiste);
      expect(kiste.labels, <String>['Zerbrechlich']);
      final ohneOrt = list.rows.first;
      expect(ohneOrt.picture, isNull);
      expect(ohneOrt.labels, <String>['Glas']);
      expect(ohneOrt.unplaced, isTrue);
    },
  );

  test('an after picture taken first still comes behind its before', () async {
    // The before picture is older than the after one; swap the times.
    await (db.update(
      db.pictures,
    )..where((p) => p.id.equals(TestIds.fotoKiste))).write(
      const PicturesCompanion(takenAt: Value('2026-11-19T10:00:00.000Z')),
    );
    final list = await customerList();
    expect(list.rows.last.picture?.id, TestIds.fotoKiste);
  });

  test(
    'newest first inside each group; an unconfirmed entry is newest',
    () async {
      await db.batch((b) {
        b.insertAll(db.entries, <EntriesCompanion>[
          _entry(
            _id(0x101),
            title: 'Placed, newer',
            roomId: TestIds.kueche,
            siteId: TestIds.alteWohnung,
            createdAt: '2026-11-20T08:00:00.000Z',
          ),
          _entry(
            _id(0x102),
            title: 'Placed, pending',
            roomId: TestIds.kueche,
            siteId: TestIds.alteWohnung,
          ),
          _entry(
            _id(0x103),
            title: 'Open, newer',
            createdAt: '2026-11-21T08:00:00.000Z',
          ),
          _entry(_id(0x104), title: 'Open, pending'),
        ]);
      });
      final list = await customerList();
      expect(list.rows.map((r) => r.entry.id), <String>[
        _id(0x104), // not placed, pending: newest
        _id(0x103),
        TestIds.kisteOhneOrt,
        _id(0x102), // placed, pending
        _id(0x101),
        TestIds.kiste,
      ]);
      expect(list.unplaced, 3);
    },
  );

  test('deleted entries, pictures, labels and links are left out', () async {
    await db.batch((b) {
      b.insert(
        db.entries,
        _entry(_id(0x105), deletedAt: '2026-11-20T08:00:00.000Z'),
      );
    });
    await (db.update(
      db.pictures,
    )..where((p) => p.entryId.equals(TestIds.kiste))).write(
      const PicturesCompanion(deletedAt: Value('2026-11-20T08:00:00.000Z')),
    );
    await (db.update(
      db.labels,
    )..where((l) => l.id.equals(TestIds.labelGlas))).write(
      const LabelsCompanion(deletedAt: Value('2026-11-20T08:00:00.000Z')),
    );
    await (db.update(
      db.entityLabels,
    )..where((l) => l.labelId.equals(TestIds.labelZerbrechlich))).write(
      const EntityLabelsCompanion(deletedAt: Value('2026-11-20T08:00:00.000Z')),
    );
    final list = await customerList();
    expect(list.rows.map((r) => r.entry.id), <String>[
      TestIds.kisteOhneOrt,
      TestIds.kiste,
    ]);
    expect(list.rows.last.picture, isNull);
    expect(list.rows.last.labels, isEmpty);
    expect(list.rows.first.labels, isEmpty);
  });

  test('a deleted room is not live', () async {
    await (db.update(
      db.rooms,
    )..where((r) => r.id.equals(TestIds.kueche))).write(
      const RoomsCompanion(deletedAt: Value('2026-11-20T08:00:00.000Z')),
    );
    final list = await customerList();
    expect(list.rooms, isEmpty);
    // Still placed: the place words say "Raum gelöscht".
    expect(list.unplaced, 1);
  });

  test('a room lists only the entries placed in it', () async {
    final kueche = await entryList(db, roomId: TestIds.kueche);
    expect(kueche.rows.map((r) => r.entry.id), <String>[TestIds.kiste]);
    expect(kueche.unplaced, 0);
    final keller = await entryList(db, roomId: TestIds.keller);
    expect(keller.rows, isEmpty);
  });

  test('200 entries are read in one go, still in order', () async {
    await db.batch((b) {
      b.insertAll(db.entries, <EntriesCompanion>[
        for (var i = 0; i < 198; i++)
          _entry(
            _id(0x1000 + i),
            title: 'Kiste $i',
            roomId: i.isEven ? TestIds.kueche : null,
            siteId: i.isEven ? TestIds.alteWohnung : null,
            createdAt:
                '2026-11-22T${(i ~/ 60).toString().padLeft(2, '0')}:${(i % 60).toString().padLeft(2, '0')}:00.000Z',
          ),
      ]);
    });
    final list = await customerList();
    expect(list.rows, hasLength(200));
    expect(list.unplaced, 100);
    expect(list.rows.take(100).every((r) => r.unplaced), isTrue);
    expect(list.rows.skip(100).every((r) => !r.unplaced), isTrue);
    expect(list.rows.first.entry.title, 'Kiste 197');
  });

  group('the watcher follows its tables', () {
    late StreamIterator<EntryList> lists;
    setUp(() {
      // Other watchers that said "SELECT 1" once took over the tables of
      // whoever opened first (issue 115).
      lists = StreamIterator<EntryList>(
        watchEntryList(db, customerId: TestIds.familieBeispiel),
      );
    });
    tearDown(() => lists.cancel());

    Future<EntryList> next() async {
      expect(
        await lists.moveNext().timeout(const Duration(seconds: 5)),
        isTrue,
      );
      return lists.current;
    }

    test('a new entry, picture, label link and room name', () async {
      final history = watchEntryList(db, roomId: TestIds.keller).listen((_) {});
      addTearDown(history.cancel);
      expect((await next()).rows, hasLength(2));

      await db.into(db.entries).insert(_entry(_id(0x201), title: 'Neu'));
      expect((await next()).rows.first.entry.title, 'Neu');

      await db
          .into(db.pictures)
          .insert(
            PicturesCompanion.insert(
              id: _id(0x202),
              workspaceId: TestIds.workspace,
              customerId: const Value<String?>(TestIds.familieBeispiel),
              fileSha256: 'a' * 64,
              fileBytes: 10,
              fileMime: 'image/jpeg',
              widthPx: 10,
              heightPx: 10,
              entryId: Value<String?>(_id(0x201)),
              takenAt: const Value<String?>('2026-11-22T08:00:00.000Z'),
            ),
          );
      var list = await next();
      expect(list.rows.first.picture?.id, _id(0x202));

      await db
          .into(db.entityLabels)
          .insert(
            EntityLabelsCompanion.insert(
              id: _id(0x203),
              workspaceId: TestIds.workspace,
              customerId: const Value<String?>(TestIds.familieBeispiel),
              entityType: 'entry',
              entityId: _id(0x201),
              labelId: TestIds.labelKueche,
            ),
          );
      list = await next();
      expect(list.rows.first.labels, <String>['Küche']);

      await (db.update(db.rooms)..where((r) => r.id.equals(TestIds.kueche)))
          .write(const RoomsCompanion(name: Value('Kochnische')));
      list = await next();
      expect(list.roomName(TestIds.kueche), 'Kochnische');
    });
  });
}
