import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';

import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
  });
  tearDown(() => db.close());

  testWidgets('shows the picture, its time and only Zurück (D-259)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location:
          '$_customer/rooms/${TestIds.kueche}'
          '/pictures/${TestIds.fotoNachher}',
      mediaFolder: demoMediaFolder(),
    );

    expect(find.text('Foto'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(find.textContaining('19.11.'), findsOneWidget);
    expect(find.text('Nachher'), findsOneWidget);
    expect(
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
      findsOneWidget,
      reason: 'buttons of #59 come later (D-75)',
    );
  });

  testWidgets('a picture without a room opens from the customer', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _customer,
      mediaFolder: demoMediaFolder(),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Öffnen'));
    await tester.pumpAndSettle();
    await loadPictures(tester);
    expect(find.text('Foto'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('a file not on this device is a plain hint (D-260)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location:
          '$_customer/rooms/${TestIds.kueche}'
          '/pictures/${TestIds.fotoFehlt}',
      mediaFolder: demoMediaFolder(),
    );

    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('unknown, deleted, wrong room or other customer is a hint', (
    tester,
  ) async {
    for (final location in <String>[
      '$_customer/pictures/no-such-id',
      '$_customer/pictures/${TestIds.fotoGeloescht}',
      '$_customer/rooms/${TestIds.keller}/pictures/${TestIds.fotoVorher}',
      '/customers/${TestIds.frauMuster}/pictures/${TestIds.fotoVorher}',
    ]) {
      await pumpWioApp(tester, db: db, location: location);
      expect(
        find.text('Dieses Foto gibt es nicht mehr.'),
        findsOneWidget,
        reason: location,
      );
      expect(find.text('Zurück'), findsOneWidget);
    }
  });
}
