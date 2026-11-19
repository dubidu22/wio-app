import 'package:drift/drift.dart';

import '../data/database.dart';

/// A synced entity that has a typed table on the device (D-193, D-194).
/// Every other entity lives only as a server copy until its table comes.
class LocalTable {
  const LocalTable({required this.jsonColumns, required this.requiredColumns});

  /// Columns the contract carries as JSON objects or lists and the device
  /// keeps as JSON text.
  final Set<String> jsonColumns;

  /// Columns without which a row cannot be shown; a rebuilt record that
  /// lacks one waits for its server copy.
  final Set<String> requiredColumns;
}

/// The typed tables: four of schema v2, pictures and notes of v3 (D-238).
const Map<String, LocalTable> localTables = <String, LocalTable>{
  'customers': LocalTable(
    jsonColumns: <String>{'contact'},
    requiredColumns: <String>{'workspace_id'},
  ),
  'sites': LocalTable(
    jsonColumns: <String>{},
    requiredColumns: <String>{'workspace_id'},
  ),
  'rooms': LocalTable(
    jsonColumns: <String>{'outline'},
    requiredColumns: <String>{'workspace_id', 'site_id'},
  ),
  'jobs': LocalTable(
    jsonColumns: <String>{},
    requiredColumns: <String>{'workspace_id', 'customer_id', 'date'},
  ),
  'pictures': LocalTable(
    jsonColumns: <String>{},
    requiredColumns: <String>{
      'workspace_id',
      'file_sha256',
      'file_bytes',
      'file_mime',
      'width_px',
      'height_px',
    },
  ),
  'notes': LocalTable(
    jsonColumns: <String>{},
    requiredColumns: <String>{'workspace_id', 'subject_type', 'subject_id'},
  ),
};

/// The drift table of [entity], or null when it has none.
TableInfo<Table, Object?>? typedTableOf(WioDatabase db, String entity) {
  if (!localTables.containsKey(entity)) return null;
  for (final table in db.allTables) {
    if (table.actualTableName == entity) return table;
  }
  return null;
}

/// Fields the server stamps or derives from the token; the device keeps them
/// locally but never pushes them (contract readOnly, plan 006 S6).
const Set<String> serverStampedFields = <String>{
  'id',
  'workspace_id',
  'created_at',
  'created_by',
  'updated_at',
  'updated_by',
  'revision',
  'deleted_at',
};

/// Entities whose create can be answered `duplicate` (D-179, D-196).
bool canBeDuplicate(String entity, Map<String, Object?> fields) =>
    const <String>{
      'labels',
      'property_keys',
      'entries',
      'entity_labels',
      'entity_properties',
    }.contains(entity) ||
    (entity == 'customers' && fields['external_ref'] != null);
