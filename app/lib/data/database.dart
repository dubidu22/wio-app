import 'package:drift/drift.dart';

import '../sync/rebuild.dart';
import 'tables.dart';

part 'database.g.dart';

/// The app's local database (D-36, D-64). Schema changes are numbered steps
/// with a committed schema dump and a migration test (D-65).
@DriftDatabase(
  tables: <Type>[
    Customers,
    Sites,
    Rooms,
    Jobs,
    Pictures,
    Notes,
    Outbox,
    SyncState,
    ServerRecords,
    RejectedChanges,
    Uploads,
  ],
)
class WioDatabase extends _$WioDatabase {
  WioDatabase(super.executor, {this.onFirstCreate});

  /// Runs once, after the tables of a new database exist: the first start
  /// after an install. The app deletes any stored session there, because the
  /// iOS keychain keeps it across an uninstall (D-122).
  final Future<void> Function()? onFirstCreate;

  @override
  int get schemaVersion => 3;

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
      if (from < 1 || from >= to || to > 3) {
        throw StateError('No migration from local schema $from to $to.');
      }
      if (from < 2) {
        // v2 (D-192): the outbox op, the server copies, the rejected list
        // and the upload queue. Existing outbox rows become upserts, which
        // is what they are.
        await m.addColumn(outbox, outbox.op);
        await m.createTable(serverRecords);
        await m.createTable(rejectedChanges);
        await m.createTable(uploads);
      }
      if (from < 3 && to >= 3) {
        // v3 (D-238, D-239): typed pictures and notes, rebuilt at once from
        // the server copies and unsent changes already on the device.
        await m.createTable(pictures);
        await m.createTable(notes);
        await rebuildAll(this, const <String>{'pictures', 'notes'});
      }
    },
  );
}
