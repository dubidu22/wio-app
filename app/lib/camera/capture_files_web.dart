import 'dart:typed_data';

/// The web build takes no pictures (D-274) and records no voice notes
/// (D-295); nothing here is ever called
/// except [sweep], which has nothing to do.
class CaptureFiles {
  CaptureFiles(Future<String> Function() base);

  factory CaptureFiles.temporary() => CaptureFiles(() async => '');

  Future<String> takeOver(String source) => throw UnsupportedError('web');

  Future<String> newRecordingPath() => throw UnsupportedError('web');

  Future<Uint8List> read(String path) => throw UnsupportedError('web');

  Future<void> overwrite(String path, Uint8List bytes) =>
      throw UnsupportedError('web');

  Future<String> write(Uint8List bytes) => throw UnsupportedError('web');

  Future<void> delete(String path) async {}

  Future<void> sweep({required DateTime before}) async {}
}
