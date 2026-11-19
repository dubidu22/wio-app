import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

/// The camera's working folder `<temporary>/wio-capture` (D-268). Shots
/// and prepared pictures live here only until they are stored; nothing in
/// it is ever uploaded, and whatever is left after a crash goes at the next
/// start.
class CaptureFiles {
  CaptureFiles(this._base);

  /// The default folder in the app's temporary folder.
  factory CaptureFiles.temporary() =>
      CaptureFiles(() async => (await getTemporaryDirectory()).path);

  final Future<String> Function() _base;
  final Random _random = Random();

  Future<Directory> _folder() async {
    final folder = Directory('${await _base()}/wio-capture');
    await folder.create(recursive: true);
    return folder;
  }

  Future<String> _newPath(String suffix) async {
    final stamp = DateTime.now().microsecondsSinceEpoch;
    return '${(await _folder()).path}/$stamp-${_random.nextInt(1 << 32)}'
        '$suffix';
  }

  /// Moves the camera's shot at [source] into the working folder, so the
  /// plugin's own copy does not stay behind. Returns the new path.
  Future<String> takeOver(String source) async {
    final target = await _newPath('.shot');
    final file = File(source);
    try {
      await file.rename(target);
    } on FileSystemException {
      await file.copy(target);
      await file.delete();
    }
    return target;
  }

  Future<Uint8List> read(String path) => File(path).readAsBytes();

  /// Writes [bytes] to a new file in the working folder.
  Future<String> write(Uint8List bytes) async {
    final path = await _newPath('.jpg');
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  Future<void> delete(String path) async {
    final file = File(path);
    if (file.existsSync()) await file.delete();
  }

  /// Deletes what an earlier run left in the working folder (D-268):
  /// every file last changed before [before], so shots of this run stay.
  Future<void> sweep({required DateTime before}) async {
    final folder = await _folder();
    await for (final entry in folder.list()) {
      try {
        if (entry.statSync().modified.isBefore(before)) {
          await entry.delete(recursive: true);
        }
      } on FileSystemException {
        // Gone already, or taken by this run in the meantime.
      }
    }
  }
}
