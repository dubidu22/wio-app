// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/me_user.dart' as _i4;
import 'package:wio_api/src/model/me_workspace.dart' as _i5;

@_i2.immutable
class Me extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Me({
    required this.deviceId,
    required this.user,
    required this.workspace,
  });

  factory Me.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Me: contains complex types',
    );
  }

  factory Me.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Me');
    return Me(
      deviceId: _$map[r'device_id'].decodeJsonString(context: r'Me.device_id'),
      user: _i4.MeUser.fromJson(_$map[r'user']),
      workspace: _i5.MeWorkspace.fromJson(_$map[r'workspace']),
    );
  }

  factory Me.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Me: contains complex types',
    );
  }

  final _i3.String deviceId;

  final _i4.MeUser user;

  final _i5.MeWorkspace workspace;

  @_i3.override
  _i3.Object? toJson() => {
    r'device_id': this.deviceId,
    r'user': this.user.toJson(),
    r'workspace': this.workspace.toJson(),
  };

  Me Function({
    _i3.String? deviceId,
    _i4.MeUser? user,
    _i5.MeWorkspace? workspace,
  })
  get copyWith {
    return ({
      _i3.String? deviceId,
      _i4.MeUser? user,
      _i5.MeWorkspace? workspace,
    }) => Me(
      deviceId: deviceId ?? this.deviceId,
      user: user ?? this.user,
      workspace: workspace ?? this.workspace,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Me &&
        other.deviceId == this.deviceId &&
        other.user == this.user &&
        other.workspace == this.workspace;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.deviceId, this.user, this.workspace]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Me: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Me: complex types cannot be URI-encoded',
    );
  }
}
