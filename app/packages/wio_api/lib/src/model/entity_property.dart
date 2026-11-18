// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/entity_property_entity_type_model.dart'
    as _i4;

/// A `entity_properties` record as sync pulls it (D-95).
@_i2.immutable
class EntityProperty extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const EntityProperty({
    required this.customerId,
    required this.entityType,
    required this.entityId,
    required this.keyId,
    required this.valueText,
    required this.valueNumber,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory EntityProperty.fromSimple(
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
        r'entity_type',
        r'entity_id',
        r'key_id',
        r'value_text',
        r'value_number',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'EntityProperty',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return EntityProperty(
      id: _$values[r'id'].decodeSimpleString(context: r'EntityProperty.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'EntityProperty.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'EntityProperty.customer_id',
      ),
      entityType: _i4.EntityPropertyEntityTypeModel.fromSimple(
        _$values[r'entity_type'],
        explode: explode,
      ),
      entityId: _$values[r'entity_id'].decodeSimpleString(
        context: r'EntityProperty.entity_id',
      ),
      keyId: _$values[r'key_id'].decodeSimpleString(
        context: r'EntityProperty.key_id',
      ),
      valueText: _$values[r'value_text'].decodeSimpleNullableString(
        context: r'EntityProperty.value_text',
      ),
      valueNumber: _$values[r'value_number'].decodeSimpleNullableString(
        context: r'EntityProperty.value_number',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'EntityProperty.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'EntityProperty.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'EntityProperty.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'EntityProperty.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'EntityProperty.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'EntityProperty.deleted_at',
      ),
    );
  }

  factory EntityProperty.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'EntityProperty');
    return EntityProperty(
      id: _$map[r'id'].decodeJsonString(context: r'EntityProperty.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'EntityProperty.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'EntityProperty.customer_id',
      ),
      entityType: _i4.EntityPropertyEntityTypeModel.fromJson(
        _$map[r'entity_type'],
      ),
      entityId: _$map[r'entity_id'].decodeJsonString(
        context: r'EntityProperty.entity_id',
      ),
      keyId: _$map[r'key_id'].decodeJsonString(
        context: r'EntityProperty.key_id',
      ),
      valueText: _$map[r'value_text'].decodeJsonNullableString(
        context: r'EntityProperty.value_text',
      ),
      valueNumber: _$map[r'value_number'].decodeJsonNullableString(
        context: r'EntityProperty.value_number',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'EntityProperty.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'EntityProperty.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'EntityProperty.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'EntityProperty.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(
        context: r'EntityProperty.revision',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'EntityProperty.deleted_at',
      ),
    );
  }

  factory EntityProperty.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'entity_type',
        r'entity_id',
        r'key_id',
        r'value_text',
        r'value_number',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'EntityProperty',
    );
    return EntityProperty(
      id: _$values[r'id'].decodeFormString(context: r'EntityProperty.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'EntityProperty.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'EntityProperty.customer_id',
      ),
      entityType: _i4.EntityPropertyEntityTypeModel.fromForm(
        _$values[r'entity_type'],
        explode: explode,
      ),
      entityId: _$values[r'entity_id'].decodeFormString(
        context: r'EntityProperty.entity_id',
      ),
      keyId: _$values[r'key_id'].decodeFormString(
        context: r'EntityProperty.key_id',
      ),
      valueText: _$values[r'value_text'].decodeFormNullableString(
        context: r'EntityProperty.value_text',
      ),
      valueNumber: _$values[r'value_number'].decodeFormNullableString(
        context: r'EntityProperty.value_number',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'EntityProperty.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'EntityProperty.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'EntityProperty.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'EntityProperty.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'EntityProperty.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'EntityProperty.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i4.EntityPropertyEntityTypeModel entityType;

  final _i3.String entityId;

  final _i3.String keyId;

  final _i3.String? valueText;

  /// Decimal as text, so no float rounding (D-95).
  final _i3.String? valueNumber;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'entity_type': this.entityType.toJson(),
    r'entity_id': this.entityId,
    r'key_id': this.keyId,
    r'value_text': this.valueText,
    r'value_number': this.valueNumber,
  };

  EntityProperty Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i4.EntityPropertyEntityTypeModel? entityType,
    _i3.String? entityId,
    _i3.String? keyId,
    _i3.String? valueText,
    _i3.String? valueNumber,
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
      _i4.EntityPropertyEntityTypeModel? entityType,
      _i3.String? entityId,
      _i3.String? keyId,
      _i3.Object? valueText = _sentinel,
      _i3.Object? valueNumber = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => EntityProperty(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      keyId: keyId ?? this.keyId,
      valueText: _i3.identical(valueText, _sentinel)
          ? this.valueText
          : (valueText as _i3.String?),
      valueNumber: _i3.identical(valueNumber, _sentinel)
          ? this.valueNumber
          : (valueNumber as _i3.String?),
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
    return other is EntityProperty &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.entityType == this.entityType &&
        other.entityId == this.entityId &&
        other.keyId == this.keyId &&
        other.valueText == this.valueText &&
        other.valueNumber == this.valueNumber &&
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
      this.entityType,
      this.entityId,
      this.keyId,
      this.valueText,
      this.valueNumber,
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
    _$result[r'entity_type'] = _i1.PropertyValue.scalar(
      this.entityType.toJson(),
    );
    _$result[r'entity_id'] = _i1.PropertyValue.scalar(this.entityId);
    _$result[r'key_id'] = _i1.PropertyValue.scalar(this.keyId);
    if (this.valueText != null) {
      _$result[r'value_text'] = _i1.PropertyValue.scalar(this.valueText!);
    }
    if (this.valueNumber != null) {
      _$result[r'value_number'] = _i1.PropertyValue.scalar(this.valueNumber!);
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
      r'Cannot uriEncode EntityProperty: complex types cannot be URI-encoded',
    );
  }
}
