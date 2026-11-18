// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/room_outline_all_of_model.dart' as _i4;

/// A `rooms` record as sync pulls it (D-95).
@_i2.immutable
class Room extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Room({
    required this.customerId,
    required this.siteId,
    required this.name,
    required this.outline,
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

  factory Room.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Room: contains complex types',
    );
  }

  factory Room.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Room');
    return Room(
      id: _$map[r'id'].decodeJsonString(context: r'Room.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Room.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Room.customer_id',
      ),
      siteId: _$map[r'site_id'].decodeJsonString(context: r'Room.site_id'),
      name: _$map[r'name'].decodeJsonNullableString(context: r'Room.name'),
      outline: _$map[r'outline'] == null
          ? null
          : _i4.RoomOutlineAllOfModel.fromJson(_$map[r'outline']),
      heightCm: _$map[r'height_cm'].decodeJsonNullableInt(
        context: r'Room.height_cm',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Room.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Room.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Room.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Room.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Room.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Room.deleted_at',
      ),
    );
  }

  factory Room.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Room: contains complex types',
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i3.String siteId;

  final _i3.String? name;

  final _i4.RoomOutlineAllOfModel? outline;

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
    r'site_id': this.siteId,
    r'name': this.name,
    r'outline': this.outline?.toJson(),
    r'height_cm': this.heightCm,
  };

  Room Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? siteId,
    _i3.String? name,
    _i4.RoomOutlineAllOfModel? outline,
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
      _i3.String? siteId,
      _i3.Object? name = _sentinel,
      _i3.Object? outline = _sentinel,
      _i3.Object? heightCm = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Room(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      siteId: siteId ?? this.siteId,
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
      outline: _i3.identical(outline, _sentinel)
          ? this.outline
          : (outline as _i4.RoomOutlineAllOfModel?),
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
    return other is Room &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.siteId == this.siteId &&
        other.name == this.name &&
        other.outline == this.outline &&
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
      this.siteId,
      this.name,
      this.outline,
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
    _$result[r'site_id'] = _i1.PropertyValue.scalar(this.siteId);
    if (this.name != null) {
      _$result[r'name'] = _i1.PropertyValue.scalar(this.name!);
    }
    if (this.outline != null) {
      _$result[r'outline'] = _i1.encodeAnyValueToPropertyValue(
        this.outline!.toJson(),
        allowEmpty: allowEmpty,
      );
    }
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
      r'Cannot uriEncode Room: complex types cannot be URI-encoded',
    );
  }
}
