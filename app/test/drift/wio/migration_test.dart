import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

/// Local schema steps (D-65, D-192; plan 044 test T1). Every version can be
/// reached from every older one, and the unsent outbox survives each step.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('schema steps', () {
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      for (final toVersion in versions.skip(i + 1)) {
        test('from $fromVersion to $toVersion', () async {
          final schema = await verifier.schemaAt(fromVersion);
          final db = WioDatabase(schema.newConnection());
          await verifier.migrateAndValidate(db, toVersion);
          await db.close();
        });
      }
    }
  });

  test('v1 to v2 keeps unsent outbox rows as upserts', () async {
    const outbox = <v1.OutboxData>[
      v1.OutboxData(
        seq: 1,
        changeId: '01970000-0000-7000-8000-0000000000f1',
        entity: 'customers',
        entityId: '01970000-0000-7000-8000-0000000000c1',
        fields: '{"name":"Frau Muster"}',
        baseRevision: null,
        deviceTime: '2026-11-19T09:00:00.000Z',
      ),
      v1.OutboxData(
        seq: 2,
        changeId: '01970000-0000-7000-8000-0000000000f2',
        entity: 'rooms',
        entityId: '01970000-0000-7000-8000-0000000000e1',
        fields: '{"height_cm":230}',
        baseRevision: 4,
        deviceTime: '2026-11-19T09:01:00.000Z',
      ),
    ];
    const syncState = <v1.SyncStateData>[
      v1.SyncStateData(
        workspaceId: '01970000-0000-7000-8000-0000000000a1',
        lastRevision: 17,
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: WioDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.outbox, outbox)
          ..insertAll(oldDb.syncState, syncState);
      },
      validateItems: (newDb) async {
        expect(await newDb.select(newDb.outbox).get(), <v2.OutboxData>[
          for (final row in outbox)
            v2.OutboxData(
              seq: row.seq,
              changeId: row.changeId,
              entity: row.entity,
              entityId: row.entityId,
              op: 'upsert',
              fields: row.fields,
              baseRevision: row.baseRevision,
              deviceTime: row.deviceTime,
            ),
        ]);
        expect(await newDb.select(newDb.syncState).get(), <v2.SyncStateData>[
          v2.SyncStateData(
            workspaceId: syncState.single.workspaceId,
            lastRevision: syncState.single.lastRevision,
          ),
        ]);
        expect(await newDb.select(newDb.serverRecords).get(), isEmpty);
        expect(await newDb.select(newDb.rejectedChanges).get(), isEmpty);
        expect(await newDb.select(newDb.uploads).get(), isEmpty);
      },
    );
  });

  test('an op outside the contract is refused', () async {
    final schema = await verifier.schemaAt(2);
    final db = WioDatabase(schema.newConnection());
    addTearDown(db.close);
    await expectLater(
      db.customStatement(
        'INSERT INTO outbox (change_id, entity, entity_id, op, fields, '
        "device_time) VALUES ('c', 'customers', 'x', 'drop', '{}', 't')",
      ),
      throwsA(anything),
    );
  });
}
