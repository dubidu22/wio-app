import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

/// The app's local database (D-36, D-64). Schema changes are numbered steps
/// with a committed schema dump and a migration test (D-65).
@DriftDatabase(tables: <Type>[Customers, Sites, Rooms, Jobs, Outbox, SyncState])
class WioDatabase extends _$WioDatabase {
  WioDatabase(super.executor, {this.onFirstCreate});

  /// Runs once, after the tables of a new database exist: the first start
  /// after an install. The app deletes any stored session there, because the
  /// iOS keychain keeps it across an uninstall (D-122).
  final Future<void> Function()? onFirstCreate;

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await onFirstCreate?.call();
    },
    // Forward-only. A schema this app does not know is never dropped or
    // recreated: the outbox may hold changes the server has never seen, so
    // the database fails to open and the screens show the error (D-65).
    onUpgrade: (m, from, to) async {
      throw StateError('No migration from local schema $from to $to.');
    },
  );
}
