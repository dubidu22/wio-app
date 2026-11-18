import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:http/http.dart' as http;
import 'package:tonik_util/tonik_util.dart';
import 'package:wio_api/wio_api.dart';

import '../data/database.dart';
import 'local_tables.dart';
import 'rebuild.dart';
import 'upload_queue.dart';

/// Most changes in one push (D-191).
const int maxPushChanges = 200;

/// Most bytes of changes in one push; the server takes 2 MiB, the margin is
/// for the envelope and encoding (D-196).
const int maxPushBytes = 1536 * 1024;

/// Records per pull page (D-183).
const int pullPageSize = 500;

/// How long one sync request may take before it counts as no answer.
const Duration syncRequestTimeout = Duration(seconds: 30);

/// Why a sync step ended.
enum SyncStop {
  /// Nothing more to do.
  done,

  /// No answer, a timeout, or a server error: try again later.
  offline,

  /// The server said the app is too old (D-156): no more requests.
  tooOld,

  /// The token is no longer valid: the session must be checked.
  signedOut,

  /// The server broke a promise of the contract (no progress, another
  /// workspace): stop and try again later.
  failed,
}

/// How a sync step ended, with the wait the server asked for.
class SyncResult {
  const SyncResult(this.stop, {this.retryAfter, this.more = false});

  static const SyncResult done = SyncResult(SyncStop.done);

  /// Done for now, but new changes wait: run again (D-211).
  static const SyncResult runAgain = SyncResult(SyncStop.done, more: true);

  final SyncStop stop;
  final Duration? retryAfter;

  /// Another run should follow at once.
  final bool more;
}

/// Pushes the outbox and pulls the server's changes for one workspace (plan
/// 044, D-192 to D-200). Every step that changes local data runs in one
/// transaction, so a crash never leaves half a page applied.
class SyncEngine {
  SyncEngine({
    required this.db,
    required this.api,
    required this.workspaceId,
    required this.tooOld,
    this.uploads,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final WioDatabase db;
  final SyncApi api;
  final String workspaceId;

  /// True once the app is too old (#38); checked before every request.
  final bool Function() tooOld;
  final DateTime Function() _clock;

  /// Sends queued files after push and pull (D-208); none in tests of the
  /// record loop.
  final UploadWorker? uploads;

  /// Push, then pull, then uploads (D-201, D-208).
  Future<SyncResult> run() async {
    final pushed = await push();
    if (pushed.stop != SyncStop.done) return pushed;
    final pulled = await pull();
    if (pulled.stop != SyncStop.done) return pulled;
    return await uploads?.run() ?? SyncResult.done;
  }

  // ---------------------------------------------------------------- push

  /// Sends the outbox in pages until it is empty or a page removes nothing
  /// (D-196 to D-199).
  Future<SyncResult> push() async {
    while (true) {
      if (tooOld()) return const SyncResult(SyncStop.tooOld);
      final rows =
          await (db.select(db.outbox)
                ..orderBy(<OrderClauseGenerator<$OutboxTable>>[
                  (o) => OrderingTerm.asc(o.seq),
                ])
                ..limit(maxPushChanges))
              .get();
      if (rows.isEmpty) return SyncResult.done;
      final page = _page(rows);
      final outcome = await _send(page);
      if (outcome.result case final stop?) return stop;
      if (outcome.removed == 0) return const SyncResult(SyncStop.failed);
    }
  }

  /// The oldest rows that fit one request (D-196): at most 200 changes and
  /// [maxPushBytes], ending before a change that depends on a record created
  /// earlier in the same page that could be answered `duplicate`.
  List<OutboxData> _page(List<OutboxData> rows) {
    final page = <OutboxData>[];
    final createdHere = <String>{};
    var bytes = 0;
    for (final row in rows) {
      final size = utf8.encode(jsonEncode(changeOf(row).toJson())).length;
      if (page.isNotEmpty && bytes + size > maxPushBytes) break;
      final fields = jsonDecode(row.fields) as Map<String, Object?>;
      if (page.isNotEmpty && _refersTo(row, fields, createdHere)) break;
      page.add(row);
      bytes += size;
      if (isCreate(row, fields) && canBeDuplicate(row.entity, fields)) {
        createdHere.add(row.entityId);
      }
    }
    return page;
  }

  static bool _refersTo(
    OutboxData row,
    Map<String, Object?> fields,
    Set<String> ids,
  ) {
    if (ids.isEmpty) return false;
    if (ids.contains(row.entityId)) return true;
    for (final MapEntry(:key, :value) in fields.entries) {
      if (key.endsWith('_id') && value is String && ids.contains(value)) {
        return true;
      }
    }
    return false;
  }

  /// Sends [page]; a page the server refuses as a whole (400 or 413) goes
  /// again one change at a time (D-199).
  Future<_PageOutcome> _send(List<OutboxData> page) async {
    final answer = await _request(page);
    switch (answer) {
      case _Results(:final results):
        return _PageOutcome(await _apply(page, results));
      case _RefusedPage(:final reason) when page.length == 1:
        await _rejectLocally(page.single, reason);
        return const _PageOutcome(1);
      case _RefusedPage():
        var removed = 0;
        for (final row in page) {
          final single = await _send(<OutboxData>[row]);
          if (single.result != null) return single;
          removed += single.removed;
        }
        return _PageOutcome(removed);
      case _Stopped(:final result):
        return _PageOutcome(0, result);
    }
  }

  Future<_PushAnswer> _request(List<OutboxData> page) async {
    final TonikResult<SyncPushResponse, http.Response> response;
    try {
      response = await api
          .syncPush(body: PushRequest(changes: page.map(changeOf).toList()))
          .timeout(syncRequestTimeout);
    } on Object {
      return const _Stopped(SyncResult(SyncStop.offline));
    }
    if (tooOld()) return const _Stopped(SyncResult(SyncStop.tooOld));
    return switch (response) {
      TonikSuccess(value: SyncPushResponse200(:final body)) => _Results(
        body.results,
      ),
      TonikSuccess(value: SyncPushResponse400()) => const _RefusedPage(
        'invalid',
      ),
      TonikSuccess(value: SyncPushResponse413()) => const _RefusedPage(
        'too_large',
      ),
      TonikSuccess(value: SyncPushResponse401(:final body))
          when body.code == 'token_invalid' =>
        const _Stopped(SyncResult(SyncStop.signedOut)),
      TonikSuccess(value: SyncPushResponse426()) => const _Stopped(
        SyncResult(SyncStop.tooOld),
      ),
      TonikSuccess(value: SyncPushResponse503(:final body)) => _Stopped(
        SyncResult(SyncStop.offline, retryAfter: _seconds(body.retryAfter)),
      ),
      _ => const _Stopped(SyncResult(SyncStop.offline)),
    };
  }

  /// Applies the answers of one page in one transaction (D-196 to D-198).
  /// Answers are matched by change id; a change without one stays queued.
  Future<int> _apply(List<OutboxData> page, List<ChangeResult> results) {
    final byId = <String, ChangeResult>{for (final r in results) r.changeId: r};
    return db.transaction(() async {
      var removed = 0;
      final touched = <RecordKey>{};
      for (final row in page) {
        final result = byId[row.changeId];
        if (result == null) continue;
        switch (result.status) {
          case ChangeResultStatusModel.applied ||
              ChangeResultStatusModel.merged:
            // The local revision stays as it is until a pull (D-195).
            await _deleteOutbox(row);
          case ChangeResultStatusModel.rejected ||
              ChangeResultStatusModel.unknown:
            final reason = result.reason ?? 'rejected';
            final existing = result.existingId;
            // Only a create is re-pointed; a duplicate value on an existing
            // record is a plain rejection (its existing_id is not kept).
            final repoint =
                reason == 'duplicate' &&
                existing != null &&
                existing != row.entityId &&
                await _isLocalCreate(row);
            if (repoint) {
              await _repoint(row, existing);
              touched.add((entity: row.entity, id: existing));
            }
            await _moveToRejected(row, reason, repoint ? existing : null);
            touched.add((entity: row.entity, id: row.entityId));
        }
        removed++;
      }
      await rebuildRecords(db, touched);
      return removed;
    });
  }

  /// A create the server has never confirmed: no server copy.
  Future<bool> _isLocalCreate(OutboxData row) async {
    final fields = jsonDecode(row.fields) as Map<String, Object?>;
    if (!isCreate(row, fields)) return false;
    final copy =
        await (db.select(db.serverRecords)..where(
              (r) => r.entity.equals(row.entity) & r.id.equals(row.entityId),
            ))
            .getSingleOrNull();
    return copy == null;
  }

  /// The record [row] created already exists as [existing] (D-198): every
  /// remaining outbox row and local reference to it points there instead.
  /// The create's own fields are not sent to [existing].
  Future<void> _repoint(OutboxData row, String existing) async {
    final from = row.entityId;
    final others = await (db.select(
      db.outbox,
    )..where((o) => o.changeId.equals(row.changeId).not())).get();
    for (final other in others) {
      final fields = jsonDecode(other.fields) as Map<String, Object?>;
      var changed = false;
      for (final key in fields.keys.toList()) {
        if (key.endsWith('_id') && fields[key] == from) {
          fields[key] = existing;
          changed = true;
        }
      }
      if (!changed && other.entityId != from) continue;
      await (db.update(db.outbox)..where((o) => o.seq.equals(other.seq))).write(
        OutboxCompanion(
          entityId: Value<String>(
            other.entityId == from && other.entity == row.entity
                ? existing
                : other.entityId,
          ),
          fields: Value<String>(jsonEncode(fields)),
        ),
      );
    }
    for (final table in localTables.keys) {
      final info = typedTableOf(db, table)!;
      for (final column in info.$columns.map((c) => c.name)) {
        if (column == 'id' || !column.endsWith('_id')) continue;
        await db.customUpdate(
          'UPDATE "$table" SET "$column" = ? WHERE "$column" = ?',
          variables: <Variable<Object>>[
            Variable<String>(existing),
            Variable<String>(from),
          ],
          updates: <TableInfo<Table, Object?>>{info},
          updateKind: UpdateKind.update,
        );
      }
    }
  }

  Future<void> _moveToRejected(
    OutboxData row,
    String reason,
    String? existing,
  ) async {
    await db
        .into(db.rejectedChanges)
        .insertOnConflictUpdate(
          RejectedChangesCompanion.insert(
            changeId: row.changeId,
            entity: row.entity,
            entityId: row.entityId,
            op: row.op,
            fields: row.fields,
            deviceTime: row.deviceTime,
            reason: reason,
            existingId: Value<String?>(existing),
            rejectedAt: _clock().toUtc().toIso8601String(),
          ),
        );
    await _deleteOutbox(row);
  }

  /// A change the server cannot take even alone (D-199).
  Future<void> _rejectLocally(OutboxData row, String reason) =>
      db.transaction(() async {
        await _moveToRejected(row, reason, null);
        await rebuildRecords(db, <RecordKey>[
          (entity: row.entity, id: row.entityId),
        ]);
      });

  Future<void> _deleteOutbox(OutboxData row) =>
      (db.delete(db.outbox)..where((o) => o.seq.equals(row.seq))).go();

  // ---------------------------------------------------------------- pull

  /// Pulls pages until `has_more` is false (D-200).
  Future<SyncResult> pull() async {
    var since = await _lastRevision();
    var resyncs = 0;
    while (true) {
      if (tooOld()) return const SyncResult(SyncStop.tooOld);
      final TonikResult<SyncPullResponse, http.Response> response;
      try {
        response = await api
            .syncPull(since: since, limit: pullPageSize)
            .timeout(syncRequestTimeout);
      } on Object {
        return const SyncResult(SyncStop.offline);
      }
      if (tooOld()) return const SyncResult(SyncStop.tooOld);
      switch (response) {
        case TonikSuccess(value: SyncPullResponse200(:final body)):
          if (body.hasMore && body.lastRevision <= since) {
            return const SyncResult(SyncStop.failed);
          }
          if (!body.records.every(_inWorkspace)) {
            return const SyncResult(SyncStop.failed);
          }
          await _store(body);
          if (!body.hasMore) return SyncResult.done;
          since = body.lastRevision;
        case TonikSuccess(value: SyncPullResponse410()):
          // Twice in one run means the server cannot serve from 0 either.
          if (++resyncs > 1) return const SyncResult(SyncStop.failed);
          await _resync();
          since = 0;
        case TonikSuccess(value: SyncPullResponse401(:final body))
            when body.code == 'token_invalid':
          return const SyncResult(SyncStop.signedOut);
        case TonikSuccess(value: SyncPullResponse426()):
          return const SyncResult(SyncStop.tooOld);
        case TonikSuccess(value: SyncPullResponse503(:final body)):
          return SyncResult(
            SyncStop.offline,
            retryAfter: _seconds(body.retryAfter),
          );
        case _:
          return const SyncResult(SyncStop.offline);
      }
    }
  }

  Future<int> _lastRevision() async {
    final row = await (db.select(
      db.syncState,
    )..where((s) => s.workspaceId.equals(workspaceId))).getSingleOrNull();
    return row?.lastRevision ?? 0;
  }

  /// Records of another workspace never enter this device (D-131).
  bool _inWorkspace(PulledRecord record) {
    if (record.entity == 'workspaces') return record.id == workspaceId;
    final owner = record.fields['workspace_id'];
    return owner == null || owner == workspaceId;
  }

  /// One page: server copies, rebuilt rows and the revision, together.
  Future<void> _store(PullResult page) => db.transaction(() async {
    for (final record in page.records) {
      await db
          .into(db.serverRecords)
          .insertOnConflictUpdate(
            ServerRecordsCompanion.insert(
              entity: record.entity,
              id: record.id,
              revision: record.revision,
              deletedAt: Value<String?>(
                record.deletedAt?.toUtc().toIso8601String(),
              ),
              fields: jsonEncode(record.fields),
            ),
          );
    }
    await rebuildRecords(db, <RecordKey>[
      for (final r in page.records) (entity: r.entity, id: r.id),
    ]);
    await db
        .into(db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            workspaceId: workspaceId,
            lastRevision: page.lastRevision,
          ),
        );
  });

  /// 410 (D-200): pulled data goes, the outbox and the rejected list stay.
  Future<void> _resync() => db.transaction(() async {
    await db.delete(db.serverRecords).go();
    for (final entity in localTables.keys) {
      await db.customUpdate(
        'DELETE FROM "$entity"',
        updates: <TableInfo<Table, Object?>>{typedTableOf(db, entity)!},
        updateKind: UpdateKind.delete,
      );
    }
    await (db.delete(
      db.syncState,
    )..where((s) => s.workspaceId.equals(workspaceId))).go();
    final queued = await db.select(db.outbox).get();
    await rebuildRecords(db, <RecordKey>[
      for (final row in queued) (entity: row.entity, id: row.entityId),
    ]);
  });

  static Duration? _seconds(int? seconds) =>
      seconds != null && seconds > 0 ? Duration(seconds: seconds) : null;
}

/// True when [row] creates its record: an upsert without a base revision
/// that carries `workspace_id`, which `LocalWriter` requires only for a new
/// record. An edit of a record not yet pulled also has no base revision, but
/// no `workspace_id`; it is never re-pointed (D-198, PR 48 review B1).
bool isCreate(OutboxData row, Map<String, Object?> fields) =>
    row.op == 'upsert' &&
    row.baseRevision == null &&
    fields.containsKey('workspace_id');

/// One outbox row as the contract's `Change`: server-stamped fields left
/// out, JSON columns sent as JSON.
Change changeOf(OutboxData row) {
  final fields = jsonDecode(row.fields) as Map<String, Object?>;
  final json = localTables[row.entity]?.jsonColumns ?? const <String>{};
  return Change(
    changeId: row.changeId,
    entity: row.entity,
    id: row.entityId,
    op: ChangeOpModel.fromJson(row.op),
    fields: <String, Object?>{
      for (final MapEntry(:key, :value) in fields.entries)
        if (!serverStampedFields.contains(key))
          key: json.contains(key) && value is String ? _json(value) : value,
    },
    baseRevision: row.baseRevision,
    deviceTime: DateTime.parse(row.deviceTime),
  );
}

Object? _json(String text) {
  try {
    return jsonDecode(text);
  } on FormatException {
    return text;
  }
}

sealed class _PushAnswer {
  const _PushAnswer();
}

class _Results extends _PushAnswer {
  const _Results(this.results);
  final List<ChangeResult> results;
}

class _RefusedPage extends _PushAnswer {
  const _RefusedPage(this.reason);
  final String reason;
}

class _Stopped extends _PushAnswer {
  const _Stopped(this.result);
  final SyncResult result;
}

class _PageOutcome {
  const _PageOutcome(this.removed, [this.result]);
  final int removed;
  final SyncResult? result;
}
