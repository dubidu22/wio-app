import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/jobs/job_list_screen.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedTestData(db);
  });
  tearDown(() => db.close());

  testWidgets('shows sites with rooms and hints for later parts', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
    );

    expect(find.text('Familie Beispiel'), findsOneWidget);
    expect(find.text('Orte'), findsOneWidget);
    expect(find.text('Alte Wohnung'), findsOneWidget);
    expect(find.text('Küche'), findsOneWidget);
    expect(find.text('Keller'), findsOneWidget);
    expect(find.text('Abstellraum'), findsNothing, reason: 'tombstoned');
    expect(find.text('Neue Wohnung'), findsOneWidget);
    expect(find.text('Noch keine Räume.'), findsOneWidget);
    expect(find.text('Wohnung Muster'), findsNothing, reason: 'other customer');
    expect(find.text('Noch keine Einträge.'), findsOneWidget);
    expect(find.text('Noch keine Fotos.'), findsOneWidget);
  });

  testWidgets('no dead buttons: only Zurück can be tapped (D-75)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
    );

    expect(
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
      findsOneWidget,
    );
    expect(find.widgetWithText(TextButton, 'Zurück'), findsOneWidget);
    expect(find.byType(BackButton), findsNothing, reason: 'icon only (D-74)');
  });

  testWidgets('a link to a customer still goes back to the job list', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.frauMuster}',
    );

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(JobListScreen), findsOneWidget);
  });

  testWidgets('an unknown or deleted customer shows a hint', (tester) async {
    for (final id in <String>['no-such-id', TestIds.geloescht]) {
      await pumpWioApp(tester, db: db, location: '/customers/$id');
      expect(find.text('Diesen Kunden gibt es nicht mehr.'), findsOneWidget);
      expect(find.text('Zurück'), findsOneWidget);
    }
  });

  testWidgets('updates when a room is written on the device', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
    );

    await tester.runAsync(
      () => LocalWriter(db).write(
        entity: 'rooms',
        id: TestIds.keller,
        fields: <String, Object?>{'name': 'Kellerraum'},
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Kellerraum'), findsOneWidget);
  });

  testWidgets('shows the load error and keeps the data (D-65)', (tester) async {
    await tester.runAsync(() => db.customStatement('DROP TABLE rooms'));
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
    );

    expect(
      find.textContaining('Die gespeicherten Daten konnten nicht gelesen'),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });
}
