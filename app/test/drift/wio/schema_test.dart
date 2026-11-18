import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wio_app/data/database.dart';

import 'generated/schema.dart';

/// The local schema must match its committed dump (D-65). A new schema
/// version adds a dump with `dart run drift_dev make-migrations`, and this
/// file gains a step test from the previous version to the new one.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('schema v1 matches drift_schemas/wio/drift_schema_v1.json', () async {
    final schema = await verifier.schemaAt(1);
    final db = WioDatabase(schema.newConnection());
    addTearDown(db.close);
    await verifier.migrateAndValidate(db, 1);
  });
}
