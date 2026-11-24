import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/queries.dart';

import '../support/test_data.dart';

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
  });
  tearDown(() => db.close());

  test('calendarDate pads to YYYY-MM-DD', () {
    expect(calendarDate(DateTime(2026, 3, 7, 23, 59)), '2026-03-07');
  });

  test('job list splits today and upcoming, without past or deleted', () async {
    final list = await watchJobList(db, '2026-11-19').first;
    expect(list.today.map((j) => j.customerName), <String>['Familie Beispiel']);
    expect(list.upcoming.map((j) => j.customerName), <String>[
      'Frau Muster',
      'Herr Probe',
    ]);
    expect(list.upcoming.map((j) => j.date), <String>[
      '2026-11-20',
      '2026-11-23',
    ]);
    expect(list.today.single.customerId, TestIds.familieBeispiel);
  });

  test('job list sorts one day by customer name', () async {
    await LocalWriter(db).write(
      entity: 'jobs',
      id: '01970000-0000-7000-8000-0000000000e1',
      fields: <String, Object?>{
        'workspace_id': TestIds.workspace,
        'customer_id': TestIds.frauMuster,
        'date': '2026-11-23',
      },
    );
    final list = await watchJobList(db, '2026-11-19').first;
    expect(list.upcoming.map((j) => j.customerName), <String>[
      'Frau Muster',
      'Frau Muster',
      'Herr Probe',
    ]);
  });

  test('job list updates when a job is written', () async {
    final counts = <int>[];
    final subscription = watchJobList(
      db,
      '2026-11-19',
    ).listen((list) => counts.add(list.today.length));
    addTearDown(subscription.cancel);
    Future<void> waitFor(bool Function() done) async {
      for (var i = 0; i < 100 && !done(); i++) {
        await Future<void>.delayed(Duration.zero);
      }
    }

    await waitFor(() => counts.isNotEmpty);
    expect(counts, <int>[1]);
    await LocalWriter(db).write(
      entity: 'jobs',
      id: '01970000-0000-7000-8000-0000000000e2',
      fields: <String, Object?>{
        'workspace_id': TestIds.workspace,
        'customer_id': TestIds.herrProbe,
        'date': '2026-11-19',
      },
    );
    await waitFor(() => counts.last == 2);
    expect(counts.last, 2);
  });

  test('customer view holds only its own live sites and rooms', () async {
    final view = await watchCustomer(db, TestIds.familieBeispiel).first;
    expect(view, isNotNull);
    expect(view!.name, 'Familie Beispiel');
    expect(view.sites.map((s) => s.name), <String>[
      'Alte Wohnung',
      'Neue Wohnung',
    ]);
    expect(view.sites.first.rooms.map((r) => r.name), <String>[
      'Keller',
      'Küche',
    ]);
    expect(view.sites.last.rooms, isEmpty);
  });

  test('customer view counts the live pictures of each room', () async {
    final view = await watchCustomer(db, TestIds.familieBeispiel).first;
    expect(
      <String?, int>{
        for (final room in view!.sites.first.rooms)
          room.name: room.pictureCount,
      },
      <String?, int>{'Keller': 0, 'Küche': 4},
      reason: 'the tombstoned picture is not counted',
    );
  });

  test('customer view updates when a picture is added', () async {
    final views = watchCustomer(db, TestIds.familieBeispiel);
    final counts = views
        .map((v) => v!.sites.first.rooms.first.pictureCount)
        .take(2)
        .toList();
    await Future<void>.delayed(Duration.zero);
    await LocalWriter(db).write(
      entity: 'pictures',
      id: '01970000-0000-7000-8000-0000000000f9',
      fields: <String, Object?>{
        'workspace_id': TestIds.workspace,
        'file_sha256': 'd' * 64,
        'file_bytes': 1,
        'file_mime': 'image/jpeg',
        'width_px': 1,
        'height_px': 1,
        'room_id': TestIds.keller,
      },
    );
    expect(await counts, <int>[0, 1]);
  });

  test('room view holds the room and its site', () async {
    final room = await watchRoom(
      db,
      TestIds.familieBeispiel,
      TestIds.kueche,
    ).first;
    expect(room!.name, 'Küche');
    expect(room.siteName, 'Alte Wohnung');
  });

  test(
    'room view is null for deleted, unknown and other customers\' rooms',
    () async {
      expect(
        await watchRoom(db, TestIds.familieBeispiel, TestIds.alterRaum).first,
        isNull,
      );
      expect(
        await watchRoom(db, TestIds.familieBeispiel, 'no-such-id').first,
        isNull,
      );
      expect(
        await watchRoom(db, TestIds.frauMuster, TestIds.kueche).first,
        isNull,
      );
    },
  );

  test('picture view checks customer, room and tombstone', () async {
    Future<Picture?> picture(String customer, String id, {String? room}) =>
        watchPicture(db, customer, id, roomId: room).first;
    expect(
      (await picture(TestIds.familieBeispiel, TestIds.fotoVorher))!.id,
      TestIds.fotoVorher,
    );
    expect(
      await picture(
        TestIds.familieBeispiel,
        TestIds.fotoVorher,
        room: TestIds.kueche,
      ),
      isNotNull,
    );
    expect(
      await picture(
        TestIds.familieBeispiel,
        TestIds.fotoVorher,
        room: TestIds.keller,
      ),
      isNull,
      reason: 'not in that room',
    );
    expect(
      await picture(TestIds.frauMuster, TestIds.fotoVorher),
      isNull,
      reason: 'another customer',
    );
    expect(
      await picture(TestIds.familieBeispiel, TestIds.fotoGeloescht),
      isNull,
      reason: 'tombstoned',
    );
  });

  test('picture view through a tombstoned room or site is null (N2)', () async {
    Future<Picture?> inKueche() => watchPicture(
      db,
      TestIds.familieBeispiel,
      TestIds.fotoVorher,
      roomId: TestIds.kueche,
    ).first;
    expect(await inKueche(), isNotNull);
    await LocalWriter(db).delete(entity: 'sites', id: TestIds.alteWohnung);
    expect(await inKueche(), isNull, reason: 'site tombstoned');
    await LocalWriter(db).restore(entity: 'sites', id: TestIds.alteWohnung);
    await LocalWriter(db).delete(entity: 'rooms', id: TestIds.kueche);
    expect(await inKueche(), isNull, reason: 'room tombstoned');
    expect(
      await watchPicture(db, TestIds.familieBeispiel, TestIds.fotoVorher).first,
      isNotNull,
      reason: 'without a room only the picture itself counts',
    );
  });

  test('customer view is null for unknown and deleted customers', () async {
    expect(await watchCustomer(db, 'no-such-id').first, isNull);
    expect(await watchCustomer(db, TestIds.geloescht).first, isNull);
  });

  group('other customers (plan 120, D-517, D-518)', () {
    Future<void> writeCustomer(String id, String? name) => LocalWriter(db)
        .write(
          entity: 'customers',
          id: id,
          fields: <String, Object?>{
            'workspace_id': TestIds.workspace,
            'name': ?name,
          },
        );

    test(
      'is empty while every live customer has a job from today on',
      () async {
        expect(await watchOtherCustomers(db, '2026-11-19').first, isEmpty);
      },
    );

    test(
      'lists customers without a job from today on, latest job first',
      () async {
        final list = await watchOtherCustomers(db, '2026-11-21').first;
        expect(list.map((c) => c.customerName), <String>[
          'Frau Muster',
          'Familie Beispiel',
        ]);
        expect(list.map((c) => c.lastJobDate), <String>[
          '2026-11-20',
          '2026-11-19',
        ]);
        expect(list.last.customerId, TestIds.familieBeispiel);
      },
    );

    test('a deleted job does not count as the last one', () async {
      // Frau Muster's deleted job on 19 Nov is ignored; her live one is 20 Nov.
      final list = await watchOtherCustomers(db, '2026-11-30').first;
      expect(list.map((c) => c.customerName), <String>[
        'Herr Probe',
        'Frau Muster',
        'Familie Beispiel',
      ]);
      expect(list.map((c) => c.lastJobDate).first, '2026-11-23');
    });

    test(
      'customers without any job come after, by name, unnamed last',
      () async {
        await writeCustomer('01970000-0000-7000-8000-0000000000e3', null);
        await writeCustomer(
          '01970000-0000-7000-8000-0000000000e2',
          'Anna Ohne',
        );
        final list = await watchOtherCustomers(db, '2026-11-21').first;
        expect(list.map((c) => c.customerName), <String?>[
          'Frau Muster',
          'Familie Beispiel',
          'Anna Ohne',
          null,
        ]);
        expect(list[2].lastJobDate, isNull);
      },
    );

    test('leaves out deleted customers and follows a new job', () async {
      final seen = <List<String>>[];
      final subscription = watchOtherCustomers(
        db,
        '2026-11-21',
      ).listen((list) => seen.add(list.map((c) => c.customerId).toList()));
      addTearDown(subscription.cancel);
      Future<void> waitFor(int count) async {
        for (var i = 0; i < 100 && seen.length < count; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
      }

      await waitFor(1);
      expect(seen.last, isNot(contains(TestIds.geloescht)));
      await LocalWriter(db).write(
        entity: 'jobs',
        id: '01970000-0000-7000-8000-0000000000e4',
        fields: <String, Object?>{
          'workspace_id': TestIds.workspace,
          'customer_id': TestIds.frauMuster,
          'date': '2026-11-25',
        },
      );
      await waitFor(2);
      expect(seen.last, <String>[TestIds.familieBeispiel]);
    });
  });
}
