// File presence (plan 062, D-332) and the web's memory (D-334).
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/media/media_presence.dart';
import 'package:wio_app/media/media_store.dart';
import 'package:wio_app/media/media_store_web.dart' as web;
import 'package:wio_app/shell/providers.dart';

import '../support/test_data.dart';

final String a = 'a' * 64;
final String b = 'b' * 64;
final String c = 'c' * 64;

PicturesCompanion _row(String id, String sha) => PicturesCompanion.insert(
  id: id,
  workspaceId: TestIds.workspace,
  fileSha256: sha,
  fileBytes: 10,
  fileMime: 'image/jpeg',
  widthPx: 1,
  heightPx: 1,
);

Future<void> _rest() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  test('one listing at start; new hashes checked once; a hash known present '
      'is never checked again (D-332)', () async {
    final folder = Directory.systemTemp.createTempSync('presence');
    addTearDown(() => folder.deleteSync(recursive: true));
    File('${folder.path}/$a').writeAsStringSync('a');
    File('${folder.path}/$a.part').writeAsStringSync('x');
    File('${folder.path}/1234.tmp').writeAsStringSync('x');
    final db = memoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWithValue(db),
        mediaStoreProvider.overrideWithValue(
          MediaStore(() async => folder.parent.path),
        ),
        mediaFolderProvider.overrideWith((ref) async => folder.path),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(mediaPresenceProvider, (_, _) {});
    addTearDown(sub.close);
    expect(container.read(mediaPresenceProvider).listed, isFalse);
    await _rest();
    expect(container.read(mediaPresenceProvider).present, <String>{a});

    // A row for a file that is here (as after a capture) and one that is not.
    File('${folder.path}/$b').writeAsStringSync('b');
    await db.into(db.pictures).insert(_row('p1', b));
    await db.into(db.pictures).insert(_row('p2', c));
    await _rest();
    expect(container.read(mediaPresenceProvider).present, <String>{a, b});
    expect(container.read(mediaPresenceProvider).of(c), MediaFileState.missing);

    // Known present: no second look, even if the file went away.
    File('${folder.path}/$a').deleteSync();
    await db.into(db.pictures).insert(_row('p3', a));
    await _rest();
    expect(container.read(mediaPresenceProvider).of(a), MediaFileState.present);

    // Loading, then a download lands.
    final notifier = container.read(mediaPresenceProvider.notifier);
    notifier.setLoading(<String>{c});
    expect(container.read(mediaPresenceProvider).of(c), MediaFileState.loading);
    notifier.markPresent(c);
    expect(container.read(mediaPresenceProvider).of(c), MediaFileState.present);
    expect(container.read(mediaPresenceProvider).loading, isEmpty);
  });

  test('no media folder: everything missing, nothing unknown', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: <Override>[
        databaseProvider.overrideWithValue(db),
        mediaStoreProvider.overrideWithValue(
          MediaStore(() => Future<String>.error('no files')),
        ),
        mediaFolderProvider.overrideWith((ref) async => null),
      ],
    );
    addTearDown(container.dispose);
    final sub = container.listen(mediaPresenceProvider, (_, _) {});
    addTearDown(sub.close);
    await _rest();
    expect(container.read(mediaPresenceProvider).of(a), MediaFileState.missing);
  });

  test(
    'wants count screens; the first want of a file is announced (D-328)',
    () {
      final wants = MediaWants();
      final announced = <String>[];
      final changes = <Set<String>>[];
      wants
        ..onWanted = announced.add
        ..onChanged = changes.add
        ..add(a)
        ..add(a)
        ..remove(a);
      expect(wants.all, <String>{a});
      wants.remove(a);
      expect(wants.all, isEmpty);
      expect(announced, <String>[a]);
      expect(changes, <Set<String>>[
        <String>{a},
        <String>{},
      ]);
    },
  );

  test('screens never stat files in build (PR 68 N3, D-332)', () {
    for (final folder in <String>['pictures', 'notes', 'rooms', 'camera']) {
      for (final file in Directory(
        'lib/$folder',
      ).listSync().whereType<File>()) {
        if (file.path.endsWith('capture_files_native.dart')) continue;
        expect(
          file.readAsStringSync(),
          isNot(contains('existsSync')),
          reason: file.path,
        );
      }
    }
  });

  group('web memory (D-334)', () {
    Uint8List bytes(int size, int seed) =>
        Uint8List.fromList(List<int>.filled(size, seed));
    String hash(List<int> data) => crypto.sha256.convert(data).toString();

    Future<String> fetch(web.MediaStore store, Uint8List data) async {
      final sha = hash(data);
      await store.writePart(sha, data.sublist(0, data.length ~/ 2));
      expect(await store.partSize(sha), data.length ~/ 2);
      await store.writePart(sha, data.sublist(data.length ~/ 2));
      expect(await store.finishPart(sha), isTrue);
      return sha;
    }

    test('keeps a checked file, refuses a wrong one', () async {
      final store = web.MediaStore(() async => '');
      final data = bytes(100, 1);
      final sha = await fetch(store, data);
      expect(store.bytesOf(sha), data);
      expect(store.memoryHashes, <String>{sha});
      await store.writePart(c, data);
      expect(await store.finishPart(c), isFalse);
      expect(store.memoryHashes, <String>{sha});
      expect(store.supported, isFalse, reason: 'the web does not capture');
    });

    test('drops the least recently used first, never one on screen', () async {
      final store = web.MediaStore(() async => '', limit: 250);
      final dropped = <String>[];
      store.onDropped = dropped.add;
      final one = await fetch(store, bytes(100, 1));
      final two = await fetch(store, bytes(100, 2));
      store.keepInMemory(<String>{one});
      store.bytesOf(two); // two is now the most recently used
      final three = await fetch(store, bytes(100, 3));
      // one is shown, so two goes although it was used later.
      expect(dropped, <String>[two]);
      expect(store.memoryHashes, <String>{one, three});
    });
  });
}
