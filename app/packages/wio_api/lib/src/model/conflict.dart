// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/conflict_entity_model.dart' as _i4;

/// A `conflicts` record as sync pulls it (D-95).
@_i2.immutable
class Conflict extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const Conflict({
    required this.customerId,
    required this.entity,
    required this.entityId,
    required this.field,
    required this.lostValue,
    required this.lostChangeId,
    required this.wonRevision,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Conflict.fromSimple(
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
        r'entity',
        r'entity_id',
        r'field',
        r'lost_value',
        r'lost_change_id',
        r'won_revision',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Conflict',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Conflict(
      id: _$values[r'id'].decodeSimpleString(context: r'Conflict.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Conflict.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'Conflict.customer_id',
      ),
      entity: _i4.ConflictEntityModel.fromSimple(
        _$values[r'entity'],
        explode: explode,
      ),
      entityId: _$values[r'entity_id'].decodeSimpleString(
        context: r'Conflict.entity_id',
      ),
      field: _$values[r'field'].decodeSimpleString(context: r'Conflict.field'),
      lostValue: _$values[r'lost_value'],
      lostChangeId: _$values[r'lost_change_id'].decodeSimpleNullableString(
        context: r'Conflict.lost_change_id',
      ),
      wonRevision: _$values[r'won_revision'].decodeSimpleInt(
        context: r'Conflict.won_revision',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Conflict.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Conflict.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Conflict.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Conflict.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Conflict.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Conflict.deleted_at',
      ),
    );
  }

  factory Conflict.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Conflict');
    return Conflict(
      id: _$map[r'id'].decodeJsonString(context: r'Conflict.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Conflict.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Conflict.customer_id',
      ),
      entity: _i4.ConflictEntityModel.fromJson(_$map[r'entity']),
      entityId: _$map[r'entity_id'].decodeJsonString(
        context: r'Conflict.entity_id',
      ),
      field: _$map[r'field'].decodeJsonString(context: r'Conflict.field'),
      lostValue: _$map[r'lost_value'],
      lostChangeId: _$map[r'lost_change_id'].decodeJsonNullableString(
        context: r'Conflict.lost_change_id',
      ),
      wonRevision: _$map[r'won_revision'].decodeJsonInt(
        context: r'Conflict.won_revision',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Conflict.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Conflict.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Conflict.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Conflict.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Conflict.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Conflict.deleted_at',
      ),
    );
  }

  factory Conflict.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'entity',
        r'entity_id',
        r'field',
        r'lost_value',
        r'lost_change_id',
        r'won_revision',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Conflict',
    );
    return Conflict(
      id: _$values[r'id'].decodeFormString(context: r'Conflict.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Conflict.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'Conflict.customer_id',
      ),
      entity: _i4.ConflictEntityModel.fromForm(
        _$values[r'entity'],
        explode: explode,
      ),
      entityId: _$values[r'entity_id'].decodeFormString(
        context: r'Conflict.entity_id',
      ),
      field: _$values[r'field'].decodeFormString(context: r'Conflict.field'),
      lostValue: _$values[r'lost_value'].decodeFormNullableString(
        context: r'Conflict.lost_value',
      ),
      lostChangeId: _$values[r'lost_change_id'].decodeFormNullableString(
        context: r'Conflict.lost_change_id',
      ),
      wonRevision: _$values[r'won_revision'].decodeFormInt(
        context: r'Conflict.won_revision',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Conflict.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Conflict.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Conflict.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Conflict.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'Conflict.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Conflict.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i4.ConflictEntityModel entity;

  final _i3.String entityId;

  final _i3.String field;

  /// The value that lost: any JSON value, null included (D-95).
  final _i3.Object? lostValue;

  final _i3.String? lostChangeId;

  final _i3.int wonRevision;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'entity': this.entity.toJson(),
    r'entity_id': this.entityId,
    r'field': this.field,
    r'lost_value': _i1.encodeUnknownJson(
      this.lostValue,
      context: r'Conflict.lost_value',
    ),
    r'lost_change_id': this.lostChangeId,
    r'won_revision': this.wonRevision,
  };

  Conflict Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i4.ConflictEntityModel? entity,
    _i3.String? entityId,
    _i3.String? field,
    _i3.Object? lostValue,
    _i3.String? lostChangeId,
    _i3.int? wonRevision,
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
      _i4.ConflictEntityModel? entity,
      _i3.String? entityId,
      _i3.String? field,
      _i3.Object? lostValue = _sentinel,
      _i3.Object? lostChangeId = _sentinel,
      _i3.int? wonRevision,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Conflict(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      field: field ?? this.field,
      lostValue: _i3.identical(lostValue, _sentinel)
          ? this.lostValue
          : lostValue,
      lostChangeId: _i3.identical(lostChangeId, _sentinel)
          ? this.lostChangeId
          : (lostChangeId as _i3.String?),
      wonRevision: wonRevision ?? this.wonRevision,
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
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is Conflict &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.entity == this.entity &&
        other.entityId == this.entityId &&
        other.field == this.field &&
        _$deepEquals.equals(other.lostValue, this.lostValue) &&
        other.lostChangeId == this.lostChangeId &&
        other.wonRevision == this.wonRevision &&
        other.createdAt == this.createdAt &&
        other.createdBy == this.createdBy &&
        other.updatedAt == this.updatedAt &&
        other.updatedBy == this.updatedBy &&
        other.revision == this.revision &&
        other.deletedAt == this.deletedAt;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.workspaceId,
      this.customerId,
      this.entity,
      this.entityId,
      this.field,
      deepEquals.hash(this.lostValue),
      this.lostChangeId,
      this.wonRevision,
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
    _$result[r'entity'] = _i1.PropertyValue.scalar(this.entity.toJson());
    _$result[r'entity_id'] = _i1.PropertyValue.scalar(this.entityId);
    _$result[r'field'] = _i1.PropertyValue.scalar(this.field);
    if (this.lostValue != null) {
      _$result[r'lost_value'] = _i1.PropertyValue.scalar(
        _i1.encodeUnknownFlatScalar(
          this.lostValue!,
          context: r'Conflict.lost_value',
        ),
      );
    }
    if (this.lostChangeId != null) {
      _$result[r'lost_change_id'] = _i1.PropertyValue.scalar(
        this.lostChangeId!,
      );
    }
    _$result[r'won_revision'] = _i1.PropertyValue.scalar(
      this.wonRevision.toString(),
    );
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Conflict: complex types cannot be URI-encoded',
    );
  }
}
