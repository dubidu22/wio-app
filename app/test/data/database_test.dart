import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:wio_app/data/database.dart';
import 'package:wio_app/data/ids.dart';

import '../support/test_data.dart';

void main() {
  test('schema v2 creates the nine tables', () async {
    final db = memoryDatabase();
    addTearDown(db.close);
    final rows = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )
        .get();
    expect(rows.map((r) => r.read<String>('name')), <String>[
      'customers',
      'jobs',
      'outbox',
      'rejected_changes',
      'rooms',
      'server_records',
      'sites',
      'sync_state',
      'uploads',
    ]);
  });

  test('an unknown schema is kept, not dropped (D-65)', () async {
    final dir = await Directory.systemTemp.createTemp('wio_db_test');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/wio.sqlite');

    final raw = sqlite3.open(file.path);
    raw
      ..execute('CREATE TABLE outbox (change_id TEXT)')
      ..execute("INSERT INTO outbox VALUES ('not-yet-pushed')")
      ..execute('PRAGMA user_version = 99');
    raw.close();

    final db = WioDatabase(NativeDatabase(file));
    await expectLater(db.customSelect('SELECT 1').get(), throwsA(anything));
    await db.close();

    final check = sqlite3.open(file.path);
    addTearDown(check.close);
    expect(
      check.select('SELECT change_id FROM outbox').single['change_id'],
      'not-yet-pushed',
    );
    expect(check.userVersion, 99);
  });

  test('ids are canonical lower-case UUID v7 with the current time', () {
    final before = DateTime.now().millisecondsSinceEpoch;
    final id = newUuidV7();
    final after = DateTime.now().millisecondsSinceEpoch;
    expect(
      id,
      matches(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ),
      ),
    );
    final millis = int.parse(
      id.replaceAll('-', '').substring(0, 12),
      radix: 16,
    );
    expect(millis, inInclusiveRange(before, after));
    expect(newUuidV7(), isNot(id));
  });
}
