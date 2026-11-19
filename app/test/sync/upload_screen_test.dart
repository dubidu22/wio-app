// Failed uploads in "Nicht gesendet" and the status line for pending
// uploads (plan 044b W1, D-214, D-216).
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

Future<WioDatabase> failed(WidgetTester tester) async {
  final db = memoryDatabase();
  addTearDown(db.close);
  await seedTestData(db);
  await seedUploads(db, <(String, int, String?)>[
    ('a' * 64, 2500000, 'permission'),
    ('b' * 64, 12900000, 'damaged'),
  ]);
  await pumpWioApp(tester, db: db);
  await settle(tester);
  return db;
}

Future<List<Upload>> rows(WioDatabase db) => db.select(db.uploads).get();

void main() {
  testWidgets('failed uploads are counted and listed with their reason', (
    tester,
  ) async {
    await failed(tester);
    expect(find.text('2 Änderungen wurden nicht übernommen.'), findsOneWidget);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
    await settle(tester);
    expect(find.text('Datei (2,4 MB)'), findsOneWidget);
    expect(find.text('Datei (12,3 MB)'), findsOneWidget);
    expect(
      find.text('Keine Berechtigung, diese Datei zu senden.'),
      findsOneWidget,
    );
    expect(find.text('Datei beschädigt.'), findsOneWidget);
    // Only a refused permission can be tried again.
    expect(
      find.widgetWithText(FilledButton, 'Noch einmal senden'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Verwerfen'), findsNWidgets(2));
  });

  testWidgets('Noch einmal senden makes the file pending again', (
    tester,
  ) async {
    final db = await failed(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
    await settle(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Noch einmal senden'));
    await settle(tester);
    final permission = (await rows(db)).firstWhere((r) => r.sha256 == 'a' * 64);
    expect(permission.failedReason, isNull);
    expect(find.text('Datei (2,4 MB)'), findsNothing);
  });

  testWidgets('Verwerfen removes it; Rückgängig brings it back', (
    tester,
  ) async {
    final db = await failed(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
    await settle(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Verwerfen').last);
    await settle(tester);
    expect(await rows(db), hasLength(1));
    expect(find.text('Verworfen.'), findsOneWidget);
    await tester.tap(find.text('Rückgängig'));
    await settle(tester);
    expect(await rows(db), hasLength(2));
    expect(find.text('Datei (12,3 MB)'), findsOneWidget);
  });

  testWidgets('the Verworfen note goes away after 8 seconds (UX rule 9)', (
    tester,
  ) async {
    await failed(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Ansehen'));
    await settle(tester);
    await tester.tap(find.widgetWithText(OutlinedButton, 'Verwerfen').last);
    await settle(tester);
    await tester.pump(const Duration(seconds: 7));
    expect(find.text('Verworfen.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await settle(tester);
    expect(find.text('Verworfen.'), findsNothing);
  });

  testWidgets('the status line names pending uploads (D-216)', (tester) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await seedTestData(db);
    await seedUploads(db, <(String, int, String?)>[
      ('c' * 64, 1000, null),
      ('d' * 64, 2000, null),
      ('e' * 64, 3000, 'damaged'),
    ]);
    await pumpWioApp(tester, db: db);
    await settle(tester);
    expect(find.text('2 Dateien werden hochgeladen.'), findsOneWidget);
  });
}
