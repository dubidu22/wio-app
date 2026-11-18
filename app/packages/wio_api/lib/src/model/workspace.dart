// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/workspace_plan_model.dart' as _i4;

/// A `workspaces` record as sync pulls it (D-95).
@_i2.immutable
class Workspace extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const Workspace({
    required this.name,
    required this.plan,
    this.id,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Workspace.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'name',
        r'plan',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Workspace',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Workspace(
      id: _$values[r'id'].decodeSimpleString(context: r'Workspace.id'),
      name: _$values[r'name'].decodeSimpleNullableString(
        context: r'Workspace.name',
      ),
      plan: _i4.WorkspacePlanModel.fromSimple(
        _$values[r'plan'],
        explode: explode,
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Workspace.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Workspace.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Workspace.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Workspace.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Workspace.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Workspace.deleted_at',
      ),
    );
  }

  factory Workspace.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Workspace');
    return Workspace(
      id: _$map[r'id'].decodeJsonString(context: r'Workspace.id'),
      name: _$map[r'name'].decodeJsonNullableString(context: r'Workspace.name'),
      plan: _i4.WorkspacePlanModel.fromJson(_$map[r'plan']),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Workspace.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Workspace.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Workspace.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Workspace.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(
        context: r'Workspace.revision',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Workspace.deleted_at',
      ),
    );
  }

  factory Workspace.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'name',
        r'plan',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Workspace',
    );
    return Workspace(
      id: _$values[r'id'].decodeFormString(context: r'Workspace.id'),
      name: _$values[r'name'].decodeFormNullableString(
        context: r'Workspace.name',
      ),
      plan: _i4.WorkspacePlanModel.fromForm(
        _$values[r'plan'],
        explode: explode,
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Workspace.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Workspace.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Workspace.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Workspace.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'Workspace.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Workspace.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? name;

  final _i4.WorkspacePlanModel plan;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {r'name': this.name, r'plan': this.plan.toJson()};

  Workspace Function({
    _i3.String? id,
    _i3.String? name,
    _i4.WorkspacePlanModel? plan,
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
      _i3.Object? name = _sentinel,
      _i4.WorkspacePlanModel? plan,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Workspace(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
      plan: plan ?? this.plan,
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
    return other is Workspace &&
        other.id == this.id &&
        other.name == this.name &&
        other.plan == this.plan &&
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
      this.name,
      this.plan,
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
    if (this.name != null) {
      _$result[r'name'] = _i1.PropertyValue.scalar(this.name!);
    }
    _$result[r'plan'] = _i1.PropertyValue.scalar(this.plan.toJson());
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
      r'Cannot uriEncode Workspace: complex types cannot be URI-encoded',
    );
  }
}
