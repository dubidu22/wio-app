import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'ids.dart';
import 'local_writer.dart';

/// Where an entry is: a site and room, then optionally a fixture slot or a
/// floor point (D-9). In M3 only site and room are used (D-424); the other
/// fields are carried so a place is always one value of seven fields
/// (D-437).
class Place {
  const Place({
    this.siteId,
    this.roomId,
    this.fixtureId,
    this.level,
    this.compartment,
    this.floorXCm,
    this.floorYCm,
  });

  /// In a room (or on its floor, which needs no point in M3, D-424).
  const Place.room({required String this.siteId, required String this.roomId})
    : fixtureId = null,
      level = null,
      compartment = null,
      floorXCm = null,
      floorYCm = null;

  /// Not placed.
  static const Place none = Place();

  final String? siteId;
  final String? roomId;
  final String? fixtureId;
  final int? level;
  final int? compartment;
  final int? floorXCm;
  final int? floorYCm;

  bool get isNone => this == none;

  /// The seven fields as contract columns, each with [prefix] (`target_`,
  /// `from_`, `to_` or nothing).
  Map<String, Object?> toFields([String prefix = '']) => <String, Object?>{
    '${prefix}site_id': siteId,
    '${prefix}room_id': roomId,
    '${prefix}fixture_id': fixtureId,
    '${prefix}level': level,
    '${prefix}compartment': compartment,
    '${prefix}floor_x_cm': floorXCm,
    '${prefix}floor_y_cm': floorYCm,
  };

  /// The place in [fields] (contract columns with [prefix]); missing fields
  /// are null, as the server takes them (D-176).
  factory Place.fromFields(Map<String, Object?> fields, [String prefix = '']) =>
      Place(
        siteId: fields['${prefix}site_id'] as String?,
        roomId: fields['${prefix}room_id'] as String?,
        fixtureId: fields['${prefix}fixture_id'] as String?,
        level: fields['${prefix}level'] as int?,
        compartment: fields['${prefix}compartment'] as int?,
        floorXCm: fields['${prefix}floor_x_cm'] as int?,
        floorYCm: fields['${prefix}floor_y_cm'] as int?,
      );

  /// The current place of [entry].
  factory Place.of(Entry entry) => Place(
    siteId: entry.siteId,
    roomId: entry.roomId,
    fixtureId: entry.fixtureId,
    level: entry.level,
    compartment: entry.compartment,
    floorXCm: entry.floorXCm,
    floorYCm: entry.floorYCm,
  );

  /// The target place of [entry] (D-9, D-426).
  factory Place.targetOf(Entry entry) => Place(
    siteId: entry.targetSiteId,
    roomId: entry.targetRoomId,
    fixtureId: entry.targetFixtureId,
    level: entry.targetLevel,
    compartment: entry.targetCompartment,
    floorXCm: entry.targetFloorXCm,
    floorYCm: entry.targetFloorYCm,
  );

  @override
  bool operator ==(Object other) =>
      other is Place &&
      other.siteId == siteId &&
      other.roomId == roomId &&
      other.fixtureId == fixtureId &&
      other.level == level &&
      other.compartment == compartment &&
      other.floorXCm == floorXCm &&
      other.floorYCm == floorYCm;

  @override
  int get hashCode => Object.hash(
    siteId,
    roomId,
    fixtureId,
    level,
    compartment,
    floorXCm,
    floorYCm,
  );

  @override
  String toString() => 'Place(${toFields()})';
}

/// What a label or property is on (contract enum, D-50). M3 screens use
/// `entry` only.
typedef Subject = ({String type, String id});

/// The subject types of `entity_labels` and `entity_properties`.
const Map<String, String> subjectTables = <String, String>{
  'entry': 'entries',
  'room': 'rooms',
  'fixture': 'fixtures',
  'picture': 'pictures',
};

/// A live entry on the device already has this code (D-51, D-428). The
/// scan screen opens [existingId] instead.
class DuplicateCode implements Exception {
  const DuplicateCode(this.existingId);

  final String existingId;

  @override
  String toString() => 'DuplicateCode($existingId)';
}

/// The device's comparison key for label and key names (D-441): trimmed,
/// inner white space collapsed to one space, lower case. Unlike the
/// server's key it does not apply Unicode NFC; a twin that differs only in
/// normal form is answered `duplicate` by the server and re-pointed
/// (D-198).
String localNameKey(String name) =>
    name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

/// The contract's decimal-as-text pattern for `value_number`.
final RegExp decimalPattern = RegExp(r'^-?[0-9]{1,14}(\.[0-9]{1,6})?$');

/// Creates, edits, moves, deletes and restores entries, and adds and
/// removes their labels and property values (D-436).
///
/// Everything the server would refuse for a reason the device can see is
/// refused here with an [ArgumentError] (D-437, D-441). `customer_id` of a
/// link is derived from its subject as the server does and pushed only when
/// known (D-442).
class EntryWriter {
  EntryWriter(this._db, this._writer, {this._ids = newUuidV7});

  final WioDatabase _db;
  final LocalWriter _writer;
  final IdGenerator _ids;

  /// Longest code in UTF-8 bytes (`entries.code VARCHAR(255)`, D-51).
  static const int maxCodeBytes = 255;

  /// Longest title (`entries.title VARCHAR(200)`).
  static const int maxTitleLength = 200;

  /// Longest label or key name (`VARCHAR(100)`).
  static const int maxNameLength = 100;

  /// Longest unit (`property_keys.unit VARCHAR(32)`).
  static const int maxUnitLength = 32;

  /// Longest text value (`entity_properties.value_text VARCHAR(1000)`).
  static const int maxValueTextLength = 1000;

  // ---------------------------------------------------------------- entries

  /// Creates an entry; with a [place] it is placed at once by a
  /// `move_entry` queued right after the create (D-438). Returns its id.
  ///
  /// Throws [DuplicateCode] when a live entry on the device has [code].
  Future<String> createEntry({
    required String workspaceId,
    String? customerId,
    String? code,
    String? title,
    Place place = Place.none,
  }) async {
    _checkCode(code);
    _checkTitle(title);
    return await _db.transaction(() async {
      if (customerId != null) await _aliveCustomer(customerId);
      await _checkUniqueCode(code, null);
      await _checkPlace(place, customerId);
      final id = _ids();
      await _writer.write(
        entity: 'entries',
        id: id,
        fields: <String, Object?>{
          'workspace_id': workspaceId,
          'customer_id': ?customerId,
          'code': ?code,
          'title': ?_orNull(title),
        },
      );
      if (!place.isNone) {
        await _writer.moveEntry(id: id, place: place.toFields());
      }
      return id;
    });
  }

  /// Changes the [code] and/or [title] of entry [id]; an absent value is
  /// left as it is, a null clears it.
  Future<void> editEntry(
    String id, {
    Value<String?> code = const Value<String?>.absent(),
    Value<String?> title = const Value<String?>.absent(),
  }) async {
    if (code.present) _checkCode(code.value);
    if (title.present) _checkTitle(title.value);
    return await _db.transaction(() async {
      await _aliveEntry(id);
      final fields = <String, Object?>{};
      if (code.present) {
        await _checkUniqueCode(code.value, id);
        fields['code'] = code.value;
      }
      if (title.present) fields['title'] = _orNull(title.value);
      if (fields.isEmpty) return;
      await _writer.write(entity: 'entries', id: id, fields: fields);
    });
  }

  /// Moves entry [id] to [place]: one `move_entry` with all seven fields
  /// (D-176, D-437). A move to the place the entry already has queues
  /// nothing.
  Future<void> move(String id, Place place) => _db.transaction(() async {
    final entry = await _aliveEntry(id);
    if (Place.of(entry) == place) return;
    await _checkPlace(place, entry.customerId);
    await _writer.moveEntry(id: id, place: place.toFields());
  });

  /// Sets the target place of entry [id] (D-9): one upsert with all seven
  /// `target_*` fields, without history (D-426, D-439).
  Future<void> setTarget(String id, Place place) => _db.transaction(() async {
    final entry = await _aliveEntry(id);
    if (Place.targetOf(entry) == place) return;
    await _checkPlace(place, entry.customerId);
    await _writer.write(
      entity: 'entries',
      id: id,
      fields: place.toFields('target_'),
    );
  });

  /// Deletes entry [id] (a tombstone; [restoreEntry] undoes it, UX rule
  /// 10). Its labels, properties, pictures and notes stay, as on the
  /// server (D-176).
  Future<void> deleteEntry(String id) =>
      _writer.delete(entity: 'entries', id: id);

  /// Undoes [deleteEntry]. Refused with [DuplicateCode] when another live
  /// entry took the code meanwhile.
  Future<void> restoreEntry(String id) => _db.transaction(() async {
    final entry = await (_db.select(
      _db.entries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (entry == null) throw ArgumentError.value(id, 'id', 'no such entry');
    await _checkUniqueCode(entry.code, id);
    await _writer.restore(entity: 'entries', id: id);
  });

  /// The live entry on the device with exactly [code] (D-51), if any.
  Future<Entry?> entryWithCode(String code) =>
      (_db.select(_db.entries)
            ..where((e) => e.code.equals(code) & e.deletedAt.isNull())
            ..orderBy(<OrderClauseGenerator<$EntriesTable>>[
              (e) => OrderingTerm.asc(e.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  // ------------------------------------------------------------- vocabulary

  /// The live label whose name has the same key as [name] (D-441), else a
  /// new one. Returns its id.
  Future<String> labelNamed({
    required String workspaceId,
    required String name,
  }) async {
    final trimmed = _checkName(name);
    return await _db.transaction(() async {
      final key = localNameKey(trimmed);
      final live =
          await (_db.select(_db.labels)..where(
                (l) => l.workspaceId.equals(workspaceId) & l.deletedAt.isNull(),
              ))
              .get();
      for (final label in live) {
        if (localNameKey(label.name) == key) return label.id;
      }
      final id = _ids();
      await _writer.write(
        entity: 'labels',
        id: id,
        fields: <String, Object?>{'workspace_id': workspaceId, 'name': trimmed},
      );
      return id;
    });
  }

  /// The live property key whose name has the same key as [name] (D-441),
  /// else a new one with [unit]. An existing key keeps its unit. Returns
  /// its id.
  Future<String> keyNamed({
    required String workspaceId,
    required String name,
    String? unit,
  }) async {
    final trimmed = _checkName(name);
    final cleanUnit = _orNull(unit)?.trim();
    if (cleanUnit != null && cleanUnit.length > maxUnitLength) {
      throw ArgumentError.value(unit, 'unit', 'longer than $maxUnitLength');
    }
    return await _db.transaction(() async {
      final key = localNameKey(trimmed);
      final live =
          await (_db.select(_db.propertyKeys)..where(
                (k) => k.workspaceId.equals(workspaceId) & k.deletedAt.isNull(),
              ))
              .get();
      for (final propertyKey in live) {
        if (localNameKey(propertyKey.name) == key) return propertyKey.id;
      }
      final id = _ids();
      await _writer.write(
        entity: 'property_keys',
        id: id,
        fields: <String, Object?>{
          'workspace_id': workspaceId,
          'name': trimmed,
          'unit': ?cleanUnit,
        },
      );
      return id;
    });
  }

  /// Deletes label [id] (a tombstone; links stay, as on the server).
  Future<void> deleteLabel(String id) =>
      _writer.delete(entity: 'labels', id: id);

  /// Undoes [deleteLabel].
  Future<void> restoreLabel(String id) =>
      _writer.restore(entity: 'labels', id: id);

  /// Deletes property key [id].
  Future<void> deletePropertyKey(String id) =>
      _writer.delete(entity: 'property_keys', id: id);

  /// Undoes [deletePropertyKey].
  Future<void> restorePropertyKey(String id) =>
      _writer.restore(entity: 'property_keys', id: id);

  // ------------------------------------------------------------------ links

  /// Puts label [labelId] on [subject] (D-442): a live link stays, a
  /// removed one is restored, else one is created. Returns the link id.
  Future<String> addLabel(Subject subject, String labelId) =>
      _db.transaction(() async {
        final customerId = await _subjectCustomer(subject);
        final label = await (_db.select(
          _db.labels,
        )..where((l) => l.id.equals(labelId))).getSingleOrNull();
        if (label == null || label.deletedAt != null) {
          throw ArgumentError.value(labelId, 'labelId', 'no such live label');
        }
        final links =
            await (_db.select(_db.entityLabels)
                  ..where(
                    (l) =>
                        l.entityType.equals(subject.type) &
                        l.entityId.equals(subject.id) &
                        l.labelId.equals(labelId),
                  )
                  ..orderBy(<OrderClauseGenerator<$EntityLabelsTable>>[
                    (l) => OrderingTerm.asc(l.id),
                  ]))
                .get();
        for (final link in links) {
          if (link.deletedAt == null) return link.id;
        }
        if (links.isNotEmpty) {
          await _writer.restore(entity: 'entity_labels', id: links.first.id);
          return links.first.id;
        }
        final id = _ids();
        await _writer.write(
          entity: 'entity_labels',
          id: id,
          fields: <String, Object?>{
            'workspace_id': label.workspaceId,
            'customer_id': ?customerId,
            'entity_type': subject.type,
            'entity_id': subject.id,
            'label_id': labelId,
          },
        );
        return id;
      });

  /// Takes a label off its subject; `restore` on the same link undoes it.
  Future<void> removeLabel(String linkId) =>
      _writer.delete(entity: 'entity_labels', id: linkId);

  /// Undoes [removeLabel].
  Future<void> restoreLabelLink(String linkId) =>
      _writer.restore(entity: 'entity_labels', id: linkId);

  /// Sets the value of key [keyId] on [subject] (D-442): exactly one of
  /// [text] or [number] (a decimal as text, the contract's pattern). One
  /// value per key per subject: a live value is changed, a removed one is
  /// restored and changed, else one is created. Returns the link id.
  Future<String> setProperty(
    Subject subject,
    String keyId, {
    String? text,
    String? number,
  }) async {
    if ((text == null) == (number == null)) {
      throw ArgumentError('Exactly one of text or number.');
    }
    if (text != null &&
        (text.trim().isEmpty || text.length > maxValueTextLength)) {
      throw ArgumentError.value(text, 'text', 'empty or too long');
    }
    if (number != null && !decimalPattern.hasMatch(number)) {
      throw ArgumentError.value(number, 'number', 'not a decimal');
    }
    final value = <String, Object?>{'value_text': text, 'value_number': number};
    return await _db.transaction(() async {
      final customerId = await _subjectCustomer(subject);
      final key = await (_db.select(
        _db.propertyKeys,
      )..where((k) => k.id.equals(keyId))).getSingleOrNull();
      if (key == null || key.deletedAt != null) {
        throw ArgumentError.value(keyId, 'keyId', 'no such live key');
      }
      final links =
          await (_db.select(_db.entityProperties)
                ..where(
                  (p) =>
                      p.entityType.equals(subject.type) &
                      p.entityId.equals(subject.id) &
                      p.keyId.equals(keyId),
                )
                ..orderBy(<OrderClauseGenerator<$EntityPropertiesTable>>[
                  (p) => OrderingTerm.asc(p.id),
                ]))
              .get();
      EntityProperty? link;
      for (final candidate in links) {
        if (candidate.deletedAt == null) link = candidate;
      }
      if (link == null && links.isNotEmpty) {
        link = links.first;
        await _writer.restore(entity: 'entity_properties', id: link.id);
      }
      if (link != null) {
        if (link.valueText != text || link.valueNumber != number) {
          await _writer.write(
            entity: 'entity_properties',
            id: link.id,
            fields: value,
          );
        }
        return link.id;
      }
      final id = _ids();
      await _writer.write(
        entity: 'entity_properties',
        id: id,
        fields: <String, Object?>{
          'workspace_id': key.workspaceId,
          'customer_id': ?customerId,
          'entity_type': subject.type,
          'entity_id': subject.id,
          'key_id': keyId,
          ...value,
        },
      );
      return id;
    });
  }

  /// Removes a property value; [restorePropertyValue] undoes it.
  Future<void> removeProperty(String linkId) =>
      _writer.delete(entity: 'entity_properties', id: linkId);

  /// Undoes [removeProperty].
  Future<void> restorePropertyValue(String linkId) =>
      _writer.restore(entity: 'entity_properties', id: linkId);

  // ----------------------------------------------------------------- checks

  static void _checkCode(String? code) {
    if (code == null) return;
    if (code.isEmpty) throw ArgumentError.value(code, 'code', 'empty');
    if (utf8.encode(code).length > maxCodeBytes) {
      throw ArgumentError.value(code, 'code', 'over $maxCodeBytes bytes');
    }
  }

  static void _checkTitle(String? title) {
    if (title != null && title.length > maxTitleLength) {
      throw ArgumentError.value(title, 'title', 'over $maxTitleLength');
    }
  }

  static String _checkName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > maxNameLength) {
      throw ArgumentError.value(name, 'name', '1 to $maxNameLength chars');
    }
    return trimmed;
  }

  static String? _orNull(String? text) =>
      text == null || text.trim().isEmpty ? null : text;

  Future<void> _checkUniqueCode(String? code, String? self) async {
    if (code == null) return;
    final twin = await entryWithCode(code);
    if (twin != null && twin.id != self) throw DuplicateCode(twin.id);
  }

  Future<Entry> _aliveEntry(String id) async {
    final entry = await (_db.select(
      _db.entries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    if (entry == null || entry.deletedAt != null) {
      throw ArgumentError.value(id, 'id', 'no such live entry');
    }
    return entry;
  }

  Future<void> _aliveCustomer(String id) async {
    final customer = await (_db.select(
      _db.customers,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (customer == null || customer.deletedAt != null) {
      throw ArgumentError.value(id, 'customerId', 'no such live customer');
    }
  }

  /// The checks of `entries` (0004_entries_history.sql) and of `move_entry`
  /// (the site belongs to the entry's customer), D-437.
  Future<void> _checkPlace(Place place, String? customerId) async {
    if (place.isNone) return;
    if ((place.siteId == null) != (place.roomId == null)) {
      throw ArgumentError.value(place, 'place', 'site and room go together');
    }
    if (place.fixtureId != null && place.roomId == null) {
      throw ArgumentError.value(place, 'place', 'a fixture needs a room');
    }
    if ((place.level != null || place.compartment != null) &&
        place.fixtureId == null) {
      throw ArgumentError.value(place, 'place', 'a slot needs a fixture');
    }
    if ((place.level ?? 1) < 1 || (place.compartment ?? 1) < 1) {
      throw ArgumentError.value(place, 'place', 'slots count from 1');
    }
    if ((place.floorXCm == null) != (place.floorYCm == null)) {
      throw ArgumentError.value(place, 'place', 'a floor point has x and y');
    }
    if (place.floorXCm != null && place.fixtureId != null) {
      throw ArgumentError.value(place, 'place', 'floor or fixture, not both');
    }
    if (place.roomId == null) return;
    final room = await (_db.select(
      _db.rooms,
    )..where((r) => r.id.equals(place.roomId!))).getSingleOrNull();
    if (room == null || room.deletedAt != null) {
      throw ArgumentError.value(place.roomId, 'roomId', 'no such live room');
    }
    if (room.siteId != place.siteId) {
      throw ArgumentError.value(place.roomId, 'roomId', 'not at that site');
    }
    final site = await (_db.select(
      _db.sites,
    )..where((s) => s.id.equals(place.siteId!))).getSingleOrNull();
    if (site == null) {
      throw ArgumentError.value(place.siteId, 'siteId', 'no such site');
    }
    if (site.customerId != customerId) {
      throw ArgumentError.value(
        place.siteId,
        'siteId',
        'a site of another customer',
      );
    }
    if (place.fixtureId != null) {
      // Fixtures have no typed table before M4; their server copy says
      // which room they are in.
      final copy =
          await (_db.select(_db.serverRecords)..where(
                (r) =>
                    r.entity.equals('fixtures') & r.id.equals(place.fixtureId!),
              ))
              .getSingleOrNull();
      final fields = copy == null
          ? null
          : jsonDecode(copy.fields) as Map<String, Object?>;
      if (fields == null || fields['room_id'] != place.roomId) {
        throw ArgumentError.value(
          place.fixtureId,
          'fixtureId',
          'no such fixture in that room',
        );
      }
    }
  }

  /// The customer of [subject], which must exist on the device and be
  /// alive (as the server derives it, D-178).
  Future<String?> _subjectCustomer(Subject subject) async {
    final table = subjectTables[subject.type];
    if (table == null) {
      throw ArgumentError.value(subject.type, 'type', 'not a subject type');
    }
    if (table == 'fixtures') {
      final copy =
          await (_db.select(_db.serverRecords)..where(
                (r) => r.entity.equals('fixtures') & r.id.equals(subject.id),
              ))
              .getSingleOrNull();
      if (copy == null || copy.deletedAt != null) {
        throw ArgumentError.value(subject.id, 'id', 'no such live fixture');
      }
      return (jsonDecode(copy.fields) as Map<String, Object?>)['customer_id']
          as String?;
    }
    final row = await _db
        .customSelect(
          'SELECT customer_id, deleted_at FROM "$table" WHERE id = ?',
          variables: <Variable<Object>>[Variable<String>(subject.id)],
        )
        .getSingleOrNull();
    if (row == null || row.read<String?>('deleted_at') != null) {
      throw ArgumentError.value(subject.id, 'id', 'no such live $table');
    }
    return row.read<String?>('customer_id');
  }
}
