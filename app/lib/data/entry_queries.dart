import 'dart:convert';

import 'package:drift/drift.dart';

import 'database.dart';
import 'entry_writer.dart';

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
Stream<List<PlaceStep>> watchPlaceHistory(WioDatabase db, String entryId) => db
    .customSelect(
      'SELECT 1',
      readsFrom: <TableInfo<Table, Object?>>{
        db.placeHistory,
        db.outbox,
        db.serverRecords,
      },
    )
    .watch()
    .asyncMap((_) => placeHistory(db, entryId));

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
