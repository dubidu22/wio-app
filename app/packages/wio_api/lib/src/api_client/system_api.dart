// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:http/http.dart' as _i6;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/operation/get_health.dart' as _i2;
import 'package:wio_api/src/response_wrapper/get_health_response.dart' as _i5;
import 'package:wio_api/src/server/server.dart' as _i1;

/// Operational endpoints
class SystemApi {
  SystemApi(_i1.Server server)
    : _getHealth = _i2.GetHealth(server.baseUrl, () => server.client);

  final _i2.GetHealth _getHealth;

  /// Check that the API is up
  /// Answers without touching the database, for deploy smoke tests.
  /// [wioAppVersion] Version of the app that sends the request (D-140), from its build. Only major.minor.patch is compared; +build is ignored (D-141). Missing: accepted. Malformed: 400 `invalid_request`. Below the server's minimum: 426 `upgrade_required` (D-142).
  _i3.Future<_i4.TonikResult<_i5.GetHealthResponse, _i6.Response>> getHealth({
    _i3.String? wioAppVersion,
    _i4.TonikCancellation? cancellation,
  }) async =>
      this._getHealth(wioAppVersion: wioAppVersion, cancellation: cancellation);
}
