import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/jobs/job_list_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';

import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
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
    expect(find.text('Noch keine Fotos.'), findsNothing, reason: 'one picture');
  });

  testWidgets('rooms are buttons with their picture count (D-259, D-264)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
    );

    final kueche = find.widgetWithText(OutlinedButton, 'Küche');
    final keller = find.widgetWithText(OutlinedButton, 'Keller');
    expect(kueche, findsOneWidget);
    expect(keller, findsOneWidget);
    expect(
      find.descendant(of: kueche, matching: find.text('4 Fotos')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: keller, matching: find.text('Noch keine Fotos')),
      findsOneWidget,
    );
    expect(tester.getSize(kueche).height, greaterThanOrEqualTo(56));

    await tester.tap(kueche);
    await tester.pumpAndSettle();
    final room = tester.widget<RoomScreen>(find.byType(RoomScreen));
    expect(room.roomId, TestIds.kueche);
    expect(room.customerId, TestIds.familieBeispiel);
  });

  testWidgets('Fotos lists only pictures without a room', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
      mediaFolder: demoMediaFolder(),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Öffnen'), findsOneWidget);
    expect(find.text('Nachher'), findsNothing);
  });

  testWidgets('a customer without pictures shows the hint', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.frauMuster}',
    );

    expect(find.text('Noch keine Fotos.'), findsOneWidget);
  });

  testWidgets('buttons: Zurück, rooms, pictures, Sprechen and Fotos '
      '(D-75, D-258, D-295)', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
      mediaFolder: demoMediaFolder(),
    );

    expect(
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
      findsNWidgets(7),
      reason:
          'Zurück, Keller, Küche, one picture, Notiz schreiben, '
          'Sprechen, Fotos',
    );
    expect(find.widgetWithText(OutlinedButton, 'Sprechen'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsOneWidget);
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

  testWidgets('Zurück keeps its size at twice the text size', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
      textScale: 2,
    );

    expect(tester.getSize(find.byIcon(Icons.arrow_back)), const Size(24, 24));
    final label = find.text('Zurück');
    final box = find.ancestor(of: label, matching: find.byType(FittedBox));
    expect(tester.getSize(box), tester.getSize(label), reason: 'not shrunk');
    expect(
      tester.getSize(find.text('Familie Beispiel')).width,
      greaterThan(120),
      reason: 'the title keeps room',
    );
  });
}
