import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;
import 'package:path_provider/path_provider.dart';

/// The device's lasting copies of picture and recording files, in
/// `<Application Support>/media/<sha256>` (D-240). The name is the hash of
/// the bytes, so no table is needed; downloads (#62) use the same folder.
class MediaStore {
  MediaStore(this._base);

  /// The default store in the Application Support folder.
  factory MediaStore.appSupport() =>
      MediaStore(() async => (await getApplicationSupportDirectory()).path);

  final Future<String> Function() _base;
  final Random _random = Random();

  /// Whether this platform keeps files at all (the web does not, D-246).
  bool get supported => true;

  Future<Directory> _folder() async {
    final folder = Directory('${await _base()}/media');
    await folder.create(recursive: true);
    return folder;
  }

  /// Size of the file at [path] in bytes.
  Future<int> size(String path) => File(path).length();

  /// Copies [source] into the folder, named by the hash of the copy itself,
  /// so a source that changes while it is copied cannot give a file whose
  /// name does not match its bytes. The copy appears whole or not at all;
  /// an existing file with the same bytes stays.
  Future<({String sha256, int size, String path})> keep(String source) async {
    final folder = (await _folder()).path;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final temporary = await File(source)
        .copy('$folder/$stamp-${_random.nextInt(1 << 32)}.tmp');
    final size = await temporary.length();
    final digest = (await crypto.sha256.bind(temporary.openRead()).first)
        .toString();
    final target = File('$folder/$digest');
    if (target.existsSync()) {
      await temporary.delete();
    } else {
      await temporary.rename(target.path);
    }
    return (sha256: digest, size: size, path: target.path);
  }

  /// The media folder itself, created when missing (D-240).
  Future<String> folder() async => (await _folder()).path;

  /// Where the file with [sha256] is or would be kept.
  Future<String> pathOf(String sha256) async =>
      '${(await _folder()).path}/$sha256';

  /// Whether the file with [sha256] is on this device.
  Future<bool> has(String sha256) async =>
      File(await pathOf(sha256)).existsSync();

  /// Files a download already holds (D-329): none on the phone's memory.
  Set<String> get memoryHashes => const <String>{};

  /// The bytes of a file kept in memory; phones keep none (the web does,
  /// D-334).
  Uint8List? bytesOf(String sha256) => null;

  /// Marks the files a screen shows, which the web never drops (D-334).
  void keepInMemory(Set<String> shown) {}

  /// Called when the web drops a file from memory; phones drop none.
  set onDropped(void Function(String sha256)? callback) {}

  File _part(String folder, String sha256) => File('$folder/$sha256.part');

  /// Bytes of an unfinished download of [sha256] (D-329); 0 when none.
  Future<int> partSize(String sha256) async {
    final part = _part(await folder(), sha256);
    return part.existsSync() ? part.length() : 0;
  }

  /// Adds [bytes] at the end of the unfinished download of [sha256], or
  /// starts it anew with [restart].
  Future<void> writePart(
    String sha256,
    List<int> bytes, {
    bool restart = false,
  }) async {
    final part = _part(await folder(), sha256);
    await part.writeAsBytes(
      bytes,
      mode: restart ? FileMode.writeOnly : FileMode.writeOnlyAppend,
      flush: true,
    );
  }

  /// Deletes the unfinished download of [sha256].
  Future<void> deletePart(String sha256) async {
    final part = _part(await folder(), sha256);
    if (part.existsSync()) await part.delete();
  }

  /// Gives the finished download its name when its SHA-256 matches
  /// (D-330): true when the file is now kept. A mismatch deletes the part.
  Future<bool> finishPart(String sha256) async {
    final dir = await folder();
    final part = _part(dir, sha256);
    if (!part.existsSync()) return false;
    final digest = (await crypto.sha256.bind(part.openRead()).first).toString();
    if (digest != sha256) {
      await part.delete();
      return false;
    }
    await part.rename('$dir/$sha256');
    return true;
  }
}
