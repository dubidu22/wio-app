// The update notice, the job-list hint and the store links (plan 038 tests
// 5, 6, 8 and 9; D-153 to D-156). No real network; the fake server answers
// from api/examples/.
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/update/store_link.dart';
import 'package:wio_app/update/update_required_screen.dart';

import '../support/fake_api.dart';
import '../support/local_rows.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

const String title = 'Bitte die App aktualisieren';
const String minimumText = 'Nötig ist mindestens Version 2.0.0.';
const String installedText = 'Installiert: 0.1.0+1';
const String updateHint =
    'Diese App-Version ist zu alt. Neue Daten werden erst nach dem Update '
    'gesendet.';
const String signedOutHint =
    'Nicht angemeldet. Neue Daten werden erst nach der Anmeldung gesendet.';

Finder get updateButton =>
    find.widgetWithText(FilledButton, 'App aktualisieren');

FakeAnswer upgradeRequired() =>
    FakeAnswer(426, apiExample('response.Problem.upgrade-required.json'));

void main() {
  testWidgets('sign-in answering 426 opens the notice and keeps no session '
      '(test 5)', (tester) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final store = FakeTokenStore();
    final api = FakeApi(<String, Object>{
      'POST /auth/sign-in': upgradeRequired(),
    });
    await pumpWioApp(
      tester,
      db: db,
      location: '/anmelden',
      store: store,
      api: api,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'E-Mail'),
      'inhaber@example.org',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Passwort'),
      'beispiel-passwort',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pumpAndSettle();

    expect(find.byType(UpdateRequiredScreen), findsOneWidget);
    expect(find.text(title), findsOneWidget);
    expect(find.text(minimumText), findsOneWidget);
    expect(find.text(installedText), findsOneWidget);
    expect(store.session, isNull);
    // The request carried the version (D-151).
    expect(
      api.to('/auth/sign-in').single.headers['Wio-App-Version'],
      '0.1.0+1',
    );
  });

  testWidgets('getMe answering 426 at start keeps everything; Zurück shows '
      'the jobs with the update hint (test 6)', (tester) async {
    final db = await seededWithOutbox();
    addTearDown(db.close);
    final before = await countRows(db);
    final session = exampleSession();
    final store = FakeTokenStore(session);
    final api = FakeApi(<String, Object>{'GET /auth/me': upgradeRequired()});
    await pumpWioApp(tester, db: db, store: store, api: api);

    expect(find.byType(UpdateRequiredScreen), findsOneWidget);
    expect(find.text(minimumText), findsOneWidget);
    expect(store.session?.token, session.token);
    expect(store.deletes, 0);
    expect(await countRows(db), before);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();

    expect(find.byType(UpdateRequiredScreen), findsNothing);
    expect(find.text(updateHint), findsOneWidget);
    expect(find.text('Familie Beispiel'), findsOneWidget);
    expect(find.text('Abmelden'), findsOneWidget);
    // Opening a customer still works offline (not a gate, D-154).
    await tester.tap(find.text('Familie Beispiel'));
    await tester.pumpAndSettle();
    expect(find.text('Alte Wohnung'), findsOneWidget);
    expect(api.requests, hasLength(1));
  });

  testWidgets('the notice opens once, not again on the next 426', (
    tester,
  ) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await seedTestData(db);
    final api = FakeApi(<String, Object>{'GET /auth/me': upgradeRequired()});
    await pumpWioApp(tester, db: db, api: api);
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    // Abmelden still works locally; its request is answered by the client.
    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateRequiredScreen), findsNothing);
    expect(api.requests, hasLength(1));
  });

  group('App aktualisieren (test 8, D-153)', () {
    Future<List<Uri>> tapUpdate(
      WidgetTester tester, {
      required TargetPlatform platform,
      bool opens = true,
    }) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      final opened = <Uri>[];
      await pumpWioApp(
        tester,
        db: db,
        api: FakeApi(<String, Object>{'GET /auth/me': upgradeRequired()}),
        opener: (uri) async {
          opened.add(uri);
          return opens;
        },
      );
      await tester.tap(updateButton);
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('Android opens the Play page of the installed package', (
      tester,
    ) async {
      final opened = await tapUpdate(tester, platform: TargetPlatform.android);
      expect(opened, <Uri>[
        Uri.parse(
          'https://play.google.com/store/apps/details?id=org.example.wio',
        ),
      ]);
      expect(find.textContaining('Suche'), findsNothing);
    });

    testWidgets('iOS without an App Store id opens the App Store with a hint', (
      tester,
    ) async {
      final opened = await tapUpdate(tester, platform: TargetPlatform.iOS);
      expect(opened, <Uri>[Uri.parse('itms-apps://apps.apple.com/')]);
      expect(find.text('Suche im App Store nach „wio“.'), findsOneWidget);
    });

    testWidgets('when nothing opens, the address is shown', (tester) async {
      await tapUpdate(tester, platform: TargetPlatform.android, opens: false);
      expect(
        find.text(
          'Die Seite ließ sich nicht öffnen. Die Adresse ist: '
          'https://play.google.com/store/apps/details?id=org.example.wio',
        ),
        findsOneWidget,
      );
    });

    test('iOS with an App Store id opens its page', () {
      final target = updateTarget(
        web: false,
        platform: TargetPlatform.iOS,
        packageName: 'org.example.wio',
        iosAppStoreId: '1234567890',
        sourceUrl: Uri.parse('https://example.org/source'),
      );
      expect(
        (target as OpenStore).uri,
        Uri.parse('https://apps.apple.com/app/id1234567890'),
      );
      expect(target.searchHint, isNull);
    });

    test('an App Store id that is not a number is not used', () {
      final target = updateTarget(
        web: false,
        platform: TargetPlatform.iOS,
        packageName: 'org.example.wio',
        iosAppStoreId: 'id123',
        sourceUrl: Uri.parse('https://example.org/source'),
      );
      expect((target as OpenStore).searchHint, SearchHint.appStore);
    });

    test('Android without a package name opens Play with a hint', () {
      final target = updateTarget(
        web: false,
        platform: TargetPlatform.android,
        packageName: '',
        iosAppStoreId: '',
        sourceUrl: Uri.parse('https://example.org/source'),
      );
      expect((target as OpenStore).searchHint, SearchHint.play);
    });

    test('the web reloads the page', () {
      expect(
        updateTarget(
          web: true,
          platform: TargetPlatform.android,
          packageName: '',
          iosAppStoreId: '',
          sourceUrl: Uri.parse('https://example.org/source'),
        ),
        isA<ReloadPage>(),
      );
    });

    test('desktop builds open the source code address', () {
      final source = Uri.parse('https://example.org/source');
      final target = updateTarget(
        web: false,
        platform: TargetPlatform.linux,
        packageName: '',
        iosAppStoreId: '',
        sourceUrl: source,
      );
      expect((target as OpenStore).uri, source);
    });
  });

  testWidgets('signed out and too old: one hint; Anmelden opens the notice '
      'and sends nothing (test 9)', (tester) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await seedTestData(db);
    // Signed out, the first request is sign-in itself; its 426 turns the
    // state on.
    final api = FakeApi(<String, Object>{
      'POST /auth/sign-in': upgradeRequired(),
    });
    await pumpWioApp(tester, db: db, store: FakeTokenStore(), api: api);
    expect(find.text(signedOutHint), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'E-Mail'),
      'inhaber@example.org',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Passwort'),
      'beispiel-passwort',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateRequiredScreen), findsOneWidget);
    expect(api.requests, hasLength(1));

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text(updateHint), findsOneWidget);
    expect(find.text(signedOutHint), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Anmelden'), findsNothing);

    // Anmelden on the sign-in screen opens the notice without a request.
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/anmelden');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
    await tester.pumpAndSettle();
    expect(find.byType(UpdateRequiredScreen), findsOneWidget);
    expect(api.requests, hasLength(1));
  });

  for (final textScale in <double>[1, 2]) {
    testWidgets('notice and hint meet the UX rules at text scale $textScale '
        '(test 10)', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      await pumpWioApp(
        tester,
        db: db,
        textScale: textScale,
        api: FakeApi(<String, Object>{'GET /auth/me': upgradeRequired()}),
      );
      expect(find.text(minimumText), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectMeetsUxRules(tester);
      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();
      expect(find.text(updateHint), findsOneWidget);
      expect(tester.takeException(), isNull);
      await expectMeetsUxRules(tester);
    });
  }
}
