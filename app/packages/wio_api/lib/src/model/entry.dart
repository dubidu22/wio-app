// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `entries` record as sync pulls it (D-95).
@_i2.immutable
class Entry extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Entry({
    required this.customerId,
    required this.code,
    required this.title,
    required this.siteId,
    required this.roomId,
    required this.fixtureId,
    required this.level,
    required this.compartment,
    required this.floorXCm,
    required this.floorYCm,
    required this.targetSiteId,
    required this.targetRoomId,
    required this.targetFixtureId,
    required this.targetLevel,
    required this.targetCompartment,
    required this.targetFloorXCm,
    required this.targetFloorYCm,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Entry.fromSimple(
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
        r'code',
        r'title',
        r'site_id',
        r'room_id',
        r'fixture_id',
        r'level',
        r'compartment',
        r'floor_x_cm',
        r'floor_y_cm',
        r'target_site_id',
        r'target_room_id',
        r'target_fixture_id',
        r'target_level',
        r'target_compartment',
        r'target_floor_x_cm',
        r'target_floor_y_cm',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Entry',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Entry(
      id: _$values[r'id'].decodeSimpleString(context: r'Entry.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Entry.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'Entry.customer_id',
      ),
      code: _$values[r'code'].decodeSimpleNullableString(
        context: r'Entry.code',
      ),
      title: _$values[r'title'].decodeSimpleNullableString(
        context: r'Entry.title',
      ),
      siteId: _$values[r'site_id'].decodeSimpleNullableString(
        context: r'Entry.site_id',
      ),
      roomId: _$values[r'room_id'].decodeSimpleNullableString(
        context: r'Entry.room_id',
      ),
      fixtureId: _$values[r'fixture_id'].decodeSimpleNullableString(
        context: r'Entry.fixture_id',
      ),
      level: _$values[r'level'].decodeSimpleNullableInt(
        context: r'Entry.level',
      ),
      compartment: _$values[r'compartment'].decodeSimpleNullableInt(
        context: r'Entry.compartment',
      ),
      floorXCm: _$values[r'floor_x_cm'].decodeSimpleNullableInt(
        context: r'Entry.floor_x_cm',
      ),
      floorYCm: _$values[r'floor_y_cm'].decodeSimpleNullableInt(
        context: r'Entry.floor_y_cm',
      ),
      targetSiteId: _$values[r'target_site_id'].decodeSimpleNullableString(
        context: r'Entry.target_site_id',
      ),
      targetRoomId: _$values[r'target_room_id'].decodeSimpleNullableString(
        context: r'Entry.target_room_id',
      ),
      targetFixtureId: _$values[r'target_fixture_id']
          .decodeSimpleNullableString(context: r'Entry.target_fixture_id'),
      targetLevel: _$values[r'target_level'].decodeSimpleNullableInt(
        context: r'Entry.target_level',
      ),
      targetCompartment: _$values[r'target_compartment']
          .decodeSimpleNullableInt(context: r'Entry.target_compartment'),
      targetFloorXCm: _$values[r'target_floor_x_cm'].decodeSimpleNullableInt(
        context: r'Entry.target_floor_x_cm',
      ),
      targetFloorYCm: _$values[r'target_floor_y_cm'].decodeSimpleNullableInt(
        context: r'Entry.target_floor_y_cm',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Entry.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Entry.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Entry.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Entry.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Entry.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Entry.deleted_at',
      ),
    );
  }

  factory Entry.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Entry');
    return Entry(
      id: _$map[r'id'].decodeJsonString(context: r'Entry.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Entry.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Entry.customer_id',
      ),
      code: _$map[r'code'].decodeJsonNullableString(context: r'Entry.code'),
      title: _$map[r'title'].decodeJsonNullableString(context: r'Entry.title'),
      siteId: _$map[r'site_id'].decodeJsonNullableString(
        context: r'Entry.site_id',
      ),
      roomId: _$map[r'room_id'].decodeJsonNullableString(
        context: r'Entry.room_id',
      ),
      fixtureId: _$map[r'fixture_id'].decodeJsonNullableString(
        context: r'Entry.fixture_id',
      ),
      level: _$map[r'level'].decodeJsonNullableInt(context: r'Entry.level'),
      compartment: _$map[r'compartment'].decodeJsonNullableInt(
        context: r'Entry.compartment',
      ),
      floorXCm: _$map[r'floor_x_cm'].decodeJsonNullableInt(
        context: r'Entry.floor_x_cm',
      ),
      floorYCm: _$map[r'floor_y_cm'].decodeJsonNullableInt(
        context: r'Entry.floor_y_cm',
      ),
      targetSiteId: _$map[r'target_site_id'].decodeJsonNullableString(
        context: r'Entry.target_site_id',
      ),
      targetRoomId: _$map[r'target_room_id'].decodeJsonNullableString(
        context: r'Entry.target_room_id',
      ),
      targetFixtureId: _$map[r'target_fixture_id'].decodeJsonNullableString(
        context: r'Entry.target_fixture_id',
      ),
      targetLevel: _$map[r'target_level'].decodeJsonNullableInt(
        context: r'Entry.target_level',
      ),
      targetCompartment: _$map[r'target_compartment'].decodeJsonNullableInt(
        context: r'Entry.target_compartment',
      ),
      targetFloorXCm: _$map[r'target_floor_x_cm'].decodeJsonNullableInt(
        context: r'Entry.target_floor_x_cm',
      ),
      targetFloorYCm: _$map[r'target_floor_y_cm'].decodeJsonNullableInt(
        context: r'Entry.target_floor_y_cm',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Entry.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Entry.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Entry.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Entry.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Entry.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Entry.deleted_at',
      ),
    );
  }

  factory Entry.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'code',
        r'title',
        r'site_id',
        r'room_id',
        r'fixture_id',
        r'level',
        r'compartment',
        r'floor_x_cm',
        r'floor_y_cm',
        r'target_site_id',
        r'target_room_id',
        r'target_fixture_id',
        r'target_level',
        r'target_compartment',
        r'target_floor_x_cm',
        r'target_floor_y_cm',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Entry',
    );
    return Entry(
      id: _$values[r'id'].decodeFormString(context: r'Entry.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Entry.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'Entry.customer_id',
      ),
      code: _$values[r'code'].decodeFormNullableString(context: r'Entry.code'),
      title: _$values[r'title'].decodeFormNullableString(
        context: r'Entry.title',
      ),
      siteId: _$values[r'site_id'].decodeFormNullableString(
        context: r'Entry.site_id',
      ),
      roomId: _$values[r'room_id'].decodeFormNullableString(
        context: r'Entry.room_id',
      ),
      fixtureId: _$values[r'fixture_id'].decodeFormNullableString(
        context: r'Entry.fixture_id',
      ),
      level: _$values[r'level'].decodeFormNullableInt(context: r'Entry.level'),
      compartment: _$values[r'compartment'].decodeFormNullableInt(
        context: r'Entry.compartment',
      ),
      floorXCm: _$values[r'floor_x_cm'].decodeFormNullableInt(
        context: r'Entry.floor_x_cm',
      ),
      floorYCm: _$values[r'floor_y_cm'].decodeFormNullableInt(
        context: r'Entry.floor_y_cm',
      ),
      targetSiteId: _$values[r'target_site_id'].decodeFormNullableString(
        context: r'Entry.target_site_id',
      ),
      targetRoomId: _$values[r'target_room_id'].decodeFormNullableString(
        context: r'Entry.target_room_id',
      ),
      targetFixtureId: _$values[r'target_fixture_id'].decodeFormNullableString(
        context: r'Entry.target_fixture_id',
      ),
      targetLevel: _$values[r'target_level'].decodeFormNullableInt(
        context: r'Entry.target_level',
      ),
      targetCompartment: _$values[r'target_compartment'].decodeFormNullableInt(
        context: r'Entry.target_compartment',
      ),
      targetFloorXCm: _$values[r'target_floor_x_cm'].decodeFormNullableInt(
        context: r'Entry.target_floor_x_cm',
      ),
      targetFloorYCm: _$values[r'target_floor_y_cm'].decodeFormNullableInt(
        context: r'Entry.target_floor_y_cm',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Entry.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Entry.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Entry.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Entry.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(context: r'Entry.revision'),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Entry.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i3.String? code;

  final _i3.String? title;

  final _i3.String? siteId;

  final _i3.String? roomId;

  final _i3.String? fixtureId;

  final _i3.int? level;

  final _i3.int? compartment;

  final _i3.int? floorXCm;

  final _i3.int? floorYCm;

  final _i3.String? targetSiteId;

  final _i3.String? targetRoomId;

  final _i3.String? targetFixtureId;

  final _i3.int? targetLevel;

  final _i3.int? targetCompartment;

  final _i3.int? targetFloorXCm;

  final _i3.int? targetFloorYCm;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'code': this.code,
    r'title': this.title,
    r'site_id': this.siteId,
    r'room_id': this.roomId,
    r'fixture_id': this.fixtureId,
    r'level': this.level,
    r'compartment': this.compartment,
    r'floor_x_cm': this.floorXCm,
    r'floor_y_cm': this.floorYCm,
    r'target_site_id': this.targetSiteId,
    r'target_room_id': this.targetRoomId,
    r'target_fixture_id': this.targetFixtureId,
    r'target_level': this.targetLevel,
    r'target_compartment': this.targetCompartment,
    r'target_floor_x_cm': this.targetFloorXCm,
    r'target_floor_y_cm': this.targetFloorYCm,
  };

  Entry Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? code,
    _i3.String? title,
    _i3.String? siteId,
    _i3.String? roomId,
    _i3.String? fixtureId,
    _i3.int? level,
    _i3.int? compartment,
    _i3.int? floorXCm,
    _i3.int? floorYCm,
    _i3.String? targetSiteId,
    _i3.String? targetRoomId,
    _i3.String? targetFixtureId,
    _i3.int? targetLevel,
    _i3.int? targetCompartment,
    _i3.int? targetFloorXCm,
    _i3.int? targetFloorYCm,
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
      _i3.Object? code = _sentinel,
      _i3.Object? title = _sentinel,
      _i3.Object? siteId = _sentinel,
      _i3.Object? roomId = _sentinel,
      _i3.Object? fixtureId = _sentinel,
      _i3.Object? level = _sentinel,
      _i3.Object? compartment = _sentinel,
      _i3.Object? floorXCm = _sentinel,
      _i3.Object? floorYCm = _sentinel,
      _i3.Object? targetSiteId = _sentinel,
      _i3.Object? targetRoomId = _sentinel,
      _i3.Object? targetFixtureId = _sentinel,
      _i3.Object? targetLevel = _sentinel,
      _i3.Object? targetCompartment = _sentinel,
      _i3.Object? targetFloorXCm = _sentinel,
      _i3.Object? targetFloorYCm = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Entry(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      code: _i3.identical(code, _sentinel) ? this.code : (code as _i3.String?),
      title: _i3.identical(title, _sentinel)
          ? this.title
          : (title as _i3.String?),
      siteId: _i3.identical(siteId, _sentinel)
          ? this.siteId
          : (siteId as _i3.String?),
      roomId: _i3.identical(roomId, _sentinel)
          ? this.roomId
          : (roomId as _i3.String?),
      fixtureId: _i3.identical(fixtureId, _sentinel)
          ? this.fixtureId
          : (fixtureId as _i3.String?),
      level: _i3.identical(level, _sentinel) ? this.level : (level as _i3.int?),
      compartment: _i3.identical(compartment, _sentinel)
          ? this.compartment
          : (compartment as _i3.int?),
      floorXCm: _i3.identical(floorXCm, _sentinel)
          ? this.floorXCm
          : (floorXCm as _i3.int?),
      floorYCm: _i3.identical(floorYCm, _sentinel)
          ? this.floorYCm
          : (floorYCm as _i3.int?),
      targetSiteId: _i3.identical(targetSiteId, _sentinel)
          ? this.targetSiteId
          : (targetSiteId as _i3.String?),
      targetRoomId: _i3.identical(targetRoomId, _sentinel)
          ? this.targetRoomId
          : (targetRoomId as _i3.String?),
      targetFixtureId: _i3.identical(targetFixtureId, _sentinel)
          ? this.targetFixtureId
          : (targetFixtureId as _i3.String?),
      targetLevel: _i3.identical(targetLevel, _sentinel)
          ? this.targetLevel
          : (targetLevel as _i3.int?),
      targetCompartment: _i3.identical(targetCompartment, _sentinel)
          ? this.targetCompartment
          : (targetCompartment as _i3.int?),
      targetFloorXCm: _i3.identical(targetFloorXCm, _sentinel)
          ? this.targetFloorXCm
          : (targetFloorXCm as _i3.int?),
      targetFloorYCm: _i3.identical(targetFloorYCm, _sentinel)
          ? this.targetFloorYCm
          : (targetFloorYCm as _i3.int?),
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
    return other is Entry &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.code == this.code &&
        other.title == this.title &&
        other.siteId == this.siteId &&
        other.roomId == this.roomId &&
        other.fixtureId == this.fixtureId &&
        other.level == this.level &&
        other.compartment == this.compartment &&
        other.floorXCm == this.floorXCm &&
        other.floorYCm == this.floorYCm &&
        other.targetSiteId == this.targetSiteId &&
        other.targetRoomId == this.targetRoomId &&
        other.targetFixtureId == this.targetFixtureId &&
        other.targetLevel == this.targetLevel &&
        other.targetCompartment == this.targetCompartment &&
        other.targetFloorXCm == this.targetFloorXCm &&
        other.targetFloorYCm == this.targetFloorYCm &&
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
      this.code,
      this.title,
      this.siteId,
      this.roomId,
      this.fixtureId,
      this.level,
      this.compartment,
      this.floorXCm,
      this.floorYCm,
      this.targetSiteId,
      this.targetRoomId,
      this.targetFixtureId,
      this.targetLevel,
      this.targetCompartment,
      this.targetFloorXCm,
      this.targetFloorYCm,
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
    if (this.code != null) {
      _$result[r'code'] = _i1.PropertyValue.scalar(this.code!);
    }
    if (this.title != null) {
      _$result[r'title'] = _i1.PropertyValue.scalar(this.title!);
    }
    if (this.siteId != null) {
      _$result[r'site_id'] = _i1.PropertyValue.scalar(this.siteId!);
    }
    if (this.roomId != null) {
      _$result[r'room_id'] = _i1.PropertyValue.scalar(this.roomId!);
    }
    if (this.fixtureId != null) {
      _$result[r'fixture_id'] = _i1.PropertyValue.scalar(this.fixtureId!);
    }
    if (this.level != null) {
      _$result[r'level'] = _i1.PropertyValue.scalar(this.level!.toString());
    }
    if (this.compartment != null) {
      _$result[r'compartment'] = _i1.PropertyValue.scalar(
        this.compartment!.toString(),
      );
    }
    if (this.floorXCm != null) {
      _$result[r'floor_x_cm'] = _i1.PropertyValue.scalar(
        this.floorXCm!.toString(),
      );
    }
    if (this.floorYCm != null) {
      _$result[r'floor_y_cm'] = _i1.PropertyValue.scalar(
        this.floorYCm!.toString(),
      );
    }
    if (this.targetSiteId != null) {
      _$result[r'target_site_id'] = _i1.PropertyValue.scalar(
        this.targetSiteId!,
      );
    }
    if (this.targetRoomId != null) {
      _$result[r'target_room_id'] = _i1.PropertyValue.scalar(
        this.targetRoomId!,
      );
    }
    if (this.targetFixtureId != null) {
      _$result[r'target_fixture_id'] = _i1.PropertyValue.scalar(
        this.targetFixtureId!,
      );
    }
    if (this.targetLevel != null) {
      _$result[r'target_level'] = _i1.PropertyValue.scalar(
        this.targetLevel!.toString(),
      );
    }
    if (this.targetCompartment != null) {
      _$result[r'target_compartment'] = _i1.PropertyValue.scalar(
        this.targetCompartment!.toString(),
      );
    }
    if (this.targetFloorXCm != null) {
      _$result[r'target_floor_x_cm'] = _i1.PropertyValue.scalar(
        this.targetFloorXCm!.toString(),
      );
    }
    if (this.targetFloorYCm != null) {
      _$result[r'target_floor_y_cm'] = _i1.PropertyValue.scalar(
        this.targetFloorYCm!.toString(),
      );
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
      r'Cannot uriEncode Entry: complex types cannot be URI-encoded',
    );
  }
}
