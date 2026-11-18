import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// D-70: the committed web database files match the table in web/README.md,
/// and that table matches the package versions in pubspec.lock.
void main() {
  final readme = File('web/README.md').readAsStringSync();
  final lock = File('pubspec.lock').readAsStringSync();

  final rows = RegExp(
    r'^\| `([^`]+)` \| (\S+) \| (\S+) \| \S+ \| ([0-9a-f]{64}) \|',
    multiLine: true,
  ).allMatches(readme).toList();

  test('README lists both files', () {
    expect(rows.map((r) => r[1]), <String>['sqlite3.wasm', 'drift_worker.js']);
  });

  for (final row in rows) {
    final file = row[1]!;
    final package = row[2]!;
    final version = row[3]!;
    final sha256Hex = row[4]!;

    test('$file has the listed SHA-256', () {
      final digest = sha256.convert(File('web/$file').readAsBytesSync());
      expect(digest.toString(), sha256Hex);
    });

    test('$file belongs to $package $version from pubspec.lock', () {
      final locked = RegExp(
        '^  $package:\\n(?:    .*\\n)*?    version: "([^"]+)"',
        multiLine: true,
      ).firstMatch(lock)?[1];
      expect(locked, version);
    });
  }
}
