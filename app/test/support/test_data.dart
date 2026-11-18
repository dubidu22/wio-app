import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:wio_app/data/database.dart';

/// A fresh in-memory database for one test.
WioDatabase memoryDatabase() => WioDatabase(NativeDatabase.memory());

/// The fixed "now" of widget and golden tests: Thursday 19 Nov 2026, 10:00.
final DateTime testNow = DateTime(2026, 11, 19, 10);

/// Invented test data (no real people or addresses, INV-07).
abstract final class TestIds {
  static const String workspace = '01970000-0000-7000-8000-000000000001';
  static const String familieBeispiel = '01970000-0000-7000-8000-0000000000c1';
  static const String frauMuster = '01970000-0000-7000-8000-0000000000c2';
  static const String herrProbe = '01970000-0000-7000-8000-0000000000c3';
  static const String geloescht = '01970000-0000-7000-8000-0000000000c4';
  static const String alteWohnung = '01970000-0000-7000-8000-0000000000a1';
  static const String neueWohnung = '01970000-0000-7000-8000-0000000000a2';
  static const String fremderOrt = '01970000-0000-7000-8000-0000000000a3';
  static const String kueche = '01970000-0000-7000-8000-0000000000b1';
  static const String keller = '01970000-0000-7000-8000-0000000000b2';
  static const String alterRaum = '01970000-0000-7000-8000-0000000000b3';
}

CustomersCompanion _customer(String id, String name, {String? deletedAt}) =>
    CustomersCompanion.insert(
      id: id,
      workspaceId: TestIds.workspace,
      name: Value<String?>(name),
      revision: const Value<int?>(1),
      deletedAt: Value<String?>(deletedAt),
    );

JobsCompanion _job(
  String id,
  String customerId,
  String date, {
  String? deletedAt,
}) => JobsCompanion.insert(
  id: id,
  workspaceId: TestIds.workspace,
  customerId: customerId,
  date: date,
  revision: const Value<int?>(1),
  deletedAt: Value<String?>(deletedAt),
);

/// Seeds data as if it had been pulled from the server: three live
/// customers, one tombstoned; jobs today, later and in the past; two sites
/// of Familie Beispiel, one with rooms.
Future<void> seedTestData(WioDatabase db) async {
  await db.batch((b) {
    b.insertAll(db.customers, <CustomersCompanion>[
      _customer(TestIds.familieBeispiel, 'Familie Beispiel'),
      _customer(TestIds.frauMuster, 'Frau Muster'),
      _customer(TestIds.herrProbe, 'Herr Probe'),
      _customer(
        TestIds.geloescht,
        'Gelöschte Kundin',
        deletedAt: '2026-11-10T08:00:00.000Z',
      ),
    ]);
    b.insertAll(db.jobs, <JobsCompanion>[
      _job(
        '01970000-0000-7000-8000-0000000000d1',
        TestIds.familieBeispiel,
        '2026-11-19',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d2',
        TestIds.frauMuster,
        '2026-11-20',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d3',
        TestIds.herrProbe,
        '2026-11-23',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d4',
        TestIds.herrProbe,
        '2026-11-18',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d5',
        TestIds.frauMuster,
        '2026-11-19',
        deletedAt: '2026-11-12T08:00:00.000Z',
      ),
      _job(
        '01970000-0000-7000-8000-0000000000d6',
        TestIds.geloescht,
        '2026-11-19',
      ),
    ]);
    b.insertAll(db.sites, <SitesCompanion>[
      SitesCompanion.insert(
        id: TestIds.alteWohnung,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        name: const Value<String?>('Alte Wohnung'),
        revision: const Value<int?>(1),
      ),
      SitesCompanion.insert(
        id: TestIds.neueWohnung,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        name: const Value<String?>('Neue Wohnung'),
        revision: const Value<int?>(1),
      ),
      SitesCompanion.insert(
        id: TestIds.fremderOrt,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.frauMuster),
        name: const Value<String?>('Wohnung Muster'),
        revision: const Value<int?>(1),
      ),
    ]);
    b.insertAll(db.rooms, <RoomsCompanion>[
      RoomsCompanion.insert(
        id: TestIds.kueche,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        siteId: TestIds.alteWohnung,
        name: const Value<String?>('Küche'),
        revision: const Value<int?>(1),
      ),
      RoomsCompanion.insert(
        id: TestIds.keller,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        siteId: TestIds.alteWohnung,
        name: const Value<String?>('Keller'),
        revision: const Value<int?>(1),
      ),
      RoomsCompanion.insert(
        id: TestIds.alterRaum,
        workspaceId: TestIds.workspace,
        customerId: const Value<String?>(TestIds.familieBeispiel),
        siteId: TestIds.alteWohnung,
        name: const Value<String?>('Abstellraum'),
        revision: const Value<int?>(1),
        deletedAt: const Value<String?>('2026-11-11T08:00:00.000Z'),
      ),
    ]);
  });
}

/// Test data plus two changes the server refused (D-197): a renamed
/// customer (permission) and a new customer whose number existed already
/// (duplicate, re-pointed).
Future<void> seedWithRejected(WioDatabase db) async {
  await seedTestData(db);
  await db.batch((b) {
    b.insertAll(db.rejectedChanges, <RejectedChangesCompanion>[
      RejectedChangesCompanion.insert(
        changeId: '01970000-0000-7000-8000-0000000000e1',
        entity: 'customers',
        entityId: TestIds.frauMuster,
        op: 'upsert',
        fields: '{"name":"Frau Muster-Probe","contact":"{}"}',
        deviceTime: '2026-11-19T08:00:00.000Z',
        reason: 'permission',
        rejectedAt: '2026-11-19T08:05:00.000Z',
      ),
      RejectedChangesCompanion.insert(
        changeId: '01970000-0000-7000-8000-0000000000e2',
        entity: 'customers',
        entityId: '01970000-0000-7000-8000-0000000000c9',
        op: 'upsert',
        fields:
            '{"workspace_id":"${TestIds.workspace}","name":"Familie B.",'
            '"external_ref":"K-17"}',
        deviceTime: '2026-11-19T08:01:00.000Z',
        reason: 'duplicate',
        existingId: const Value<String?>(TestIds.familieBeispiel),
        rejectedAt: '2026-11-19T08:04:00.000Z',
      ),
    ]);
  });
}
