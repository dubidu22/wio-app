@Tags(<String>['ux'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Size;
import 'package:flutter_test/flutter_test.dart';

import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
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

  for (final MapEntry(key: file, value: screen) in screenCatalog.entries) {
    for (final size in <Size>[phoneSize, tabletSize]) {
      testWidgets('$file meets the UX rules at $size', (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await screen.seed(db);
        await pumpWioApp(
          tester,
          db: db,
          location: screen.location,
          size: size,
          mediaFolder: demoMediaFolder(),
        );
        await expectMeetsUxRules(tester);
      });
    }

    // Text scales with the system font size (KB ux-rules.md); at twice the
    // size nothing may overflow.
    testWidgets('$file has no overflow at text scale 2', (tester) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await screen.seed(db);
      await pumpWioApp(
        tester,
        db: db,
        location: screen.location,
        textScale: 2,
        mediaFolder: demoMediaFolder(),
      );
      expect(tester.takeException(), isNull);
      await expectMeetsUxRules(tester);
    });
  }
}
