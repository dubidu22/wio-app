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

  test('customer view is null for unknown and deleted customers', () async {
    expect(await watchCustomer(db, 'no-such-id').first, isNull);
    expect(await watchCustomer(db, TestIds.geloescht).first, isNull);
  });
}
