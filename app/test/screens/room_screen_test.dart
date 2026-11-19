import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/pictures/picture_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';

import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _kueche =
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}';

/// "Do. 19.11., 08:05" for a time of 19 Nov 2026 in UTC, in the device's
/// time zone, as the screen shows it.
String _time(int hour, int minute) {
  final local = DateTime.utc(2026, 11, 19, hour, minute).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'Do. ${local.day}.${local.month}., '
      '${two(local.hour)}:${two(local.minute)}';
}

Finder _openButtons() => find.widgetWithText(OutlinedButton, 'Öffnen');

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
  });
  tearDown(() => db.close());

  testWidgets(
    'shows the room, its site and its pictures, after behind before',
    (tester) async {
      await pumpWioApp(
        tester,
        db: db,
        location: _kueche,
        mediaFolder: demoMediaFolder(),
      );

      expect(find.text('Küche'), findsOneWidget);
      expect(find.text('Alte Wohnung'), findsOneWidget);
      expect(find.text('Fotos'), findsNWidgets(2), reason: 'heading, button');
      // Oldest first, each after picture right behind its before picture
      // (D-281): Vorher 8:05, its Nachher 9:40, then 8:07 and 9:45.
      final times = <String>[
        _time(8, 5),
        _time(9, 40),
        _time(8, 7),
        _time(9, 45),
      ];
      for (final time in times) {
        expect(find.text(time), findsOneWidget, reason: time);
      }
      final tops = <double>[
        for (final time in times) tester.getTopLeft(find.text(time)).dy,
      ];
      final lefts = <double>[
        for (final time in times) tester.getTopLeft(find.text(time)).dx,
      ];
      expect(tops[0], tops[1], reason: 'first row');
      expect(lefts[0], lessThan(lefts[1]));
      expect(tops[2], greaterThan(tops[0]), reason: 'second row');
      expect(
        find.text(_time(8, 6)),
        findsNothing,
        reason: 'tombstoned picture',
      );
      expect(find.text('Nachher'), findsOneWidget, reason: 'after picture');
      expect(find.byType(Image), findsNWidgets(3));
    },
  );

  testWidgets('a picture whose file is not here has a hint, no Öffnen', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );

    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsOneWidget);
    expect(_openButtons(), findsNWidgets(3));
    expect(
      find.ancestor(
        of: find.text(_time(9, 45)),
        matching: find.byType(OutlinedButton),
      ),
      findsNothing,
    );
  });

  testWidgets('no hint while the media folder is not known yet (S1)', (
    tester,
  ) async {
    final folder = Completer<String?>();
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolderFuture: folder.future,
    );

    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsNothing);
    expect(_openButtons(), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.text(_time(8, 5)), findsOneWidget, reason: 'time is shown');

    folder.complete(demoMediaFolder());
    await tester.pumpAndSettle();
    await loadPictures(tester);
    expect(find.byType(Image), findsNWidgets(3));
    expect(_openButtons(), findsNWidgets(3));
    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsOneWidget);
  });

  testWidgets('without a media folder (web) every picture is a hint', (
    tester,
  ) async {
    await pumpWioApp(tester, db: db, location: _kueche);

    expect(
      find.text('Foto ist noch nicht auf diesem Gerät.'),
      findsNWidgets(4),
    );
    expect(_openButtons(), findsNothing);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('buttons: Zurück, Öffnen, Sprechen and the main button Fotos '
      '(D-258, D-295)', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );

    expect(
      find.byWidgetPredicate((w) => w is ButtonStyleButton),
      findsNWidgets(7),
      reason: 'Zurück, three Öffnen, Notiz schreiben, Sprechen, Fotos',
    );
    expect(find.widgetWithText(OutlinedButton, 'Sprechen'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Zurück'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsOneWidget);
  });

  testWidgets('a room without pictures shows a plain hint', (tester) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.keller}',
    );

    expect(find.text('Keller'), findsOneWidget);
    expect(find.text('Noch keine Fotos in diesem Raum.'), findsOneWidget);
  });

  testWidgets('an unknown, deleted or other customer\'s room shows a hint', (
    tester,
  ) async {
    for (final location in <String>[
      '/customers/${TestIds.familieBeispiel}/rooms/no-such-id',
      '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.alterRaum}',
      '/customers/${TestIds.frauMuster}/rooms/${TestIds.kueche}',
    ]) {
      await pumpWioApp(tester, db: db, location: location);
      expect(
        find.text('Diesen Raum gibt es nicht mehr.'),
        findsOneWidget,
        reason: location,
      );
      expect(find.text('Zurück'), findsOneWidget);
    }
  });

  testWidgets('Öffnen opens the picture and Zurück returns to the room', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: demoMediaFolder(),
    );

    await tester.tap(_openButtons().first);
    await tester.pumpAndSettle();
    await loadPictures(tester);
    final screen = tester.widget<PictureScreen>(find.byType(PictureScreen));
    expect(screen.pictureId, TestIds.fotoVorher);
    expect(screen.roomId, TestIds.kueche);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.text('Familie Beispiel'), findsOneWidget, reason: 'customer');
  });

  testWidgets('a picture written on the device appears at once', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.keller}',
      mediaFolder: demoMediaFolder(),
    );

    await tester.runAsync(
      () => LocalWriter(db).write(
        entity: 'pictures',
        id: '01970000-0000-7000-8000-0000000000f9',
        fields: <String, Object?>{
          'workspace_id': TestIds.workspace,
          'customer_id': TestIds.familieBeispiel,
          'file_sha256': DemoFiles.kellerRegal,
          'file_bytes': 15604,
          'file_mime': 'image/jpeg',
          'width_px': 640,
          'height_px': 480,
          'taken_at': '2026-11-19T09:50:00.000Z',
          'room_id': TestIds.keller,
        },
      ),
    );
    await tester.pumpAndSettle();
    await loadPictures(tester);
    expect(find.text('Noch keine Fotos in diesem Raum.'), findsNothing);
    expect(_openButtons(), findsOneWidget);
  });
}
