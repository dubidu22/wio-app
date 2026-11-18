@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fake_api.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// The sign-in screen's other states and the signed-out job list (D-76,
/// plan 035 test 16), at phone and tablet size. The empty sign-in screen is
/// in the screen catalogue's goldens.
void main() {
  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};

  Future<void> signInWith(WidgetTester tester, Object answer, Size size) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await pumpWioApp(
      tester,
      db: db,
      location: '/anmelden',
      size: size,
      store: FakeTokenStore(),
      api: FakeApi(<String, Object>{'POST /auth/sign-in': answer}),
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
  }

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets(
      'sign-in with wrong password at $sizeName size',
      skip: _notLinux,
      (tester) async {
        await signInWith(
          tester,
          FakeAnswer.problem(401, 'invalid_credentials'),
          size,
        );
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/sign_in_screen_error_$sizeName.png'),
        );
      },
    );

    testWidgets('sign-in workspace choice at $sizeName size', skip: _notLinux, (
      tester,
    ) async {
      await signInWith(
        tester,
        FakeAnswer(409, apiExample('response.Problem.workspace-choice.json')),
        size,
      );
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/sign_in_screen_workspaces_$sizeName.png'),
      );
    });

    testWidgets('job list signed out at $sizeName size', skip: _notLinux, (
      tester,
    ) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedTestData(db);
      await pumpWioApp(tester, db: db, size: size, store: FakeTokenStore());
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/job_list_screen_signed_out_$sizeName.png'),
      );
    });
  }
}
