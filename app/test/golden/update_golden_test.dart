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

/// The update notice with the server's minimum version and the job list
/// with the update hint (D-76, plan 038 test 11), at phone and tablet size.
/// The notice without a minimum is in the screen catalogue's goldens.
void main() {
  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};

  Future<void> tooOldAtStart(WidgetTester tester, Size size) async {
    final db = memoryDatabase();
    addTearDown(db.close);
    await seedTestData(db);
    await pumpWioApp(
      tester,
      db: db,
      size: size,
      api: FakeApi(<String, Object>{
        'GET /auth/me': FakeAnswer(
          426,
          apiExample('response.Problem.upgrade-required.json'),
        ),
      }),
    );
  }

  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets(
      'update notice with minimum at $sizeName size',
      skip: _notLinux,
      (tester) async {
        await tooOldAtStart(tester, size);
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/update_required_minimum_$sizeName.png'),
        );
      },
    );

    testWidgets(
      'job list with the update hint at $sizeName size',
      skip: _notLinux,
      (tester) async {
        await tooOldAtStart(tester, size);
        await tester.tap(find.text('Zurück'));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/job_list_update_hint_$sizeName.png'),
        );
      },
    );
  }
}
