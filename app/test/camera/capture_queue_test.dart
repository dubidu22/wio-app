// The capture queue (plan 058 test T2, D-267, D-268, D-273).
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:wio_app/camera/capture_files.dart';
import 'package:wio_app/camera/capture_queue.dart';
import 'package:wio_app/camera/picture_processor.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/local_writer.dart';
import 'package:wio_app/data/media_writer.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/sync/upload_queue.dart';

import '../support/jpeg_metadata.dart';
import '../support/test_data.dart';

void main() {
  late Directory folder;
  late Directory pluginCache;
  late WioDatabase db;
  late MediaStore media;
  late CaptureFiles files;
  final now = DateTime.utc(2026, 11, 19, 9, 30);

  CaptureQueue queueWith({
    Future<PreparedJpeg> Function(Uint8List shot) prepare = preparePicture,
  }) => CaptureQueue(
    db: db,
    writer: MediaWriter(
      db,
      LocalWriter(db, clock: () => now),
      media,
      UploadStore(() async => '${folder.path}/support'),
      clock: () => now,
    ),
    files: files,
    prepare: prepare,
  );

  /// A shot as the camera plugin leaves it in its own cache folder.
  var shots = 0;
  String shot({int width = 640, int height = 480, int? shade}) {
    final file = File('${pluginCache.path}/CAP${shots++}.jpg')
      ..writeAsBytesSync(
        shotWithLocation(
          width: width,
          height: height,
          shade: shade ?? shots * 40,
        ),
      );
    return file.path;
  }

  List<FileSystemEntity> workFiles() {
    final work = Directory('${folder.path}/temp/wio-capture');
    return work.existsSync() ? work.listSync() : <FileSystemEntity>[];
  }

  const room = (
    customerId: TestIds.familieBeispiel,
    roomId: TestIds.kueche,
    afterOf: null,
  );

  setUp(() async {
    folder = await Directory.systemTemp.createTemp('capture_queue_test');
    pluginCache = await Directory('${folder.path}/plugin').create();
    db = memoryDatabase();
    await seedTestData(db);
    media = MediaStore(() async => '${folder.path}/support');
    files = CaptureFiles(() async => '${folder.path}/temp');
  });
  tearDown(() async {
    await db.close();
    await folder.delete(recursive: true);
  });

  test('a shot becomes one stripped picture with its upload', () async {
    final queue = queueWith();
    final session = CaptureSession(room);
    final path = shot(width: 2880, height: 1620);

    queue.add(session, path, DateTime.utc(2026, 11, 19, 9, 12));
    expect(session.pending, 1);
    await queue.idle;

    expect((session.stored, session.pending, session.failed), (1, 0, 0));
    final picture = (await db.select(db.pictures).get()).single;
    expect(picture.roomId, TestIds.kueche);
    expect(picture.customerId, TestIds.familieBeispiel);
    expect(picture.workspaceId, TestIds.workspace);
    expect(picture.fileMime, 'image/jpeg');
    expect((picture.widthPx, picture.heightPx), (2560, 1440));
    expect(DateTime.parse(picture.takenAt!), DateTime.utc(2026, 11, 19, 9, 12));

    // The kept file is the one that uploads, and it carries no metadata.
    final upload = (await db.select(db.uploads).get()).single;
    expect(upload.sha256, picture.fileSha256);
    final kept = File(await media.pathOf(picture.fileSha256));
    final bytes = kept.readAsBytesSync();
    expect(sha256.convert(bytes).toString(), picture.fileSha256);
    expect(bytes.length, picture.fileBytes);
    expect(jpegHeaderMarkers(bytes).where(isMetadataMarker), isEmpty);
    expect(img.decodeJpgExif(bytes)?.isEmpty ?? true, isTrue);
    final uploadCopy = File(upload.path).readAsBytesSync();
    expect(jpegHeaderMarkers(uploadCopy).where(isMetadataMarker), isEmpty);

    // Neither the plugin's shot nor any working file stays behind.
    expect(File(path).existsSync(), isFalse);
    expect(workFiles(), isEmpty);
  });

  test('quick presses are stored one after the other in press order', () async {
    final queue = queueWith();
    final session = CaptureSession(room);
    for (var minute = 1; minute <= 3; minute++) {
      queue.add(session, shot(), DateTime.utc(2026, 11, 19, 9, minute));
    }
    expect(session.pending, 3);
    await queue.idle;

    expect((session.stored, session.pending), (3, 0));
    final rows = await db.select(db.pictures).get();
    // Ids are UUIDv7, so id order is the order the rows were written.
    rows.sort((a, b) => a.id.compareTo(b.id));
    expect(rows.map((p) => DateTime.parse(p.takenAt!).minute), <int>[1, 2, 3]);
    expect(await db.select(db.uploads).get(), hasLength(3));
  });

  test('a customer target makes a picture without a room', () async {
    final queue = queueWith();
    final session = CaptureSession((
      customerId: TestIds.familieBeispiel,
      roomId: null,
      afterOf: null,
    ));
    queue.add(session, shot(), now);
    await queue.idle;

    final picture = (await db.select(db.pictures).get()).single;
    expect(picture.roomId, isNull);
    expect(picture.customerId, TestIds.familieBeispiel);
  });

  test(
    'an after target links after_of to the before picture (D-276)',
    () async {
      final queue = queueWith();
      queue.add(CaptureSession(room), shot(shade: 10), now);
      await queue.idle;
      final before = (await db.select(db.pictures).get()).single;

      // The after camera of a room picture is opened with only the customer
      // known; room and customer come from the before picture.
      final session = CaptureSession((
        customerId: TestIds.familieBeispiel,
        roomId: null,
        afterOf: before.id,
      ));
      queue.add(session, shot(shade: 90), now);
      queue.add(session, shot(shade: 170), now);
      await queue.idle;

      expect((session.stored, session.failed), (2, 0));
      final after = await (db.select(
        db.pictures,
      )..where((p) => p.id.isNotValue(before.id))).get();
      expect(after, hasLength(2));
      for (final picture in after) {
        expect(picture.afterOf, before.id);
        expect(picture.roomId, TestIds.kueche);
        expect(picture.customerId, TestIds.familieBeispiel);
        expect(picture.fileSha256, isNot(before.fileSha256));
      }
      expect(await db.select(db.uploads).get(), hasLength(3));
    },
  );

  test('an after shot of a deleted picture counts as failed', () async {
    final queue = queueWith();
    queue.add(CaptureSession(room), shot(), now);
    await queue.idle;
    final before = (await db.select(db.pictures).get()).single;
    await MediaWriter(
      db,
      LocalWriter(db, clock: () => now),
      media,
      UploadStore(() async => '${folder.path}/support'),
      clock: () => now,
    ).deletePicture(before.id);

    final session = CaptureSession((
      customerId: TestIds.familieBeispiel,
      roomId: TestIds.kueche,
      afterOf: before.id,
    ));
    queue.add(session, shot(), now);
    await queue.idle;

    expect((session.stored, session.failed), (0, 1));
    expect(await db.select(db.pictures).get(), hasLength(1));
    expect(await db.select(db.uploads).get(), hasLength(1));
    expect(workFiles(), isEmpty);
  });

  test('a shot that cannot be prepared leaves no row and no upload', () async {
    final queue = queueWith(
      prepare: (_) async => throw const UnreadablePicture(),
    );
    final session = CaptureSession(room);
    final path = shot();
    queue.add(session, path, now);
    await queue.idle;

    expect((session.stored, session.pending, session.failed), (0, 0, 1));
    expect(await db.select(db.pictures).get(), isEmpty);
    expect(await db.select(db.uploads).get(), isEmpty);
    expect(File(path).existsSync(), isFalse);
    expect(workFiles(), isEmpty);
  });

  test('a failed shot does not stop the next one', () async {
    var calls = 0;
    final queue = queueWith(
      prepare: (bytes) {
        if (calls++ == 0) throw const UnreadablePicture();
        return preparePicture(bytes);
      },
    );
    final session = CaptureSession(room);
    queue.add(session, shot(), now);
    queue.add(session, shot(), now);
    await queue.idle;
    expect((session.stored, session.failed), (1, 1));
  });

  test('sweep deletes shots left by an earlier run, not this run\'s', () async {
    final left = await files.takeOver(shot());
    File(left)
        .setLastModifiedSync(DateTime.now().subtract(const Duration(hours: 1)));
    final queue = queueWith();
    final fresh = await files.takeOver(shot());
    await queue.sweep();
    expect(File(left).existsSync(), isFalse);
    expect(File(fresh).existsSync(), isTrue);
  });
}
