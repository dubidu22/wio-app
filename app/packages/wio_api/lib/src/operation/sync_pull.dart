// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:http/http.dart' as _i5;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/model/problem.dart' as _i8;
import 'package:wio_api/src/model/pull_result.dart' as _i7;
import 'package:wio_api/src/operation/http_operation.dart' as _i1;
import 'package:wio_api/src/response/maintenance.dart' as _i9;
import 'package:wio_api/src/response_wrapper/sync_pull_response.dart' as _i2;

final class SyncPull extends _i1.HttpOperation<_i2.SyncPullResponse> {
  SyncPull(super.baseUrl, super.clientAccessor);

  static const _i3.int limitDefault = 500;

  _i3.Future<_i4.TonikResult<_i2.SyncPullResponse, _i5.Response>> call({
    required _i3.int since,
    _i3.int limit = limitDefault,
    _i3.String? wioAppVersion,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.HttpOperationRequest(
        method: 'GET',
        path: _path(),
        query: _queryParameters(since: since, limit: limit),
        data: _data(),
        options: _options(wioAppVersion: wioAppVersion),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path() {
    return [r'sync', r'pull'];
  }

  _i3.Object? _data() {
    return null;
  }

  _i3.String? _queryParameters({required _i3.int since, _i3.int? limit}) {
    final _$entries = <_i4.ParameterEntry>[];
    _$entries.addAll(
      since.toForm(
        r'since',
        explode: true,
        allowEmpty: false,
        textEncoding: _i6.utf8,
      ),
    );
    if (limit != null) {
      _$entries.addAll(
        limit.toForm(
          r'limit',
          explode: true,
          allowEmpty: false,
          textEncoding: _i6.utf8,
        ),
      );
    }
    if (_$entries.isEmpty) {
      return null;
    }
    return _$entries
        .map((e) => e.name.isEmpty ? e.value : '${e.name}=${e.value}')
        .join('&');
  }

  _i3.Map<_i3.String, _i3.String> _options({_i3.String? wioAppVersion}) {
    final _$headers = <_i3.String, _i3.String>{};
    _$headers['Accept'] = r'application/json,application/problem+json';
    if (wioAppVersion != null) {
      _$headers[r'Wio-App-Version'] = wioAppVersion.toSimple(
        explode: false,
        allowEmpty: false,
        literal: true,
      );
    }
    return _$headers;
  }

  _i2.SyncPullResponse _parseResponse(_i5.Response response) {
    final _$mediaType = _i4.extractMediaType(response.headers['content-type']);
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.PullResult.fromJson(_$json);
        return _i2.SyncPullResponse200(body: _$body);
      case (200, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (400, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i8.Problem.fromJson(_$json);
        return _i2.SyncPullResponse400(body: _$body);
      case (400, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (401, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i8.Problem.fromJson(_$json);
        return _i2.SyncPullResponse401(body: _$body);
      case (401, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (410, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i8.Problem.fromJson(_$json);
        return _i2.SyncPullResponse410(body: _$body);
      case (410, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (426, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i8.Problem.fromJson(_$json);
        return _i2.SyncPullResponse426(body: _$body);
      case (426, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (503, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i8.Problem.fromJson(_$json);
        return _i2.SyncPullResponse503(
          body: _i9.Maintenance(
            body: _$body,
            retryAfter: (response.headers[r'retry-after'])
                .decodeSimpleNullableInt(context: r'Retry-After'),
          ),
        );
      case (503, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (_, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i8.Problem.fromJson(_$json);
        return _i2.SyncPullResponseDefault(body: _$body);
      default:
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
    }
  }
}
