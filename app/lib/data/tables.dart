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

/// Any picture (D-7, D-238). The file is addressed by its SHA-256 and kept
/// on the device in the media folder (D-240); file fields never change
/// after create (D-241).
class Pictures extends Table with SyncedColumns {
  TextColumn get customerId => text().nullable()();
  TextColumn get fileSha256 => text()();
  IntColumn get fileBytes => integer()();
  TextColumn get fileMime => text()();
  IntColumn get widthPx => integer()();
  IntColumn get heightPx => integer()();

  /// Device time, information only.
  TextColumn get takenAt => text().nullable()();
  TextColumn get roomId => text().nullable()();
  TextColumn get entryId => text().nullable()();

  /// The picture this one is the after picture of (D-7).
  TextColumn get afterOf => text().nullable()();
}

/// Text and/or voice about an entry, room, picture, job or customer
/// (D-3, D-50, D-238).
class Notes extends Table with SyncedColumns {
  TextColumn get customerId => text().nullable()();

  /// `entry`, `room`, `picture`, `job` or `customer`.
  TextColumn get subjectType => text()();
  TextColumn get subjectId => text()();

  /// The column `text`; the getter cannot be called `text` in drift.
  TextColumn get noteText => text().named('text').nullable()();
  TextColumn get audioSha256 => text().nullable()();
  IntColumn get audioBytes => integer().nullable()();
  IntColumn get audioSeconds => integer().nullable()();
  TextColumn get transcript => text().nullable()();

  /// `device` or `manual`; set exactly when there is a transcript.
  TextColumn get transcriptSource => text().nullable()();
}

/// The ops of contract v1 (D-176); schema v2 adds the column (D-192).
const List<String> outboxOps = <String>[
  'upsert',
  'delete',
  'restore',
  'move_entry',
];

/// Changes not yet confirmed by the server (KB sync.md, step 1; D-66).
class Outbox extends Table {
  /// Insertion order; the order changes are pushed in.
  IntColumn get seq => integer().autoIncrement()();
  TextColumn get changeId => text().unique()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();

  /// What the change does; rows of schema v1 were all upserts. The check
  /// names its own column, drift's documented form for a column check.
  TextColumn get op => text()
      .withDefault(const Constant<String>('upsert'))
      // ignore: recursive_getters
      .check(op.isIn(outboxOps))();

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

/// The last pulled state of every record, of every entity, exactly as the
/// server sent it (D-193, D-194). Local rows are rebuilt from it plus the
/// unsent changes in the outbox.
class ServerRecords extends Table {
  TextColumn get entity => text()();
  TextColumn get id => text()();
  IntColumn get revision => integer()();
  TextColumn get deletedAt => text().nullable()();

  /// The whole record as a JSON object.
  TextColumn get fields => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{entity, id};
}

/// Changes the server refused, kept for the owner to see (D-197). Never
/// sent again under the same change id (D-172).
class RejectedChanges extends Table {
  TextColumn get changeId => text()();
  TextColumn get entity => text()();
  TextColumn get entityId => text()();
  TextColumn get op => text()();

  /// The changed fields as a JSON object, as they were queued.
  TextColumn get fields => text()();
  TextColumn get deviceTime => text()();

  /// The server's reason, or a local one (`too_large`) (D-199).
  TextColumn get reason => text()();

  /// With `duplicate`: the record that already held the value (D-198).
  TextColumn get existingId => text().nullable()();
  TextColumn get rejectedAt => text()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{changeId};
}

/// Files waiting to be uploaded (D-202); filled in PR 2 of #44.
class Uploads extends Table {
  TextColumn get sha256 => text()();

  /// The app's own copy of the file.
  TextColumn get path => text()();
  IntColumn get size => integer()();
  TextColumn get createdAt => text()();

  /// Null while the upload is pending.
  TextColumn get failedReason => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{sha256};
}
