// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i4;

import 'package:http/http.dart' as _i7;
import 'package:tonik_util/tonik_util.dart' as _i5;
import 'package:wio_api/src/model/push_request.dart' as _i8;
import 'package:wio_api/src/operation/sync_pull.dart' as _i3;
import 'package:wio_api/src/operation/sync_push.dart' as _i2;
import 'package:wio_api/src/response_wrapper/sync_pull_response.dart' as _i9;
import 'package:wio_api/src/response_wrapper/sync_push_response.dart' as _i6;
import 'package:wio_api/src/server/server.dart' as _i1;

/// Push and pull of changes (KB sync.md, D-96, D-97)
class SyncApi {
  SyncApi(_i1.Server server)
    : _syncPush = _i2.SyncPush(server.baseUrl, () => server.client),
      _syncPull = _i3.SyncPull(server.baseUrl, () => server.client);

  final _i2.SyncPush _syncPush;

  final _i3.SyncPull _syncPull;

  /// Send up to 200 changes from the outbox
  /// The server applies each change in its own transaction and answers one result per change, in request order. The app removes a change from its outbox only when its `change_id` comes back `applied` or `merged`; a `change_id` the server already applied is answered again, not applied twice (KB sync.md).
  _i4.Future<_i5.TonikResult<_i6.SyncPushResponse, _i7.Response>> syncPush({
    required _i8.PushRequest body,
    _i5.TonikCancellation? cancellation,
  }) async => this._syncPush(body: body, cancellation: cancellation);

  /// Changed records since a revision, in revision order
  /// Repeat with `since` = `last_revision` until `has_more` is false, then store `last_revision` (KB sync.md). Records the token may not read are never returned.
  _i4.Future<_i5.TonikResult<_i9.SyncPullResponse, _i7.Response>> syncPull({
    required _i4.int since,
    _i4.int limit = _i3.SyncPull.limitDefault,
    _i5.TonikCancellation? cancellation,
  }) async =>
      this._syncPull(since: since, limit: limit, cancellation: cancellation);
}
