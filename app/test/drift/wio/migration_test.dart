import 'dart:convert';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;

/// Local schema steps (D-65, D-192, D-239, D-435; plan 044 test T1, plan
/// 054 tests T1 and T2, plan 101 tests T1 and T2). Every version can be
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

  test('v2 to v3 rebuilds pulled pictures and notes (D-239)', () async {
    const ws = '01970000-0000-7000-8000-0000000000a1';
    const picture = '01970000-0000-7000-8000-0000000000e7';
    const note = '01970000-0000-7000-8000-0000000000e8';
    const unsent = '01970000-0000-7000-8000-0000000000e9';
    const sha =
        'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';
    final copies = <v2.ServerRecordsData>[
      v2.ServerRecordsData(
        entity: 'pictures',
        id: picture,
        revision: 5,
        fields: jsonEncode(<String, Object?>{
          'id': picture,
          'workspace_id': ws,
          'customer_id': null,
          'file_sha256': sha,
          'file_bytes': 1200,
          'file_mime': 'image/jpeg',
          'width_px': 2560,
          'height_px': 1920,
          'taken_at': '2026-11-19T08:00:00.000Z',
          'room_id': null,
          'entry_id': null,
          'after_of': null,
          'revision': 5,
          'deleted_at': null,
        }),
      ),
      v2.ServerRecordsData(
        entity: 'notes',
        id: note,
        revision: 6,
        deletedAt: '2026-11-19T09:00:00.000Z',
        fields: jsonEncode(<String, Object?>{
          'id': note,
          'workspace_id': ws,
          'subject_type': 'picture',
          'subject_id': picture,
          'text': 'Riss',
          'revision': 6,
          'deleted_at': '2026-11-19T09:00:00.000Z',
        }),
      ),
      v2.ServerRecordsData(
        entity: 'customers',
        id: '01970000-0000-7000-8000-0000000000c1',
        revision: 1,
        fields: '{"name":"Frau Muster"}',
      ),
    ];
    const outbox = <v2.OutboxData>[
      v2.OutboxData(
        seq: 1,
        changeId: '01970000-0000-7000-8000-0000000000f1',
        entity: 'notes',
        entityId: unsent,
        op: 'upsert',
        fields:
            '{"workspace_id":"$ws","subject_type":"picture",'
            '"subject_id":"$picture","text":"Noch nicht gesendet"}',
        baseRevision: null,
        deviceTime: '2026-11-19T09:05:00.000Z',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 2,
      newVersion: 3,
      createOld: v2.DatabaseAtV2.new,
      createNew: v3.DatabaseAtV3.new,
      openTestedDatabase: WioDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.serverRecords, copies)
          ..insertAll(oldDb.outbox, outbox);
      },
      validateItems: (newDb) async {
        final pictures = await newDb.select(newDb.pictures).get();
        expect(pictures, hasLength(1));
        expect(pictures.single.id, picture);
        expect(pictures.single.fileSha256, sha);
        expect(pictures.single.fileBytes, 1200);
        expect(pictures.single.widthPx, 2560);
        expect(pictures.single.revision, 5);
        expect(pictures.single.takenAt, '2026-11-19T08:00:00.000Z');
        final notes =
            await (newDb.select(newDb.notes)
                  ..orderBy(<OrderClauseGenerator<v3.Notes>>[
                    (n) => OrderingTerm.asc(n.id),
                  ]))
                .get();
        expect(notes.map((n) => n.id), <String>[note, unsent]);
        expect(notes.first.text$, 'Riss');
        expect(notes.first.deletedAt, '2026-11-19T09:00:00.000Z');
        expect(notes.first.revision, 6);
        expect(notes.last.text$, 'Noch nicht gesendet');
        expect(notes.last.revision, isNull);
        expect(await newDb.select(newDb.outbox).get(), hasLength(1));
        expect(await newDb.select(newDb.serverRecords).get(), hasLength(3));
      },
    );
  });

  test('v3 to v4 rebuilds pulled entries, history and vocabulary '
      '(D-435)', () async {
    const ws = '01970000-0000-7000-8000-0000000000a1';
    const customer = '01970000-0000-7000-8000-0000000000c1';
    const site = '01970000-0000-7000-8000-0000000000a2';
    const room = '01970000-0000-7000-8000-0000000000b1';
    const entry = '01970000-0000-7000-8000-0000000000e1';
    const history = '01970000-0000-7000-8000-0000000000e2';
    const label = '01970000-0000-7000-8000-0000000000e3';
    const key = '01970000-0000-7000-8000-0000000000e4';
    const labelLink = '01970000-0000-7000-8000-0000000000e5';
    const value = '01970000-0000-7000-8000-0000000000e6';
    v3.ServerRecordsData copy(
      String entity,
      String id,
      int revision,
      Map<String, Object?> fields,
    ) => v3.ServerRecordsData(
      entity: entity,
      id: id,
      revision: revision,
      fields: jsonEncode(<String, Object?>{
        'id': id,
        'workspace_id': ws,
        'revision': revision,
        'deleted_at': null,
        ...fields,
      }),
    );
    final copies = <v3.ServerRecordsData>[
      copy('entries', entry, 7, <String, Object?>{
        'customer_id': customer,
        'code': 'WIO-0001',
        'title': 'Bücherkiste',
        'site_id': site,
        'room_id': room,
        'fixture_id': null,
        'level': null,
        'compartment': null,
        'floor_x_cm': null,
        'floor_y_cm': null,
        'target_site_id': null,
        'target_room_id': null,
      }),
      copy('place_history', history, 8, <String, Object?>{
        'customer_id': customer,
        'entry_id': entry,
        'from_site_id': null,
        'from_room_id': null,
        'to_site_id': site,
        'to_room_id': room,
        'moved_at': '2026-11-19T08:00:00.000Z',
      }),
      copy('labels', label, 9, <String, Object?>{'name': 'Bücher'}),
      copy('property_keys', key, 10, <String, Object?>{
        'name': 'Gewicht',
        'unit': 'kg',
      }),
      copy('entity_labels', labelLink, 11, <String, Object?>{
        'customer_id': customer,
        'entity_type': 'entry',
        'entity_id': entry,
        'label_id': label,
      }),
      copy('entity_properties', value, 12, <String, Object?>{
        'customer_id': customer,
        'entity_type': 'entry',
        'entity_id': entry,
        'key_id': key,
        'value_text': null,
        'value_number': '12.5',
      }),
    ];
    const outbox = <v3.OutboxData>[
      v3.OutboxData(
        seq: 1,
        changeId: '01970000-0000-7000-8000-0000000000f1',
        entity: 'entries',
        entityId: entry,
        op: 'upsert',
        fields: '{"title":"Bücher und Spiele"}',
        baseRevision: 7,
        deviceTime: '2026-11-19T09:05:00.000Z',
      ),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: WioDatabase.new,
      createItems: (batch, oldDb) {
        batch
          ..insertAll(oldDb.serverRecords, copies)
          ..insertAll(oldDb.outbox, outbox);
      },
      validateItems: (newDb) async {
        final entries = await newDb.select(newDb.entries).get();
        expect(entries.single.id, entry);
        expect(entries.single.code, 'WIO-0001');
        expect(entries.single.title, 'Bücher und Spiele');
        expect(entries.single.roomId, room);
        expect(entries.single.revision, 7);
        final steps = await newDb.select(newDb.placeHistory).get();
        expect(steps.single.toRoomId, room);
        expect(steps.single.fromRoomId, isNull);
        expect(steps.single.movedAt, '2026-11-19T08:00:00.000Z');
        expect((await newDb.select(newDb.labels).getSingle()).name, 'Bücher');
        expect((await newDb.select(newDb.propertyKeys).getSingle()).unit, 'kg');
        expect(
          (await newDb.select(newDb.entityLabels).getSingle()).labelId,
          label,
        );
        expect(
          (await newDb.select(newDb.entityProperties).getSingle()).valueNumber,
          '12.5',
        );
        expect(await newDb.select(newDb.outbox).get(), hasLength(1));
        expect(await newDb.select(newDb.serverRecords).get(), hasLength(6));
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
