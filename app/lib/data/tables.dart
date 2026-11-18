import 'package:drift/drift.dart';

/// Common fields of every synced record (KB data-model.md, plan 003).
///
/// Timestamps are ISO-8601 UTC text exactly as the sync API carries them.
/// `created_*`, `updated_*`, `revision` and `deleted_at` are stamped by the
/// server; they stay null on the device until a pull brings them (D-64).
mixin SyncedColumns on Table {
  TextColumn get id => text()();
  TextColumn get workspaceId => text()();
  TextColumn get createdAt => text().nullable()();
  TextColumn get createdBy => text().nullable()();
  TextColumn get updatedAt => text().nullable()();
  TextColumn get updatedBy => text().nullable()();
  IntColumn get revision => integer().nullable()();
  TextColumn get deletedAt => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{id};
}

/// A household served (professional workspaces only).
class Customers extends Table with SyncedColumns {
  TextColumn get name => text().nullable()();

  /// JSON object as text.
  TextColumn get contact => text().nullable()();
  TextColumn get externalRef => text().nullable()();
}

/// An address of a customer; a move has two.
class Sites extends Table with SyncedColumns {
  TextColumn get customerId => text().nullable()();
  TextColumn get name => text().nullable()();
  TextColumn get address => text().nullable()();
}

/// A room at a site.
class Rooms extends Table with SyncedColumns {
  TextColumn get customerId => text().nullable()();
  TextColumn get siteId => text()();
  TextColumn get name => text().nullable()();

  /// Corner points in cm as a JSON list.
  TextColumn get outline => text().nullable()();
  IntColumn get heightCm => integer().nullable()();
}

/// A working day at a customer.
class Jobs extends Table with SyncedColumns {
  TextColumn get customerId => text()();

  /// Local calendar date, `YYYY-MM-DD`.
  TextColumn get date => text()();
  IntColumn get agreedMinutes => integer().nullable()();
  TextColumn get reportSentAt => text().nullable()();
}

/// Changes not yet confirmed by the server (KB sync.md, step 1; D-66).
class Outbox extends Table {
  /// Insertion order; the order changes are pushed in.
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get changeId => text().unique()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();

  /// The changed fields only, as a JSON object.
  TextColumn get fields => text()();
  IntColumn get baseRevision => integer().nullable()();
  TextColumn get deviceTime => text()();
}

/// The last revision pulled per workspace (KB sync.md, step 4).
class SyncState extends Table {
  TextColumn get workspaceId => text()();
  IntColumn get lastRevision => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{workspaceId};
}
