// Session, start, sign-out and token storage (plan 035, tests 6 to 9, 11,
// 12, 14). No real network; the fake server answers from api/examples/.
import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_api/wio_api.dart';
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/auth/device_name.dart';
import 'package:wio_app/auth/session.dart';
import 'package:wio_app/auth/session_provider.dart';
import 'package:wio_app/auth/token_store_native.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/shell/providers.dart';

import '../support/fake_api.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String signedOutHint =
    'Nicht angemeldet. Neue Daten werden erst nach der Anmeldung gesendet.';

/// Local rows per table, to prove nothing is wiped (D-65, D-129).
Future<Map<String, int>> countRows(WioDatabase db) async => <String, int>{
  for (final table in <String>[
    'customers',
    'sites',
    'rooms',
    'jobs',
    'outbox',
    'sync_state',
  ])
    table:
        (await db.customSelect('SELECT COUNT(*) AS n FROM $table').getSingle())
            .read<int>('n'),
};

/// Test data plus one unsent change in the outbox.
Future<WioDatabase> seededWithOutbox() async {
  final db = memoryDatabase();
  await seedTestData(db);
  await db
      .into(db.outbox)
      .insert(
        OutboxCompanion.insert(
          changeId: '01970000-0000-7000-8000-0000000000f1',
          entity: 'customers',
          entityId: TestIds.frauMuster,
          fields: '{"name":"Frau Muster"}',
          deviceTime: '2026-11-19T09:00:00.000Z',
        ),
      );
  return db;
}

/// The example session with older names, so a refresh is visible.
Session staleSession() {
  final fresh = exampleSession();
  return Session(
    token: fresh.token,
    deviceId: fresh.deviceId,
    user: MeUser.fromJson(<String, Object?>{
      ...fresh.user.toJson()! as Map<String, Object?>,
      'display_name': 'Alter Name',
    }),
    workspace: MeWorkspace.fromJson(<String, Object?>{
      ...fresh.workspace.toJson()! as Map<String, Object?>,
      'name': 'Alter Betrieb',
    }),
    apiBase: fakeApiBase,
  );
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AuthClient (D-133)', () {
    test('adds the bearer to every request but sign-in', () async {
      final api = FakeApi();
      final session = exampleSession(token: 'wio_abc');
      final auth = buildAuthApi(fakeApiBase, api.client, () => session);
      await auth.getMe();
      await auth.signOut();
      await auth.signIn(
        body: const SignInRequest(
          email: 'inhaber@example.org',
          password: 'beispiel-passwort',
          deviceName: 'Testtelefon',
        ),
      );
      expect(
        api.to('/auth/me').single.headers['Authorization'],
        'Bearer wio_abc',
      );
      expect(
        api.to('/auth/sign-out').single.headers['Authorization'],
        'Bearer wio_abc',
      );
      expect(api.to('/auth/sign-in').single.headers['Authorization'], isNull);
    });

    test('sends no header without a token', () async {
      final api = FakeApi();
      await buildAuthApi(fakeApiBase, api.client, () => null).getMe();
      expect(api.to('/auth/me').single.headers['Authorization'], isNull);
    });

    // Review PR 37, finding 1: a token goes only to the server it came from.
    test('sends no token to a server other than the session\'s', () async {
      for (final other in <String>[
        'https://staging.example.org',
        'https://api.example.org.other.net',
        'http://api.example.org',
        'https://api.example.org:8443',
      ]) {
        final api = FakeApi();
        final session = exampleSession(token: 'wio_abc');
        await buildAuthApi(other, api.client, () => session).getMe();
        expect(
          api.to('/auth/me').single.headers['Authorization'],
          isNull,
          reason: other,
        );
      }
    });

    test('isUnderBase compares origin and path, not a string prefix', () {
      const base = 'https://example.org/api';
      expect(
        isUnderBase(Uri.parse('https://example.org/api/auth/me'), base),
        isTrue,
      );
      expect(isUnderBase(Uri.parse('https://EXAMPLE.org/api'), base), isTrue);
      expect(
        isUnderBase(Uri.parse('https://example.org/apix/auth/me'), base),
        isFalse,
      );
      expect(
        isUnderBase(Uri.parse('https://example.org/auth/me'), base),
        isFalse,
      );
      expect(
        isUnderBase(Uri.parse('https://example.org/x'), 'not a url'),
        isFalse,
      );
    });
  });

  group('start: getMe in the background (D-129)', () {
    testWidgets('200 refreshes the names', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      final store = FakeTokenStore(staleSession());
      await pumpWioApp(tester, db: db, store: store);
      expect(store.session?.workspace.name, 'Demo Umzüge');
      expect(store.session?.user.displayName, 'Inhaber Beispiel');
      await scrollTo(tester, find.text('Abmelden'));
      expect(
        find.text('Angemeldet als Inhaber Beispiel bei Demo Umzüge'),
        findsOneWidget,
      );
    });

    testWidgets('401 token_invalid signs out and keeps every local row', (
      tester,
    ) async {
      final db = await seededWithOutbox();
      addTearDown(db.close);
      final before = await countRows(db);
      final store = FakeTokenStore(exampleSession());
      final api = FakeApi(<String, Object>{
        'GET /auth/me': FakeAnswer.problem(401, 'token_invalid'),
      });
      await pumpWioApp(tester, db: db, store: store, api: api);

      expect(api.to('/auth/me').single.headers['Authorization'], isNotNull);
      expect(store.session, isNull);
      expect(find.text(signedOutHint), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Anmelden'), findsOneWidget);
      // The list stays usable: no gate (D-130).
      expect(find.text('Familie Beispiel'), findsOneWidget);
      expect(await countRows(db), before);
      expect(before['outbox'], 1);
    });

    final keep = <String, Object>{
      'no signal': noSignal,
      'maintenance': FakeAnswer.problem(503, 'maintenance'),
      'a 401 with another code': FakeAnswer.problem(401, 'something_else'),
      'a 500': FakeAnswer.problem(500, 'internal'),
    };
    for (final MapEntry(key: name, value: answer) in keep.entries) {
      testWidgets('$name keeps the session', (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedTestData(db);
        final store = FakeTokenStore(exampleSession());
        await pumpWioApp(
          tester,
          db: db,
          store: store,
          api: FakeApi(<String, Object>{'GET /auth/me': answer}),
        );
        expect(store.session, isNotNull);
        expect(store.deletes, 0);
        expect(find.text(signedOutHint), findsNothing);
      });
    }
  });

  testWidgets('a session of another server is dropped at start', (
    tester,
  ) async {
    final db = await seededWithOutbox();
    addTearDown(db.close);
    final before = await countRows(db);
    final fromStaging = Session.tryDecode(
      exampleSession().encode().replaceAll(
        fakeApiBase,
        'https://staging.example.org',
      ),
    )!;
    final store = FakeTokenStore(fromStaging);
    final api = FakeApi();
    await pumpWioApp(tester, db: db, store: store, api: api);
    expect(store.session, isNull);
    expect(store.deletes, 1);
    expect(api.requests, isEmpty);
    expect(find.text(signedOutHint), findsOneWidget);
    expect(await countRows(db), before);
  });

  group('signed out at start (D-130)', () {
    testWidgets('a fresh install opens Anmelden', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      final api = FakeApi();
      await pumpWioApp(tester, db: db, store: FakeTokenStore(), api: api);
      expect(find.widgetWithText(TextField, 'E-Mail'), findsOneWidget);
      expect(api.requests, isEmpty);
      // Zurück still reaches the (empty) job list: nothing is a gate.
      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();
      expect(find.text('Aufträge'), findsOneWidget);
      expect(find.text(signedOutHint), findsOneWidget);
    });

    testWidgets('with local data the job list shows, with the hint', (
      tester,
    ) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      await pumpWioApp(tester, db: db, store: FakeTokenStore());
      expect(find.text('Aufträge'), findsOneWidget);
      expect(find.text(signedOutHint), findsOneWidget);
      expect(find.text('Abmelden'), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Anmelden'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'E-Mail'), findsOneWidget);
    });
  });

  group('Abmelden (D-132)', () {
    testWidgets('shows Abmelden … and ignores a second tap', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      final later = Completer<FakeAnswer>();
      final store = FakeTokenStore(exampleSession());
      final api = FakeApi(<String, Object>{'POST /auth/sign-out': later});
      await pumpWioApp(tester, db: db, store: store, api: api);
      await scrollTo(tester, find.text('Abmelden'));

      await tester.tap(find.widgetWithText(OutlinedButton, 'Abmelden'));
      await tester.pump();
      expect(find.text('Abmelden …'), findsOneWidget);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Abmelden …'));
      await tester.pump();

      later.complete(const FakeAnswer(204));
      await tester.pumpAndSettle();
      expect(api.to('/auth/sign-out'), hasLength(1));
      expect(find.text('Abgemeldet.'), findsOneWidget);
      expect(store.session, isNull);
    });

    final answers = <String, Object>{
      '204': const FakeAnswer(204),
      '401': FakeAnswer.problem(401, 'token_invalid'),
      'no signal': noSignal,
    };
    for (final MapEntry(key: name, value: answer) in answers.entries) {
      testWidgets('signs out on $name and keeps the data', (tester) async {
        final db = await seededWithOutbox();
        addTearDown(db.close);
        final before = await countRows(db);
        final store = FakeTokenStore(exampleSession());
        final api = FakeApi(<String, Object>{'POST /auth/sign-out': answer});
        await pumpWioApp(tester, db: db, store: store, api: api);

        await scrollTo(tester, find.text('Abmelden'));
        await tester.tap(find.widgetWithText(OutlinedButton, 'Abmelden'));
        await tester.pumpAndSettle();

        expect(
          api.to('/auth/sign-out').single.headers['Authorization'],
          'Bearer ${exampleSession().token}',
        );
        expect(store.session, isNull);
        expect(find.text('Abgemeldet.'), findsOneWidget);
        expect(find.text('Abmelden'), findsNothing);
        expect(await countRows(db), before);
      });
    }
  });

  group('a new database deletes an old session (D-122)', () {
    test('onFirstCreate runs once, when the tables are new', () async {
      var calls = 0;
      final db = WioDatabase(
        NativeDatabase.memory(),
        onFirstCreate: () async => calls++,
      );
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get();
      await db.customSelect('SELECT 1').get();
      expect(calls, 1);
    });

    test('the session is read only after the database opened', () async {
      final store = FakeTokenStore(exampleSession());
      final db = WioDatabase(
        NativeDatabase.memory(),
        onFirstCreate: store.delete,
      );
      addTearDown(db.close);
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          tokenStoreProvider.overrideWithValue(store),
          apiBaseUrlProvider.overrideWithValue(fakeApiBase),
        ],
      );
      addTearDown(container.dispose);
      expect(await container.read(sessionProvider.future), isNull);
      expect(store.deletes, 1);
    });

    test('an existing database keeps the session', () async {
      final store = FakeTokenStore(exampleSession());
      final db = memoryDatabase();
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get();
      final container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          tokenStoreProvider.overrideWithValue(store),
          apiBaseUrlProvider.overrideWithValue(fakeApiBase),
        ],
      );
      addTearDown(container.dispose);
      expect(await container.read(sessionProvider.future), isNotNull);
    });
  });

  group('native store options (D-121)', () {
    test('Android uses the default keystore ciphers', () {
      expect(wioAndroidOptions, same(AndroidOptions.defaultOptions));
    });

    test('iOS keeps the item on this device only', () {
      expect(
        wioIosOptions.toMap()['accessibility'],
        KeychainAccessibility.first_unlock_this_device.name,
      );
    });
  });

  group('session entry (D-124)', () {
    test('round-trips and never prints the token', () {
      final session = exampleSession(token: 'wio_secret-token-value');
      final back = Session.tryDecode(session.encode());
      expect(back?.token, 'wio_secret-token-value');
      expect(back?.workspace.id, session.workspace.id);
      expect(back?.user.displayName, 'Inhaber Beispiel');
      expect(back?.apiBase, fakeApiBase);
      expect('$session', isNot(contains('secret')));
    });

    test('an unreadable entry is no session', () {
      expect(Session.tryDecode('not json'), isNull);
      expect(Session.tryDecode('{"token":1}'), isNull);
    });
  });

  group('device name (D-125)', () {
    test('Android: maker and model, without repeating the maker', () {
      expect(
        describeDevice(manufacturer: 'Xiaomi', model: '23090RA98G'),
        'Xiaomi 23090RA98G',
      );
      expect(
        describeDevice(manufacturer: 'Google', model: 'Google Pixel 8'),
        'Google Pixel 8',
      );
    });

    test('iOS: the model id only', () {
      expect(describeDevice(model: 'iPhone16,1'), 'iPhone16,1');
    });

    test('web: the browser', () {
      expect(describeDevice(browser: 'Browser firefox'), 'Browser firefox');
    });

    test('at most 100 characters, and a word when nothing is known', () {
      expect(describeDevice(model: 'x' * 150), hasLength(100));
      expect(describeDevice(), 'Gerät');
      expect(describeDevice(manufacturer: '  ', model: ''), 'Gerät');
    });
  });
}
