import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/shell/providers.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedTestData(db);
  });
  tearDown(() => db.close());

  testWidgets('shows today and upcoming jobs as buttons', (tester) async {
    await pumpWioApp(tester, db: db);

    expect(find.text('Heute'), findsOneWidget);
    expect(find.text('Kommend'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Familie Beispiel'),
      findsOneWidget,
    );
    expect(find.widgetWithText(OutlinedButton, 'Frau Muster'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, 'Herr Probe'), findsOneWidget);
    expect(find.text('Fr., 20. Nov.'), findsOneWidget);
    expect(find.text('Mo., 23. Nov.'), findsOneWidget);
    expect(find.text('Gelöschte Kundin'), findsNothing);
    expect(find.text('Heute keine Aufträge.'), findsNothing);
  });

  testWidgets('a job opens its customer, and Zurück returns', (tester) async {
    await pumpWioApp(tester, db: db);

    await tester.tap(find.text('Familie Beispiel'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(find.text('Alte Wohnung'), findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsNothing);
    expect(find.text('Aufträge'), findsOneWidget);
  });

  testWidgets('Quellcode opens the source address in the browser', (
    tester,
  ) async {
    final opened = <Uri>[];
    await pumpWioApp(
      tester,
      db: db,
      opener: (uri) async {
        opened.add(uri);
        return true;
      },
    );

    expect(find.widgetWithText(TextButton, 'Quellcode'), findsOneWidget);
    await tester.tap(find.text('Quellcode'));
    await tester.pumpAndSettle();
    expect(opened, <Uri>[Uri.parse(wioSourceUrl)]);
    expect(wioSourceUrl, 'https://github.com/dubidu22/wio-app');
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('Quellcode shows the address when no browser opens', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, opener: (uri) async => false);

    await tester.tap(find.text('Quellcode'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Den Quellcode gibt es hier: https://github.com/dubidu22/wio-app',
      ),
      findsOneWidget,
    );
  });
}
