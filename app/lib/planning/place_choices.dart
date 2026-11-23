import 'package:drift/drift.dart';

import '../data/database.dart';
import '../data/entry_writer.dart';
import '../data/watch_reads.dart';

/// One room the picker offers (plan 107).
class RoomChoice {
  const RoomChoice({required this.id, required this.siteId, this.name});

  final String id;
  final String siteId;
  final String? name;

  /// The place "on the floor of this room" (D-450).
  Place get floor => Place.room(siteId: siteId, roomId: id);
}

/// One site with its live rooms, by name.
class SiteChoice {
  const SiteChoice({
    required this.id,
    required this.rooms,
    this.name,
    this.address,
  });

  final String id;
  final String? name;
  final String? address;
  final List<RoomChoice> rooms;
}

/// What the place and target pickers show for one entry: the entry and
/// the live sites of its customer with their live rooms (plan 107, D-451).
class PlaceChoices {
  const PlaceChoices({required this.entry, required this.sites});

  final Entry entry;

  /// Sites by name, then id (as the customer screen, D-259).
  final List<SiteChoice> sites;

  Place get place => Place.of(entry);
  Place get target => Place.targetOf(entry);

  /// The live room [id], or null when it is unknown or deleted.
  RoomChoice? room(String? id) {
    if (id == null) return null;
    for (final site in sites) {
      for (final room in site.rooms) {
        if (room.id == id) return room;
      }
    }
    return null;
  }

  /// Sites with the one holding the target room first (move day, D-455);
  /// otherwise as [sites].
  List<SiteChoice> get sitesTargetFirst {
    final first = target.siteId;
    if (first == null) return sites;
    return <SiteChoice>[
      ...sites.where((s) => s.id == first),
      ...sites.where((s) => s.id != first),
    ];
  }
}

/// [PlaceChoices] of entry [entryId]; null when the entry does not exist,
/// is deleted or belongs to another customer than [customerId].
Stream<PlaceChoices?> watchPlaceChoices(
  WioDatabase db,
  String customerId,
  String entryId,
) => watchReads<PlaceChoices?>(
  db,
  name: 'place_choices',
  tables: <TableInfo<Table, Object?>>{db.entries, db.sites, db.rooms},
  read: () => placeChoices(db, customerId, entryId),
);

/// One read of [watchPlaceChoices].
Future<PlaceChoices?> placeChoices(
  WioDatabase db,
  String customerId,
  String entryId,
) async {
  final entry =
      await (db.select(db.entries)
            ..where((e) => e.id.equals(entryId) & e.deletedAt.isNull()))
          .getSingleOrNull();
  if (entry == null || entry.customerId != customerId) return null;
  final sites =
      await (db.select(db.sites)
            ..where(
              (s) => s.customerId.equals(customerId) & s.deletedAt.isNull(),
            )
            ..orderBy(<OrderClauseGenerator<$SitesTable>>[
              (s) => OrderingTerm.asc(s.name),
              (s) => OrderingTerm.asc(s.id),
            ]))
          .get();
  final rooms =
      await (db.select(db.rooms)
            ..where(
              (r) =>
                  r.siteId.isIn(sites.map((s) => s.id)) & r.deletedAt.isNull(),
            )
            ..orderBy(<OrderClauseGenerator<$RoomsTable>>[
              (r) => OrderingTerm.asc(r.name),
              (r) => OrderingTerm.asc(r.id),
            ]))
          .get();
  return PlaceChoices(
    entry: entry,
    sites: <SiteChoice>[
      for (final site in sites)
        SiteChoice(
          id: site.id,
          name: site.name,
          address: site.address,
          rooms: <RoomChoice>[
            for (final room in rooms)
              if (room.siteId == site.id)
                RoomChoice(id: room.id, siteId: site.id, name: room.name),
          ],
        ),
    ],
  );
}
