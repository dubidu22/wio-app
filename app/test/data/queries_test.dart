import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/queries.dart';

import '../support/test_data.dart';

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedTestData(db);
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

  test('customer view is null for unknown and deleted customers', () async {
    expect(await watchCustomer(db, 'no-such-id').first, isNull);
    expect(await watchCustomer(db, TestIds.geloescht).first, isNull);
  });
}
