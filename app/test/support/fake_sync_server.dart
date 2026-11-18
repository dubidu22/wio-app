import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fake_api.dart';

/// A small sync server in memory (plan 044 §4, D-190), following plan 006
/// as approved (D-172 to D-191): a revision counter per workspace, one
/// stored answer per `change_id` (rejections included), field merge with
/// `merged` and `conflicts`, duplicates with `existing_id`, tombstones, pull
/// pages with `has_more` and `last_revision`, 410 and 426. It can lose a
/// request or an answer on command. It is no substitute for the real server
/// (a cross-stack test is a later CI step), but the app's loop is proved
/// against the same rules.
class FakeSyncServer {
  FakeSyncServer({this.workspaceId = defaultWorkspace});

  static const String defaultWorkspace = '01970000-0000-7000-8000-000000000001';

  final String workspaceId;

  int counter = 0;

  /// entity → id → the whole record as pull sends it.
  final Map<String, Map<String, Map<String, Object?>>> records =
      <String, Map<String, Map<String, Object?>>>{};

  final Map<String, ({String payload, Map<String, Object?> answer})> _answers =
      <String, ({String payload, Map<String, Object?> answer})>{};

  /// entity/id/field → who wrote it last, at which revision.
  final Map<String, ({int revision, String device, String changeId})>
  _fieldVersions = <String, ({int revision, String device, String changeId})>{};

  /// Answer 426 to everything.
  bool tooOld = false;

  /// Answer the n-th pull request from now with 410 (when its `since` is
  /// above 0), as after a restore of the server's database.
  int? resyncOnPull;

  /// Refuse a change with this reason (for example `permission`).
  String? Function(Map<String, Object?> change)? refuse;

  /// Refuse a whole push with 400 when it holds such a change.
  bool Function(Map<String, Object?> change)? breaksPage;

  /// Lose this many requests (before the server sees them) and answers
  /// (after the server applied them).
  int loseRequests = 0;
  int loseAnswers = 0;

  /// Lose requests and answers at random with [lossRate].
  Random? random;
  double lossRate = 0;

  /// Sizes of the push pages that reached the server, in order.
  final List<int> pushPages = <int>[];

  /// Every request that reached the server, as "METHOD /path".
  final List<String> requests = <String>[];

  /// A record the server already holds, with a new revision.
  Map<String, Object?> put(
    String entity,
    String id,
    Map<String, Object?> fields, {
    String device = 'server',
  }) {
    final revision = ++counter;
    final record = <String, Object?>{
      'id': id,
      'workspace_id': workspaceId,
      'created_at': '2026-11-01T08:00:00.000Z',
      'created_by': null,
      'updated_at': '2026-11-01T08:00:00.000Z',
      'updated_by': null,
      'deleted_at': null,
      ...fields,
      'revision': revision,
    };
    (records[entity] ??= <String, Map<String, Object?>>{})[id] = record;
    for (final field in fields.keys) {
      _fieldVersions['$entity/$id/$field'] = (
        revision: revision,
        device: device,
        changeId: 'seed',
      );
    }
    return record;
  }

  /// The live records of [entity] as the devices should show them.
  Map<String, Map<String, Object?>> live(String entity) =>
      <String, Map<String, Object?>>{
        for (final MapEntry(:key, :value)
            in (records[entity] ?? <String, Map<String, Object?>>{}).entries)
          if (value['deleted_at'] == null) key: value,
      };

  /// The client of one device.
  http.Client clientFor(String device) => MockClient((request) async {
    final key = '${request.method} ${request.url.path}';
    if (_lose(() => loseRequests--, loseRequests > 0)) {
      throw http.ClientException('request lost (fake)');
    }
    requests.add(key);
    if (tooOld) {
      return _json(426, <String, Object?>{
        ...problemBody(426, 'upgrade_required'),
        'minimum_app_version': '2.0.0',
      });
    }
    final http.Response response;
    switch (key) {
      case 'POST /sync/push':
        response = _push(request, device);
      case 'GET /sync/pull':
        response = _pull(request);
      default:
        response = _json(404, problemBody(404, 'not_found'));
    }
    if (_lose(() => loseAnswers--, loseAnswers > 0)) {
      throw http.ClientException('answer lost (fake)');
    }
    return response;
  });

  bool _lose(void Function() count, bool scripted) {
    if (scripted) {
      count();
      return true;
    }
    final r = random;
    return r != null && r.nextDouble() < lossRate;
  }

  http.Response _push(http.Request request, String device) {
    final body = jsonDecode(request.body) as Map<String, Object?>;
    final changes = (body['changes']! as List<Object?>)
        .cast<Map<String, Object?>>();
    if (changes.isEmpty || changes.length > 200) {
      return _json(413, problemBody(413, 'too_many_changes'));
    }
    if (breaksPage != null && changes.any(breaksPage!)) {
      return _json(400, problemBody(400, 'invalid_request'));
    }
    pushPages.add(changes.length);
    return _json(200, <String, Object?>{
      'results': <Object?>[for (final c in changes) _answer(c, device)],
    });
  }

  Map<String, Object?> _answer(Map<String, Object?> change, String device) {
    final changeId = change['change_id']! as String;
    final payload = jsonEncode(<Object?>[
      change['entity'],
      change['id'],
      change['op'],
      change['fields'],
    ]);
    final stored = _answers[changeId];
    if (stored != null) {
      // D-172: the same answer again; a reused id with another payload is
      // invalid.
      return stored.payload == payload
          ? stored.answer
          : _result(changeId, 'rejected', reason: 'invalid');
    }
    final answer = _applyChange(change, device);
    _answers[changeId] = (payload: payload, answer: answer);
    return answer;
  }

  Map<String, Object?> _applyChange(
    Map<String, Object?> change,
    String device,
  ) {
    final changeId = change['change_id']! as String;
    final entity = change['entity']! as String;
    final id = change['id']! as String;
    final op = change['op']! as String;
    final fields = (change['fields']! as Map<String, Object?>);
    final base = (change['base_revision'] as int?) ?? 0;
    final refused = refuse?.call(change);
    if (refused != null) return _result(changeId, 'rejected', reason: refused);
    if (fields.keys.any(_readOnly.contains)) {
      return _result(changeId, 'rejected', reason: 'invalid');
    }
    final table = records[entity] ??= <String, Map<String, Object?>>{};
    final record = table[id];
    switch (op) {
      case 'delete' || 'restore':
        if (record == null) {
          return _result(changeId, 'rejected', reason: 'not_found');
        }
        final deleted = op == 'delete';
        if ((record['deleted_at'] != null) == deleted) {
          return _result(changeId, 'applied', revision: record['revision']);
        }
        if (!deleted) {
          final clash = _duplicateOf(entity, record, id);
          if (clash != null) {
            return _result(
              changeId,
              'rejected',
              reason: 'duplicate',
              existingId: clash,
            );
          }
        }
        final revision = ++counter;
        record
          ..['deleted_at'] = deleted ? '2026-11-19T12:00:00.000Z' : null
          ..['revision'] = revision;
        return _result(changeId, 'applied', revision: revision);
      case 'upsert' || 'move_entry':
        if (record == null) {
          final created = <String, Object?>{...fields, 'id': id};
          for (final field in _required[entity] ?? const <String>[]) {
            if (created[field] == null) {
              return _result(changeId, 'rejected', reason: 'invalid');
            }
          }
          final clash = _duplicateOf(entity, created, id);
          if (clash != null) {
            return _result(
              changeId,
              'rejected',
              reason: 'duplicate',
              existingId: clash,
            );
          }
          final stored = put(entity, id, fields, device: device);
          _stamp(entity, id, fields.keys, changeId, device);
          return _result(changeId, 'applied', revision: stored['revision']);
        }
        if (record['deleted_at'] != null) {
          return _result(changeId, 'rejected', reason: 'deleted');
        }
        final clash = _duplicateOf(entity, <String, Object?>{
          ...record,
          ...fields,
        }, id);
        if (clash != null) {
          return _result(
            changeId,
            'rejected',
            reason: 'duplicate',
            existingId: clash,
          );
        }
        final merged = (record['revision']! as int) > base;
        final revision = ++counter;
        for (final MapEntry(key: field, :value) in fields.entries) {
          final version = _fieldVersions['$entity/$id/$field'];
          // A device overwriting its own earlier edit is no conflict
          // (PR 46, refining D-173).
          if (version != null &&
              version.revision > base &&
              version.device != device &&
              jsonEncode(record[field]) != jsonEncode(value)) {
            put('conflicts', 'conflict-${++_conflicts}', <String, Object?>{
              'entity': entity,
              'entity_id': id,
              'field': field,
              'lost_value': record[field],
              'lost_change_id': version.changeId,
              'won_revision': revision,
            });
          }
          record[field] = value;
        }
        record['revision'] = revision;
        _stamp(entity, id, fields.keys, changeId, device, revision: revision);
        return _result(
          changeId,
          merged ? 'merged' : 'applied',
          revision: revision,
        );
    }
    return _result(changeId, 'rejected', reason: 'invalid');
  }

  int _conflicts = 0;

  void _stamp(
    String entity,
    String id,
    Iterable<String> fields,
    String changeId,
    String device, {
    int? revision,
  }) {
    final at = revision ?? records[entity]![id]!['revision']! as int;
    for (final field in fields) {
      _fieldVersions['$entity/$id/$field'] = (
        revision: at,
        device: device,
        changeId: changeId,
      );
    }
  }

  /// The live record of [entity] that already holds a unique value of
  /// [record] (D-51): label names, customers' external_ref.
  String? _duplicateOf(String entity, Map<String, Object?> record, String id) {
    final key = _unique[entity];
    if (key == null || record[key] == null) return null;
    for (final other in live(entity).values) {
      if (other['id'] != id && other[key] == record[key]) {
        return other['id']! as String;
      }
    }
    return null;
  }

  static const Map<String, String> _unique = <String, String>{
    'labels': 'name',
    'customers': 'external_ref',
  };

  static const Map<String, List<String>> _required = <String, List<String>>{
    'rooms': <String>['site_id'],
    'jobs': <String>['customer_id', 'date'],
    'labels': <String>['name'],
  };

  static const Set<String> _readOnly = <String>{
    'id',
    'workspace_id',
    'created_at',
    'created_by',
    'updated_at',
    'updated_by',
    'revision',
    'deleted_at',
  };

  http.Response _pull(http.Request request) {
    final since = int.parse(request.url.queryParameters['since']!);
    final limit = int.parse(request.url.queryParameters['limit'] ?? '500');
    final countdown = resyncOnPull;
    if (countdown != null) resyncOnPull = countdown - 1;
    if (since > counter || (countdown == 1 && since > 0)) {
      return _json(410, problemBody(410, 'resync_required'));
    }
    final changed =
        <({String entity, Map<String, Object?> record})>[
          for (final MapEntry(key: entity, value: table) in records.entries)
            for (final record in table.values)
              if ((record['revision']! as int) > since)
                (entity: entity, record: record),
        ]..sort(
          (a, b) => (a.record['revision']! as int).compareTo(
            b.record['revision']! as int,
          ),
        );
    final page = changed.take(limit).toList();
    final hasMore = changed.length > limit;
    return _json(200, <String, Object?>{
      'records': <Object?>[
        for (final r in page)
          <String, Object?>{
            'entity': r.entity,
            'id': r.record['id'],
            'revision': r.record['revision'],
            'deleted_at': r.record['deleted_at'],
            'fields': r.record,
          },
      ],
      'has_more': hasMore,
      'last_revision': hasMore ? page.last.record['revision'] : counter,
    });
  }

  static Map<String, Object?> _result(
    String changeId,
    String status, {
    Object? revision,
    String? reason,
    String? existingId,
  }) => <String, Object?>{
    'change_id': changeId,
    'status': status,
    'revision': revision,
    'reason': reason,
    'existing_id': existingId,
  };

  static http.Response _json(int status, Map<String, Object?> body) =>
      http.Response.bytes(
        utf8.encode(jsonEncode(body)),
        status,
        headers: <String, String>{
          'content-type': status >= 400
              ? 'application/problem+json'
              : 'application/json',
        },
      );
}
