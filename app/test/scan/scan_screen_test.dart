import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/camera/camera_screen.dart';
import 'package:wio_app/camera/capture_camera.dart';
import 'package:wio_app/customers/customer_screen.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/rooms/room_screen.dart';
import 'package:wio_app/scan/scan_screen.dart';

import '../support/fake_qr_scanner.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _customer = '/customers/${TestIds.familieBeispiel}';
const String _kueche = '$_customer/rooms/${TestIds.kueche}';

class _NoMediaStore extends MediaStore {
  _NoMediaStore() : super(() async => '');

  @override
  bool get supported => false;
}

Finder _newEntry() => find.widgetWithText(OutlinedButton, '+ Eintrag');
Finder _withoutCode() => find.widgetWithText(FilledButton, 'Ohne Code');

void main() {
  late WioDatabase db;
  late FakeQrScanner scanner;
  late List<String> seeded;

  setUp(() async {
    db = memoryDatabase();
    await seedWithEntries(db);
    seeded = [for (final e in await db.select(db.entries).get()) e.id];
    scanner = FakeQrScanner();
  });
  tearDown(() => db.close());

  Future<void> pumpAt(
    WidgetTester tester,
    String location, {
    MediaStore? mediaStore,
  }) => pumpWioApp(
    tester,
    db: db,
    location: location,
    qrScanner: () => scanner,
    mediaStore: mediaStore,
  );

  Future<List<Entry>> newEntries() =>
      (db.select(db.entries)..where((e) => e.id.isNotIn(seeded))).get();

  Future<List<OutboxData>> outbox() => db.select(db.outbox).get();

  Future<void> read(WidgetTester tester, String code) async {
    scanner.read(code);
    await tester.pumpAndSettle();
  }

  testWidgets('+ Eintrag opens the scanner at once, Ohne Code is the main '
      'button (UX rules 3, 5; D-465, D-466)', (tester) async {
    await pumpAt(tester, _customer);
    expect(_newEntry(), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Fotos'), findsOneWidget);

    await tester.tap(_newEntry());
    await tester.pumpAndSettle();

    expect(find.byType(ScanScreen), findsOneWidget);
    expect(scanner.isOpen, isTrue);
    expect(
      find.byKey(const ValueKey<String>('fake-scan-preview')),
      findsOneWidget,
    );
    expect(find.text('QR-Code vor die Kamera halten'), findsOneWidget);
    expect(_withoutCode(), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget, reason: 'one main');
    expect(find.widgetWithText(TextButton, 'Zurück'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'Zurück'));
    await tester.pumpAndSettle();
    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(scanner.isOpen, isFalse);
  });

  testWidgets('a new code becomes an entry with that code and opens its '
      'camera (D-51, D-466)', (tester) async {
    await pumpAt(tester, '$_customer/eintrag');
    await read(tester, ' Box-17 ');

    final entry = (await newEntries()).single;
    expect(entry.code, ' Box-17 ', reason: 'taken unchanged');
    expect(entry.customerId, TestIds.familieBeispiel);
    expect(entry.roomId, isNull, reason: 'not placed from the customer');
    final changes = await outbox();
    expect(changes.map((c) => (c.entity, c.op)), <(String, String)>[
      ('entries', 'upsert'),
    ]);

    expect(find.byType(CameraScreen), findsOneWidget);
    expect(find.text(' Box-17 '), findsOneWidget, reason: 'camera title');
    expect(scanner.isOpen, isFalse);

    await tester.tap(find.widgetWithText(TextButton, 'Fertig'));
    await tester.pumpAndSettle();
    // The entry's own address; until #103 it shows the customer.
    expect(find.byType(CustomerScreen), findsOneWidget);
  });

  testWidgets('from a room, the new entry is placed on its floor '
      '(D-424, D-425)', (tester) async {
    await pumpAt(tester, _kueche);
    expect(find.text('Einträge in diesem Raum'), findsOneWidget);
    await tester.ensureVisible(_newEntry());
    await tester.tap(_newEntry());
    await tester.pumpAndSettle();
    expect(find.byType(ScanScreen), findsOneWidget);

    await read(tester, 'WIO-0100');

    final entry = (await newEntries()).single;
    expect(entry.siteId, TestIds.alteWohnung);
    expect(entry.roomId, TestIds.kueche);
    final changes = await outbox();
    expect(changes.map((c) => (c.entity, c.op)), <(String, String)>[
      ('entries', 'upsert'),
      ('entries', 'move_entry'),
    ]);
    final move = jsonDecode(changes.last.fields) as Map<String, Object?>;
    expect(move['site_id'], TestIds.alteWohnung);
    expect(move['room_id'], TestIds.kueche);
    expect(move['floor_x_cm'], isNull);
    expect(find.byType(CameraScreen), findsOneWidget);
  });

  testWidgets('a known code opens its entry, nothing new is written (D-428)', (
    tester,
  ) async {
    await pumpAt(tester, _kueche);
    await tester.ensureVisible(_newEntry());
    await tester.tap(_newEntry());
    await tester.pumpAndSettle();
    await read(tester, 'WIO-0042');

    expect(await newEntries(), isEmpty);
    expect(await outbox(), isEmpty);
    expect(find.byType(CameraScreen), findsNothing);
    // The entry's address under its customer; until #103 that customer.
    expect(find.byType(CustomerScreen), findsOneWidget);
    expect(find.text('Familie Beispiel'), findsOneWidget);
    expect(find.byType(RoomScreen), findsNothing);
  });

  testWidgets('a known code of another customer opens it under that '
      'customer (D-428)', (tester) async {
    await (db.update(db.entries)
          ..where((e) => e.id.equals(TestIds.fremdeKiste)))
        .write(const EntriesCompanion(code: Value<String?>('MUSTER-1')));
    await pumpAt(tester, '$_customer/eintrag');
    await read(tester, 'MUSTER-1');

    expect(await newEntries(), isEmpty);
    expect(find.text('Frau Muster'), findsOneWidget);
  });

  testWidgets('a code over 255 bytes is not taken; scanning goes on (D-469)', (
    tester,
  ) async {
    await pumpAt(tester, '$_customer/eintrag');
    await read(tester, 'ä' * 128); // 256 bytes in UTF-8

    expect(
      find.text('Dieser Code ist zu lang für Wio (höchstens 255 Zeichen).'),
      findsOneWidget,
    );
    expect(await newEntries(), isEmpty);
    expect(find.byType(ScanScreen), findsOneWidget);
    expect(scanner.isOpen, isTrue);

    await read(tester, 'a' * 255);
    expect((await newEntries()).single.code, 'a' * 255);
  });

  testWidgets('Ohne Code creates an entry without a code', (tester) async {
    await pumpAt(tester, '$_customer/eintrag');
    await tester.tap(_withoutCode());
    await tester.pumpAndSettle();

    final entry = (await newEntries()).single;
    expect(entry.code, isNull);
    expect(find.byType(CameraScreen), findsOneWidget);
    expect(find.text('Eintrag ohne Namen'), findsOneWidget);
  });

  testWidgets('one scan makes one entry, even when codes come quickly', (
    tester,
  ) async {
    await pumpAt(tester, '$_customer/eintrag');
    scanner
      ..read('A-1')
      ..read('A-1')
      ..read('B-2');
    await tester.pumpAndSettle();

    final entries = await newEntries();
    expect(entries, hasLength(1));
    expect(entries.single.code, 'A-1');
  });

  testWidgets('a refused camera shows the M2 hint; Noch einmal fragen opens '
      'it again; Ohne Code still works (D-269)', (tester) async {
    scanner = FakeQrScanner(openError: const CameraDenied());
    await pumpAt(tester, '$_customer/eintrag');

    expect(find.text('Wio darf die Kamera nicht benutzen.'), findsOneWidget);
    expect(find.text('QR-Code vor die Kamera halten'), findsNothing);
    expect(scanner.opened, 1);

    scanner.openError = null;
    await tester.tap(find.widgetWithText(OutlinedButton, 'Noch einmal fragen'));
    await tester.pumpAndSettle();
    expect(scanner.opened, 2);
    expect(scanner.isOpen, isTrue);
    expect(find.text('QR-Code vor die Kamera halten'), findsOneWidget);

    scanner = FakeQrScanner(openError: const CameraDenied());
    await pumpAt(tester, '$_customer/eintrag');
    await tester.tap(_withoutCode());
    await tester.pumpAndSettle();
    expect(await newEntries(), hasLength(1));
  });

  testWidgets('the camera is let go in the background and taken again on '
      'return', (tester) async {
    await pumpAt(tester, '$_customer/eintrag');
    expect(scanner.isOpen, isTrue);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pumpAndSettle();
    expect(scanner.isOpen, isFalse);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(scanner.opened, 2);
    expect(scanner.isOpen, isTrue);
    await read(tester, 'C-3');
    expect((await newEntries()).single.code, 'C-3');
  });

  testWidgets('on the web + Eintrag creates an entry without a code and '
      'does not scan (D-433)', (tester) async {
    await pumpAt(tester, _customer, mediaStore: _NoMediaStore());
    await tester.tap(_newEntry());
    await tester.pumpAndSettle();

    expect(find.byType(ScanScreen), findsNothing);
    expect(scanner.opened, 0);
    final entry = (await newEntries()).single;
    expect(entry.code, isNull);
    expect(entry.roomId, isNull);
    expect(find.byType(CustomerScreen), findsOneWidget);
  });
}
