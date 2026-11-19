@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Size, WidgetsApp;
import 'package:flutter_test/flutter_test.dart';

import 'package:wio_app/camera/capture_camera.dart';

import '../support/fake_camera.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';
import '../ux/screen_catalog.dart';

/// Goldens are rendered on Linux only, where CI renders them (plan 002).
final bool _notLinux = !Platform.isLinux;

/// Every screen of the catalogue at phone and tablet size (D-76), with the
/// invented test data and the fixed clock of pumpWioApp.
///
/// Picture times are shown in the device's time zone and the goldens were
/// rendered in UTC, as CI runs: run goldens with `TZ=UTC`.
void main() {
  setUpAll(() {
    if (!_notLinux && DateTime.now().timeZoneOffset != Duration.zero) {
      fail(
        'Run goldens with TZ=UTC (for example TZ=UTC flutter test --tags '
        'golden): picture times are local and the goldens show UTC.',
      );
    }
  });

  const sizes = <String, Size>{'phone': phoneSize, 'tablet': tabletSize};
  for (final MapEntry(key: file, value: screen) in screenCatalog.entries) {
    final name = file.split('/').last.replaceAll('.dart', '');
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
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
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
      });
    }
  }

  // A room without pictures shows the plain hint (D-258).
  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets('room_screen empty at $sizeName size', skip: _notLinux, (
      tester,
    ) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedWithPictures(db);
      await pumpWioApp(
        tester,
        db: db,
        location:
            '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.keller}',
        size: size,
        mediaFolder: demoMediaFolder(),
      );
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/room_screen_empty_$sizeName.png'),
      );
    });
  }

  // A refused camera shows the plain hint and Noch einmal fragen (D-269).
  for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
    testWidgets('camera_screen denied at $sizeName size', skip: _notLinux, (
      tester,
    ) async {
      final db = memoryDatabase();
      addTearDown(db.close);
      await seedWithPictures(db);
      await pumpWioApp(
        tester,
        db: db,
        location:
            '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}'
            '/kamera',
        size: size,
        camera: () => FakeCamera(openError: const CameraDenied()),
      );
      await expectLater(
        find.byType(WidgetsApp),
        matchesGoldenFile('goldens/camera_screen_denied_$sizeName.png'),
      );
    });
  }
}
