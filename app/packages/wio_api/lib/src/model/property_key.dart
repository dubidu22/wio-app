// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `property_keys` record as sync pulls it (D-95).
@_i2.immutable
class PropertyKey extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PropertyKey({
    required this.name,
    required this.unit,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory PropertyKey.fromSimple(
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
        r'name',
        r'unit',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'PropertyKey',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PropertyKey(
      id: _$values[r'id'].decodeSimpleString(context: r'PropertyKey.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'PropertyKey.workspace_id',
      ),
      name: _$values[r'name'].decodeSimpleString(context: r'PropertyKey.name'),
      unit: _$values[r'unit'].decodeSimpleNullableString(
        context: r'PropertyKey.unit',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'PropertyKey.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'PropertyKey.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'PropertyKey.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'PropertyKey.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'PropertyKey.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'PropertyKey.deleted_at',
      ),
    );
  }

  factory PropertyKey.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PropertyKey');
    return PropertyKey(
      id: _$map[r'id'].decodeJsonString(context: r'PropertyKey.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'PropertyKey.workspace_id',
      ),
      name: _$map[r'name'].decodeJsonString(context: r'PropertyKey.name'),
      unit: _$map[r'unit'].decodeJsonNullableString(
        context: r'PropertyKey.unit',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'PropertyKey.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'PropertyKey.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'PropertyKey.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'PropertyKey.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(
        context: r'PropertyKey.revision',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'PropertyKey.deleted_at',
      ),
    );
  }

  factory PropertyKey.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'name',
        r'unit',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'PropertyKey',
    );
    return PropertyKey(
      id: _$values[r'id'].decodeFormString(context: r'PropertyKey.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'PropertyKey.workspace_id',
      ),
      name: _$values[r'name'].decodeFormString(context: r'PropertyKey.name'),
      unit: _$values[r'unit'].decodeFormNullableString(
        context: r'PropertyKey.unit',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'PropertyKey.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'PropertyKey.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'PropertyKey.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'PropertyKey.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'PropertyKey.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'PropertyKey.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String name;

  final _i3.String? unit;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {r'name': this.name, r'unit': this.unit};

  PropertyKey Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? name,
    _i3.String? unit,
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
      _i3.String? name,
      _i3.Object? unit = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => PropertyKey(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      name: name ?? this.name,
      unit: _i3.identical(unit, _sentinel) ? this.unit : (unit as _i3.String?),
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
    return other is PropertyKey &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.name == this.name &&
        other.unit == this.unit &&
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
      this.name,
      this.unit,
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
    _$result[r'name'] = _i1.PropertyValue.scalar(this.name);
    if (this.unit != null) {
      _$result[r'unit'] = _i1.PropertyValue.scalar(this.unit!);
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
      r'Cannot uriEncode PropertyKey: complex types cannot be URI-encoded',
    );
  }
}
