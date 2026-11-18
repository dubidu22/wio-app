// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:http/http.dart' as _i5;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/model/file_state.dart' as _i6;
import 'package:wio_api/src/model/problem.dart' as _i7;
import 'package:wio_api/src/operation/http_operation.dart' as _i1;
import 'package:wio_api/src/response/maintenance.dart' as _i8;
import 'package:wio_api/src/response_wrapper/put_file_chunk_response.dart'
    as _i2;

final class PutFileChunk extends _i1.HttpOperation<_i2.PutFileChunkResponse> {
  PutFileChunk(super.baseUrl, super.clientAccessor);

  _i3.Future<_i4.TonikResult<_i2.PutFileChunkResponse, _i5.Response>> call({
    required _i4.TonikFile body,
    required _i3.String sha256,
    required _i3.String contentRange,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.HttpOperationRequest(
        method: 'PUT',
        path: _path(sha256: sha256),
        query: null,
        data: _data(body: body),
        options: _options(contentRange: contentRange),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({required _i3.String sha256}) {
    return [r'files', sha256.toSimple(explode: false, allowEmpty: false)];
  }

  _i3.Object? _data({required _i4.TonikFile body}) {
    return body.toBytes();
  }

  _i3.Map<_i3.String, _i3.String> _options({required _i3.String contentRange}) {
    final _$headers = <_i3.String, _i3.String>{};
    _$headers['Accept'] = r'application/json,application/problem+json';
    _$headers[r'Content-Range'] = contentRange.toSimple(
      explode: false,
      allowEmpty: false,
      literal: true,
    );
    _$headers[r'Content-Type'] = r'application/octet-stream';
    return _$headers;
  }

  _i2.PutFileChunkResponse _parseResponse(_i5.Response response) {
    final _$mediaType = _i4.extractMediaType(response.headers['content-type']);
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i6.FileState.fromJson(_$json);
        return _i2.PutFileChunkResponse200(body: _$body);
      case (200, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (202, r'application/json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i6.FileState.fromJson(_$json);
        return _i2.PutFileChunkResponse202(body: _$body);
      case (202, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (400, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.Problem.fromJson(_$json);
        return _i2.PutFileChunkResponse400(body: _$body);
      case (400, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (401, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.Problem.fromJson(_$json);
        return _i2.PutFileChunkResponse401(body: _$body);
      case (401, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (409, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.Problem.fromJson(_$json);
        return _i2.PutFileChunkResponse409(body: _$body);
      case (409, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (413, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.Problem.fromJson(_$json);
        return _i2.PutFileChunkResponse413(body: _$body);
      case (413, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (422, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.Problem.fromJson(_$json);
        return _i2.PutFileChunkResponse422(body: _$body);
      case (422, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (503, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i7.Problem.fromJson(_$json);
        return _i2.PutFileChunkResponse503(
          body: _i8.Maintenance(
            body: _$body,
            retryAfter: (response.headers[r'retry-after'])
                .decodeSimpleNullableInt(context: r'Retry-After'),
          ),
        );
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
