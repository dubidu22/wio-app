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
  const RoomView({required this.id, required this.name});

  final String id;
  final String? name;
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
              RoomView(id: room.id, name: room.name),
          ],
        ),
    ],
  );
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
