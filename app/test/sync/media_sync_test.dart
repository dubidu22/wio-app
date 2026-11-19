// Pictures and notes through the sync loop against the fake sync server
// (plan 054 tests T10 to T13, D-238 to D-243). No real network.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wio_api/wio_api.dart' show SyncApi;
import 'package:wio_app/auth/auth_client.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/media_writer.dart';
import 'package:wio_app/data/queries.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/sync/sync_engine.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/fake_api.dart';
import '../support/fake_sync_server.dart';
import '../support/test_data.dart';

const String ws = FakeSyncServer.defaultWorkspace;
const String customer = '01970000-0000-7000-8000-0000000000c1';
const String site = '01970000-0000-7000-8000-0000000000a1';
const String room = '01970000-0000-7000-8000-0000000000b1';
const String sha =
    'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

/// One phone with its own media folder.
class Phone {
  Phone(this.server, String name, this.folder) : db = memoryDatabase() {
    media = MediaStore(() async => '${folder.path}/$name');
    writer = MediaWriter(
      db,
      LocalWriter(db),
      media,
      UploadStore(() async => '${folder.path}/$name'),
    );
    engine = SyncEngine(
      db: db,
      api: SyncApi(
        buildApiServer(
          fakeApiBase,
          server.clientFor(name),
          exampleSession,
          ApiHooks(tooOld: () => null, reportTooOld: (_) {}),
        ),
      ),
      workspaceId: ws,
      tooOld: () => false,
      clock: () => DateTime.utc(2026, 11, 19, 12),
    );
    addTearDown(db.close);
  }

  final FakeSyncServer server;
  final Directory folder;
  final WioDatabase db;
  late final MediaStore media;
  late final MediaWriter writer;
  late final SyncEngine engine;

  Future<String> source(String content) async {
    final file = File('${folder.path}/src-${content.hashCode}');
    await file.writeAsString(content);
    return file.path;
  }

  Future<String> takePicture(String content) async => writer.addPicture(
    workspaceId: ws,
    file: PreparedPicture(
      path: await source(content),
      mime: 'image/jpeg',
      widthPx: 2560,
      heightPx: 1920,
    ),
    roomId: room,
  );

  Future<int> outbox() async => (await db.select(db.outbox).get()).length;
}

void main() {
  late FakeSyncServer server;
  late Directory folder;

  setUp(() async {
    server = FakeSyncServer();
    folder = await Directory.systemTemp.createTemp('media_sync_test');
    server
      ..put('customers', customer, <String, Object?>{
        'name': 'Familie Beispiel',
      })
      ..put('sites', site, <String, Object?>{'customer_id': customer})
      ..put('rooms', room, <String, Object?>{
        'customer_id': customer,
        'site_id': site,
        'name': 'Küche',
      });
  });
  tearDown(() => folder.delete(recursive: true));

  test('a picture and a note are pushed, confirmed and pulled (T10)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    final picture = await phone.takePicture('jpeg');
    final note = await phone.writer.addNote(
      workspaceId: ws,
      subjectType: 'picture',
      subjectId: picture,
      text: 'Riss in der Fliese',
    );

    expect((await phone.engine.run()).stop, SyncStop.done);
    expect(await phone.outbox(), 0);
    expect(server.live('pictures')[picture]!['room_id'], room);
    expect(server.live('pictures')[picture]!['customer_id'], customer);
    expect(server.live('notes')[note]!['text'], 'Riss in der Fliese');

    final rows = await watchPicturesOfRoom(phone.db, room).first;
    expect(rows.single.id, picture);
    expect(rows.single.revision, server.live('pictures')[picture]!['revision']);
    final notes = await watchNotesOf(phone.db, 'picture', picture).first;
    expect(notes.single.revision, isNotNull);
  });

  test(
    "another device's picture and note arrive as typed rows (T11)",
    () async {
      const picture = '01970000-0000-7000-8000-0000000000e1';
      const note = '01970000-0000-7000-8000-0000000000e2';
      server
        ..put('pictures', picture, <String, Object?>{
          'customer_id': customer,
          'file_sha256': sha,
          'file_bytes': 900000,
          'file_mime': 'image/jpeg',
          'width_px': 2560,
          'height_px': 1440,
          'taken_at': '2026-11-19T08:00:00.000Z',
          'room_id': room,
          'entry_id': null,
          'after_of': null,
        })
        ..put('notes', note, <String, Object?>{
          'customer_id': customer,
          'subject_type': 'room',
          'subject_id': room,
          'text': null,
          'audio_sha256': sha,
          'audio_bytes': 4000,
          'audio_seconds': 4,
          'transcript': 'Wasserfleck',
          'transcript_source': 'device',
        });
      final phone = Phone(server, 'b', folder);
      await phone.engine.pull();

      final rows = await watchPicturesOfRoom(phone.db, room).first;
      expect(rows.single.fileSha256, sha);
      expect(rows.single.heightPx, 1440);
      final notes = await watchNotesOf(phone.db, 'room', room).first;
      expect(notes.single.transcript, 'Wasserfleck');
      expect(notes.single.audioSeconds, 4);
      expect(await phone.media.has(sha), isFalse, reason: 'download is #62');
    },
  );

  test('a refused picture disappears and is listed (T12)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    server.refuse = (c) => c['entity'] == 'pictures' ? 'permission' : null;
    final picture = await phone.takePicture('jpeg');
    await phone.engine.push();
    expect(await watchPicturesOfRoom(phone.db, room).first, isEmpty);
    final rejected =
        (await phone.db.select(phone.db.rejectedChanges).get()).single;
    expect(rejected.entityId, picture);
    expect(rejected.reason, 'permission');
  });

  test('a 410 resync keeps an unsent picture (T13)', () async {
    final phone = Phone(server, 'a', folder);
    await phone.engine.pull();
    final picture = await phone.takePicture('jpeg');
    server.put(
      'customers',
      '01970000-0000-7000-8000-0000000000c9',
      <String, Object?>{'name': 'Neu'},
    );
    server.resyncOnPull = 1;
    expect((await phone.engine.pull()).stop, SyncStop.done);
    expect(await phone.outbox(), 1);
    final rows = await watchPicturesOfRoom(phone.db, room).first;
    expect(rows.single.id, picture);
    expect(rows.single.revision, isNull);
  });
}
