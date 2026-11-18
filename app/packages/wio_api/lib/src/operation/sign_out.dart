// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:http/http.dart' as _i5;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/model/problem.dart' as _i6;
import 'package:wio_api/src/operation/http_operation.dart' as _i1;
import 'package:wio_api/src/response/maintenance.dart' as _i7;
import 'package:wio_api/src/response_wrapper/sign_out_response.dart' as _i2;

final class SignOut extends _i1.HttpOperation<_i2.SignOutResponse> {
  SignOut(super.baseUrl, super.clientAccessor);

  _i3.Future<_i4.TonikResult<_i2.SignOutResponse, _i5.Response>> call({
    _i3.String? wioAppVersion,
    _i4.TonikCancellation? cancellation,
  }) {
    return this.execute(
      cancellation: cancellation,
      prepare: () => _i1.HttpOperationRequest(
        method: 'POST',
        path: _path(),
        query: null,
        data: _data(),
        options: _options(wioAppVersion: wioAppVersion),
      ),
      decode: _parseResponse,
    );
  }

  _i3.List<_i3.String> _path() {
    return [r'auth', r'sign-out'];
  }

  _i3.Object? _data() {
    return null;
  }

  _i3.Map<_i3.String, _i3.String> _options({_i3.String? wioAppVersion}) {
    final _$headers = <_i3.String, _i3.String>{};
    _$headers['Accept'] = r'application/problem+json';
    if (wioAppVersion != null) {
      _$headers[r'Wio-App-Version'] = wioAppVersion.toSimple(
        explode: false,
        allowEmpty: false,
        literal: true,
      );
    }
    return _$headers;
  }

  _i2.SignOutResponse _parseResponse(_i5.Response response) {
    final _$mediaType = _i4.extractMediaType(response.headers['content-type']);
    switch ((response.statusCode, _$mediaType)) {
      case (204, _):
        return _i2.SignOutResponse204();
      case (401, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i6.Problem.fromJson(_$json);
        return _i2.SignOutResponse401(body: _$body);
      case (401, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (426, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i6.Problem.fromJson(_$json);
        return _i2.SignOutResponse426(body: _$body);
      case (426, _):
        final _$content = response.headers['content-type'] ?? 'not specified';
        final _$matched = _$mediaType ?? 'none';
        final _$status = response.statusCode;
        throw _i4.ResponseDecodingException(
          'Unexpected content type: ${_$content} (matched as: ${_$matched}) for status code: ${_$status}',
        );
      case (503, r'application/problem+json'):
        final _$json = _i4.decodeResponseJson<_i3.Object?>(response.bodyBytes);
        final _$body = _i6.Problem.fromJson(_$json);
        return _i2.SignOutResponse503(
          body: _i7.Maintenance(
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
        final _$body = _i6.Problem.fromJson(_$json);
        return _i2.SignOutResponseDefault(body: _$body);
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
