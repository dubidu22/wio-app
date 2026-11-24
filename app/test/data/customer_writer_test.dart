// The writer that adds customers, sites, rooms and jobs (plan 106) and the
// customer's job list.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/customer_writer.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/queries.dart';

import '../support/test_data.dart';

const String ws = TestIds.workspace;

void main() {
  late WioDatabase db;
  late CustomerWriter writer;

  setUp(() async {
    db = memoryDatabase();
    await seedTestData(db);
    var next = 0;
    writer = CustomerWriter(
      db,
      LocalWriter(db, clock: () => DateTime.utc(2026, 11, 19, 9, 30)),
      ids: () =>
          '01970000-0000-7000-8000-${(0xa00 + next++).toRadixString(16).padLeft(12, '0')}',
    );
  });
  tearDown(() => db.close());

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();
  Map<String, Object?> fieldsOf(OutboxData row) =>
      jsonDecode(row.fields) as Map<String, Object?>;

  group('create', () {
    test('a customer comes with a job: two records, two changes', () async {
      final id = await writer.createCustomer(
        workspaceId: ws,
        name: '  Familie Neu ',
        date: '2026-11-19',
      );

      final customer = await (db.select(
        db.customers,
      )..where((c) => c.id.equals(id))).getSingle();
      expect(customer.name, 'Familie Neu');
      expect(customer.workspaceId, ws);
      final job = await (db.select(
        db.jobs,
      )..where((j) => j.customerId.equals(id))).getSingle();
      expect(job.date, '2026-11-19');
      final changes = await outbox();
      expect(changes.map((c) => c.entity), <String>['customers', 'jobs']);
      expect(changes.map((c) => c.op), everyElement('upsert'));
      expect(fieldsOf(changes[0]), <String, Object?>{
        'workspace_id': ws,
        'name': 'Familie Neu',
      });
      expect(fieldsOf(changes[1]), <String, Object?>{
        'workspace_id': ws,
        'customer_id': id,
        'date': '2026-11-19',
      });
    });

    test('a blank name is stored as no name', () async {
      final id = await writer.createCustomer(
        workspaceId: ws,
        name: '   ',
        date: '2026-11-19',
      );
      final customer = await (db.select(
        db.customers,
      )..where((c) => c.id.equals(id))).getSingle();
      expect(customer.name, isNull);
      expect(fieldsOf((await outbox()).first).containsKey('name'), isFalse);
    });

    test(
      'a site and a room carry the customer and the parent workspace',
      () async {
        final siteId = await writer.createSite(
          customerId: TestIds.familieBeispiel,
          name: 'Neue Wohnung',
        );
        final roomId = await writer.createRoom(siteId: siteId, name: 'Bad');

        final changes = await outbox();
        expect(changes.map((c) => c.entity), <String>['sites', 'rooms']);
        expect(fieldsOf(changes[0]), <String, Object?>{
          'workspace_id': ws,
          'customer_id': TestIds.familieBeispiel,
          'name': 'Neue Wohnung',
        });
        expect(fieldsOf(changes[1]), <String, Object?>{
          'workspace_id': ws,
          'customer_id': TestIds.familieBeispiel,
          'site_id': siteId,
          'name': 'Bad',
        });
        final room = await (db.select(
          db.rooms,
        )..where((r) => r.id.equals(roomId))).getSingle();
        expect(room.customerId, TestIds.familieBeispiel);
      },
    );

    test('a job is one change with the date', () async {
      await writer.createJob(
        customerId: TestIds.familieBeispiel,
        date: '2026-12-01',
      );
      final changes = await outbox();
      expect(changes, hasLength(1));
      expect(fieldsOf(changes.single)['date'], '2026-12-01');
    });

    test(
      'a deleted or unknown parent is refused, nothing is written',
      () async {
        await expectLater(
          writer.createSite(customerId: TestIds.geloescht),
          throwsArgumentError,
        );
        await expectLater(
          writer.createRoom(siteId: 'no-such-site'),
          throwsArgumentError,
        );
        await expectLater(
          writer.createJob(customerId: TestIds.geloescht, date: '2026-12-01'),
          throwsArgumentError,
        );
        expect(await outbox(), isEmpty);
      },
    );

    test('a name over 200 characters and a bad date are refused', () async {
      await expectLater(
        writer.createSite(customerId: TestIds.familieBeispiel, name: 'x' * 201),
        throwsArgumentError,
      );
      await expectLater(
        writer.createJob(
          customerId: TestIds.familieBeispiel,
          date: '19.11.2026',
        ),
        throwsArgumentError,
      );
      expect(await outbox(), isEmpty);
    });
  });

  group('change', () {
    test('rename queues only the name; blank clears it', () async {
      await writer.rename(
        entity: 'rooms',
        id: TestIds.kueche,
        name: ' Küche neu ',
      );
      await writer.rename(entity: 'rooms', id: TestIds.kueche, name: '');
      final changes = await outbox();
      expect(fieldsOf(changes[0]), <String, Object?>{'name': 'Küche neu'});
      expect(fieldsOf(changes[1]), <String, Object?>{'name': null});
      final room = await (db.select(
        db.rooms,
      )..where((r) => r.id.equals(TestIds.kueche))).getSingle();
      expect(room.name, isNull);
    });

    test(
      'rename refuses a table without a name and a deleted record',
      () async {
        await expectLater(
          writer.rename(entity: 'jobs', id: 'x', name: 'a'),
          throwsArgumentError,
        );
        await expectLater(
          writer.rename(entity: 'customers', id: TestIds.geloescht, name: 'a'),
          throwsArgumentError,
        );
      },
    );

    test('a job moves to another date', () async {
      final id = await writer.createJob(
        customerId: TestIds.familieBeispiel,
        date: '2026-12-01',
      );
      await writer.changeJobDate(id: id, date: '2026-12-02');
      final job = await (db.select(
        db.jobs,
      )..where((j) => j.id.equals(id))).getSingle();
      expect(job.date, '2026-12-02');
      expect(fieldsOf((await outbox()).last), <String, Object?>{
        'date': '2026-12-02',
      });
    });

    test('delete is a tombstone and restore undoes it', () async {
      await writer.delete(entity: 'rooms', id: TestIds.kueche);
      var room = await (db.select(
        db.rooms,
      )..where((r) => r.id.equals(TestIds.kueche))).getSingle();
      expect(room.deletedAt, isNotNull);
      await writer.restore(entity: 'rooms', id: TestIds.kueche);
      room = await (db.select(
        db.rooms,
      )..where((r) => r.id.equals(TestIds.kueche))).getSingle();
      expect(room.deletedAt, isNull);
      expect((await outbox()).map((c) => c.op), <String>['delete', 'restore']);
    });

    test('delete refuses a table the phone does not add to', () async {
      await expectLater(
        writer.delete(entity: 'pictures', id: TestIds.fotoVorher),
        throwsArgumentError,
      );
    });
  });

  group('the customer\'s jobs', () {
    test('from today on, soonest first, deleted ones skipped', () async {
      await db.batch((b) {
        b.insertAll(db.jobs, <JobsCompanion>[
          JobsCompanion.insert(
            id: '01970000-0000-7000-8000-000000000e01',
            workspaceId: ws,
            customerId: TestIds.frauMuster,
            date: '2026-11-18',
          ),
          JobsCompanion.insert(
            id: '01970000-0000-7000-8000-000000000e02',
            workspaceId: ws,
            customerId: TestIds.frauMuster,
            date: '2026-12-24',
          ),
          JobsCompanion.insert(
            id: '01970000-0000-7000-8000-000000000e03',
            workspaceId: ws,
            customerId: TestIds.frauMuster,
            date: '2026-11-19',
          ),
        ]);
      });
      final jobs = await watchJobsOfCustomer(
        db,
        TestIds.frauMuster,
        '2026-11-19',
      ).first;
      expect(jobs.map((j) => j.date), <String>[
        '2026-11-19',
        '2026-11-20',
        '2026-12-24',
      ]);
    });

    test(
      'the stream shows a new job, with another watcher open first',
      () async {
        final other = watchCustomer(db, TestIds.familieBeispiel).listen((_) {});
        addTearDown(other.cancel);
        final emitted = <List<String>>[];
        final sub = watchJobsOfCustomer(
          db,
          TestIds.familieBeispiel,
          '2026-11-19',
        ).listen((jobs) => emitted.add(<String>[for (final j in jobs) j.date]));
        addTearDown(sub.cancel);
        await pumpEventQueue();
        final before = emitted.last;

        await writer.createJob(
          customerId: TestIds.familieBeispiel,
          date: '2027-01-02',
        );
        await pumpEventQueue();

        expect(emitted.last, <String>[...before, '2027-01-02']);
      },
    );

    test('a deleted customer has none', () async {
      expect(
        await watchJobsOfCustomer(db, TestIds.geloescht, '2026-11-19').first,
        isEmpty,
      );
    });
  });
}
