// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/opening_kind_model.dart' as _i4;

/// A `openings` record as sync pulls it (D-95).
@_i2.immutable
class Opening extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Opening({
    required this.customerId,
    required this.roomId,
    required this.kind,
    required this.wallIndex,
    required this.offsetCm,
    required this.widthCm,
    required this.heightCm,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Opening.fromSimple(
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
        r'room_id',
        r'kind',
        r'wall_index',
        r'offset_cm',
        r'width_cm',
        r'height_cm',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Opening',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Opening(
      id: _$values[r'id'].decodeSimpleString(context: r'Opening.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Opening.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'Opening.customer_id',
      ),
      roomId: _$values[r'room_id'].decodeSimpleString(
        context: r'Opening.room_id',
      ),
      kind: _i4.OpeningKindModel.fromSimple(
        _$values[r'kind'],
        explode: explode,
      ),
      wallIndex: _$values[r'wall_index'].decodeSimpleInt(
        context: r'Opening.wall_index',
      ),
      offsetCm: _$values[r'offset_cm'].decodeSimpleInt(
        context: r'Opening.offset_cm',
      ),
      widthCm: _$values[r'width_cm'].decodeSimpleInt(
        context: r'Opening.width_cm',
      ),
      heightCm: _$values[r'height_cm'].decodeSimpleNullableInt(
        context: r'Opening.height_cm',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Opening.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Opening.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Opening.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Opening.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Opening.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Opening.deleted_at',
      ),
    );
  }

  factory Opening.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Opening');
    return Opening(
      id: _$map[r'id'].decodeJsonString(context: r'Opening.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Opening.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Opening.customer_id',
      ),
      roomId: _$map[r'room_id'].decodeJsonString(context: r'Opening.room_id'),
      kind: _i4.OpeningKindModel.fromJson(_$map[r'kind']),
      wallIndex: _$map[r'wall_index'].decodeJsonInt(
        context: r'Opening.wall_index',
      ),
      offsetCm: _$map[r'offset_cm'].decodeJsonInt(
        context: r'Opening.offset_cm',
      ),
      widthCm: _$map[r'width_cm'].decodeJsonInt(context: r'Opening.width_cm'),
      heightCm: _$map[r'height_cm'].decodeJsonNullableInt(
        context: r'Opening.height_cm',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Opening.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Opening.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Opening.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Opening.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Opening.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Opening.deleted_at',
      ),
    );
  }

  factory Opening.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'room_id',
        r'kind',
        r'wall_index',
        r'offset_cm',
        r'width_cm',
        r'height_cm',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Opening',
    );
    return Opening(
      id: _$values[r'id'].decodeFormString(context: r'Opening.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Opening.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'Opening.customer_id',
      ),
      roomId: _$values[r'room_id'].decodeFormString(
        context: r'Opening.room_id',
      ),
      kind: _i4.OpeningKindModel.fromForm(_$values[r'kind'], explode: explode),
      wallIndex: _$values[r'wall_index'].decodeFormInt(
        context: r'Opening.wall_index',
      ),
      offsetCm: _$values[r'offset_cm'].decodeFormInt(
        context: r'Opening.offset_cm',
      ),
      widthCm: _$values[r'width_cm'].decodeFormInt(
        context: r'Opening.width_cm',
      ),
      heightCm: _$values[r'height_cm'].decodeFormNullableInt(
        context: r'Opening.height_cm',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Opening.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Opening.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Opening.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Opening.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'Opening.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Opening.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i3.String roomId;

  final _i4.OpeningKindModel kind;

  final _i3.int wallIndex;

  final _i3.int offsetCm;

  final _i3.int widthCm;

  final _i3.int? heightCm;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'room_id': this.roomId,
    r'kind': this.kind.toJson(),
    r'wall_index': this.wallIndex,
    r'offset_cm': this.offsetCm,
    r'width_cm': this.widthCm,
    r'height_cm': this.heightCm,
  };

  Opening Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? roomId,
    _i4.OpeningKindModel? kind,
    _i3.int? wallIndex,
    _i3.int? offsetCm,
    _i3.int? widthCm,
    _i3.int? heightCm,
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
      _i3.String? roomId,
      _i4.OpeningKindModel? kind,
      _i3.int? wallIndex,
      _i3.int? offsetCm,
      _i3.int? widthCm,
      _i3.Object? heightCm = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Opening(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      roomId: roomId ?? this.roomId,
      kind: kind ?? this.kind,
      wallIndex: wallIndex ?? this.wallIndex,
      offsetCm: offsetCm ?? this.offsetCm,
      widthCm: widthCm ?? this.widthCm,
      heightCm: _i3.identical(heightCm, _sentinel)
          ? this.heightCm
          : (heightCm as _i3.int?),
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
    return other is Opening &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.roomId == this.roomId &&
        other.kind == this.kind &&
        other.wallIndex == this.wallIndex &&
        other.offsetCm == this.offsetCm &&
        other.widthCm == this.widthCm &&
        other.heightCm == this.heightCm &&
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
      this.roomId,
      this.kind,
      this.wallIndex,
      this.offsetCm,
      this.widthCm,
      this.heightCm,
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
    _$result[r'room_id'] = _i1.PropertyValue.scalar(this.roomId);
    _$result[r'kind'] = _i1.PropertyValue.scalar(this.kind.toJson());
    _$result[r'wall_index'] = _i1.PropertyValue.scalar(
      this.wallIndex.toString(),
    );
    _$result[r'offset_cm'] = _i1.PropertyValue.scalar(this.offsetCm.toString());
    _$result[r'width_cm'] = _i1.PropertyValue.scalar(this.widthCm.toString());
    if (this.heightCm != null) {
      _$result[r'height_cm'] = _i1.PropertyValue.scalar(
        this.heightCm!.toString(),
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
      r'Cannot uriEncode Opening: complex types cannot be URI-encoded',
    );
  }
}
