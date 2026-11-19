@Tags(<String>['golden'])
library;

import 'dart:io';

import 'package:flutter/widgets.dart'
    show AxisDirection, Scrollable, Size, WidgetsApp;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wio_app/camera/capture_camera.dart';
import 'package:wio_app/media/media_presence.dart';
import 'package:wio_app/voice/voice_recorder.dart';

import '../support/fake_camera.dart';
import '../support/fake_player.dart';
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
  // (D-293), with speech recognition refused on an iPhone (D-340); Sprechen
  // on the room, customer and picture screens is in the
  // catalogue goldens above (D-295).
  final voice = <String, void Function(FakeVoiceRecorder recorder)>{
    'voice_screen_text': (r) => r
      ..transcript(TranscriptStatus.ready)
      ..partial('Kiste mit Wintersachen im Keller, 180 cm hoch'),
    'voice_screen_no_text': (r) => r.transcript(TranscriptStatus.noOnDevice),
    'voice_screen_german': (r) => r.transcript(TranscriptStatus.germanMissing),
    'voice_screen_speech_refused': (r) =>
        r.transcript(TranscriptStatus.speechRefused),
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

  // The Notizen section on the three screens, scrolled into view (D-298,
  // D-305), a note playing (D-301), and the note screen for a text note
  // and a new one (D-302, D-304); the voice note's screen is in the
  // catalogue.
  const kueche =
      '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}';
  final notes = <String, ({String location, bool scroll, bool play})>{
    'room_screen_notes': (location: kueche, scroll: true, play: false),
    'room_screen_playing': (location: kueche, scroll: true, play: true),
    'customer_screen_notes': (
      location: '/customers/${TestIds.familieBeispiel}',
      scroll: true,
      play: false,
    ),
    'picture_screen_notes': (
      location: '$kueche/pictures/${TestIds.fotoRegal}',
      scroll: true,
      play: false,
    ),
    'note_screen_text': (
      location: '$kueche/notizen/${TestIds.notizText}',
      scroll: false,
      play: false,
    ),
    'note_screen_new': (
      location: '$kueche/notizen/neu',
      scroll: false,
      play: false,
    ),
  };
  for (final MapEntry(key: name, value: shot) in notes.entries) {
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedWithNotes(db);
        final player = FakeNotePlayer();
        await pumpWioApp(
          tester,
          db: db,
          location: shot.location,
          size: size,
          mediaFolder: demoMediaFolder(),
          notePlayer: player,
        );
        if (shot.scroll) {
          await tester.scrollUntilVisible(
            find.text('Notiz schreiben'),
            200,
            scrollable: find
                .byWidgetPredicate(
                  (w) =>
                      w is Scrollable && w.axisDirection == AxisDirection.down,
                )
                .first,
          );
          await tester.pumpAndSettle();
        }
        if (shot.play) {
          await tester.tap(find.text('Abspielen'));
          await tester.pumpAndSettle();
          player.at(const Duration(seconds: 12));
          await tester.pump();
        }
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
      });
    }
  }

  // Files coming in from another device (plan 062, D-333): the tile and the
  // note card say "wird geladen".
  final loading = <String, bool>{
    'room_screen_loading': false,
    'room_screen_notes_loading': true,
  };
  for (final MapEntry(key: name, value: scroll) in loading.entries) {
    for (final MapEntry(key: sizeName, value: size) in sizes.entries) {
      testWidgets('$name at $sizeName size', skip: _notLinux, (tester) async {
        final db = memoryDatabase();
        addTearDown(db.close);
        await seedWithNotes(db);
        await pumpWioApp(
          tester,
          db: db,
          location: kueche,
          size: size,
          mediaFolder: demoMediaFolder(
            without: <String>{DemoFiles.kuecheRegal, DemoFiles.noteAudio},
          ),
        );
        ProviderScope.containerOf(tester.element(find.byType(WidgetsApp)))
            .read(mediaPresenceProvider.notifier)
            .setLoading(<String>{DemoFiles.kuecheRegal, DemoFiles.noteAudio});
        await tester.pumpAndSettle();
        if (scroll) {
          await tester.scrollUntilVisible(
            find.text('Notiz schreiben'),
            200,
            scrollable: find
                .byWidgetPredicate(
                  (w) =>
                      w is Scrollable && w.axisDirection == AxisDirection.down,
                )
                .first,
          );
          await tester.pumpAndSettle();
        }
        await expectLater(
          find.byType(WidgetsApp),
          matchesGoldenFile('goldens/${name}_$sizeName.png'),
        );
      });
    }
  }
}
