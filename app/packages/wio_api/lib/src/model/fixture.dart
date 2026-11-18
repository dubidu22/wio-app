// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/fixture_levels_all_of_model.dart' as _i4;

/// A `fixtures` record as sync pulls it (D-95).
@_i2.immutable
class Fixture extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Fixture({
    required this.customerId,
    required this.roomId,
    required this.name,
    required this.xCm,
    required this.yCm,
    required this.rotationDeg,
    required this.widthCm,
    required this.depthCm,
    required this.heightCm,
    required this.levels,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Fixture.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Fixture: contains complex types',
    );
  }

  factory Fixture.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Fixture');
    return Fixture(
      id: _$map[r'id'].decodeJsonString(context: r'Fixture.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Fixture.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Fixture.customer_id',
      ),
      roomId: _$map[r'room_id'].decodeJsonString(context: r'Fixture.room_id'),
      name: _$map[r'name'].decodeJsonNullableString(context: r'Fixture.name'),
      xCm: _$map[r'x_cm'].decodeJsonInt(context: r'Fixture.x_cm'),
      yCm: _$map[r'y_cm'].decodeJsonInt(context: r'Fixture.y_cm'),
      rotationDeg: _$map[r'rotation_deg'].decodeJsonInt(
        context: r'Fixture.rotation_deg',
      ),
      widthCm: _$map[r'width_cm'].decodeJsonNullableInt(
        context: r'Fixture.width_cm',
      ),
      depthCm: _$map[r'depth_cm'].decodeJsonNullableInt(
        context: r'Fixture.depth_cm',
      ),
      heightCm: _$map[r'height_cm'].decodeJsonNullableInt(
        context: r'Fixture.height_cm',
      ),
      levels: _$map[r'levels'] == null
          ? null
          : _i4.FixtureLevelsAllOfModel.fromJson(_$map[r'levels']),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Fixture.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Fixture.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Fixture.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Fixture.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Fixture.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Fixture.deleted_at',
      ),
    );
  }

  factory Fixture.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Fixture: contains complex types',
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i3.String roomId;

  final _i3.String? name;

  final _i3.int xCm;

  final _i3.int yCm;

  final _i3.int rotationDeg;

  final _i3.int? widthCm;

  final _i3.int? depthCm;

  final _i3.int? heightCm;

  final _i4.FixtureLevelsAllOfModel? levels;

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
    r'name': this.name,
    r'x_cm': this.xCm,
    r'y_cm': this.yCm,
    r'rotation_deg': this.rotationDeg,
    r'width_cm': this.widthCm,
    r'depth_cm': this.depthCm,
    r'height_cm': this.heightCm,
    r'levels': this.levels?.toJson(),
  };

  Fixture Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? roomId,
    _i3.String? name,
    _i3.int? xCm,
    _i3.int? yCm,
    _i3.int? rotationDeg,
    _i3.int? widthCm,
    _i3.int? depthCm,
    _i3.int? heightCm,
    _i4.FixtureLevelsAllOfModel? levels,
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
      _i3.Object? name = _sentinel,
      _i3.int? xCm,
      _i3.int? yCm,
      _i3.int? rotationDeg,
      _i3.Object? widthCm = _sentinel,
      _i3.Object? depthCm = _sentinel,
      _i3.Object? heightCm = _sentinel,
      _i3.Object? levels = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Fixture(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      roomId: roomId ?? this.roomId,
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
      xCm: xCm ?? this.xCm,
      yCm: yCm ?? this.yCm,
      rotationDeg: rotationDeg ?? this.rotationDeg,
      widthCm: _i3.identical(widthCm, _sentinel)
          ? this.widthCm
          : (widthCm as _i3.int?),
      depthCm: _i3.identical(depthCm, _sentinel)
          ? this.depthCm
          : (depthCm as _i3.int?),
      heightCm: _i3.identical(heightCm, _sentinel)
          ? this.heightCm
          : (heightCm as _i3.int?),
      levels: _i3.identical(levels, _sentinel)
          ? this.levels
          : (levels as _i4.FixtureLevelsAllOfModel?),
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
    return other is Fixture &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.roomId == this.roomId &&
        other.name == this.name &&
        other.xCm == this.xCm &&
        other.yCm == this.yCm &&
        other.rotationDeg == this.rotationDeg &&
        other.widthCm == this.widthCm &&
        other.depthCm == this.depthCm &&
        other.heightCm == this.heightCm &&
        other.levels == this.levels &&
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
      this.name,
      this.xCm,
      this.yCm,
      this.rotationDeg,
      this.widthCm,
      this.depthCm,
      this.heightCm,
      this.levels,
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
    if (this.name != null) {
      _$result[r'name'] = _i1.PropertyValue.scalar(this.name!);
    }
    _$result[r'x_cm'] = _i1.PropertyValue.scalar(this.xCm.toString());
    _$result[r'y_cm'] = _i1.PropertyValue.scalar(this.yCm.toString());
    _$result[r'rotation_deg'] = _i1.PropertyValue.scalar(
      this.rotationDeg.toString(),
    );
    if (this.widthCm != null) {
      _$result[r'width_cm'] = _i1.PropertyValue.scalar(
        this.widthCm!.toString(),
      );
    }
    if (this.depthCm != null) {
      _$result[r'depth_cm'] = _i1.PropertyValue.scalar(
        this.depthCm!.toString(),
      );
    }
    if (this.heightCm != null) {
      _$result[r'height_cm'] = _i1.PropertyValue.scalar(
        this.heightCm!.toString(),
      );
    }
    if (this.levels != null) {
      _$result[r'levels'] = _i1.encodeAnyValueToPropertyValue(
        this.levels!.toJson(),
        allowEmpty: allowEmpty,
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
      r'Cannot uriEncode Fixture: complex types cannot be URI-encoded',
    );
  }
}
