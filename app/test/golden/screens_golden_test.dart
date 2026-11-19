@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart' show Size, WidgetsApp;
import 'package:flutter_test/flutter_test.dart';

import 'package:wio_app/camera/capture_camera.dart';
import 'package:wio_app/voice/voice_recorder.dart';

import '../support/fake_camera.dart';
import '../support/fake_voice.dart';
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

  // An after picture with its before picture under "Vorher" (D-280), and
  // the after camera with the before picture over the live image (D-277).
  final extra = <String, String>{
    'picture_screen_after':
        '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}'
        '/pictures/${TestIds.fotoNachher}',
    'camera_screen_after':
        '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}'
        '/pictures/${TestIds.fotoVorher}/nachher',
  };
  for (final MapEntry(key: name, value: location) in extra.entries) {
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedWithPictures(db);
        await pumpWioApp(
          tester,
          db: db,
          location: location,
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

  // The voice note while speaking (D-62), without a transcript on this
  // phone (D-61), with German to load (D-287), with the microphone refused
  // (D-293); Sprechen on the room, customer and picture screens is in the
  // catalogue goldens above (D-295).
  final voice = <String, void Function(FakeVoiceRecorder recorder)>{
    'voice_screen_text': (r) => r
      ..transcript(TranscriptStatus.ready)
      ..partial('Kiste mit Wintersachen im Keller, 180 cm hoch'),
    'voice_screen_no_text': (r) => r.transcript(TranscriptStatus.noOnDevice),
    'voice_screen_german': (r) => r.transcript(TranscriptStatus.germanMissing),
    'voice_screen_denied': (r) {},
  };
  for (final MapEntry(key: name, value: drive) in voice.entries) {
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedWithPictures(db);
        final recorder = name == 'voice_screen_denied'
            ? FakeVoiceRecorder(
                permissionNow: VoicePermission.refused,
                permissionAfterAsking: VoicePermission.refused,
              )
            : FakeVoiceRecorder();
        await pumpWioApp(
          tester,
          db: db,
          location:
              '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}'
              '/sprechen',
          size: size,
          voiceRecorder: recorder,
        );
        drive(recorder);
        await tester.pump();
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
      });
    }
  }
}
