// "Nicht gesendet" names entries, labels and moves (plan 101 test T17,
// D-444). No golden changes: the catalogue's goldens keep their customers.
import 'package:drift/drift.dart' show Value;
import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

const String existing = '01970000-0000-7000-8000-000000000e01';
const String mine = '01970000-0000-7000-8000-000000000e02';
const String label = '01970000-0000-7000-8000-000000000e03';

RejectedChangesCompanion _rejected(
  String changeId,
  String entity,
  String entityId,
  String op,
  String fields,
  String reason, {
  String? existingId,
}) => RejectedChangesCompanion.insert(
  changeId: changeId,
  entity: entity,
  entityId: entityId,
  op: op,
  fields: fields,
  deviceTime: '2026-11-19T08:00:00.000Z',
  reason: reason,
  existingId: Value<String?>(existingId),
  rejectedAt:
      '2026-11-19T08:0${changeId.substring(changeId.length - 1)}:00.000Z',
);

void main() {
  testWidgets('entries, labels and moves have their own words', (tester) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await seedTestData(db);
    await db.batch((b) {
      b
        ..insert(
          db.entries,
          EntriesCompanion.insert(
            id: existing,
            workspaceId: TestIds.workspace,
            customerId: const Value<String?>(TestIds.familieBeispiel),
            code: const Value<String?>('WIO-0007'),
            title: const Value<String?>('Winterkleidung'),
            revision: const Value<int?>(4),
          ),
        )
        ..insertAll(db.rejectedChanges, <RejectedChangesCompanion>[
          // A create joined to the existing entry (D-198): its own code,
          // the existing entry's title.
          _rejected(
            '01970000-0000-7000-8000-0000000000f1',
            'entries',
            mine,
            'upsert',
            '{"workspace_id":"${TestIds.workspace}","code":"WIO-0007"}',
            'duplicate',
            existingId: existing,
          ),
          _rejected(
            '01970000-0000-7000-8000-0000000000f2',
            'entries',
            existing,
            'move_entry',
            '{"site_id":null,"room_id":null,"fixture_id":null,"level":null,'
                '"compartment":null,"floor_x_cm":null,"floor_y_cm":null}',
            'permission',
          ),
          _rejected(
            '01970000-0000-7000-8000-0000000000f3',
            'labels',
            label,
            'upsert',
            '{"workspace_id":"${TestIds.workspace}","name":"Bücher"}',
            'permission',
          ),
          _rejected(
            '01970000-0000-7000-8000-0000000000f4',
            'entries',
            existing,
            'upsert',
            '{"title":"Sommer","target_site_id":null,"target_room_id":null}',
            'permission',
          ),
        ]);
    });
    await pumpWioApp(
      tester,
      db: db,
      location: '/nicht-gesendet',
      size: const Size(390, 2400),
    );

    expect(find.text('Eintrag: Winterkleidung'), findsNWidgets(2));
    // A refused edit names the entry as the change wanted it, as for
    // customers.
    expect(find.text('Eintrag: Sommer'), findsOneWidget);
    expect(
      find.text('Gab es schon. Mit dem vorhandenen Eintrag verbunden.'),
      findsOneWidget,
    );
    expect(find.text('Ort geändert'), findsOneWidget);
    expect(find.text('Label: Bücher'), findsOneWidget);
    expect(find.text('Geändert: Titel, Ziel'), findsOneWidget);
  });
}
