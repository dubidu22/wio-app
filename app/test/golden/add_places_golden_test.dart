@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Size, WidgetsApp;
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// The screens of plan 106 that the catalogue does not show: a new
/// customer (empty field, no **Löschen**), a changed job (**Löschen**) and
/// Aufträge with **+ Kunde** over an empty workspace. Run with `TZ=UTC`.
void main() {
  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};
  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    for (final (name, location, seeded) in <(String, String, bool)>[
      ('name_screen_new', '/kunde/neu', false),
      (
        'job_screen_change',
        '/customers/${TestIds.familieBeispiel}/auftrag/'
            '01970000-0000-7000-8000-0000000000d1',
        true,
      ),
      ('job_list_screen_empty', '/', false),
    ]) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        if (seeded) await seedTestData(db);
        await pumpWioApp(tester, db: db, location: location, size: size);
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
      });
    }
  }
}
