@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Scrollable, Size, WidgetsApp;
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// The sections Labels and Eigenschaften of the entry screen (plan 104),
/// scrolled into view, with chosen and not chosen chips. Run with `TZ=UTC`
/// like the other goldens.
void main() {
  setUpAll(() {
    if (!_notLinux && DateTime.now().timeZoneOffset != Duration.zero) {
      fail('Run goldens with TZ=UTC (TZ=UTC flutter test --tags golden).');
    }
  });

  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};
  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets('entry_vocabulary at $sizeName size', skip: _notLinux, (
      tester,
    ) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedWithVocabulary(db);
      await pumpWioApp(
        tester,
        db: db,
        location:
            '/customers/${TestIds.familieBeispiel}/entries/${TestIds.kiste}',
        size: size,
      );
      await tester.scrollUntilVisible(
        find.text('Neue Eigenschaft'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      // Back up until the heading Labels is in view: both sections show.
      await tester.scrollUntilVisible(
        find.text('Labels'),
        -50,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/entry_vocabulary_$sizeName.png'),
      );
    });
  }
}
