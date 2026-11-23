import 'package:drift/drift.dart';

import 'database.dart';
import 'ids.dart';
import 'local_writer.dart';

/// Adds, changes, deletes and restores customers, sites, rooms and jobs
/// (plan 106). Every change is one record write and one outbox change;
/// [createCustomer] writes two records in one transaction.
///
/// A site, room or job takes its workspace from its live parent and always
/// carries `customer_id`, which the server derives from the parent and
/// accepts only when it matches (D-437). A blank name is stored as null, so
/// the existing "… ohne Namen" texts show (UX rule 4).
class CustomerWriter {
  CustomerWriter(this._db, this._writer, {this._ids = newUuidV7});

  final WioDatabase _db;
  final LocalWriter _writer;
  final IdGenerator _ids;

  /// Longest name (`customers.name`, `sites.name`, `rooms.name`: VARCHAR(200)).
  static const int maxNameLength = 200;

  /// The tables that have a name this writer changes.
  static const Set<String> namedEntities = <String>{
    'customers',
    'sites',
    'rooms',
  };

  /// Creates a customer in [workspaceId] with a job on [date]
  /// (`YYYY-MM-DD`), so the customer is on the job list (plan 106, P3).
  /// Returns the customer's id.
  Future<String> createCustomer({
    required String workspaceId,
    required String? name,
    required String date,
  }) async {
    final trimmed = _name(name);
    _checkDate(date);
    return await _db.transaction(() async {
      final id = _ids();
      await _writer.write(
        entity: 'customers',
        id: id,
        fields: <String, Object?>{
          'workspace_id': workspaceId,
          'name': ?trimmed,
        },
      );
      await _writer.write(
        entity: 'jobs',
        id: _ids(),
        fields: <String, Object?>{
          'workspace_id': workspaceId,
          'customer_id': id,
          'date': date,
        },
      );
      return id;
    });
  }

  /// Creates a site of live customer [customerId]. Returns its id.
  Future<String> createSite({required String customerId, String? name}) async {
    final trimmed = _name(name);
    return await _db.transaction(() async {
      final customer = await _liveCustomer(customerId);
      final id = _ids();
      await _writer.write(
        entity: 'sites',
        id: id,
        fields: <String, Object?>{
          'workspace_id': customer.workspaceId,
          'customer_id': customerId,
          'name': ?trimmed,
        },
      );
      return id;
    });
  }

  /// Creates a room at live site [siteId]. Returns its id.
  Future<String> createRoom({required String siteId, String? name}) async {
    final trimmed = _name(name);
    return await _db.transaction(() async {
      final site = await _liveSite(siteId);
      final id = _ids();
      await _writer.write(
        entity: 'rooms',
        id: id,
        fields: <String, Object?>{
          'workspace_id': site.workspaceId,
          'customer_id': site.customerId,
          'site_id': siteId,
          'name': ?trimmed,
        },
      );
      return id;
    });
  }

  /// Creates a job of live customer [customerId] on [date] (`YYYY-MM-DD`).
  /// Returns its id.
  Future<String> createJob({
    required String customerId,
    required String date,
  }) async {
    _checkDate(date);
    return await _db.transaction(() async {
      final customer = await _liveCustomer(customerId);
      final id = _ids();
      await _writer.write(
        entity: 'jobs',
        id: id,
        fields: <String, Object?>{
          'workspace_id': customer.workspaceId,
          'customer_id': customerId,
          'date': date,
        },
      );
      return id;
    });
  }

  /// Sets the name of customer, site or room [id] in [entity] (a table
  /// name); a blank [name] clears it. Queues only the name.
  Future<void> rename({
    required String entity,
    required String id,
    required String? name,
  }) async {
    if (!namedEntities.contains(entity)) {
      throw ArgumentError.value(entity, 'entity', 'has no name to change');
    }
    final trimmed = _name(name);
    return await _db.transaction(() async {
      await _live(entity, id);
      await _writer.write(
        entity: entity,
        id: id,
        fields: <String, Object?>{'name': trimmed},
      );
    });
  }

  /// Moves live job [id] to [date] (`YYYY-MM-DD`).
  Future<void> changeJobDate({required String id, required String date}) async {
    _checkDate(date);
    return await _db.transaction(() async {
      await _live('jobs', id);
      await _writer.write(
        entity: 'jobs',
        id: id,
        fields: <String, Object?>{'date': date},
      );
    });
  }

  /// Deletes record [id] of [entity] (a tombstone, so [restore] can undo
  /// it). Nothing is cascaded: the parents of children are read live only.
  Future<void> delete({required String entity, required String id}) async {
    _checkEntity(entity);
    await _writer.delete(entity: entity, id: id);
  }

  /// Undoes [delete].
  Future<void> restore({required String entity, required String id}) async {
    _checkEntity(entity);
    await _writer.restore(entity: entity, id: id);
  }

  static const Set<String> _entities = <String>{
    'customers',
    'sites',
    'rooms',
    'jobs',
  };

  void _checkEntity(String entity) {
    if (!_entities.contains(entity)) {
      throw ArgumentError.value(entity, 'entity', 'not added on the phone');
    }
  }

  /// Trimmed [name], null when blank; over [maxNameLength] is refused.
  String? _name(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.length > maxNameLength) {
      throw ArgumentError.value(name, 'name', 'over $maxNameLength');
    }
    return trimmed;
  }

  static final RegExp _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  void _checkDate(String date) {
    if (!_datePattern.hasMatch(date) || DateTime.tryParse(date) == null) {
      throw ArgumentError.value(date, 'date', 'not YYYY-MM-DD');
    }
  }

  Future<Customer> _liveCustomer(String id) async {
    final row = await (_db.select(
      _db.customers,
    )..where((c) => c.id.equals(id) & c.deletedAt.isNull())).getSingleOrNull();
    if (row == null) {
      throw ArgumentError.value(id, 'customerId', 'no such live customer');
    }
    return row;
  }

  Future<Site> _liveSite(String id) async {
    final row = await (_db.select(
      _db.sites,
    )..where((s) => s.id.equals(id) & s.deletedAt.isNull())).getSingleOrNull();
    if (row == null) {
      throw ArgumentError.value(id, 'siteId', 'no such live site');
    }
    return row;
  }

  Future<void> _live(String entity, String id) async {
    final found = await _db
        .customSelect(
          'SELECT 1 FROM "$entity" WHERE id = ? AND deleted_at IS NULL',
          variables: <Variable<Object>>[Variable<String>(id)],
          readsFrom: <TableInfo<Table, Object?>>{
            switch (entity) {
              'customers' => _db.customers,
              'sites' => _db.sites,
              'rooms' => _db.rooms,
              _ => _db.jobs,
            },
          },
        )
        .getSingleOrNull();
    if (found == null) {
      throw ArgumentError.value(id, 'id', 'no such live record in $entity');
    }
  }
}
