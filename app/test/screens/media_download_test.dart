// Files from other devices on screen (plan 062, D-332, D-333): a tile and a
// note card switch from the hint to the picture or Abspielen when the file
// lands, without a reload. The download runs against the fake sync server.
import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_presence.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/rooms/room_screen.dart';
import 'package:wio_app/sync/sync_runner.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/media.dart';
import '../support/pump.dart';
import '../support/test_data.dart';

const String _kueche =
    '/customers/${TestIds.familieBeispiel}/rooms/${TestIds.kueche}';

/// A media folder `<base>/media` with the demo files except [leaveOut].
({String base, String folder}) _mediaWithout(Set<String> leaveOut) {
  final base = Directory.systemTemp.createTempSync('wio-download-');
  addTearDown(() => base.deleteSync(recursive: true));
  final folder = Directory('${base.path}/media')..createSync();
  for (final file in Directory(
    demoMediaFolder(),
  ).listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (!leaveOut.contains(name)) file.copySync('${folder.path}/$name');
  }
  return (base: base.path, folder: folder.path);
}

/// The media store with synchronous file work: file futures started in
/// the fake time of widget tests never finish (see `loadPictures`). The
/// real asynchronous store is tested in `download_queue_test.dart`.
class _SyncFileStore extends MediaStore {
  _SyncFileStore(this.base) : super(() async => base);

  final String base;

  File _part(String sha256) => File('$base/media/$sha256.part');

  @override
  Future<int> partSize(String sha256) async =>
      _part(sha256).existsSync() ? _part(sha256).lengthSync() : 0;

  @override
  Future<void> writePart(
    String sha256,
    List<int> bytes, {
    bool restart = false,
  }) async => _part(sha256).writeAsBytesSync(
    bytes,
    mode: restart ? FileMode.writeOnly : FileMode.writeOnlyAppend,
  );

  @override
  Future<void> deletePart(String sha256) async {
    if (_part(sha256).existsSync()) _part(sha256).deleteSync();
  }

  @override
  Future<bool> finishPart(String sha256) async {
    final part = _part(sha256);
    if (!part.existsSync()) return false;
    if (crypto.sha256.convert(part.readAsBytesSync()).toString() != sha256) {
      part.deleteSync();
      return false;
    }
    part.renameSync('$base/media/$sha256');
    return true;
  }
}

ProviderContainer _container(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(RoomScreen)));

void main() {
  late WioDatabase db;

  setUp(() async {
    db = memoryDatabase();
  });
  tearDown(() => db.close());

  testWidgets('a picture from another device is fetched and shown without a '
      'reload (#62 done when 1)', (tester) async {
    await seedWithPictures(db);
    final media = _mediaWithout(<String>{DemoFiles.kuecheRegal});
    final bytes = File('${DemoFiles.folder}/${DemoFiles.kuecheRegal}.jpg')
        .readAsBytesSync();
    final server = FakeSyncServer(workspaceId: exampleSession().workspace.id);
    server.files[DemoFiles.kuecheRegal] = bytes;
    // The other phone's row, as the server holds it.
    server.put('pictures', TestIds.fotoRegal, <String, Object?>{
      'customer_id': TestIds.familieBeispiel,
      'file_sha256': DemoFiles.kuecheRegal,
      'file_bytes': bytes.length,
      'file_mime': 'image/jpeg',
      'width_px': 2560,
      'height_px': 1920,
      'taken_at': null,
      'room_id': TestIds.kueche,
      'entry_id': null,
      'after_of': null,
    });
    final client = server.clientFor('phone');
    final api = FakeApi(<String, Object>{
      'POST /sync/push': client,
      'GET /sync/pull': client,
      'GET /files/${DemoFiles.kuecheRegal}': client,
      'GET /files/${DemoFiles.missing}': client,
    });
    await pumpWioApp(
      tester,
      db: db,
      api: api,
      location: _kueche,
      mediaFolder: media.folder,
      mediaStore: _SyncFileStore(media.base),
    );
    expect(find.byType(Image), findsNWidgets(2));
    expect(
      find.text('Foto ist noch nicht auf diesem Gerät.'),
      findsNWidgets(2),
    );

    final container = _container(tester);
    unawaited(container.read(syncProvider.notifier).run());
    await settle(tester);
    await loadPictures(tester);

    expect(File('${media.folder}/${DemoFiles.kuecheRegal}').existsSync(), true);
    expect(find.byType(Image), findsNWidgets(3));
    expect(
      find.text('Foto ist noch nicht auf diesem Gerät.'),
      findsOneWidget,
      reason: 'the missing file is on no device: 404, hint stays',
    );
    expect(server.downloads, hasLength(2));
  });

  testWidgets('"wird geladen" only while the file comes in (D-333)', (
    tester,
  ) async {
    await seedWithPictures(db);
    final media = _mediaWithout(<String>{DemoFiles.kuecheRegal});
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: media.folder,
      mediaStore: MediaStore(() async => media.base),
    );
    final presence = _container(tester).read(mediaPresenceProvider.notifier);
    presence.setLoading(<String>{DemoFiles.kuecheRegal});
    await tester.pump();
    expect(find.text('Foto wird geladen.'), findsOneWidget);
    expect(find.text('Foto ist noch nicht auf diesem Gerät.'), findsOneWidget);

    presence.setLoading(const <String>{});
    await tester.pump();
    expect(find.text('Foto wird geladen.'), findsNothing);
    expect(
      find.text('Foto ist noch nicht auf diesem Gerät.'),
      findsNWidgets(2),
    );
  });

  testWidgets('a screen showing a missing file asks for it first (D-328)', (
    tester,
  ) async {
    await seedWithPictures(db);
    final media = _mediaWithout(<String>{DemoFiles.kuecheRegal});
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: media.folder,
      mediaStore: MediaStore(() async => media.base),
    );
    final wants = _container(tester).read(mediaWantsProvider).all;
    expect(wants, contains(DemoFiles.kuecheRegal));
    expect(wants, contains(DemoFiles.missing));
  });

  testWidgets('a recording that lands turns the hint into Abspielen', (
    tester,
  ) async {
    await seedWithNotes(db);
    final media = _mediaWithout(<String>{DemoFiles.noteAudio});
    await pumpWioApp(
      tester,
      db: db,
      location: _kueche,
      mediaFolder: media.folder,
      mediaStore: MediaStore(() async => media.base),
    );
    final container = _container(tester);
    final presence = container.read(mediaPresenceProvider.notifier);
    presence.setLoading(<String>{DemoFiles.noteAudio});
    await tester.pump();
    await tester.scrollUntilVisible(find.text('Aufnahme wird geladen.'), 200);
    expect(find.text('Aufnahme wird geladen.'), findsOneWidget);
    final playButtons = find.text('Abspielen').evaluate().length;

    File('${media.folder}/${DemoFiles.noteAudio}')
        .writeAsBytesSync(<int>[0, 1]);
    presence.markPresent(DemoFiles.noteAudio);
    await tester.pumpAndSettle();
    expect(find.text('Aufnahme wird geladen.'), findsNothing);
    expect(find.text('Abspielen').evaluate().length, playButtons + 1);
  });
}
