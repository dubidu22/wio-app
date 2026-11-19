/// On the web no picture or recording is kept in M2: the web build shows
/// and plays, but does not capture (D-222, D-246). Where downloaded files
/// live on the web is decided by #62.
class MediaStore {
  MediaStore(Future<String> Function() base);

  factory MediaStore.appSupport() => MediaStore(() async => '');

  /// Whether this platform keeps files at all.
  bool get supported => false;

  Never _unsupported() =>
      throw UnsupportedError('The web build does not keep files (D-246).');

  Future<int> size(String path) async => _unsupported();

  Future<({String sha256, int size, String path})> keep(String source) async =>
      _unsupported();

  Future<String> pathOf(String sha256) async => _unsupported();

  Future<bool> has(String sha256) async => false;
}
