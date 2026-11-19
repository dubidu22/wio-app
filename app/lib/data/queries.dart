import 'package:drift/drift.dart';

import 'database.dart';

/// One row of the job list.
class JobListItem {
  const JobListItem({
    required this.jobId,
    required this.customerId,
    required this.customerName,
    required this.date,
  });

  final String jobId;
  final String customerId;
  final String? customerName;

  /// Local calendar date, `YYYY-MM-DD`.
  final String date;
}

/// The job list of level 1: today and later (KB workflows.md).
class JobList {
  const JobList({required this.today, required this.upcoming});

  final List<JobListItem> today;
  final List<JobListItem> upcoming;
}

/// A site with its rooms, for the customer screen.
class SiteView {
  const SiteView({
    required this.id,
    required this.name,
    required this.address,
    required this.rooms,
  });

  final String id;
  final String? name;
  final String? address;
  final List<RoomView> rooms;
}

/// A room, for the customer screen.
class RoomView {
  const RoomView({required this.id, required this.name, this.pictureCount = 0});

  final String id;
  final String? name;

  /// Live pictures of the room (D-264).
  final int pictureCount;
}

/// Everything the room screen shows besides its pictures (D-259).
class RoomScreenView {
  const RoomScreenView({
    required this.id,
    required this.name,
    required this.siteName,
  });

  final String id;
  final String? name;
  final String? siteName;
}

/// Everything level 2 shows of one customer.
class CustomerView {
  const CustomerView({
    required this.id,
    required this.name,
    required this.sites,
  });

  final String id;
  final String? name;
  final List<SiteView> sites;
}

/// `YYYY-MM-DD` of [time] in its own time zone.
String calendarDate(DateTime time) =>
    '${time.year.toString().padLeft(4, '0')}-'
    '${time.month.toString().padLeft(2, '0')}-'
    '${time.day.toString().padLeft(2, '0')}';

/// Jobs from [today] (`YYYY-MM-DD`) on, without tombstoned jobs or
/// customers, sorted by date and customer name.
Stream<JobList> watchJobList(WioDatabase db, String today) {
  final query =
      db.select(db.jobs).join(<Join<HasResultSet, Object?>>[
          innerJoin(
            db.customers,
            db.customers.id.equalsExp(db.jobs.customerId),
          ),
        ])
        ..where(
          db.jobs.deletedAt.isNull() &
              db.customers.deletedAt.isNull() &
              db.jobs.date.isBiggerOrEqualValue(today),
        )
        ..orderBy(<OrderingTerm>[
          OrderingTerm.asc(db.jobs.date),
          OrderingTerm.asc(db.customers.name),
          OrderingTerm.asc(db.jobs.id),
        ]);
  return query.watch().map((rows) {
    final today_ = <JobListItem>[];
    final upcoming = <JobListItem>[];
    for (final row in rows) {
      final job = row.readTable(db.jobs);
      final item = JobListItem(
        jobId: job.id,
        customerId: job.customerId,
        customerName: row.readTable(db.customers).name,
        date: job.date,
      );
      (job.date == today ? today_ : upcoming).add(item);
    }
    return JobList(today: today_, upcoming: upcoming);
  });
}

/// Customer [customerId] with its live sites and rooms, or null when the
/// customer does not exist or is tombstoned.
Stream<CustomerView?> watchCustomer(WioDatabase db, String customerId) {
  return db
      .customSelect(
        'SELECT 1',
        readsFrom: <TableInfo<Table, Object?>>{
          db.customers,
          db.sites,
          db.rooms,
          db.pictures,
        },
      )
      .watch()
      .asyncMap((_) => _loadCustomer(db, customerId));
}

Future<CustomerView?> _loadCustomer(WioDatabase db, String customerId) async {
  final customer =
      await (db.select(db.customers)
            ..where((c) => c.id.equals(customerId) & c.deletedAt.isNull()))
          .getSingleOrNull();
  if (customer == null) {
    return null;
  }
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
  final count = db.pictures.id.count();
  final counts = <String, int>{
    for (final row
        in await (db.selectOnly(db.pictures)
              ..addColumns(<Expression<Object>>[db.pictures.roomId, count])
              ..where(
                db.pictures.roomId.isIn(rooms.map((r) => r.id)) &
                    db.pictures.deletedAt.isNull(),
              )
              ..groupBy(<Expression<Object>>[db.pictures.roomId]))
            .get())
      row.read(db.pictures.roomId)!: row.read(count)!,
  };
  return CustomerView(
    id: customer.id,
    name: customer.name,
    sites: <SiteView>[
      for (final site in sites)
        SiteView(
          id: site.id,
          name: site.name,
          address: site.address,
          rooms: <RoomView>[
            for (final room in rooms.where((r) => r.siteId == site.id))
              RoomView(
                id: room.id,
                name: room.name,
                pictureCount: counts[room.id] ?? 0,
              ),
          ],
        ),
    ],
  );
}

/// Room [roomId] of customer [customerId] with its site's name, or null
/// when the room, its site or the customer is unknown or tombstoned, or the
/// room belongs to another customer (D-264).
Stream<RoomScreenView?> watchRoom(
  WioDatabase db,
  String customerId,
  String roomId,
) {
  final query =
      db.select(db.rooms).join(<Join<HasResultSet, Object?>>[
        innerJoin(db.sites, db.sites.id.equalsExp(db.rooms.siteId)),
        innerJoin(db.customers, db.customers.id.equalsExp(db.sites.customerId)),
      ])..where(
        db.rooms.id.equals(roomId) &
            db.rooms.deletedAt.isNull() &
            db.sites.deletedAt.isNull() &
            db.customers.id.equals(customerId) &
            db.customers.deletedAt.isNull(),
      );
  return query.watchSingleOrNull().map((row) {
    if (row == null) {
      return null;
    }
    final room = row.readTable(db.rooms);
    return RoomScreenView(
      id: room.id,
      name: room.name,
      siteName: row.readTable(db.sites).name,
    );
  });
}

/// Live picture [pictureId] of customer [customerId], or null when it is
/// unknown, tombstoned or another customer's. With [roomId], also null when
/// the picture is not in that room or the room or its site is tombstoned
/// (D-259).
Stream<Picture?> watchPicture(
  WioDatabase db,
  String customerId,
  String pictureId, {
  String? roomId,
}) {
  final query =
      db.select(db.pictures).join(<Join<HasResultSet, Object?>>[
        if (roomId != null) ...<Join<HasResultSet, Object?>>[
          innerJoin(db.rooms, db.rooms.id.equalsExp(db.pictures.roomId)),
          innerJoin(db.sites, db.sites.id.equalsExp(db.rooms.siteId)),
        ],
      ])..where(
        db.pictures.id.equals(pictureId) &
            db.pictures.customerId.equals(customerId) &
            db.pictures.deletedAt.isNull() &
            (roomId == null
                ? const Constant(true)
                : db.pictures.roomId.equals(roomId) &
                      db.rooms.deletedAt.isNull() &
                      db.sites.deletedAt.isNull()),
      );
  return query.watchSingleOrNull().map((row) => row?.readTable(db.pictures));
}

/// Live after pictures of picture [pictureId] of customer [customerId],
/// oldest first (D-275, D-280).
Stream<List<Picture>> watchAfterPictures(
  WioDatabase db,
  String customerId,
  String pictureId,
) =>
    (db.select(db.pictures)
          ..where(
            (p) =>
                p.afterOf.equals(pictureId) &
                p.customerId.equals(customerId) &
                p.deletedAt.isNull(),
          )
          ..orderBy(_pictureOrder))
        .watch();

/// [pictures] (oldest first) with each after picture moved right behind
/// its before picture, and its own after pictures behind it (D-281). An
/// after picture whose before picture is not in the list keeps its place.
List<Picture> withAfterPicturesBehind(List<Picture> pictures) {
  final ids = <String>{for (final p in pictures) p.id};
  final afterOf = <String, List<Picture>>{};
  final roots = <Picture>[];
  for (final picture in pictures) {
    final before = picture.afterOf;
    if (before != null && before != picture.id && ids.contains(before)) {
      afterOf.putIfAbsent(before, () => <Picture>[]).add(picture);
    } else {
      roots.add(picture);
    }
  }
  final ordered = <Picture>[];
  final seen = <String>{};
  void place(Picture picture) {
    if (!seen.add(picture.id)) return;
    ordered.add(picture);
    for (final after in afterOf[picture.id] ?? const <Picture>[]) {
      place(after);
    }
  }

  roots.forEach(place);
  // A cycle of after pictures (only from bad data) has no root: keep its
  // pictures in time order rather than lose them.
  for (final picture in pictures) {
    place(picture);
  }
  return ordered;
}

/// Live pictures of room [roomId], oldest first (D-245).
Stream<List<Picture>> watchPicturesOfRoom(WioDatabase db, String roomId) =>
    (db.select(db.pictures)
          ..where((p) => p.roomId.equals(roomId) & p.deletedAt.isNull())
          ..orderBy(_pictureOrder))
        .watch();

/// Live pictures of customer [customerId] that belong to no room and no
/// entry (customer screen "Fotos"), oldest first (D-245).
Stream<List<Picture>> watchPicturesOfCustomerWithoutRoom(
  WioDatabase db,
  String customerId,
) =>
    (db.select(db.pictures)
          ..where(
            (p) =>
                p.customerId.equals(customerId) &
                p.roomId.isNull() &
                p.entryId.isNull() &
                p.deletedAt.isNull(),
          )
          ..orderBy(_pictureOrder))
        .watch();

/// Live notes about [subjectId] of [subjectType], oldest first; notes not
/// yet confirmed by the server come last (D-245).
Stream<List<Note>> watchNotesOf(
  WioDatabase db,
  String subjectType,
  String subjectId,
) =>
    (db.select(db.notes)
          ..where(
            (n) =>
                n.subjectType.equals(subjectType) &
                n.subjectId.equals(subjectId) &
                n.deletedAt.isNull(),
          )
          ..orderBy(<OrderClauseGenerator<$NotesTable>>[
            (n) => OrderingTerm.asc(n.createdAt, nulls: NullsOrder.last),
            (n) => OrderingTerm.asc(n.id),
          ]))
        .watch();

final List<OrderClauseGenerator<$PicturesTable>> _pictureOrder =
    <OrderClauseGenerator<$PicturesTable>>[
      (p) => OrderingTerm.asc(p.takenAt, nulls: NullsOrder.last),
      (p) => OrderingTerm.asc(p.createdAt, nulls: NullsOrder.last),
      (p) => OrderingTerm.asc(p.id),
    ];

/// Live note [id], or null once it is deleted or unknown.
Stream<Note?> watchNote(WioDatabase db, String id) => (db.select(
  db.notes,
)..where((n) => n.id.equals(id) & n.deletedAt.isNull())).watchSingleOrNull();
