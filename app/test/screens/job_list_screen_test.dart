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

  testWidgets('a list left open over midnight moves the new day to Heute', (
    tester,
  ) async {
    var now = DateTime(2026, 11, 19, 23, 59);
    await pumpWioApp(tester, db: db, clock: () => now);
    expect(
      find.widgetWithText(OutlinedButton, 'Familie Beispiel'),
      findsOneWidget,
    );
    expect(find.text('Fr., 20. Nov.'), findsOneWidget);

    now = DateTime(2026, 11, 20, 0, 0, 2);
    await tester.pump(const Duration(minutes: 1, seconds: 2));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(OutlinedButton, 'Frau Muster'), findsOneWidget);
    expect(find.text('Fr., 20. Nov.'), findsNothing, reason: 'now today');
    // Yesterday's customer stays reachable under Weitere Kunden (D-517).
    await scrollTo(tester, find.text('Weitere Kunden'));
    expect(
      find.widgetWithText(OutlinedButton, 'Familie Beispiel'),
      findsOneWidget,
    );
    expect(find.text('Letzter Auftrag: 19. Nov. 2026'), findsOneWidget);
  });

  group('Weitere Kunden (plan 120)', () {
    testWidgets('is left out while every customer has a job from today on', (
      tester,
    ) async {
      await pumpWioApp(tester, db: db);
      await scrollTo(tester, find.text('Abmelden'));
      expect(find.text('Weitere Kunden'), findsNothing);
      expect(find.textContaining('Letzter Auftrag'), findsNothing);
    });

    testWidgets('lists customers whose jobs passed, latest first, and opens '
        'them', (tester) async {
      await pumpWioApp(tester, db: db, now: DateTime(2026, 11, 21, 9));
      await scrollTo(tester, find.text('Weitere Kunden'));
      // Herr Probe has a job on 23 Nov, so he stays under Kommend only.
      expect(find.text('Herr Probe'), findsOneWidget);
      await scrollTo(tester, find.text('Letzter Auftrag: 19. Nov. 2026'));
      expect(find.text('Letzter Auftrag: 20. Nov. 2026'), findsOneWidget);
      final muster = tester.getTopLeft(find.text('Frau Muster')).dy;
      final beispiel = tester.getTopLeft(find.text('Familie Beispiel')).dy;
      expect(muster, lessThan(beispiel), reason: 'latest job first');

      await tester.tap(find.text('Familie Beispiel'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Alte Wohnung'), findsOneWidget);
    });

    testWidgets('a customer whose only job is deleted comes back there', (
      tester,
    ) async {
      await pumpWioApp(
        tester,
        db: db,
        location: '/customers/${TestIds.familieBeispiel}',
      );
      await scrollTo(tester, find.text('Do., 19. Nov.'));
      await tester.tap(find.text('Do., 19. Nov.'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.widgetWithText(OutlinedButton, 'Löschen'));
      await tester.tap(find.widgetWithText(OutlinedButton, 'Löschen'));
      await tester.pumpAndSettle();
      expect(find.byType(CustomerScreen), findsOneWidget);

      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();
      expect(find.text('Heute keine Aufträge.'), findsOneWidget);
      await scrollTo(tester, find.text('Weitere Kunden'));
      expect(
        find.widgetWithText(OutlinedButton, 'Familie Beispiel'),
        findsOneWidget,
      );
      expect(find.textContaining('Letzter Auftrag'), findsNothing);
    });

    testWidgets('a customer without a name or a job is listed too', (
      tester,
    ) async {
      final other = memoryDatabase();
      addTearDown(other.close);
      await seedWithOtherCustomers(other);
      await pumpWioApp(tester, db: other);
      await scrollTo(tester, find.text('Kunde ohne Namen'));
      expect(find.text('Letzter Auftrag: 12. Nov. 2026'), findsOneWidget);
      final vorbei = tester.getTopLeft(find.text('Herr Vorbei')).dy;
      final ohne = tester.getTopLeft(find.text('Kunde ohne Namen')).dy;
      expect(vorbei, lessThan(ohne), reason: 'customers with a job first');
    });

    testWidgets('a deleted customer is not listed', (tester) async {
      await pumpWioApp(tester, db: db, now: DateTime(2026, 11, 30, 9));
      await scrollTo(tester, find.text('Abmelden'));
      expect(find.text('Weitere Kunden'), findsOneWidget);
      expect(find.text('Gelöschte Kundin'), findsNothing);
    });
  });
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  final scrollable = find.byType(Scrollable).first;
  for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -200));
    await tester.pump();
  }
  await tester.ensureVisible(finder.first);
  await tester.pumpAndSettle();
}
