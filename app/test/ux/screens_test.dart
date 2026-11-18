@Tags(<String>['ux'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import '../support/ux_guidelines.dart';
import 'screen_catalog.dart';

void main() {
  test('every lib/**/*_screen.dart file is in the screen catalogue', () {
    final screenFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .map((file) => file.path.replaceAll(r'\', '/'))
        .where((path) => path.endsWith('_screen.dart'))
        .toSet();

    expect(screenFiles, isNotEmpty);
    expect(screenCatalog.keys.toSet(), equals(screenFiles));
  });

  for (final entry in screenCatalog.entries) {
    testWidgets('${entry.key} meets the UX rules', (tester) async {
      await pumpScreen(tester, entry.value());
      await expectMeetsUxRules(tester);
    });
  }
}
