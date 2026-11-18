import 'dart:typed_data';

/// On the web no file is stored for upload yet; that comes with pictures in
/// M2 (D-202, D-217). The worker never reaches these methods, because no
/// upload row can exist.
class UploadStore {
  UploadStore(Future<String> Function() base);

  factory UploadStore.appSupport() => UploadStore(() async => '');

  Never _unsupported() =>
      throw UnsupportedError('Uploads on the web come with M2 (D-217).');

  Future<({String sha256, int size})> hash(String path) async => _unsupported();

  Future<String> keep(String source, String sha256) async => _unsupported();

  Future<Uint8List> read(String path, int start, int length) async =>
      _unsupported();

  Future<bool> exists(String path) async => false;

  Future<void> remove(String path) async {}

  Future<void> sweep(Set<String> keep) async {}
}
