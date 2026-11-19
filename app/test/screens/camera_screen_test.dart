// The camera screen (plan 058 tests T2b, T3, T4; D-265..D-274; PR 69
// round 1).
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/camera/camera_providers.dart';
import 'package:wio_app/camera/camera_screen.dart';
import 'package:wio_app/camera/capture_camera.dart';
import 'package:wio_app/camera/capture_files.dart';
import 'package:wio_app/camera/picture_processor.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/pictures/picture_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/fake_camera.dart';
import '../support/jpeg_metadata.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _kueche =
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}';

/// A media store that keeps nothing, as on the web (D-246, D-274).
class _NoMediaStore extends MediaStore {
  _NoMediaStore() : super(() async => '');

  @override
  bool get supported => false;
}

Finder _shutter() => find.widgetWithText(FilledButton, 'Foto');

void main() {
  late WioDatabase db;
  late Directory folder;
  late FakeCamera camera;
  late List<String> seeded;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
    seeded = [for (final p in await db.select(db.pictures).get()) p.id];
    folder = Directory.systemTemp.createTempSync('camera_screen_test');
    Directory('${folder.path}/shots').createSync();
    camera = FakeCamera(folder: '${folder.path}/shots');
  });
  tearDown(() async {
    await db.close();
    folder.deleteSync(recursive: true);
  });

  /// The app over real folders for shots, kept files and uploads.
  Future<void> pumpCamera(
    WidgetTester tester, {
    String location = _kueche,
    PictureProcessor? prepare,
    String? mediaFolder,
  }) => pumpWioApp(
    tester,
    db: db,
    location: location,
    camera: () => camera,
    mediaStore: MediaStore(() async => '${folder.path}/support'),
    uploadStore: UploadStore(() async => '${folder.path}/support'),
    captureFiles: CaptureFiles(() async => '${folder.path}/temp'),
    preparePicture: prepare,
    mediaFolder: mediaFolder,
  );

  Future<List<Picture>> newPictures(WidgetTester tester) async =>
      (await tester.runAsync(
        () =>
            (db.select(db.pictures)..where((p) => p.id.isNotIn(seeded))).get(),
      ))!;

  /// Presses "Foto" for real: the shot's files are read and written
  /// outside the fake time of the test.
  Future<void> press(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.tap(_shutter());
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
  }

  Future<void> drain(WidgetTester tester) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final queue = container.read(captureQueueProvider);
    // File work runs in real time, the database's streams in the test's
    // fake time, so both get turns until the queue is done.
    for (var turn = 0; turn < 500 && queue.busy; turn++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump();
    }
    expect(queue.busy, isFalse, reason: 'the queue finished');
    await tester.pumpAndSettle();
  }

  testWidgets('Fotos opens the camera at once, with Foto and Fertig', (
    tester,
  ) async {
    await pumpCamera(tester);
    await tester.tap(find.widgetWithText(FilledButton, 'Fotos'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraScreen), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('fake-preview')), findsOneWidget);
    expect(_shutter(), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Fertig'), findsOneWidget);
    expect(find.text('Zurück'), findsNothing, reason: 'D-270');
    expect(find.text('Küche'), findsOneWidget, reason: 'title');
    expect(find.text('Noch kein Foto'), findsOneWidget);
    expect(camera.isOpen, isTrue);
  });

  testWidgets('every press is a picture, without any step to confirm', (
    tester,
  ) async {
    await pumpCamera(tester, location: '$_kueche/kamera');

    await press(tester);
    await drain(tester);
    expect(find.text('1 Foto gespeichert'), findsOneWidget);
    expect(find.byType(Dialog), findsNothing);
    expect(_shutter(), findsOneWidget, reason: 'the camera stays open');

    await press(tester);
    await drain(tester);
    expect(find.text('2 Fotos gespeichert'), findsOneWidget);

    final pictures = await newPictures(tester);
    expect(pictures, hasLength(2));
    for (final picture in pictures) {
      expect(picture.roomId, TestIds.kueche);
      expect(DateTime.parse(picture.takenAt!), testNow.toUtc());
      final bytes = File('${folder.path}/support/media/${picture.fileSha256}')
          .readAsBytesSync();
      expect(jpegHeaderMarkers(bytes).where(isMetadataMarker), isEmpty);
    }
    final uploads = (await tester.runAsync(() => db.select(db.uploads).get()))!;
    expect(uploads.map((u) => u.sha256).toSet(), <String>{
      for (final p in pictures) p.fileSha256,
    });
  });

  testWidgets('Fertig while pictures are still being saved loses none', (
    tester,
  ) async {
    // A flag, not a Completer: the shots wait in real time, and a
    // Completer made in the test's fake time would only wake them on a pump.
    var held = true;
    await pumpCamera(
      tester,
      prepare: (Uint8List shot) async {
        while (held) {
          await Future<void>.delayed(const Duration(milliseconds: 5));
        }
        return preparePictureBytes(shot);
      },
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Fotos'));
    await tester.pumpAndSettle();

    await press(tester);
    await press(tester);
    await press(tester);
    await tester.pump();
    expect(find.text('3 Fotos werden gespeichert'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect(find.byType(CameraScreen), findsNothing);
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(camera.isOpen, isFalse);

    held = false;
    await drain(tester);
    expect(await newPictures(tester), hasLength(3));
    final uploads = (await tester.runAsync(() => db.select(db.uploads).get()))!;
    expect(uploads, hasLength(3));
    expect(
      Directory('${folder.path}/temp/wio-capture').listSync(),
      isEmpty,
      reason: 'no shot left behind',
    );
  });

  testWidgets('a refused camera shows a plain hint and asks again', (
    tester,
  ) async {
    camera.openError = const CameraDenied();
    await pumpCamera(tester, location: '$_kueche/kamera');

    expect(find.text('Wio darf die Kamera nicht benutzen.'), findsOneWidget);
    expect(find.textContaining('Einstellungen des Telefons'), findsOneWidget);
    expect(_shutter(), findsNothing);
    expect(find.widgetWithText(TextButton, 'Fertig'), findsOneWidget);

    camera.openError = null;
    await tester.tap(find.widgetWithText(OutlinedButton, 'Noch einmal fragen'));
    await tester.pumpAndSettle();
    expect(_shutter(), findsOneWidget);
    expect(camera.opened, 2);
  });

  testWidgets('a camera that fails to start shows a hint and tries again', (
    tester,
  ) async {
    camera.openError = const CameraUnavailable('broken');
    await pumpCamera(tester, location: '$_kueche/kamera');

    expect(
      find.text('Die Kamera lässt sich gerade nicht öffnen.'),
      findsOneWidget,
    );
    camera.openError = null;
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Noch einmal versuchen'),
    );
    await tester.pumpAndSettle();
    expect(_shutter(), findsOneWidget);
  });

  testWidgets('the camera is let go in the background and opened again', (
    tester,
  ) async {
    await pumpCamera(tester, location: '$_kueche/kamera');
    expect(camera.isOpen, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pumpAndSettle();
    expect(camera.isOpen, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(camera.isOpen, isTrue);
    expect(_shutter(), findsOneWidget);
  });

  testWidgets('the permission prompt does not open the camera twice', (
    tester,
  ) async {
    // The prompt makes the app inactive while the camera opens (PR 69 B1).
    final gate = Completer<void>();
    camera.openGate = gate;
    await pumpCamera(tester, location: '$_kueche/kamera');
    expect(_shutter(), findsNothing);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    gate.complete();
    await tester.pumpAndSettle();

    expect(camera.opened, 1);
    expect(camera.closed, 0);
    expect(camera.isOpen, isTrue);
    expect(_shutter(), findsOneWidget);
  });

  testWidgets('after a refusal, coming back does not ask again by itself', (
    tester,
  ) async {
    camera.openError = const CameraDenied();
    await pumpCamera(tester, location: '$_kueche/kamera');
    expect(find.text('Wio darf die Kamera nicht benutzen.'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(camera.opened, 1);
    expect(find.text('Wio darf die Kamera nicht benutzen.'), findsOneWidget);
  });

  testWidgets('a failed shot lets the camera go before trying again', (
    tester,
  ) async {
    await pumpCamera(tester, location: '$_kueche/kamera');
    camera.shotError = const CameraUnavailable('broken');
    await press(tester);
    await tester.pumpAndSettle();

    expect(
      find.text('Die Kamera lässt sich gerade nicht öffnen.'),
      findsOneWidget,
    );
    expect(camera.closed, camera.opened, reason: 'no camera left open');

    camera.shotError = null;
    await tester.tap(
      find.widgetWithText(OutlinedButton, 'Noch einmal versuchen'),
    );
    await tester.pumpAndSettle();
    expect(camera.opened - camera.closed, 1, reason: 'exactly one open');
    await press(tester);
    await drain(tester);
    expect(await newPictures(tester), hasLength(1));
  });

  testWidgets('a press while a shot is being taken is a picture too', (
    tester,
  ) async {
    await pumpCamera(tester, location: '$_kueche/kamera');
    // Two taps without waiting in between (UX rule 5, PR 69 S1).
    await tester.runAsync(() async {
      await tester.tap(_shutter());
      await tester.tap(_shutter());
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await drain(tester);
    expect(camera.shots, 2);
    expect(await newPictures(tester), hasLength(2));
    expect(find.text('2 Fotos gespeichert'), findsOneWidget);
  });

  testWidgets('Fotos on the customer screen takes pictures without a room', (
    tester,
  ) async {
    await pumpCamera(tester, location: '/customers/${TestIds.familieBeispiel}');
    await tester.tap(find.widgetWithText(FilledButton, 'Fotos'));
    await tester.pumpAndSettle();
    expect(find.text('Familie Beispiel'), findsOneWidget, reason: 'title');

    await press(tester);
    await drain(tester);
    final picture = (await newPictures(tester)).single;
    expect(picture.roomId, isNull);
    expect(picture.customerId, TestIds.familieBeispiel);

    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('no Fotos button where the app takes no pictures (web)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaStore: _NoMediaStore(),
    );
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsNothing);

    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}',
      mediaStore: _NoMediaStore(),
    );
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsNothing);
  });

  /// The before picture's file in the app's own media folder, as if it
  /// was taken on this device.
  void keepBeforeFile() {
    final media = Directory('${folder.path}/support/media')
      ..createSync(recursive: true);
    File('${DemoFiles.folder}/${DemoFiles.kuecheVorher}.jpg')
        .copySync('${media.path}/${DemoFiles.kuecheVorher}');
  }

  testWidgets('Nachher aufnehmen: overlay, and every press an after picture '
      'of the camera frame only (D-276, D-277)', (tester) async {
    keepBeforeFile();
    await pumpCamera(
      tester,
      location: '$_kueche/pictures/${TestIds.fotoVorher}',
      mediaFolder: '${folder.path}/support/media',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Nachher aufnehmen'));
    await tester.pumpAndSettle();

    expect(find.byType(CameraScreen), findsOneWidget);
    expect(_shutter(), findsOneWidget, reason: 'opens directly, rule 5');
    final overlay = tester.widget<Opacity>(
      find.byKey(const ValueKey<String>('after-overlay')),
    );
    expect(overlay.opacity, afterOverlayOpacity);
    expect(afterOverlayOpacity, 0.4);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey<String>('after-overlay')),
        matching: find.byType(Image),
      ),
      findsOneWidget,
    );
    expect(find.text('Nachher-Foto: Das Vorher-Foto liegt darüber.'), findsOne);
    expect(find.byType(Slider), findsNothing, reason: 'UX rule 6');

    await press(tester);
    await press(tester);
    await drain(tester);
    expect(find.text('2 Fotos gespeichert'), findsOneWidget);

    final pictures = await newPictures(tester);
    expect(pictures, hasLength(2));
    final frames = (await tester.runAsync(
      () async => <String>{
        for (final shot in camera.shotBytes)
          sha256.convert(preparePictureBytes(shot).bytes).toString(),
      },
    ))!;
    for (final picture in pictures) {
      expect(picture.afterOf, TestIds.fotoVorher);
      expect(picture.roomId, TestIds.kueche);
      expect(picture.customerId, TestIds.familieBeispiel);
      // The stored file is the camera's own frame, prepared; nothing of
      // the overlay is in it.
      expect(frames, contains(picture.fileSha256));
      expect(picture.fileSha256, isNot(DemoFiles.kuecheVorher));
    }

    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect(find.byType(PictureScreen), findsOneWidget);
    expect(find.text('Nachher'), findsNWidgets(4), reason: 'row + 3 tiles');
  });

  testWidgets('a before picture not on this device: hint, camera still works', (
    tester,
  ) async {
    await pumpCamera(
      tester,
      location: '$_kueche/pictures/${TestIds.fotoVorher}/nachher',
      mediaFolder: '${folder.path}/support/media',
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('after-overlay')), findsNothing);
    expect(find.text('Vorher-Foto ist nicht auf diesem Gerät.'), findsOne);
    await press(tester);
    await drain(tester);
    expect((await newPictures(tester)).single.afterOf, TestIds.fotoVorher);

    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    expect(find.byType(PictureScreen), findsOneWidget, reason: 'D-276');
  });

  testWidgets('no Nachher aufnehmen where the app takes no pictures (web)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoVorher}',
      mediaStore: _NoMediaStore(),
    );
    expect(find.text('Nachher aufnehmen'), findsNothing);
    expect(find.widgetWithText(OutlinedButton, 'Löschen'), findsOneWidget);
  });
}
