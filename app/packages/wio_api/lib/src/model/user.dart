// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/user_role_model.dart' as _i4;

/// A `users` record as sync pulls it (D-95).
@_i2.immutable
class User extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const User({
    required this.customerId,
    required this.role,
    required this.displayName,
    required this.email,
    required this.expiresAt,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory User.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'role',
        r'display_name',
        r'email',
        r'expires_at',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'User',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return User(
      id: _$values[r'id'].decodeSimpleString(context: r'User.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'User.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'User.customer_id',
      ),
      role: _i4.UserRoleModel.fromSimple(_$values[r'role'], explode: explode),
      displayName: _$values[r'display_name'].decodeSimpleNullableString(
        context: r'User.display_name',
      ),
      email: _$values[r'email'].decodeSimpleNullableString(
        context: r'User.email',
      ),
      expiresAt: _$values[r'expires_at'].decodeSimpleNullableDateTime(
        context: r'User.expires_at',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'User.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'User.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'User.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'User.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'User.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'User.deleted_at',
      ),
    );
  }

  factory User.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'User');
    return User(
      id: _$map[r'id'].decodeJsonString(context: r'User.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'User.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'User.customer_id',
      ),
      role: _i4.UserRoleModel.fromJson(_$map[r'role']),
      displayName: _$map[r'display_name'].decodeJsonNullableString(
        context: r'User.display_name',
      ),
      email: _$map[r'email'].decodeJsonNullableString(context: r'User.email'),
      expiresAt: _$map[r'expires_at'].decodeJsonNullableDateTime(
        context: r'User.expires_at',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'User.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'User.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'User.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'User.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'User.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'User.deleted_at',
      ),
    );
  }

  factory User.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'role',
        r'display_name',
        r'email',
        r'expires_at',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'User',
    );
    return User(
      id: _$values[r'id'].decodeFormString(context: r'User.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'User.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'User.customer_id',
      ),
      role: _i4.UserRoleModel.fromForm(_$values[r'role'], explode: explode),
      displayName: _$values[r'display_name'].decodeFormNullableString(
        context: r'User.display_name',
      ),
      email: _$values[r'email'].decodeFormNullableString(
        context: r'User.email',
      ),
      expiresAt: _$values[r'expires_at'].decodeFormNullableDateTime(
        context: r'User.expires_at',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'User.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'User.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'User.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'User.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(context: r'User.revision'),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'User.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i4.UserRoleModel role;

  final _i3.String? displayName;

  final _i3.String? email;

  final _i3.DateTime? expiresAt;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'role': this.role.toJson(),
    r'display_name': this.displayName,
    r'email': this.email,
    r'expires_at': this.expiresAt?.toTimeZonedIso8601String(),
  };

  User Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i4.UserRoleModel? role,
    _i3.String? displayName,
    _i3.String? email,
    _i3.DateTime? expiresAt,
    _i3.DateTime? createdAt,
    _i3.String? createdBy,
    _i3.DateTime? updatedAt,
    _i3.String? updatedBy,
    _i3.int? revision,
    _i3.DateTime? deletedAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? id = _sentinel,
      _i3.Object? workspaceId = _sentinel,
      _i3.Object? customerId = _sentinel,
      _i4.UserRoleModel? role,
      _i3.Object? displayName = _sentinel,
      _i3.Object? email = _sentinel,
      _i3.Object? expiresAt = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => User(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      role: role ?? this.role,
      displayName: _i3.identical(displayName, _sentinel)
          ? this.displayName
          : (displayName as _i3.String?),
      email: _i3.identical(email, _sentinel)
          ? this.email
          : (email as _i3.String?),
      expiresAt: _i3.identical(expiresAt, _sentinel)
          ? this.expiresAt
          : (expiresAt as _i3.DateTime?),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime?),
      createdBy: _i3.identical(createdBy, _sentinel)
          ? this.createdBy
          : (createdBy as _i3.String?),
      updatedAt: _i3.identical(updatedAt, _sentinel)
          ? this.updatedAt
          : (updatedAt as _i3.DateTime?),
      updatedBy: _i3.identical(updatedBy, _sentinel)
          ? this.updatedBy
          : (updatedBy as _i3.String?),
      revision: _i3.identical(revision, _sentinel)
          ? this.revision
          : (revision as _i3.int?),
      deletedAt: _i3.identical(deletedAt, _sentinel)
          ? this.deletedAt
          : (deletedAt as _i3.DateTime?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is User &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.role == this.role &&
        other.displayName == this.displayName &&
        other.email == this.email &&
        other.expiresAt == this.expiresAt &&
        other.createdAt == this.createdAt &&
        other.createdBy == this.createdBy &&
        other.updatedAt == this.updatedAt &&
        other.updatedBy == this.updatedBy &&
        other.revision == this.revision &&
        other.deletedAt == this.deletedAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.workspaceId,
      this.customerId,
      this.role,
      this.displayName,
      this.email,
      this.expiresAt,
      this.createdAt,
      this.createdBy,
      this.updatedAt,
      this.updatedBy,
      this.revision,
      this.deletedAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    if (this.customerId != null) {
      _$result[r'customer_id'] = _i1.PropertyValue.scalar(this.customerId!);
    }
    _$result[r'role'] = _i1.PropertyValue.scalar(this.role.toJson());
    if (this.displayName != null) {
      _$result[r'display_name'] = _i1.PropertyValue.scalar(this.displayName!);
    }
    if (this.email != null) {
      _$result[r'email'] = _i1.PropertyValue.scalar(this.email!);
    }
    if (this.expiresAt != null) {
      _$result[r'expires_at'] = _i1.PropertyValue.scalar(
        this.expiresAt!.toTimeZonedIso8601String(),
      );
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
      r'Cannot uriEncode User: complex types cannot be URI-encoded',
    );
  }
}
