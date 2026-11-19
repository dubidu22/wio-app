import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/pictures/picture_screen.dart';
import 'package:wio_app/rooms/room_screen.dart';

import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';
const String _kueche = '$_customer/rooms/${TestIds.kueche}';

/// A picture time as tiles show it, in the device's time zone.
String _time(int hour, int minute) {
  final local = DateTime.utc(2026, 11, 19, hour, minute).toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return 'Do. ${local.day}.${local.month}., '
      '${two(local.hour)}:${two(local.minute)}';
}

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
    await seedWithPictures(db);
  });
  tearDown(() => db.close());

  Future<String?> deletedAt(WidgetTester tester, String id) async =>
      (await tester.runAsync(
        () =>
            (db.select(db.pictures)..where((p) => p.id.equals(id))).getSingle(),
      ))!.deletedAt;

  testWidgets('an after picture shows its before picture under Vorher', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoNachher}',
      mediaFolder: demoMediaFolder(),
    );

    expect(find.text('Foto'), findsOneWidget);
    expect(find.textContaining('19.11.'), findsNWidgets(2), reason: 'both');
    expect(find.text('Nachher'), findsOneWidget, reason: 'word, D-5');
    expect(find.text('Vorher'), findsOneWidget, reason: 'D-280');
    expect(find.byType(Image), findsNWidgets(2), reason: 'picture + tile');
    expect(find.widgetWithText(FilledButton, 'Nachher aufnehmen'), findsOne);
    expect(find.widgetWithText(OutlinedButton, 'Löschen'), findsOneWidget);
    expect(
      find.widgetWithText(OutlinedButton, 'Sprechen'),
      findsOneWidget,
      reason: 'D-295',
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Öffnen'));
    await tester.pumpAndSettle();
    expect(find.text('Vorher'), findsNothing);
    expect(find.text('Nachher'), findsNWidgets(2), reason: 'row and tile');
    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget, reason: 'D-261');
  });

  testWidgets('the picture can be zoomed, as an extra only (D-279)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoRegal}',
      mediaFolder: demoMediaFolder(),
    );
    final viewer = tester.widget<InteractiveViewer>(
      find.byType(InteractiveViewer),
    );
    expect(viewer.maxScale, 4);
    expect(find.text('Nachher'), findsNothing, reason: 'no after pictures');
    expect(find.text('Vorher'), findsNothing);
  });

  testWidgets('Löschen goes back at once and Rückgängig brings it back', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoRegal}',
      mediaFolder: demoMediaFolder(),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Löschen'));
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(find.byType(Dialog), findsNothing, reason: 'UX rule 9');
    expect(find.text('Foto gelöscht.'), findsOneWidget);
    expect(find.text(_time(8, 7)), findsNothing);
    expect(await deletedAt(tester, TestIds.fotoRegal), isNotNull);

    await tester.tap(find.widgetWithText(SnackBarAction, 'Rückgängig'));
    await tester.pumpAndSettle();
    expect(await deletedAt(tester, TestIds.fotoRegal), isNull);
    expect(find.text(_time(8, 7)), findsOneWidget);
  });

  testWidgets('a double tap on Löschen deletes once (PR 72 S1)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoRegal}',
      mediaFolder: demoMediaFolder(),
    );

    final delete = find.widgetWithText(OutlinedButton, 'Löschen');
    await tester.tap(delete);
    await tester.tap(delete, warnIfMissed: false);
    await tester.pumpAndSettle();

    final outbox = await tester.runAsync(
      () => (db.select(
        db.outbox,
      )..where((o) => o.entityId.equals(TestIds.fotoRegal))).get(),
    );
    expect(outbox, hasLength(1));
    expect(find.text('Foto gelöscht.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();
    expect(find.text('Foto gelöscht.'), findsNothing, reason: 'no second one');
  });

  testWidgets('without Rückgängig the note goes after 8 s, still deleted', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoRegal}',
      mediaFolder: demoMediaFolder(),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Löschen'));
    await tester.pumpAndSettle();
    expect(find.text('Foto gelöscht.'), findsOneWidget);
    await tester.pump(const Duration(seconds: 7));
    expect(find.text('Rückgängig'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Foto gelöscht.'), findsNothing);
    expect(await deletedAt(tester, TestIds.fotoRegal), isNotNull);
    final outbox = await tester.runAsync(
      () => (db.select(
        db.outbox,
      )..where((o) => o.entityId.equals(TestIds.fotoRegal))).get(),
    );
    expect(outbox, isNotEmpty, reason: 'the tombstone is pushed');
  });

  testWidgets('deleting a before picture keeps its after picture (D-278)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: '$_kueche/pictures/${TestIds.fotoVorher}',
      mediaFolder: demoMediaFolder(),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Löschen'));
    await tester.pumpAndSettle();
    expect(find.byType(RoomScreen), findsOneWidget);
    expect(find.text(_time(8, 5)), findsNothing, reason: 'before is gone');
    expect(find.text(_time(9, 40)), findsOneWidget, reason: 'after stays');
    expect(find.text('Nachher'), findsOneWidget);
    expect(await deletedAt(tester, TestIds.fotoNachher), isNull);

    // Still reachable: it opens, without a Vorher row.
    await tester.pump(const Duration(seconds: 9));
    await tester.pumpAndSettle();
    final tile = find.ancestor(
      of: find.text(_time(9, 40)),
      matching: find.byType(OutlinedButton),
    );
    await tester.tap(tile);
    await tester.pumpAndSettle();
    expect(find.byType(PictureScreen), findsOneWidget);
    expect(find.text('Dieses Foto gibt es nicht mehr.'), findsNothing);
    expect(find.text('Vorher'), findsNothing);
  });

  testWidgets('a picture without a room opens from the customer', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location: _customer,
      mediaFolder: demoMediaFolder(),
    );

    await tester.tap(find.widgetWithText(OutlinedButton, 'Öffnen'));
    await tester.pumpAndSettle();
    await loadPictures(tester);
    expect(find.text('Foto'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);

    await tester.tap(find.text('Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('empty until the media folder is known, then the picture', (
    tester,
  ) async {
    final folder = Completer<String?>();
    await pumpWioApp(
      tester,
      db: db,
      location: '$_customer/pictures/${TestIds.fotoFlur}',
      mediaFolderFuture: folder.future,
    );

    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsNothing);
    expect(find.byType(Image), findsNothing);
    expect(find.text('Zurück'), findsOneWidget);

    folder.complete(demoMediaFolder());
    await tester.pumpAndSettle();
    await loadPictures(tester);
    expect(find.byType(Image), findsOneWidget);
    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsNothing);
  });

  testWidgets('a file not on this device is a plain hint (D-260)', (
    tester,
  ) async {
    await pumpWioApp(
      tester,
      db: db,
      location:
          '$_customer/rooms/${TestIds.kueche}'
          '/pictures/${TestIds.fotoFehlt}',
      mediaFolder: demoMediaFolder(),
    );

    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('unknown, deleted, wrong room or other customer is a hint', (
    tester,
  ) async {
    for (final location in <String>[
      '$_customer/pictures/no-such-id',
      '$_customer/pictures/${TestIds.fotoGeloescht}',
      '$_customer/rooms/${TestIds.keller}/pictures/${TestIds.fotoVorher}',
      '/customers/${TestIds.frauMuster}/pictures/${TestIds.fotoVorher}',
    ]) {
      await pumpWioApp(tester, db: db, location: location);
      expect(
        find.text('Dieses Foto gibt es nicht mehr.'),
        findsOneWidget,
        reason: location,
      );
      expect(find.text('Zurück'), findsOneWidget);
    }
  });
}
