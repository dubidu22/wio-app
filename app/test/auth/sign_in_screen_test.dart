// The sign-in screen against the fake server (plan 035, tests 1 to 5, 10
// and 15). No real network: every answer comes from api/examples/ or a
// scripted problem+json.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/auth/sign_in_controller.dart';
import 'package:wio_app/auth/sign_in_screen.dart';
import 'package:wio_app/data/database.dart';

import '../support/fake_api.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../support/ux_guidelines.dart';

const String email = 'inhaber@example.org';
const String password = 'beispiel-passwort';

Finder get emailField => find.widgetWithText(TextField, 'E-Mail');
Finder get passwordField => find.widgetWithText(TextField, 'Passwort');
Finder get signInButton => find.widgetWithText(FilledButton, 'Anmelden');

/// Opens "Anmelden", signed out, over [db] (empty when not given).
Future<(FakeApi, FakeTokenStore, WioDatabase)> openSignIn(
  WidgetTester tester, {
  FakeApi? api,
  WioDatabase? db,
  DateTime Function()? clock,
  Size size = phoneSize,
}) async {
  final database = db ?? memoryDatabase();
  if (db == null) addTearDown(database.close);
  final fake = api ?? FakeApi();
  final store = FakeTokenStore();
  await pumpWioApp(
    tester,
    db: database,
    location: '/anmelden',
    store: store,
    api: fake,
    clock: clock,
    size: size,
  );
  return (fake, store, database);
}

SignInController controllerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(SignInScreen)))
        .read(signInControllerProvider.notifier);

Future<void> fillAndSubmit(WidgetTester tester) async {
  await tester.enterText(emailField, ' $email ');
  await tester.enterText(passwordField, password);
  await tester.tap(signInButton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('signs in, keeps the session and opens the job list', (
    tester,
  ) async {
    final (api, store, _) = await openSignIn(tester);
    expect(find.text('Dieses Gerät: Testtelefon'), findsOneWidget);

    await fillAndSubmit(tester);

    expect(api.signInBodies, <Map<String, Object?>>[
      <String, Object?>{
        'email': email,
        'password': password,
        'device_name': 'Testtelefon',
      },
    ]);
    // Sign-in is the one request without a token (D-133).
    expect(api.to('/auth/sign-in').single.headers['Authorization'], isNull);
    final stored = apiExample('response.SignInResult.basic.json');
    expect(store.session?.token, stored['token']);
    expect(store.session?.workspace.name, 'Demo Umzüge');
    expect(store.session?.apiBase, fakeApiBase);
    expect(find.text('Aufträge'), findsOneWidget);
    expect(find.text('Nicht angemeldet.', findRichText: true), findsNothing);
  });

  group('409: one button per workspace (D-127)', () {
    FakeApi choiceThenSuccess() => FakeApi(<String, Object>{
      'POST /auth/sign-in': <Object>[
        FakeAnswer(409, apiExample('response.Problem.workspace-choice.json')),
        FakeAnswer(200, apiExample('response.SignInResult.basic.json')),
      ],
    });

    testWidgets('a tap signs in again with that workspace', (tester) async {
      final (api, store, _) = await openSignIn(
        tester,
        api: choiceThenSuccess(),
      );
      await fillAndSubmit(tester);

      expect(find.text('Für welchen Betrieb?'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Demo Umzüge'), findsOne);
      expect(find.widgetWithText(OutlinedButton, 'Demo privat'), findsOne);
      // The workspace step has no Anmelden button (UX rule 3: one main
      // action, the workspace buttons).
      expect(signInButton, findsNothing);
      await expectMeetsUxRules(tester);

      await tester.tap(find.widgetWithText(OutlinedButton, 'Demo privat'));
      await tester.pumpAndSettle();

      final bodies = api.signInBodies;
      expect(bodies, hasLength(2));
      expect(bodies.first.containsKey('workspace_id'), isFalse);
      expect(
        bodies.last['workspace_id'],
        '01990000-0000-7000-8000-000100000002',
      );
      expect(bodies.last['password'], password);
      expect(store.session, isNotNull);
      expect(find.text('Aufträge'), findsOneWidget);
    });

    testWidgets('a workspace without a name gets a word', (tester) async {
      final choice = apiExample('response.Problem.workspace-choice.json');
      ((choice['workspaces']! as List).last as Map)['name'] = null;
      await openSignIn(
        tester,
        api: FakeApi(<String, Object>{
          'POST /auth/sign-in': FakeAnswer(409, choice),
        }),
      );
      await fillAndSubmit(tester);
      expect(
        find.widgetWithText(OutlinedButton, 'Betrieb ohne Namen'),
        findsOne,
      );
    });

    testWidgets('Zurück returns to the fields and clears the password', (
      tester,
    ) async {
      await openSignIn(tester, api: choiceThenSuccess());
      await fillAndSubmit(tester);
      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();

      expect(find.text('Für welchen Betrieb?'), findsNothing);
      expect(tester.widget<TextField>(emailField).controller!.text, ' $email ');
      expect(tester.widget<TextField>(passwordField).controller!.text, '');
      // Still on the sign-in screen, not the job list.
      expect(signInButton, findsOneWidget);
    });
  });

  group('a German message per answer (D-128)', () {
    final cases = <String, (Object, String)>{
      'invalid_credentials': (
        FakeAnswer.problem(401, 'invalid_credentials'),
        'E-Mail oder Passwort stimmt nicht.',
      ),
      'maintenance': (
        FakeAnswer.problem(503, 'maintenance', headers: {'retry-after': '60'}),
        'Der Server wird gerade aktualisiert. Bitte versuch es in ein paar '
            'Minuten noch einmal.',
      ),
      'invalid_request': (
        FakeAnswer.problem(400, 'invalid_request'),
        'Bitte prüfe die E-Mail-Adresse.',
      ),
      'an unknown code': (
        FakeAnswer.problem(418, 'some_future_code'),
        'Der Server hat einen Fehler gemeldet. Bitte versuch es später noch '
            'einmal.',
      ),
      'a 500 that is not JSON': (
        const FakeAnswer(500, '<html>Internal Server Error</html>'),
        'Der Server hat einen Fehler gemeldet. Bitte versuch es später noch '
            'einmal.',
      ),
      'a 409 without workspaces': (
        FakeAnswer.problem(409, 'workspace_choice_required'),
        'Der Server hat einen Fehler gemeldet. Bitte versuch es später noch '
            'einmal.',
      ),
      'no signal': (
        noSignal,
        'Keine Verbindung zum Server. Prüfe das Netz und tippe noch einmal '
            'auf Anmelden.',
      ),
    };
    for (final MapEntry(key: name, value: (answer, text)) in cases.entries) {
      testWidgets(name, (tester) async {
        final (_, store, _) = await openSignIn(
          tester,
          api: FakeApi(<String, Object>{'POST /auth/sign-in': answer}),
        );
        await fillAndSubmit(tester);
        expect(find.text(text), findsOneWidget);
        expect(store.session, isNull);
        expect(signInButton, findsOneWidget);
      });
    }

    testWidgets('a server that does not answer within 15 s', (tester) async {
      final never = Completer<FakeAnswer>();
      await openSignIn(
        tester,
        api: FakeApi(<String, Object>{'POST /auth/sign-in': never}),
      );
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
      await tester.tap(signInButton);
      await tester.pump();
      expect(find.text('Anmelden …'), findsOneWidget);
      await tester.pump(const Duration(seconds: 16));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'Keine Verbindung zum Server. Prüfe das Netz und tippe noch einmal '
          'auf Anmelden.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('a second tap while sending sends nothing', (tester) async {
      final later = Completer<FakeAnswer>();
      final (api, _, _) = await openSignIn(
        tester,
        api: FakeApi(<String, Object>{'POST /auth/sign-in': later}),
      );
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
      await tester.tap(signInButton);
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Anmelden …'));
      await tester.pump();
      expect(api.to('/auth/sign-in'), hasLength(1));
      later.complete(FakeAnswer.problem(401, 'invalid_credentials'));
      await tester.pumpAndSettle();
    });
  });

  group('429: the wait from Retry-After (D-128)', () {
    testWidgets('counts down, and no request goes out before it ends', (
      tester,
    ) async {
      var now = testNow;
      final (api, _, _) = await openSignIn(
        tester,
        clock: () => now,
        api: FakeApi(<String, Object>{
          'POST /auth/sign-in': <Object>[
            FakeAnswer.problem(
              429,
              'too_many_attempts',
              headers: {'retry-after': '600'},
            ),
            FakeAnswer.problem(401, 'invalid_credentials'),
          ],
        }),
      );
      await fillAndSubmit(tester);
      expect(
        find.text('Zu viele Versuche. Bitte warte noch 10 Minuten.'),
        findsOneWidget,
      );

      now = now.add(const Duration(minutes: 5, seconds: 30));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Zu viele Versuche. Bitte warte noch 5 Minuten.'),
        findsOneWidget,
      );

      await tester.tap(signInButton);
      await tester.pumpAndSettle();
      expect(api.to('/auth/sign-in'), hasLength(1));
      expect(
        find.text('Zu viele Versuche. Bitte warte noch 5 Minuten.'),
        findsOneWidget,
      );

      now = now.add(const Duration(minutes: 4));
      await tester.pump(const Duration(seconds: 1));
      expect(
        find.text('Zu viele Versuche. Bitte warte noch 1 Minute.'),
        findsOneWidget,
      );

      now = now.add(const Duration(minutes: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Zu viele Versuche'), findsNothing);

      await tester.tap(signInButton);
      await tester.pumpAndSettle();
      expect(api.to('/auth/sign-in'), hasLength(2));
      expect(find.text('E-Mail oder Passwort stimmt nicht.'), findsOneWidget);
    });

    testWidgets('without Retry-After it waits the server window, 15 min', (
      tester,
    ) async {
      await openSignIn(
        tester,
        api: FakeApi(<String, Object>{
          'POST /auth/sign-in': FakeAnswer.problem(429, 'too_many_attempts'),
        }),
      );
      await fillAndSubmit(tester);
      expect(
        find.text('Zu viele Versuche. Bitte warte noch 15 Minuten.'),
        findsOneWidget,
      );
    });

    testWidgets('a Retry-After the client cannot read waits 15 min too', (
      tester,
    ) async {
      await openSignIn(
        tester,
        api: FakeApi(<String, Object>{
          'POST /auth/sign-in': FakeAnswer.problem(
            429,
            'too_many_attempts',
            headers: {'retry-after': 'Wed, 18 Nov 2026 20:00:00 GMT'},
          ),
        }),
      );
      await fillAndSubmit(tester);
      expect(
        find.text('Zu viele Versuche. Bitte warte noch 15 Minuten.'),
        findsOneWidget,
      );
    });
  });

  testWidgets('empty fields: a hint, nothing sent, button never disabled', (
    tester,
  ) async {
    final (api, _, _) = await openSignIn(tester);
    expect(tester.widget<FilledButton>(signInButton).onPressed, isNotNull);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Bitte E-Mail und Passwort eingeben.'), findsOneWidget);

    await tester.enterText(emailField, email);
    await tester.tap(signInButton);
    await tester.pumpAndSettle();
    expect(find.text('Bitte E-Mail und Passwort eingeben.'), findsOneWidget);
    expect(api.requests, isEmpty);
  });

  testWidgets('Passwort zeigen shows and hides the password', (tester) async {
    await openSignIn(tester);
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
    await tester.tap(find.text('Passwort zeigen'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(passwordField).obscureText, isFalse);
    await tester.tap(find.text('Passwort verbergen'));
    await tester.pumpAndSettle();
    expect(tester.widget<TextField>(passwordField).obscureText, isTrue);
  });

  group('another workspace on this device (D-131)', () {
    testWidgets('revokes the new token and keeps nothing', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      final (api, store, _) = await openSignIn(tester, db: db);
      await fillAndSubmit(tester);

      expect(
        find.text(
          'Auf diesem Gerät liegen Daten eines anderen Betriebs. Melde dich '
          'mit diesem Betrieb an.',
        ),
        findsOneWidget,
      );
      expect(store.session, isNull);
      final token = apiExample('response.SignInResult.basic.json')['token'];
      expect(
        api.to('/auth/sign-out').single.headers['Authorization'],
        'Bearer $token',
      );
    });

    testWidgets('revokes it even when the screen was left meanwhile', (
      tester,
    ) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      final later = Completer<FakeAnswer>();
      final (api, store, _) = await openSignIn(
        tester,
        db: db,
        api: FakeApi(<String, Object>{'POST /auth/sign-in': later}),
      );
      await tester.enterText(emailField, email);
      await tester.enterText(passwordField, password);
      await tester.tap(signInButton);
      await tester.pump();
      await tester.tap(find.text('Zurück'));
      await tester.pumpAndSettle();
      expect(find.text('Aufträge'), findsOneWidget);

      later.complete(
        FakeAnswer(200, apiExample('response.SignInResult.basic.json')),
      );
      await tester.pumpAndSettle();

      expect(api.to('/auth/sign-out'), hasLength(1));
      expect(store.session, isNull);
    });
  });

  testWidgets('a session kept when the screen was left during sign-in', (
    tester,
  ) async {
    final later = Completer<FakeAnswer>();
    final (_, store, _) = await openSignIn(
      tester,
      api: FakeApi(<String, Object>{'POST /auth/sign-in': later}),
    );
    await tester.enterText(emailField, email);
    await tester.enterText(passwordField, password);
    await tester.tap(signInButton);
    await tester.pump();
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    later.complete(
      FakeAnswer(200, apiExample('response.SignInResult.basic.json')),
    );
    await tester.pumpAndSettle();
    expect(store.session, isNotNull);
  });

  // Review PR 37, finding 4: the password is kept only for the workspace
  // step (D-127).
  group('the controller forgets the password', () {
    final answers = <String, Object>{
      '401': FakeAnswer.problem(401, 'invalid_credentials'),
      '429': FakeAnswer.problem(429, 'too_many_attempts'),
      '503': FakeAnswer.problem(503, 'maintenance'),
      '426 until #38 adds the update notice': FakeAnswer.problem(
        426,
        'upgrade_required',
      ),
      'no signal': noSignal,
    };
    for (final MapEntry(key: name, value: answer) in answers.entries) {
      testWidgets('after $name', (tester) async {
        await openSignIn(
          tester,
          api: FakeApi(<String, Object>{'POST /auth/sign-in': answer}),
        );
        await fillAndSubmit(tester);
        expect(controllerOf(tester).holdsPassword, isFalse);
      });
    }

    testWidgets('but keeps it for the 409 workspace step', (tester) async {
      await openSignIn(
        tester,
        api: FakeApi(<String, Object>{
          'POST /auth/sign-in': FakeAnswer(
            409,
            apiExample('response.Problem.workspace-choice.json'),
          ),
        }),
      );
      await fillAndSubmit(tester);
      expect(controllerOf(tester).holdsPassword, isTrue);
    });

    testWidgets('a failure in the workspace step returns to the fields', (
      tester,
    ) async {
      await openSignIn(
        tester,
        api: FakeApi(<String, Object>{
          'POST /auth/sign-in': <Object>[
            FakeAnswer(
              409,
              apiExample('response.Problem.workspace-choice.json'),
            ),
            noSignal,
          ],
        }),
      );
      await fillAndSubmit(tester);
      await tester.tap(find.widgetWithText(OutlinedButton, 'Demo privat'));
      await tester.pumpAndSettle();
      expect(controllerOf(tester).holdsPassword, isFalse);
      expect(find.text('Für welchen Betrieb?'), findsNothing);
      expect(signInButton, findsOneWidget);
    });
  });

  // Review PR 37, finding 5: signing in again revokes the old token.
  testWidgets('signing in while signed in revokes the old token', (
    tester,
  ) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final store = FakeTokenStore(exampleSession(token: 'wio_old-token'));
    final api = FakeApi();
    await pumpWioApp(
      tester,
      db: db,
      location: '/anmelden',
      store: store,
      api: api,
    );
    await fillAndSubmit(tester);

    final newToken = apiExample('response.SignInResult.basic.json')['token'];
    expect(store.session?.token, newToken);
    expect(
      api.to('/auth/sign-out').single.headers['Authorization'],
      'Bearer wio_old-token',
    );
  });

  group('UX rules in every state (rules 1 and 3)', () {
    for (final size in <Size>[phoneSize, tabletSize]) {
      testWidgets('message state at $size', (tester) async {
        await openSignIn(
          tester,
          size: size,
          api: FakeApi(<String, Object>{
            'POST /auth/sign-in': FakeAnswer.problem(
              401,
              'invalid_credentials',
            ),
          }),
        );
        await fillAndSubmit(tester);
        await expectMeetsUxRules(tester);
      });
    }
  });
}
