import 'dart:collection';
import 'dart:typed_data';

import 'package:crypto/crypto.dart' as crypto;

/// Most bytes the web keeps in memory (D-334).
const int webMemoryBytes = 128 * 1024 * 1024;

/// The web keeps no files on disk: it does not capture (D-222, D-246), and
/// files fetched from the server live in memory for the page's life only,
/// at most [webMemoryBytes], least recently used dropped first, never one
/// a screen shows (D-334). Nothing about customers stays in the browser.
class MediaStore {
  MediaStore(Future<String> Function() base, {this.limit = webMemoryBytes});

  factory MediaStore.appSupport() => MediaStore(() async => '');

  /// Most bytes kept in memory.
  final int limit;

  /// Kept files, least recently used first.
  final LinkedHashMap<String, Uint8List> _files =
      LinkedHashMap<String, Uint8List>();
  final Map<String, BytesBuilder> _parts = <String, BytesBuilder>{};
  Set<String> _shown = const <String>{};
  int _bytes = 0;

  /// Told when a file leaves memory, so its state goes back to missing.
  void Function(String sha256)? onDropped;

  /// Whether this platform keeps files on disk and captures.
  bool get supported => false;

  Never _unsupported() =>
      throw UnsupportedError('The web build does not keep files (D-246).');

  Future<int> size(String path) async => _unsupported();

  Future<({String sha256, int size, String path})> keep(String source) async =>
      _unsupported();

  Future<String> folder() async => _unsupported();

  Future<String> pathOf(String sha256) async => _unsupported();

  Future<bool> has(String sha256) async => _files.containsKey(sha256);

  /// Files kept in memory.
  Set<String> get memoryHashes => _files.keys.toSet();

  /// The bytes of a kept file, now the most recently used.
  Uint8List? bytesOf(String sha256) {
    final bytes = _files.remove(sha256);
    if (bytes == null) return null;
    _files[sha256] = bytes;
    return bytes;
  }

  /// The files screens show now; never dropped (D-334).
  void keepInMemory(Set<String> shown) => _shown = shown;

  Future<int> partSize(String sha256) async => _parts[sha256]?.length ?? 0;

  Future<void> writePart(
    String sha256,
    List<int> bytes, {
    bool restart = false,
  }) async {
    final part = restart ? BytesBuilder() : (_parts[sha256] ?? BytesBuilder());
    part.add(bytes);
    _parts[sha256] = part;
  }

  Future<void> deletePart(String sha256) async => _parts.remove(sha256);

  /// Keeps the finished download when its SHA-256 matches (D-330).
  Future<bool> finishPart(String sha256) async {
    final part = _parts.remove(sha256);
    if (part == null) return false;
    final bytes = part.takeBytes();
    if (crypto.sha256.convert(bytes).toString() != sha256) return false;
    _files.remove(sha256);
    _files[sha256] = bytes;
    _bytes += bytes.length;
    _dropOld(keep: sha256);
    return true;
  }

  void _dropOld({required String keep}) {
    if (_bytes <= limit) return;
    for (final sha in _files.keys.toList()) {
      if (_bytes <= limit) return;
      if (sha == keep || _shown.contains(sha)) continue;
      _bytes -= _files.remove(sha)!.length;
      onDropped?.call(sha);
    }
  }
}
