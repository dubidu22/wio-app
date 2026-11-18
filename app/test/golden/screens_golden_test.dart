@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Size, WidgetsApp;
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import '../support/test_data.dart';
import '../ux/screen_catalog.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// Every screen of the catalogue at phone and tablet size (D-76), with the
/// invented test data and the fixed clock of pumpWioApp.
void main() {
  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};
  for (final MapEntry(key: file, value: screen) in screenCatalog.entries) {
    final name = file.split('/').last.replaceAll('.dart', '');
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await screen.seed(db);
        await pumpWioApp(tester, db: db, location: screen.location, size: size);
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
      });
    }
  }
}
