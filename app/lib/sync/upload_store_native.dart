import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:path_provider/path_provider.dart';

/// The app's own copies of files waiting for upload, in
/// `<Application Support>/uploads/<sha256>` (D-202, D-210).
class UploadStore {
  UploadStore(this._base);

  /// The default store in the Application Support folder.
  factory UploadStore.appSupport() =>
      UploadStore(() async => (await getApplicationSupportDirectory()).path);

  final Future<String> Function() _base;
  final Random _random = Random();

  Future<Directory> _folder() async {
    final folder = Directory('${await _base()}/uploads');
    await folder.create(recursive: true);
    return folder;
  }

  /// SHA-256 and size of the file at [path], read as a stream.
  Future<({String sha256, int size})> hash(String path) async {
    final file = File(path);
    final size = await file.length();
    final digest = await sha256.bind(file.openRead()).first;
    return (sha256: digest.toString(), size: size);
  }

  /// Size of the file at [path] in bytes.
  Future<int> size(String path) => File(path).length();

  /// Copies [source] into the folder and names the copy by the hash of the
  /// copy itself, so a source that changes while it is copied cannot give
  /// a row whose bytes do not match its name (PR 51 review N3). The copy
  /// appears whole or not at all; an existing copy of the same bytes stays.
  Future<({String sha256, int size, String path})> keep(String source) async {
    final folder = (await _folder()).path;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final temporary = await File(source)
        .copy('$folder/$stamp-${_random.nextInt(1 << 32)}.tmp');
    // The sweep spares recent files; a copy may keep the source's time.
    await temporary.setLastModified(DateTime.now());
    final (:sha256, :size) = await hash(temporary.path);
    final target = File('$folder/$sha256');
    if (target.existsSync()) {
      await remove(temporary.path);
    } else {
      await temporary.rename(target.path);
    }
    return (sha256: sha256, size: size, path: target.path);
  }

  /// At most [length] bytes of [path] from [start].
  Future<Uint8List> read(String path, int start, int length) async {
    final file = await File(path).open();
    try {
      await file.setPosition(start);
      return await file.read(length);
    } finally {
      await file.close();
    }
  }

  Future<bool> exists(String path) async => File(path).existsSync();

  /// Deletes [path]; a missing file is fine.
  Future<void> remove(String path) async {
    try {
      await File(path).delete();
    } on FileSystemException {
      // Already gone.
    }
  }

  /// Deletes copies (and left-over `.tmp` files) whose name is not in
  /// [keep] and that were last changed before [before] (D-215). Files
  /// written after that, by an enqueue running alongside the sweep, stay
  /// (PR 51 review S1).
  Future<void> sweep(Set<String> keep, {required DateTime before}) async {
    final folder = await _folder();
    await for (final entry in folder.list()) {
      if (entry is! File) continue;
      if (keep.contains(entry.uri.pathSegments.last)) continue;
      try {
        if (entry.lastModifiedSync().isBefore(before)) {
          await remove(entry.path);
        }
      } on FileSystemException {
        // Renamed or deleted meanwhile.
      }
    }
  }
}
