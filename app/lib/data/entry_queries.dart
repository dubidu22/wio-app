import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'entry_writer.dart';
import 'queries.dart' show pictureOrder, withAfterPicturesBehind;
import 'watch_reads.dart';

/// One step of an entry's place history (D-54, D-440).
class PlaceStep {
  const PlaceStep({
    required this.from,
    required this.to,
    required this.movedAt,
    required this.pending,
  });

  /// [Place.none] for the first placement (D-425).
  final Place from;
  final Place to;

  /// ISO-8601 UTC: the server's time, or the device time while [pending].
  final String movedAt;

  /// A move the server has not confirmed yet ("wird gesendet", #108).
  final bool pending;
}

/// A label on a subject, with the link to remove it by.
typedef LabelOn = ({String linkId, Label label});

/// A property value on a subject, with its key.
typedef PropertyOn = ({EntityProperty value, PropertyKey key});

/// Entry [id], or null when it does not exist or is deleted.
Stream<Entry?> watchEntry(WioDatabase db, String id) => (db.select(
  db.entries,
)..where((e) => e.id.equals(id) & e.deletedAt.isNull())).watchSingleOrNull();

/// The live entries of customer [customerId], oldest first; entries the
/// server has not seen yet (no `created_at`) come last.
Stream<List<Entry>> watchEntriesOfCustomer(WioDatabase db, String customerId) =>
    (db.select(db.entries)
          ..where((e) => e.customerId.equals(customerId) & e.deletedAt.isNull())
          ..orderBy(_entryOrder))
        .watch();

/// The live entries placed in room [roomId], oldest first.
Stream<List<Entry>> watchEntriesInRoom(WioDatabase db, String roomId) =>
    (db.select(db.entries)
          ..where((e) => e.roomId.equals(roomId) & e.deletedAt.isNull())
          ..orderBy(_entryOrder))
        .watch();

final List<OrderClauseGenerator<$EntriesTable>> _entryOrder =
    <OrderClauseGenerator<$EntriesTable>>[
      (e) => OrderingTerm(expression: e.createdAt, nulls: NullsOrder.last),
      (e) => OrderingTerm.asc(e.id),
    ];

/// The place history of entry [entryId], newest first (D-440): the
/// server's rows, then one pending step per unsent `move_entry`, "from"
/// being the place before it (server copy, then earlier unsent moves).
Stream<List<PlaceStep>> watchPlaceHistory(WioDatabase db, String entryId) =>
    watchReads<List<PlaceStep>>(
      db,
      name: 'place_history',
      tables: <TableInfo<Table, Object?>>{
        db.placeHistory,
        db.outbox,
        db.serverRecords,
      },
      read: () => placeHistory(db, entryId),
    );

/// One read of [watchPlaceHistory].
Future<List<PlaceStep>> placeHistory(WioDatabase db, String entryId) async {
  final rows =
      await (db.select(db.placeHistory)
            ..where((h) => h.entryId.equals(entryId))
            ..orderBy(<OrderClauseGenerator<$PlaceHistoryTable>>[
              (h) => OrderingTerm.asc(h.movedAt),
              (h) =>
                  OrderingTerm(expression: h.revision, nulls: NullsOrder.last),
              (h) => OrderingTerm.asc(h.id),
            ]))
          .get();
  final steps = <PlaceStep>[
    for (final row in rows)
      PlaceStep(
        from: Place(
          siteId: row.fromSiteId,
          roomId: row.fromRoomId,
          fixtureId: row.fromFixtureId,
          level: row.fromLevel,
          compartment: row.fromCompartment,
          floorXCm: row.fromFloorXCm,
          floorYCm: row.fromFloorYCm,
        ),
        to: Place(
          siteId: row.toSiteId,
          roomId: row.toRoomId,
          fixtureId: row.toFixtureId,
          level: row.toLevel,
          compartment: row.toCompartment,
          floorXCm: row.toFloorXCm,
          floorYCm: row.toFloorYCm,
        ),
        movedAt: row.movedAt,
        pending: false,
      ),
  ];
  final moves =
      await (db.select(db.outbox)
            ..where(
              (o) =>
                  o.entity.equals('entries') &
                  o.entityId.equals(entryId) &
                  o.op.equals('move_entry'),
            )
            ..orderBy(<OrderClauseGenerator<$OutboxTable>>[
              (o) => OrderingTerm.asc(o.seq),
            ]))
          .get();
  if (moves.isNotEmpty) {
    final copy =
        await (db.select(db.serverRecords)
              ..where((r) => r.entity.equals('entries') & r.id.equals(entryId)))
            .getSingleOrNull();
    var place = copy == null
        ? Place.none
        : Place.fromFields(jsonDecode(copy.fields) as Map<String, Object?>);
    for (final move in moves) {
      final to = Place.fromFields(
        jsonDecode(move.fields) as Map<String, Object?>,
      );
      // The server writes no history for a move to the same place.
      if (to != place) {
        steps.add(
          PlaceStep(
            from: place,
            to: to,
            movedAt: move.deviceTime,
            pending: true,
          ),
        );
      }
      place = to;
    }
  }
  return steps.reversed.toList();
}

/// The live labels on [subject] (live links to live labels), by name.
Stream<List<LabelOn>> watchLabelsOf(WioDatabase db, Subject subject) {
  final query =
      db.select(db.entityLabels).join(<Join<HasResultSet, Object?>>[
          innerJoin(db.labels, db.labels.id.equalsExp(db.entityLabels.labelId)),
        ])
        ..where(
          db.entityLabels.entityType.equals(subject.type) &
              db.entityLabels.entityId.equals(subject.id) &
              db.entityLabels.deletedAt.isNull() &
              db.labels.deletedAt.isNull(),
        )
        ..orderBy(<OrderingTerm>[
          OrderingTerm.asc(db.labels.name.lower()),
          OrderingTerm.asc(db.labels.id),
        ]);
  return query.watch().map(
    (rows) => <LabelOn>[
      for (final row in rows)
        (
          linkId: row.readTable(db.entityLabels).id,
          label: row.readTable(db.labels),
        ),
    ],
  );
}

/// The live property values on [subject] with their live keys, by key name.
Stream<List<PropertyOn>> watchPropertiesOf(WioDatabase db, Subject subject) {
  final query =
      db.select(db.entityProperties).join(<Join<HasResultSet, Object?>>[
          innerJoin(
            db.propertyKeys,
            db.propertyKeys.id.equalsExp(db.entityProperties.keyId),
          ),
        ])
        ..where(
          db.entityProperties.entityType.equals(subject.type) &
              db.entityProperties.entityId.equals(subject.id) &
              db.entityProperties.deletedAt.isNull() &
              db.propertyKeys.deletedAt.isNull(),
        )
        ..orderBy(<OrderingTerm>[
          OrderingTerm.asc(db.propertyKeys.name.lower()),
          OrderingTerm.asc(db.propertyKeys.id),
        ]);
  return query.watch().map(
    (rows) => <PropertyOn>[
      for (final row in rows)
        (
          value: row.readTable(db.entityProperties),
          key: row.readTable(db.propertyKeys),
        ),
    ],
  );
}

/// The sort stamp of a link that no server has confirmed yet: newer than
/// any stamp the server gives (plan 104, P3).
const String _pendingStamp = '9999-12-31T23:59:59.999Z';

/// The workspace's live labels, most recently used first (plan 104, P3): a
/// label is used when it sits on any subject; the newest link counts, a
/// link without `created_at` (not confirmed yet) is the newest of all, ties
/// go to the newer link id (UUIDv7). Removed links count too, so a chip
/// does not jump when its label is taken off. Labels never used follow, newest
/// first, then by name.
Stream<List<Label>> watchLabelChoices(WioDatabase db) => db
    .customSelect(
      'SELECT l.* FROM labels l '
      'LEFT JOIN entity_labels el ON el.label_id = l.id '
      'WHERE l.deleted_at IS NULL '
      'GROUP BY l.id '
      'ORDER BY MAX(el.id) IS NULL, '
      "MAX(COALESCE(el.created_at, '$_pendingStamp')) DESC, "
      'MAX(el.id) DESC, '
      "COALESCE(l.created_at, '$_pendingStamp') DESC, "
      'lower(l.name), l.id',
      readsFrom: <TableInfo<Table, Object?>>{db.labels, db.entityLabels},
    )
    .watch()
    .map((rows) => <Label>[for (final row in rows) db.labels.map(row.data)]);

/// A live property key with what the workspace has put under it (D-429).
class KeyChoice {
  const KeyChoice({
    required this.key,
    required this.liveValues,
    required this.textValues,
  });

  final PropertyKey key;

  /// Live values of the key on any subject.
  final int liveValues;

  /// How many of them are text, not a number.
  final int textValues;

  /// The number pad is used (D-429, plan 104 P6): the key has a unit, or it
  /// has values and all of them are numbers.
  bool get numeric {
    final unit = key.unit;
    return (unit != null && unit.trim().isNotEmpty) ||
        (liveValues > 0 && textValues == 0);
  }
}

/// The workspace's live property keys, most recently used first (as
/// [watchLabelChoices]), with the counts that decide the keyboard.
Stream<List<KeyChoice>> watchKeyChoices(WioDatabase db) => db
    .customSelect(
      'SELECT k.*, '
      'COALESCE(SUM(CASE WHEN ep.id IS NOT NULL AND ep.deleted_at IS NULL '
      'THEN 1 ELSE 0 END), 0) '
      'AS live_values, '
      'COALESCE(SUM(CASE WHEN ep.id IS NOT NULL AND ep.deleted_at IS NULL '
      'AND ep.value_number IS NULL THEN 1 ELSE 0 END), 0) AS text_values '
      'FROM property_keys k '
      'LEFT JOIN entity_properties ep ON ep.key_id = k.id '
      'WHERE k.deleted_at IS NULL '
      'GROUP BY k.id '
      'ORDER BY MAX(ep.id) IS NULL, '
      "MAX(COALESCE(ep.created_at, '$_pendingStamp')) DESC, "
      'MAX(ep.id) DESC, '
      "COALESCE(k.created_at, '$_pendingStamp') DESC, "
      'lower(k.name), k.id',
      readsFrom: <TableInfo<Table, Object?>>{
        db.propertyKeys,
        db.entityProperties,
      },
    )
    .watch()
    .map(
      (rows) => <KeyChoice>[
        for (final row in rows)
          KeyChoice(
            key: db.propertyKeys.map(row.data),
            liveValues: row.read<int>('live_values'),
            textValues: row.read<int>('text_values'),
          ),
      ],
    );

/// The workspace's live labels by name, ignoring case (SQLite `lower`,
/// ASCII letters; PR 109 review S1) ("most recently used" is #104).
Stream<List<Label>> watchLabels(WioDatabase db) =>
    (db.select(db.labels)
          ..where((l) => l.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$LabelsTable>>[
            (l) => OrderingTerm.asc(l.name.lower()),
            (l) => OrderingTerm.asc(l.id),
          ]))
        .watch();

/// The workspace's live property keys by name.
Stream<List<PropertyKey>> watchPropertyKeys(WioDatabase db) =>
    (db.select(db.propertyKeys)
          ..where((k) => k.deletedAt.isNull())
          ..orderBy(<OrderClauseGenerator<$PropertyKeysTable>>[
            (k) => OrderingTerm.asc(k.name.lower()),
            (k) => OrderingTerm.asc(k.id),
          ]))
        .watch();

/// One entry of a list (plan 105): the entry, its first picture and the
/// names of its labels.
class EntryListRow {
  const EntryListRow({
    required this.entry,
    required this.picture,
    required this.labels,
  });

  final Entry entry;

  /// The first picture as the entry screen shows it (after pictures right
  /// behind their before picture, D-281); null when it has none.
  final Picture? picture;

  /// Names of the live labels on the entry, by name.
  final List<String> labels;

  /// The entry has no room (plan 105, P2).
  bool get unplaced => Place.of(entry).roomId == null;
}

/// The entries of a customer or of a room with what a list row shows (plan
/// 105): entries without a room first, then the placed ones, each group
/// newest first.
class EntryList {
  const EntryList({required this.rows, required this.rooms});

  final List<EntryListRow> rows;

  /// Live rooms the entries name: id to name (null for an unnamed room).
  final Map<String, String?> rooms;

  /// How many entries have no room; they are the first [unplaced] rows.
  int get unplaced => rows.where((r) => r.unplaced).length;

  bool isLiveRoom(String roomId) => rooms.containsKey(roomId);
  String? roomName(String roomId) => rooms[roomId];
}

/// The live entries of customer [customerId], or of room [roomId] (give
/// exactly one), as a list read in bulk (plan 105, P5). One watcher serves
/// both: [watchReads] only needs the name to say which tables it hears, and
/// they are the same for both.
Stream<EntryList> watchEntryList(
  WioDatabase db, {
  String? customerId,
  String? roomId,
}) => watchReads<EntryList>(
  db,
  name: 'entry_list',
  tables: <TableInfo<Table, Object?>>{
    db.entries,
    db.pictures,
    db.labels,
    db.entityLabels,
    db.rooms,
  },
  read: () => entryList(db, customerId: customerId, roomId: roomId),
);

/// One read of [watchEntryList]: four queries however many entries.
Future<EntryList> entryList(
  WioDatabase db, {
  String? customerId,
  String? roomId,
}) async {
  assert((customerId == null) != (roomId == null), 'one scope, not both');
  final entries =
      await (db.select(db.entries)..where(
            (e) =>
                e.deletedAt.isNull() &
                (customerId != null
                    ? e.customerId.equals(customerId)
                    : e.roomId.equals(roomId!)),
          ))
          .get();
  // Newest first; an entry the server has not confirmed yet (no created_at)
  // is the newest, ties go to the newer id (UUIDv7), as plan 104.
  String stamp(Entry e) => e.createdAt ?? _pendingStamp;
  entries.sort((a, b) {
    final byTime = stamp(b).compareTo(stamp(a));
    return byTime != 0 ? byTime : b.id.compareTo(a.id);
  });
  if (entries.isEmpty) {
    return const EntryList(rows: <EntryListRow>[], rooms: <String, String?>{});
  }
  final ids = <String>[for (final e in entries) e.id];

  final pictures =
      await (db.select(db.pictures)
            ..where((p) => p.entryId.isIn(ids) & p.deletedAt.isNull())
            ..orderBy(pictureOrder))
          .get();
  final picturesOf = <String, List<Picture>>{};
  for (final p in pictures) {
    picturesOf.putIfAbsent(p.entryId!, () => <Picture>[]).add(p);
  }

  final links =
      await (db.select(db.entityLabels).join(<Join<HasResultSet, Object?>>[
              innerJoin(
                db.labels,
                db.labels.id.equalsExp(db.entityLabels.labelId),
              ),
            ])
            ..where(
              db.entityLabels.entityType.equals('entry') &
                  db.entityLabels.entityId.isIn(ids) &
                  db.entityLabels.deletedAt.isNull() &
                  db.labels.deletedAt.isNull(),
            )
            ..orderBy(<OrderingTerm>[
              OrderingTerm.asc(db.labels.name.lower()),
              OrderingTerm.asc(db.labels.id),
            ]))
          .get();
  final labelsOf = <String, List<String>>{};
  for (final row in links) {
    labelsOf
        .putIfAbsent(row.readTable(db.entityLabels).entityId, () => <String>[])
        .add(row.readTable(db.labels).name);
  }

  final roomIds = <String>{
    for (final e in entries)
      if (Place.of(e).roomId != null) Place.of(e).roomId!,
  };
  final rooms = roomIds.isEmpty
      ? const <Room>[]
      : await (db.select(
          db.rooms,
        )..where((r) => r.id.isIn(roomIds) & r.deletedAt.isNull())).get();

  final rows = <EntryListRow>[
    for (final e in entries)
      EntryListRow(
        entry: e,
        picture: switch (picturesOf[e.id]) {
          final List<Picture> list => withAfterPicturesBehind(list).first,
          null => null,
        },
        labels: labelsOf[e.id] ?? const <String>[],
      ),
  ];
  // A stable partition keeps the newest-first order inside both groups.
  return EntryList(
    rows: <EntryListRow>[
      ...rows.where((r) => r.unplaced),
      ...rows.where((r) => !r.unplaced),
    ],
    rooms: <String, String?>{for (final r in rooms) r.id: r.name},
  );
}
