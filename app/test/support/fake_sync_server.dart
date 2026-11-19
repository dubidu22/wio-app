import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

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

  /// Files of the workspace by SHA-256: the bytes received so far and the
  /// total from the first chunk (D-185, D-186).
  final Map<String, ({int total, BytesBuilder bytes})> partFiles =
      <String, ({int total, BytesBuilder bytes})>{};

  /// Complete files by SHA-256.
  final Map<String, Uint8List> files = <String, Uint8List>{};

  /// Devices whose token is a helper's: files answer 403 (D-206).
  final Set<String> helpers = <String>{};

  /// Files whose next completion fails the hash check once more (422).
  final Map<String, int> breakHash = <String, int>{};

  /// Content-Range headers of every chunk that reached the server.
  final List<String> chunks = <String>[];

  /// Answer every file request with this status and code (for example
  /// 413, or 401 `token_invalid`).
  int? fileStatus;
  String fileCode = 'refused';

  /// How long a chunk's answer takes after the server stored it.
  Duration chunkDelay = Duration.zero;

  /// Lose the answers of this many chunk uploads after storing them.
  int loseChunkAnswers = 0;

  /// Range headers of every download that reached the server, with their
  /// If-Range (#62).
  final List<({String? range, String? ifRange})> downloads =
      <({String? range, String? ifRange})>[];

  /// Files served with their first byte changed this many more times.
  final Map<String, int> serveWrongBytes = <String, int>{};

  /// Files answered with the whole file (200) whatever the Range says.
  final Set<String> ignoreRange = <String>{};

  /// Files answered with 416 this many more times.
  final Map<String, int> refuseRange = <String, int>{};

  /// Files whose 416 answers leave out the Content-Range size (#82).
  final Set<String> hideRangeSize = <String>{};

  /// Called with "METHOD /path" after each answer, to change the server
  /// between two requests.
  void Function(String key)? afterRequest;

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
      case _ when key.startsWith('GET /files/') && key.endsWith('/state'):
        response = _fileState(request.url.pathSegments[1], device);
      case _ when key.startsWith('PUT /files/'):
        response = _putChunk(request, request.url.pathSegments[1], device);
      case _ when key.startsWith('GET /files/'):
        response = _getFile(request, request.url.pathSegments[1], device);
      default:
        response = _json(404, problemBody(404, 'not_found'));
    }
    afterRequest?.call(key);
    if (key.startsWith('PUT /files/') && chunkDelay > Duration.zero) {
      await Future<void>.delayed(chunkDelay);
    }
    if (_lose(() => loseAnswers--, loseAnswers > 0)) {
      throw http.ClientException('answer lost (fake)');
    }
    if (key.startsWith('PUT /files/') && loseChunkAnswers > 0) {
      loseChunkAnswers--;
      throw http.ClientException('chunk answer lost (fake)');
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
    'pictures': <String>[
      'file_sha256',
      'file_bytes',
      'file_mime',
      'width_px',
      'height_px',
    ],
    'notes': <String>['subject_type', 'subject_id'],
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

  /// A part of a file stored as the server would hold it after a lost
  /// answer.
  void putPart(String sha256, List<int> bytes, int total) =>
      partFiles[sha256] = (total: total, bytes: BytesBuilder()..add(bytes));

  int _received(String sha256) =>
      files[sha256]?.length ?? partFiles[sha256]?.bytes.length ?? 0;

  Map<String, Object?> _state(String sha256) => <String, Object?>{
    'sha256': sha256,
    'size': files[sha256]?.length ?? partFiles[sha256]?.total,
    'received_bytes': _received(sha256),
    'complete': files.containsKey(sha256),
  };

  http.Response? _fileRefusal(String device) {
    if (helpers.contains(device)) {
      return _json(403, problemBody(403, 'forbidden'));
    }
    final status = fileStatus;
    if (status != null) return _json(status, problemBody(status, fileCode));
    return null;
  }

  http.Response _fileState(String sha256, String device) =>
      _fileRefusal(device) ?? _json(200, _state(sha256));

  /// The mime of a live record that points at [sha256], or null: then the
  /// hash answers the same 404 as an unknown one (D-224).
  String? _readableMime(String sha256) {
    for (final picture in live('pictures').values) {
      if (picture['file_sha256'] == sha256) {
        return picture['file_mime'] as String? ?? 'application/octet-stream';
      }
    }
    for (final note in live('notes').values) {
      if (note['audio_sha256'] == sha256) return 'audio/mp4';
    }
    return null;
  }

  /// The 416 of `getFile`: the file size in Content-Range (plan 079).
  http.Response _refused(String sha256, int size) {
    final response = _json(416, problemBody(416, 'range_not_satisfiable'));
    if (hideRangeSize.contains(sha256)) return response;
    return http.Response(
      response.body,
      416,
      headers: <String, String>{
        ...response.headers,
        'content-range': 'bytes */$size',
      },
    );
  }

  /// `getFile` as plan 055: one range, 206/416, ETag, If-Range (D-230).
  http.Response _getFile(http.Request request, String sha256, String device) {
    final refused = _fileRefusal(device);
    if (refused != null) return refused;
    final range = request.headers['range'];
    final ifRange = request.headers['if-range'];
    downloads.add((range: range, ifRange: ifRange));
    final mime = _readableMime(sha256);
    var bytes = files[sha256];
    if (mime == null || bytes == null) {
      return _json(404, problemBody(404, 'not_found'));
    }
    if ((serveWrongBytes[sha256] ?? 0) > 0) {
      serveWrongBytes[sha256] = serveWrongBytes[sha256]! - 1;
      bytes = Uint8List.fromList(bytes)..[0] ^= 0xff;
    }
    final headers = <String, String>{
      'content-type': mime,
      'etag': '"$sha256"',
      'accept-ranges': 'bytes',
      'cache-control': 'private, no-cache',
    };
    if ((refuseRange[sha256] ?? 0) > 0) {
      refuseRange[sha256] = refuseRange[sha256]! - 1;
      return _refused(sha256, bytes.length);
    }
    final match = RegExp(r'^bytes=(\d+)-(\d*)$').firstMatch(range ?? '');
    if (match == null ||
        ignoreRange.contains(sha256) ||
        (ifRange != null && ifRange != '"$sha256"')) {
      return http.Response.bytes(
        bytes,
        200,
        headers: <String, String>{
          ...headers,
          'content-length': '${bytes.length}',
        },
      );
    }
    final first = int.parse(match[1]!);
    if (first >= bytes.length) {
      return _refused(sha256, bytes.length);
    }
    var last = match[2]!.isEmpty ? bytes.length - 1 : int.parse(match[2]!);
    if (last >= bytes.length) last = bytes.length - 1;
    final piece = bytes.sublist(first, last + 1);
    return http.Response.bytes(
      piece,
      206,
      headers: <String, String>{
        ...headers,
        'content-length': '${piece.length}',
        'content-range': 'bytes $first-$last/${bytes.length}',
      },
    );
  }

  http.Response _putChunk(http.Request request, String sha256, String device) {
    final refused = _fileRefusal(device);
    if (refused != null) return refused;
    final range = request.headers['content-range'] ?? '';
    chunks.add(range);
    final match = RegExp(r'^bytes (\d+)-(\d+)/(\d+)$').firstMatch(range);
    if (match == null) return _json(400, problemBody(400, 'invalid_request'));
    final first = int.parse(match[1]!);
    final last = int.parse(match[2]!);
    final total = int.parse(match[3]!);
    final body = request.bodyBytes;
    if (total < 1 || last < first || last >= total) {
      return _json(400, problemBody(400, 'invalid_request'));
    }
    // As the real server: a body that does not match its range is a bad
    // request; a chunk or file over the limits is too large.
    if (body.length != last - first + 1) {
      return _json(400, problemBody(400, 'invalid_request'));
    }
    if (body.length > 4 * 1024 * 1024 || total > 100 * 1024 * 1024) {
      return _json(413, problemBody(413, 'payload_too_large'));
    }
    if (files.containsKey(sha256)) return _json(200, _state(sha256));
    final part = partFiles[sha256];
    if (part != null && part.total != total) {
      return _json(400, problemBody(400, 'invalid_request'));
    }
    if (first != _received(sha256)) {
      return _json(409, <String, Object?>{
        ...problemBody(409, 'offset_mismatch'),
        'received_bytes': _received(sha256),
      });
    }
    final stored = part ?? (total: total, bytes: BytesBuilder());
    partFiles[sha256] = stored;
    stored.bytes.add(body);
    if (stored.bytes.length < total) return _json(202, _state(sha256));
    final bytes = stored.bytes.takeBytes();
    partFiles.remove(sha256);
    final broken = (breakHash[sha256] ?? 0) > 0;
    if (broken) breakHash[sha256] = breakHash[sha256]! - 1;
    if (broken || sha256Of(bytes) != sha256) {
      return _json(422, problemBody(422, 'hash_mismatch'));
    }
    files[sha256] = bytes;
    return _json(200, _state(sha256));
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

/// Lower-case hex SHA-256 of [bytes].
String sha256Of(List<int> bytes) => sha256.convert(bytes).toString();
