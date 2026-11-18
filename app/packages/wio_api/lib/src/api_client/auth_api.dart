// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i7;

import 'package:http/http.dart' as _i10;
import 'package:tonik_util/tonik_util.dart' as _i8;
import 'package:wio_api/src/model/sign_in_request.dart' as _i11;
import 'package:wio_api/src/operation/get_me.dart' as _i4;
import 'package:wio_api/src/operation/list_devices.dart' as _i5;
import 'package:wio_api/src/operation/revoke_device.dart' as _i6;
import 'package:wio_api/src/operation/sign_in.dart' as _i2;
import 'package:wio_api/src/operation/sign_out.dart' as _i3;
import 'package:wio_api/src/response_wrapper/get_me_response.dart' as _i13;
import 'package:wio_api/src/response_wrapper/list_devices_response.dart'
    as _i14;
import 'package:wio_api/src/response_wrapper/revoke_device_response.dart'
    as _i15;
import 'package:wio_api/src/response_wrapper/sign_in_response.dart' as _i9;
import 'package:wio_api/src/response_wrapper/sign_out_response.dart' as _i12;
import 'package:wio_api/src/server/server.dart' as _i1;

/// Owner sign-in and device tokens (behaviour in issue 5, D-100)
class AuthApi {
  AuthApi(_i1.Server server)
    : _signIn = _i2.SignIn(server.baseUrl, () => server.client),
      _signOut = _i3.SignOut(server.baseUrl, () => server.client),
      _getMe = _i4.GetMe(server.baseUrl, () => server.client),
      _listDevices = _i5.ListDevices(server.baseUrl, () => server.client),
      _revokeDevice = _i6.RevokeDevice(server.baseUrl, () => server.client);

  final _i2.SignIn _signIn;

  final _i3.SignOut _signOut;

  final _i4.GetMe _getMe;

  final _i5.ListDevices _listDevices;

  final _i6.RevokeDevice _revokeDevice;

  /// Sign in with e-mail and password and get a device token
  /// Creates one device token for this device. When the e-mail and password match users in more than one workspace and no `workspace_id` is given, the answer is 409 with the workspaces to choose from (only after the password matched).
  _i7.Future<_i8.TonikResult<_i9.SignInResponse, _i10.Response>> signIn({
    required _i11.SignInRequest body,
    _i8.TonikCancellation? cancellation,
  }) async => this._signIn(body: body, cancellation: cancellation);

  /// Revoke the calling device token
  _i7.Future<_i8.TonikResult<_i12.SignOutResponse, _i10.Response>> signOut({
    _i8.TonikCancellation? cancellation,
  }) async => this._signOut(cancellation: cancellation);

  /// The signed-in user and workspace of this token
  _i7.Future<_i8.TonikResult<_i13.GetMeResponse, _i10.Response>> getMe({
    _i8.TonikCancellation? cancellation,
  }) async => this._getMe(cancellation: cancellation);

  /// The devices signed in as this user
  _i7.Future<_i8.TonikResult<_i14.ListDevicesResponse, _i10.Response>>
  listDevices({_i8.TonikCancellation? cancellation}) async =>
      this._listDevices(cancellation: cancellation);

  /// Sign out another device of this user
  _i7.Future<_i8.TonikResult<_i15.RevokeDeviceResponse, _i10.Response>>
  revokeDevice({
    required _i7.String deviceId,
    _i8.TonikCancellation? cancellation,
  }) async =>
      this._revokeDevice(deviceId: deviceId, cancellation: cancellation);
}
