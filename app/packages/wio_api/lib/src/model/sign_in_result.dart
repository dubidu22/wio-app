// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/me_user.dart' as _i4;
import 'package:wio_api/src/model/me_workspace.dart' as _i5;

@_i2.immutable
class SignInResult extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const SignInResult({
    required this.token,
    required this.deviceId,
    required this.user,
    required this.workspace,
  });

  factory SignInResult.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for SignInResult: contains complex types',
    );
  }

  factory SignInResult.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'SignInResult');
    return SignInResult(
      token: _$map[r'token'].decodeJsonString(context: r'SignInResult.token'),
      deviceId: _$map[r'device_id'].decodeJsonString(
        context: r'SignInResult.device_id',
      ),
      user: _i4.MeUser.fromJson(_$map[r'user']),
      workspace: _i5.MeWorkspace.fromJson(_$map[r'workspace']),
    );
  }

  factory SignInResult.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for SignInResult: contains complex types',
    );
  }

  /// Send as `Authorization: Bearer <token>`; the server keeps only its hash.
  final _i3.String token;

  final _i3.String deviceId;

  final _i4.MeUser user;

  final _i5.MeWorkspace workspace;

  @_i3.override
  _i3.Object? toJson() => {
    r'token': this.token,
    r'device_id': this.deviceId,
    r'user': this.user.toJson(),
    r'workspace': this.workspace.toJson(),
  };

  SignInResult Function({
    _i3.String? token,
    _i3.String? deviceId,
    _i4.MeUser? user,
    _i5.MeWorkspace? workspace,
  })
  get copyWith {
    return ({
      _i3.String? token,
      _i3.String? deviceId,
      _i4.MeUser? user,
      _i5.MeWorkspace? workspace,
    }) => SignInResult(
      token: token ?? this.token,
      deviceId: deviceId ?? this.deviceId,
      user: user ?? this.user,
      workspace: workspace ?? this.workspace,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SignInResult &&
        other.token == this.token &&
        other.deviceId == this.deviceId &&
        other.user == this.user &&
        other.workspace == this.workspace;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.token,
      this.deviceId,
      this.user,
      this.workspace,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for SignInResult: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode SignInResult: complex types cannot be URI-encoded',
    );
  }
}
