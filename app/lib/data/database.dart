import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// The app's local database (D-36, D-64). Schema changes are numbered steps
/// with a committed schema dump and a migration test (D-65).
@DriftDatabase(tables: <Type>[Customers, Sites, Rooms, Jobs, Outbox, SyncState])
class WioDatabase extends _$WioDatabase {
  WioDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    // Forward-only. A schema this app does not know is never dropped or
    // recreated: the outbox may hold changes the server has never seen, so
    // the database fails to open and the screens show the error (D-65).
    onUpgrade: (m, from, to) async {
      throw StateError('No migration from local schema $from to $to.');
    },
  );
}
