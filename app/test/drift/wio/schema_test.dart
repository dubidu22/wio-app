import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';

import 'generated/schema.dart';

/// The local schema must match its committed dump (D-65). A new schema
/// version adds a dump with `dart run drift_dev make-migrations`, and this
/// migration_test.dart covers every step from an older version.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('the current schema matches its dump', () async {
    final schema = await verifier.schemaAt(2);
    final db = WioDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 2);
  });
}
