// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/me_user_role_model.dart' as _i4;

@_i2.immutable
class MeUser extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const MeUser({
    required this.id,
    required this.role,
    required this.displayName,
  });

  factory MeUser.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'role', r'display_name'},
      listKeys: {},
      context: r'MeUser',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return MeUser(
      id: _$values[r'id'].decodeSimpleString(context: r'MeUser.id'),
      role: _i4.MeUserRoleModel.fromSimple(_$values[r'role'], explode: explode),
      displayName: _$values[r'display_name'].decodeSimpleNullableString(
        context: r'MeUser.display_name',
      ),
    );
  }

  factory MeUser.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'MeUser');
    return MeUser(
      id: _$map[r'id'].decodeJsonString(context: r'MeUser.id'),
      role: _i4.MeUserRoleModel.fromJson(_$map[r'role']),
      displayName: _$map[r'display_name'].decodeJsonNullableString(
        context: r'MeUser.display_name',
      ),
    );
  }

  factory MeUser.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'role', r'display_name'},
      listKeys: {},
      context: r'MeUser',
    );
    return MeUser(
      id: _$values[r'id'].decodeFormString(context: r'MeUser.id'),
      role: _i4.MeUserRoleModel.fromForm(_$values[r'role'], explode: explode),
      displayName: _$values[r'display_name'].decodeFormNullableString(
        context: r'MeUser.display_name',
      ),
    );
  }

  final _i3.String id;

  final _i4.MeUserRoleModel role;

  final _i3.String? displayName;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'role': this.role.toJson(),
    r'display_name': this.displayName,
  };

  MeUser Function({
    _i3.String? id,
    _i4.MeUserRoleModel? role,
    _i3.String? displayName,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i4.MeUserRoleModel? role,
      _i3.Object? displayName = _sentinel,
    }) => MeUser(
      id: id ?? this.id,
      role: role ?? this.role,
      displayName: _i3.identical(displayName, _sentinel)
          ? this.displayName
          : (displayName as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MeUser &&
        other.id == this.id &&
        other.role == this.role &&
        other.displayName == this.displayName;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.role, this.displayName]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'role'] = _i1.PropertyValue.scalar(this.role.toJson());
    if (this.displayName != null) {
      _$result[r'display_name'] = _i1.PropertyValue.scalar(this.displayName!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode MeUser: complex types cannot be URI-encoded',
    );
  }
}
