import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

/// Issue #15, D-40: the web fallback fonts in web/assets/fallback-fonts/
/// match the table in their README, every family has its licence, and no
/// file is there that the table does not name. Which paths the engine asks
/// for is checked on the built app by tools/ci/web-fallback-fonts-check.mjs.
void main() {
  const dir = 'web/assets/fallback-fonts';
  final readme = File('$dir/README.md').readAsStringSync();

  final rows = RegExp(
    r'^\| `([a-z0-9]+/v\d+/[A-Za-z0-9_.-]+\.woff2)` \| (\d+) \| ([0-9a-f]{64}) \|',
    multiLine: true,
  ).allMatches(readme).toList();

  final onDisk = Directory(dir)
      .listSync(recursive: true)
      .whereType<File>()
      .map((f) => f.path.replaceAll(r'\', '/').substring(dir.length + 1))
      .where((path) => path.endsWith('.woff2'))
      .toSet();

  test('the table lists emoji and symbols, and exactly the files on disk', () {
    final listed = rows.map((r) => r[1]!).toSet();
    expect(listed, hasLength(rows.length));
    expect(listed.where((p) => p.startsWith('notocoloremoji/')), isNotEmpty);
    expect(listed, equals(onDisk));
  });

  for (final row in rows) {
    final path = row[1]!;
    test('$path has the listed size and SHA-256', () {
      final bytes = File('$dir/$path').readAsBytesSync();
      expect(bytes.length, int.parse(row[2]!));
      expect(sha256.convert(bytes).toString(), row[3]);
    });
  }

  test('every family ships its OFL licence text', () {
    final families = onDisk.map((p) => p.split('/').first).toSet();
    for (final family in families) {
      final licence = File('$dir/$family/OFL.txt');
      expect(licence.existsSync(), isTrue, reason: family);
      expect(
        licence.readAsStringSync(),
        contains('SIL Open Font License, Version 1.1'),
        reason: family,
      );
    }
  });
}
