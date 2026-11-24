// The entry lists on the customer and room screens (plan 105, P1..P7).
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/entries/entry_list.dart';
import 'package:wio_app/entries/entry_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';

import '../support/fake_api.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';

Finder _row(String text) =>
    find.ancestor(of: find.text(text), matching: find.byType(EntryRow));

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithVocabulary(db);
  });
  tearDown(() => db.close());

  // Signed out: the owner's add and change buttons move the lists down
  // (plan 106); add_places_test covers the owner.
  Future<void> pump(WidgetTester tester, String location) => pumpWioApp(
    tester,
    db: db,
    location: location,
    store: FakeTokenStore(),
    mediaFolder: demoMediaFolder(),
  );

  testWidgets('the customer screen lists its entries, not placed first', (
    tester,
  ) async {
    await pump(tester, _customer);

    expect(find.text('Noch keine Einträge.'), findsNothing);
    expect(find.text('Kiste Muster'), findsNothing, reason: 'other customer');
    expect(find.byType(EntryRow), findsNWidgets(2));
    // The hint comes before the first row, the entry without a place first.
    expect(find.text('1 Eintrag ist noch nicht abgelegt.'), findsOneWidget);
    final open = _row('Eintrag ohne Namen');
    final placed = _row('Kiste Geschirr');
    expect(
      tester.getTopLeft(find.text('1 Eintrag ist noch nicht abgelegt.')).dy,
      lessThan(tester.getTopLeft(open).dy),
    );
    expect(tester.getTopLeft(open).dy, lessThan(tester.getTopLeft(placed).dy));
    // Name, place in words and labels as text (P1).
    expect(
      find.descendant(of: open, matching: find.text('Noch nicht abgelegt')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: open, matching: find.text('Labels: Glas')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: placed, matching: find.text('Küche, Boden')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: placed, matching: find.text('Labels: Zerbrechlich')),
      findsOneWidget,
    );
    // Rows are big buttons (UX rules 1 and 3).
    expect(
      tester.getSize(find.byType(EntryRow).first).height,
      greaterThanOrEqualTo(72),
    );
    expect(
      find.descendant(
        of: find.byType(EntryRow).first,
        matching: find.byType(OutlinedButton),
      ),
      findsOneWidget,
    );
  });

  testWidgets('+ Eintrag stays above the list (P4)', (tester) async {
    await pump(tester, _customer);

    final button = find.widgetWithText(OutlinedButton, '+ Eintrag');
    expect(button, findsOneWidget);
    expect(
      tester.getTopLeft(button).dy,
      lessThan(tester.getTopLeft(find.byType(EntryRow).first).dy),
    );
  });

  testWidgets('a customer without entries keeps the plain hint', (
    tester,
  ) async {
    await pump(tester, '/customers/${TestIds.herrProbe}');

    expect(find.text('Noch keine Einträge.'), findsOneWidget);
    expect(find.byType(EntryRow), findsNothing);
    expect(find.textContaining('noch nicht abgelegt'), findsNothing);
  });

  testWidgets('a tap opens the entry and Back returns to the customer', (
    tester,
  ) async {
    await pump(tester, _customer);

    await tester.ensureVisible(_row('Kiste Geschirr'));
    await tester.pumpAndSettle();
    await tester.tap(_row('Kiste Geschirr'));
    await tester.pumpAndSettle();
    final screen = tester.widget<EntryScreen>(find.byType(EntryScreen));
    expect(screen.entryId, TestIds.kiste);
    expect(screen.customerId, TestIds.familieBeispiel);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(find.byType(EntryScreen), findsNothing);
  });

  testWidgets('the room lists its own entries; Back returns to the room', (
    tester,
  ) async {
    await pump(tester, '$_customer/rooms/${TestIds.kueche}');

    expect(find.text('Einträge in diesem Raum'), findsOneWidget);
    expect(find.byType(EntryRow), findsOneWidget);
    expect(_row('Kiste Geschirr'), findsOneWidget);
    expect(find.text('Eintrag ohne Namen'), findsNothing, reason: 'no room');
    expect(find.textContaining('noch nicht abgelegt'), findsNothing);

    await tester.tap(_row('Kiste Geschirr'));
    await tester.pumpAndSettle();
    expect(find.byType(EntryScreen), findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget);
  });

  testWidgets('a room without entries says so', (tester) async {
    await pump(tester, '$_customer/rooms/${TestIds.keller}');

    expect(find.text('Noch keine Einträge in diesem Raum.'), findsOneWidget);
    expect(find.byType(EntryRow), findsNothing);
  });

  testWidgets('the list follows a new entry and a deleted one', (tester) async {
    await pump(tester, '$_customer/rooms/${TestIds.kueche}');
    expect(find.byType(EntryRow), findsOneWidget);

    await tester.runAsync(
      () => db
          .into(db.entries)
          .insert(
            EntriesCompanion.insert(
              id: '01970000-0000-7000-8000-0000000000e9',
              workspaceId: TestIds.workspace,
              customerId: const Value<String?>(TestIds.familieBeispiel),
              title: const Value<String?>('Kiste Neu'),
              siteId: const Value<String?>(TestIds.alteWohnung),
              roomId: const Value<String?>(TestIds.kueche),
            ),
          ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EntryRow), findsNWidgets(2));
    // Not confirmed by the server yet: the newest.
    expect(
      tester.getTopLeft(_row('Kiste Neu')).dy,
      lessThan(tester.getTopLeft(_row('Kiste Geschirr')).dy),
    );

    await tester.runAsync(
      () => (db.update(db.entries)..where((e) => e.id.equals(TestIds.kiste)))
          .write(
            const EntriesCompanion(
              deletedAt: Value('2026-11-22T08:00:00.000Z'),
            ),
          ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(EntryRow), findsOneWidget);
    expect(_row('Kiste Neu'), findsOneWidget);
  });

  testWidgets('rows and screens meet the UX rules', (tester) async {
    await pump(tester, _customer);
    await expectMeetsUxRules(tester);
  });
}
