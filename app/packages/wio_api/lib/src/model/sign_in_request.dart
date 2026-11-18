// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class SignInRequest extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const SignInRequest({
    required this.email,
    required this.password,
    required this.deviceName,
    this.workspaceId,
  });

  factory SignInRequest.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'email', r'password', r'device_name', r'workspace_id'},
      listKeys: {},
      context: r'SignInRequest',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return SignInRequest(
      email: _$values[r'email'].decodeSimpleString(
        context: r'SignInRequest.email',
      ),
      password: _$values[r'password'].decodeSimpleString(
        context: r'SignInRequest.password',
      ),
      deviceName: _$values[r'device_name'].decodeSimpleString(
        context: r'SignInRequest.device_name',
      ),
      workspaceId: _$values[r'workspace_id'].decodeSimpleNullableString(
        context: r'SignInRequest.workspace_id',
      ),
    );
  }

  factory SignInRequest.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'SignInRequest');
    return SignInRequest(
      email: _$map[r'email'].decodeJsonString(context: r'SignInRequest.email'),
      password: _$map[r'password'].decodeJsonString(
        context: r'SignInRequest.password',
      ),
      deviceName: _$map[r'device_name'].decodeJsonString(
        context: r'SignInRequest.device_name',
      ),
      workspaceId: _$map[r'workspace_id'].decodeJsonNullableString(
        context: r'SignInRequest.workspace_id',
      ),
    );
  }

  factory SignInRequest.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'email', r'password', r'device_name', r'workspace_id'},
      listKeys: {},
      context: r'SignInRequest',
    );
    return SignInRequest(
      email: _$values[r'email'].decodeFormString(
        context: r'SignInRequest.email',
      ),
      password: _$values[r'password'].decodeFormString(
        context: r'SignInRequest.password',
      ),
      deviceName: _$values[r'device_name'].decodeFormString(
        context: r'SignInRequest.device_name',
      ),
      workspaceId: _$values[r'workspace_id'].decodeFormNullableString(
        context: r'SignInRequest.workspace_id',
      ),
    );
  }

  final _i3.String email;

  final _i3.String password;

  /// Shown in the device list, for example the phone model.
  final _i3.String deviceName;

  /// Only after a 409 with several workspaces.
  final _i3.String? workspaceId;

  @_i3.override
  _i3.Object? toJson() => {
    r'email': this.email,
    r'password': this.password,
    r'device_name': this.deviceName,
    if (this.workspaceId != null) r'workspace_id': this.workspaceId,
  };

  SignInRequest Function({
    _i3.String? email,
    _i3.String? password,
    _i3.String? deviceName,
    _i3.String? workspaceId,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? email,
      _i3.String? password,
      _i3.String? deviceName,
      _i3.Object? workspaceId = _sentinel,
    }) => SignInRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      deviceName: deviceName ?? this.deviceName,
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is SignInRequest &&
        other.email == this.email &&
        other.password == this.password &&
        other.deviceName == this.deviceName &&
        other.workspaceId == this.workspaceId;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.email,
      this.password,
      this.deviceName,
      this.workspaceId,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'email'] = _i1.PropertyValue.scalar(this.email);
    _$result[r'password'] = _i1.PropertyValue.scalar(this.password);
    _$result[r'device_name'] = _i1.PropertyValue.scalar(this.deviceName);
    if (this.workspaceId != null) {
      _$result[r'workspace_id'] = _i1.PropertyValue.scalar(this.workspaceId!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode SignInRequest: complex types cannot be URI-encoded',
    );
  }
}
