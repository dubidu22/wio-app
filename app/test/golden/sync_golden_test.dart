@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/local_writer.dart';

import '../support/pump.dart';
import '../support/test_data.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// The job list with refused changes and unsent ones (D-76, D-197, D-203;
/// plan 044 test T17), at phone and tablet size. "Nicht gesendet" itself is
/// in the screen catalogue's goldens.
void main() {
  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};
  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets(
      'job list with refused and unsent changes at $sizeName size',
      skip: _notLinux,
      (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedWithRejected(db);
        final writer = LocalWriter(db, clock: () => testNow);
        await writer.write(
          entity: 'customers',
          id: TestIds.herrProbe,
          fields: <String, Object?>{'name': 'Herr Probe-Muster'},
        );
        await writer.write(
          entity: 'rooms',
          id: TestIds.keller,
          fields: <String, Object?>{'height_cm': 230},
        );
        await pumpWioApp(tester, db: db, size: size);
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/job_list_sync_$sizeName.png'),
        );
      },
    );
  }
}
