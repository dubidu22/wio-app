// Adding, changing and deleting customers, sites, rooms and jobs on the
// phone (plan 106, P1..P9).
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_api/wio_api.dart';
import 'package:wio_app/auth/session.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/customers/job_screen.dart';
import 'package:wio_app/customers/name_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/jobs/job_list_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';

import '../support/fake_api.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';

Finder _button(String text) => _buttons(text).first;

Finder _buttons(String text) => find.byWidgetPredicate(
  (w) =>
      (w is OutlinedButton || w is FilledButton) &&
      find
          .descendant(of: find.byWidget(w), matching: find.text(text))
          .evaluate()
          .isNotEmpty,
  description: 'button "$text"',
);

void main() {
  late WioDatabase db;

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  Future<T> read<T>(WidgetTester tester, Future<T> Function() query) async =>
      (await tester.runAsync(query)) as T;

  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    final scrollable = find.byType(Scrollable).first;
    for (var i = 0; i < 40 && finder.evaluate().isEmpty; i++) {
      await tester.drag(scrollable, const Offset(0, -200));
      await tester.pump();
    }
    await tester.ensureVisible(finder.first);
    await tester.pumpAndSettle();
  }

  Future<void> tapButton(WidgetTester tester, String text) async {
    await scrollTo(tester, _buttons(text));
    await tester.tap(_buttons(text).first);
    await tester.pumpAndSettle();
  }

  Future<void> typeName(WidgetTester tester, String name) async {
    await tester.enterText(find.byType(TextField), name);
    await tester.pump();
  }

  Future<List<OutboxData>> outbox(WidgetTester tester) =>
      read(tester, () => db.select(db.outbox).get());

  Future<void> pump(WidgetTester tester, [String location = '/']) =>
      pumpWioApp(tester, db: db, location: location);

  group('from a workspace without customers', () {
    testWidgets('a customer with one site and two rooms, no typing needed '
        'for the second room', (tester) async {
      await pump(tester);
      expect(find.text('Heute keine Aufträge.'), findsOneWidget);

      await tapButton(tester, '+ Kunde');
      expect(find.byType(NameScreen), findsOneWidget);
      await typeName(tester, 'Familie Neu');
      await tapButton(tester, 'Anlegen');

      // The new customer's screen opens; its job today is already there.
      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Familie Neu'), findsOneWidget);
      expect(find.text('Noch keine Orte.'), findsOneWidget);

      await tapButton(tester, '+ Ort');
      await typeName(tester, 'Neue Wohnung');
      await tapButton(tester, 'Anlegen');
      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Neue Wohnung', skipOffstage: false), findsOneWidget);

      await tapButton(tester, '+ Raum');
      await typeName(tester, 'Küche');
      await tapButton(tester, 'Anlegen');
      await tapButton(tester, '+ Raum');
      // The second room has no name at all (UX rule 4).
      await tapButton(tester, 'Anlegen');
      expect(find.text('Küche', skipOffstage: false), findsOneWidget);
      expect(find.text('Raum ohne Namen', skipOffstage: false), findsOneWidget);

      final customers = await read(tester, () => db.select(db.customers).get());
      final sites = await read(tester, () => db.select(db.sites).get());
      final rooms = await read(tester, () => db.select(db.rooms).get());
      final jobs = await read(tester, () => db.select(db.jobs).get());
      expect(customers.single.name, 'Familie Neu');
      expect(sites.single.name, 'Neue Wohnung');
      expect(sites.single.customerId, customers.single.id);
      expect(
        rooms.map((r) => r.name),
        unorderedEquals(<String?>['Küche', null]),
      );
      expect(rooms.map((r) => r.siteId), everyElement(sites.single.id));
      expect(rooms.map((r) => r.customerId), everyElement(customers.single.id));
      expect(jobs.single.date, '2026-11-19');
      expect((await outbox(tester)).map((c) => c.entity), <String>[
        'customers',
        'jobs',
        'sites',
        'rooms',
        'rooms',
      ]);

      // Back on Aufträge the customer stands under "Heute".
      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();
      expect(find.byType(JobListScreen), findsOneWidget);
      expect(find.text('Familie Neu'), findsOneWidget);
      expect(find.text('Heute keine Aufträge.'), findsNothing);
    });

    testWidgets('an empty name gives the customer without a name', (
      tester,
    ) async {
      await pump(tester);
      await tapButton(tester, '+ Kunde');
      await tapButton(tester, 'Anlegen');

      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Kunde ohne Namen'), findsOneWidget);
      final changes = await outbox(tester);
      expect(
        (jsonDecode(changes.first.fields) as Map<String, Object?>).keys,
        isNot(contains('name')),
      );
    });

    testWidgets('a second tap on Anlegen creates one customer', (tester) async {
      await pump(tester);
      await tapButton(tester, '+ Kunde');
      await typeName(tester, 'Einmal');
      await tester.tap(_button('Anlegen'));
      await tester.tap(_button('Anlegen'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(
        await read(tester, () => db.select(db.customers).get()),
        hasLength(1),
      );
    });

    testWidgets('Zurück saves nothing', (tester) async {
      await pump(tester);
      await tapButton(tester, '+ Kunde');
      await typeName(tester, 'Nie gespeichert');
      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();

      expect(find.byType(JobListScreen), findsOneWidget);
      expect(await read(tester, () => db.select(db.customers).get()), isEmpty);
    });
  });

  group('change and delete', () {
    setUp(() async => seedTestData(db));

    testWidgets('Ändern renames the customer and returns', (tester) async {
      await pump(tester, _customer);
      await tapButton(tester, 'Kunde ändern');
      expect(find.byType(NameScreen), findsOneWidget);
      // The field starts with the name.
      expect(
        find.widgetWithText(TextField, 'Familie Beispiel'),
        findsOneWidget,
      );

      await typeName(tester, 'Familie Neu');
      await tapButton(tester, 'Ändern');

      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Familie Neu'), findsOneWidget);
      final change = (await outbox(tester)).single;
      expect(change.entity, 'customers');
      expect(jsonDecode(change.fields), <String, Object?>{
        'name': 'Familie Neu',
      });
    });

    testWidgets('a site is renamed from the customer screen', (tester) async {
      await pump(tester, _customer);
      await tapButton(tester, 'Ort ändern');
      await typeName(tester, 'Alte Wohnung neu');
      await tapButton(tester, 'Ändern');

      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(
        find.text('Alte Wohnung neu', skipOffstage: false),
        findsOneWidget,
      );
      expect((await outbox(tester)).single.entity, 'sites');
    });

    testWidgets('a room is renamed from its screen', (tester) async {
      await pump(tester, '$_customer/rooms/${TestIds.kueche}');
      await tapButton(tester, 'Raum ändern');
      await typeName(tester, 'Küche neu');
      await tapButton(tester, 'Ändern');

      expect(find.byType(RoomScreen), findsOneWidget);
      expect(find.text('Küche neu'), findsOneWidget);
      expect((await outbox(tester)).single.entity, 'rooms');
    });

    testWidgets('Löschen deletes at once, Rückgängig brings it back', (
      tester,
    ) async {
      await pump(tester, _customer);
      await tapButton(tester, 'Kunde ändern');
      await tapButton(tester, 'Löschen');

      expect(find.byType(JobListScreen), findsOneWidget);
      expect(find.text('Kunde gelöscht.'), findsOneWidget);
      var row = await read(
        tester,
        () => (db.select(
          db.customers,
        )..where((c) => c.id.equals(TestIds.familieBeispiel))).getSingle(),
      );
      expect(row.deletedAt, isNotNull);

      await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
      await tester.pumpAndSettle();
      row = await read(
        tester,
        () => (db.select(
          db.customers,
        )..where((c) => c.id.equals(TestIds.familieBeispiel))).getSingle(),
      );
      expect(row.deletedAt, isNull);
    });

    testWidgets('the note goes by itself after 8 seconds', (tester) async {
      await pump(tester, _customer);
      await tapButton(tester, 'Kunde ändern');
      await tapButton(tester, 'Löschen');
      expect(find.text('Kunde gelöscht.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 9));
      await tester.pumpAndSettle();
      expect(find.text('Kunde gelöscht.'), findsNothing);
    });

    testWidgets('a deleted site is gone from the customer screen, '
        'Rückgängig restores it with its rooms', (tester) async {
      await pump(tester, _customer);
      expect(find.text('Küche', skipOffstage: false), findsOneWidget);
      await tapButton(tester, 'Ort ändern');
      await tapButton(tester, 'Löschen');

      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Ort gelöscht.'), findsOneWidget);
      expect(find.text('Küche', skipOffstage: false), findsNothing);

      await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
      await tester.pumpAndSettle();
      expect(find.text('Küche', skipOffstage: false), findsOneWidget);
    });

    testWidgets('a record that is gone says so', (tester) async {
      await pump(tester, '$_customer/ort/00000000-0000-7000-8000-0000000fffff');
      expect(find.text('Das gibt es nicht mehr.'), findsOneWidget);
      expect(find.text('Anlegen'), findsNothing);
      expect(find.text('Ändern'), findsNothing);
    });
  });

  group('jobs', () {
    setUp(() async => seedTestData(db));

    testWidgets('+ Auftrag preselects today and the calendar changes it', (
      tester,
    ) async {
      await pump(tester, _customer);
      expect(find.text('Noch keine Aufträge.'), findsNothing);

      await tapButton(tester, '+ Auftrag');
      expect(find.byType(JobScreen), findsOneWidget);
      expect(find.text('Datum: Do., 19. Nov. 2026'), findsOneWidget);

      await tester.tap(_button('Datum: Do., 19. Nov. 2026'));
      await tester.pumpAndSettle();
      // Calendar only: no text field to type a date into.
      expect(find.byType(TextField), findsNothing);
      await tester.tap(find.text('27'));
      await tester.pump();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.text('Datum: Fr., 27. Nov. 2026'), findsOneWidget);

      await tapButton(tester, 'Anlegen');
      expect(find.byType(CustomerScreen), findsOneWidget);
      final jobs = await read(
        tester,
        () => (db.select(
          db.jobs,
        )..where((j) => j.customerId.equals(TestIds.familieBeispiel))).get(),
      );
      expect(jobs.map((j) => j.date), contains('2026-11-27'));
      expect((await outbox(tester)).single.entity, 'jobs');

      // The customer's section lists it, the job list shows it under Kommend.
      await scrollTo(tester, find.text('Fr., 27. Nov.'));
      expect(find.text('Fr., 27. Nov.'), findsOneWidget);
    });

    testWidgets('a job opens to change its date and to delete it', (
      tester,
    ) async {
      await pump(tester, _customer);
      await scrollTo(tester, find.text('Do., 19. Nov.'));
      await tester.tap(find.text('Do., 19. Nov.'));
      await tester.pumpAndSettle();
      expect(find.text('Auftrag ändern'), findsOneWidget);

      await tapButton(tester, 'Löschen');
      expect(find.byType(CustomerScreen), findsOneWidget);
      expect(find.text('Auftrag gelöscht.'), findsOneWidget);
      expect(
        find.text('Noch keine Aufträge.', skipOffstage: false),
        findsOneWidget,
      );
    });
  });

  group('owner only (P2)', () {
    setUp(() async => seedTestData(db));

    // getMe answers the role too, so the session follows it (D-129).
    final me = apiExample('response.Me.basic.json');
    final helperMe = <String, Object?>{
      ...me,
      'user': <String, Object?>{
        ...(me['user']! as Map<String, Object?>),
        'role': 'helper',
      },
    };
    final helper = Session(
      token: 'wio_helper',
      deviceId: exampleSession().deviceId,
      user: const MeUser(
        id: '01990000-0000-7000-8000-000200000009',
        role: MeUserRoleModel.helper,
        displayName: 'Helferin',
      ),
      workspace: exampleSession().workspace,
      apiBase: fakeApiBase,
    );

    for (final (name, signedIn) in <(String, bool)>[
      ('signed out', false),
      ('as a helper', true),
    ]) {
      Future<void> pumpAs(WidgetTester tester, String location) => pumpWioApp(
        tester,
        db: db,
        location: location,
        store: signedIn ? FakeTokenStore(helper) : FakeTokenStore(),
        api: FakeApi(<String, Object>{
          'GET /auth/me': FakeAnswer(200, helperMe),
        }),
      );

      testWidgets('$name: no add or change buttons', (tester) async {
        await pumpAs(tester, '/');
        expect(find.text('+ Kunde'), findsNothing);
        await pumpAs(tester, _customer);
        expect(find.text('Kunde ändern'), findsNothing);
        expect(find.text('+ Ort', skipOffstage: false), findsNothing);
        expect(find.text('+ Raum', skipOffstage: false), findsNothing);
        expect(find.text('+ Auftrag', skipOffstage: false), findsNothing);
        expect(find.text('Ort ändern', skipOffstage: false), findsNothing);
        await pumpAs(tester, '$_customer/rooms/${TestIds.kueche}');
        expect(find.text('Raum ändern'), findsNothing);
      });

      testWidgets('$name: a link to an add screen says it is for the owner', (
        tester,
      ) async {
        await pumpAs(tester, '/kunde/neu');
        expect(find.text('Das kann nur der Inhaber.'), findsOneWidget);
        expect(find.text('Anlegen'), findsNothing);
        await pumpAs(tester, '$_customer/auftrag/neu');
        expect(find.text('Das kann nur der Inhaber.'), findsOneWidget);
      });
    }
  });

  testWidgets('every add and change button is a labelled 56 px target', (
    tester,
  ) async {
    await seedTestData(db);
    await pump(tester, _customer);
    await expectMeetsUxRules(tester);
  });
}
