// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:http/http.dart' as _i5;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/model/accept_ranges_model.dart' as _i7;
import 'package:wio_api/src/model/problem.dart' as _i10;
import 'package:wio_api/src/operation/http_operation.dart' as _i1;
import 'package:wio_api/src/response/files_sha256_get200_response.dart' as _i6;
import 'package:wio_api/src/response/files_sha256_get206_response.dart' as _i8;
import 'package:wio_api/src/response/files_sha256_get304_response.dart' as _i9;
import 'package:wio_api/src/response/maintenance.dart' as _i11;
import 'package:wio_api/src/response_wrapper/get_file_response.dart' as _i2;

final class GetFile extends _i1.HttpOperation<_i2.GetFileResponse> {
  GetFile(super.baseUrl, super.clientAccessor);

  _i3.Future<_i4.TonikResult<_i2.GetFileResponse, _i5.Response>> call({
    required _i3.String sha256,
    _i3.String? range,
    _i3.String? ifNoneMatch,
    _i3.String? ifRange,
    _i3.String? wioAppVersion,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.HttpOperationRequest(
        method: 'GET',
        path: _path(sha256: sha256),
        query: null,
        data: _data(),
        options: _options(
          range: range,
          ifNoneMatch: ifNoneMatch,
          ifRange: ifRange,
          wioAppVersion: wioAppVersion,
        ),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path({required _i3.String sha256}) {
    return [r'files', sha256.toSimple(explode: false, allowEmpty: false)];
  }

  _i3.Object? _data() {
    return null;
  }

  _i3.Map<_i3.String, _i3.String> _options({
    _i3.String? range,
    _i3.String? ifNoneMatch,
    _i3.String? ifRange,
    _i3.String? wioAppVersion,
  }) {
    final _$headers = <_i3.String, _i3.String>{};
    _$headers['Accept'] = r'image/jpeg,image/png,image/webp,image/heic,audio/mp4,application/octet-stream,application/problem+json';
    if (range != null) {
      _$headers[r'Range'] = range.toSimple(
        explode: false,
        allowEmpty: false,
        literal: true,
      );
    }
    if (ifNoneMatch != null) {
      _$headers[r'If-None-Match'] = ifNoneMatch.toSimple(
        explode: false,
        allowEmpty: false,
        literal: true,
      );
    }
    if (ifRange != null) {
      _$headers[r'If-Range'] = ifRange.toSimple(
        explode: false,
        allowEmpty: false,
        literal: true,
      );
    }
    if (wioAppVersion != null) {
      _$headers[r'Wio-App-Version'] = wioAppVersion.toSimple(
        explode: false,
        allowEmpty: false,
        literal: true,
      );
    }
    return _$headers;
  }

  _i2.GetFileResponse _parseResponse(_i5.Response response) {
    final _$mediaType = _i4.extractMediaType(response.headers['content-type']);
    switch ((response.statusCode, _$mediaType)) {
      case (200, r'image/jpeg'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse200(
          body: _i6.FilesSha256Get200ResponseJpeg(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
          ),
        );
      case (200, r'image/png'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse200(
          body: _i6.FilesSha256Get200ResponsePng(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
          ),
        );
      case (200, r'image/webp'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse200(
          body: _i6.FilesSha256Get200ResponseWebp(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
          ),
        );
      case (200, r'image/heic'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse200(
          body: _i6.FilesSha256Get200ResponseHeic(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
          ),
        );
      case (200, r'audio/mp4'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse200(
          body: _i6.FilesSha256Get200ResponseMp4(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
          ),
        );
      case (200, r'application/octet-stream'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse200(
          body: _i6.FilesSha256Get200ResponseOctetStream(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
          ),
        );
      case (200, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (206, r'image/jpeg'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse206(
          body: _i8.FilesSha256Get206ResponseJpeg(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
            contentRange: (response.headers[r'content-range'])
                .decodeSimpleString(context: r'Content-Range'),
          ),
        );
      case (206, r'image/png'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse206(
          body: _i8.FilesSha256Get206ResponsePng(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
            contentRange: (response.headers[r'content-range'])
                .decodeSimpleString(context: r'Content-Range'),
          ),
        );
      case (206, r'image/webp'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse206(
          body: _i8.FilesSha256Get206ResponseWebp(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
            contentRange: (response.headers[r'content-range'])
                .decodeSimpleString(context: r'Content-Range'),
          ),
        );
      case (206, r'image/heic'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse206(
          body: _i8.FilesSha256Get206ResponseHeic(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
            contentRange: (response.headers[r'content-range'])
                .decodeSimpleString(context: r'Content-Range'),
          ),
        );
      case (206, r'audio/mp4'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse206(
          body: _i8.FilesSha256Get206ResponseMp4(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
            contentRange: (response.headers[r'content-range'])
                .decodeSimpleString(context: r'Content-Range'),
          ),
        );
      case (206, r'application/octet-stream'):
        final _$body = _i4.TonikFileBytes(
          _i4.decodeResponseBytes(response.bodyBytes),
        );
        return _i2.GetFileResponse206(
          body: _i8.FilesSha256Get206ResponseOctetStream(
            body: _$body,
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
            acceptRanges: _i7.AcceptRangesModel.fromSimple(
              (response.headers[r'accept-ranges']),
              explode: false,
            ),
            contentLength: (response.headers[r'content-length'])
                .decodeSimpleInt(context: r'Content-Length'),
            contentRange: (response.headers[r'content-range'])
                .decodeSimpleString(context: r'Content-Range'),
          ),
        );
      case (206, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (304, _):
        return _i2.GetFileResponse304(
          body: _i9.FilesSha256Get304Response(
            eTag: (response.headers[r'etag']).decodeSimpleString(
              context: r'ETag',
            ),
          ),
        );
      case (400, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse400(body: _$body);
      case (400, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (401, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse401(body: _$body);
      case (401, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (403, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse403(body: _$body);
      case (403, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (404, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse404(body: _$body);
      case (404, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (416, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse416(body: _$body);
      case (416, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (426, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse426(body: _$body);
      case (426, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (503, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponse503(
          body: _i11.Maintenance(
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
        final _$body = _i10.Problem.fromJson(_$json);
        return _i2.GetFileResponseDefault(body: _$body);
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
