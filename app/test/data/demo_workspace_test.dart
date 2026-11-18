import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/queries.dart';

import '../support/demo_workspace.dart';
import '../support/test_data.dart';

/// Demo ids (D-79): table code and row number.
const String _umzuege = '01990000-0000-7000-8000-000100000001';
const String _privat = '01990000-0000-7000-8000-000100000002';
const String _familieBeispiel = '01990000-0000-7000-8000-000300000001';
const String _zuhause = '01990000-0000-7000-8000-000400000003';
const String _neueKueche = '01990000-0000-7000-8000-000500000003';

void main() {
  final demo = DemoWorkspace.fromFile();
  late WioDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<int> count(String table) async =>
      (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
          .read<int>('n');

  test('loads every local table with the rows of the file', () async {
    await demo.load(db);
    final synced = db.allTables
        .map((t) => t.actualTableName)
        .where((t) => !DemoWorkspace.localOnlyTables.contains(t));
    expect(synced, hasLength(4));
    for (final table in synced) {
      expect(await count(table), demo.tables[table]!.length, reason: table);
    }
    expect(await count('customers'), 1);
    expect(await count('sites'), 3);
    expect(await count('rooms'), 4);
    expect(await count('jobs'), 2);
    expect(await count('outbox'), 0);
  });

  test('keeps times as text, JSON as JSON text, nulls as null', () async {
    await demo.load(db);
    final room = await (db.select(
      db.rooms,
    )..where((r) => r.id.equals(_neueKueche))).getSingle();
    final fileRoom = demo.tables['rooms']!.singleWhere(
      (r) => r['id'] == _neueKueche,
    );
    expect(jsonDecode(room.outline!), fileRoom['outline']);
    expect(room.heightCm, 260);
    expect(room.createdAt, '2026-11-02T08:13:00.000Z');
    expect(room.deletedAt, isNull);

    final customer = await (db.select(
      db.customers,
    )..where((c) => c.id.equals(_familieBeispiel))).getSingle();
    expect(jsonDecode(customer.contact!), <String, Object?>{
      'email': 'familie.beispiel@example.org',
    });

    final site = await (db.select(
      db.sites,
    )..where((s) => s.id.equals(_zuhause))).getSingle();
    expect(site.workspaceId, _privat);
    expect(site.customerId, isNull);
  });

  test('the file covers every local synced table and column', () {
    for (final table in db.allTables) {
      final name = table.actualTableName;
      if (DemoWorkspace.localOnlyTables.contains(name)) {
        expect(demo.tables, isNot(contains(name)), reason: name);
        continue;
      }
      final rows = demo.tables[name];
      expect(rows, isNotNull, reason: 'local table $name not in the file');
      final deviceOnly = DemoWorkspace.deviceOnlyColumns[name] ?? <String>{};
      for (final column in table.$columns.map((c) => c.name)) {
        if (deviceOnly.contains(column)) {
          continue;
        }
        for (final row in rows!) {
          expect(
            row.containsKey(column),
            isTrue,
            reason: 'local column $name.$column not in row ${row['id']}',
          );
        }
      }
    }
  });

  test('a file column the local table lacks is an error', () async {
    final file = DemoWorkspace.fromJson(
      jsonEncode(<String, Object?>{
        'format': 1,
        'tables': <Object?>[
          <String, Object?>{
            'table': 'jobs',
            'rows': <Object?>[
              <String, Object?>{
                'id': '01990000-0000-7000-8000-000f00000009',
                'workspace_id': _umzuege,
                'customer_id': _familieBeispiel,
                'date': '2026-11-19',
                'colour': 'blau',
              },
            ],
          },
        ],
      }),
    );
    await expectLater(
      file.load(db),
      throwsA(
        isA<StateError>().having(
          (e) => e.message,
          'message',
          contains('jobs.colour'),
        ),
      ),
    );
    expect(await count('jobs'), 0);
  });

  test('tables the device does not hold are skipped', () async {
    final file = DemoWorkspace.fromJson(
      jsonEncode(<String, Object?>{
        'format': 1,
        'tables': <Object?>[
          <String, Object?>{
            'table': 'fixtures',
            'rows': <Object?>[
              <String, Object?>{
                'id': '01990000-0000-7000-8000-000700000009',
                'workspace_id': _umzuege,
                'revision': 3,
                'anything': true,
              },
            ],
          },
        ],
      }),
    );
    await file.load(db);
    final state = await db.select(db.syncState).getSingle();
    expect(state.workspaceId, _umzuege);
    expect(state.lastRevision, 3);
  });

  test('an unknown format is rejected', () {
    expect(
      () => DemoWorkspace.fromJson('{"format": 2, "tables": []}'),
      throwsFormatException,
    );
  });

  test('sync_state holds the highest revision per workspace', () async {
    await demo.load(db);
    final state = <String, int>{
      for (final row in await db.select(db.syncState).get())
        row.workspaceId: row.lastRevision,
    };
    expect(state, <String, int>{_umzuege: 46, _privat: 6});
    expect(state, demo.lastRevisions);
  });

  test('without sync state, sync_state stays empty', () async {
    await demo.load(db, withSyncState: false);
    expect(await count('sync_state'), 0);
    expect(await count('jobs'), 2);
  });

  test('the job list shows the demo jobs', () async {
    await demo.load(db);
    final list = await watchJobList(db, '2026-11-19').first;
    expect(list.today.map((j) => j.customerName), <String>['Familie Beispiel']);
    expect(list.upcoming.map((j) => j.date), <String>['2026-11-20']);
  });

  test('the customer screen shows the demo sites and rooms', () async {
    await demo.load(db);
    final customer = await watchCustomer(db, _familieBeispiel).first;
    expect(customer!.name, 'Familie Beispiel');
    expect(
      <String?, List<String?>>{
        for (final site in customer.sites)
          site.name: site.rooms.map((r) => r.name).toList(),
      },
      <String?, List<String?>>{
        'Alte Wohnung': <String?>['Keller', 'Küche'],
        'Neue Wohnung': <String?>['Küche'],
      },
    );
  });

  test('the demo ids never collide with the inline test ids', () async {
    await seedTestData(db);
    await demo.load(db);
    expect(await count('customers'), 5);
  });
}
