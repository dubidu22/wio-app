import 'package:wio_app/data/database.dart';

import 'test_data.dart';

/// Local rows per table, to prove nothing is wiped (D-65, D-129).
Future<Map<String, int>> countRows(WioDatabase db) async => <String, int>{
  for (final table in <String>[
    'customers',
    'sites',
    'rooms',
    'jobs',
    'outbox',
    'sync_state',
  ])
    table:
        (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
            .read<int>('n'),
};

/// Test data plus one unsent change in the outbox.
Future<WioDatabase> seededWithOutbox() async {
  final db = memoryDatabase();
  await seedTestData(db);
  await db
      .into(db.outbox)
      .insert(
        OutboxCompanion.insert(
          changeId: '01970000-0000-7000-8000-0000000000f1',
          entity: 'customers',
          entityId: TestIds.frauMuster,
          fields: '{"name":"Frau Muster"}',
          deviceTime: '2026-11-19T09:00:00.000Z',
        ),
      );
  return db;
}
