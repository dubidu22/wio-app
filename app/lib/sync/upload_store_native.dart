import 'dart:io';
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

  /// Copies [source] into the folder as [sha256] unless a copy is there;
  /// returns the copy's path. The copy appears whole or not at all.
  Future<String> keep(String source, String sha256) async {
    final target = File('${(await _folder()).path}/$sha256');
    if (!target.existsSync()) {
      final temporary = await File(source).copy('${target.path}.tmp');
      await temporary.rename(target.path);
    }
    return target.path;
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

  /// Deletes copies whose name is not in [keep] (D-215).
  Future<void> sweep(Set<String> keep) async {
    final folder = await _folder();
    await for (final entry in folder.list()) {
      final name = entry.uri.pathSegments.last;
      if (entry is File && !keep.contains(name)) await remove(entry.path);
    }
  }
}
