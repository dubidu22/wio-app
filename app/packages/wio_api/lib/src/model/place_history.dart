// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `place_history` record as sync pulls it (D-95).
@_i2.immutable
class PlaceHistory extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PlaceHistory({
    required this.customerId,
    required this.entryId,
    required this.fromSiteId,
    required this.fromRoomId,
    required this.fromFixtureId,
    required this.fromLevel,
    required this.fromCompartment,
    required this.fromFloorXCm,
    required this.fromFloorYCm,
    required this.toSiteId,
    required this.toRoomId,
    required this.toFixtureId,
    required this.toLevel,
    required this.toCompartment,
    required this.toFloorXCm,
    required this.toFloorYCm,
    required this.movedAt,
    required this.movedBy,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory PlaceHistory.fromSimple(
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
        r'entry_id',
        r'from_site_id',
        r'from_room_id',
        r'from_fixture_id',
        r'from_level',
        r'from_compartment',
        r'from_floor_x_cm',
        r'from_floor_y_cm',
        r'to_site_id',
        r'to_room_id',
        r'to_fixture_id',
        r'to_level',
        r'to_compartment',
        r'to_floor_x_cm',
        r'to_floor_y_cm',
        r'moved_at',
        r'moved_by',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'PlaceHistory',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return PlaceHistory(
      id: _$values[r'id'].decodeSimpleString(context: r'PlaceHistory.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'PlaceHistory.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.customer_id',
      ),
      entryId: _$values[r'entry_id'].decodeSimpleString(
        context: r'PlaceHistory.entry_id',
      ),
      fromSiteId: _$values[r'from_site_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.from_site_id',
      ),
      fromRoomId: _$values[r'from_room_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.from_room_id',
      ),
      fromFixtureId: _$values[r'from_fixture_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.from_fixture_id',
      ),
      fromLevel: _$values[r'from_level'].decodeSimpleNullableInt(
        context: r'PlaceHistory.from_level',
      ),
      fromCompartment: _$values[r'from_compartment'].decodeSimpleNullableInt(
        context: r'PlaceHistory.from_compartment',
      ),
      fromFloorXCm: _$values[r'from_floor_x_cm'].decodeSimpleNullableInt(
        context: r'PlaceHistory.from_floor_x_cm',
      ),
      fromFloorYCm: _$values[r'from_floor_y_cm'].decodeSimpleNullableInt(
        context: r'PlaceHistory.from_floor_y_cm',
      ),
      toSiteId: _$values[r'to_site_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.to_site_id',
      ),
      toRoomId: _$values[r'to_room_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.to_room_id',
      ),
      toFixtureId: _$values[r'to_fixture_id'].decodeSimpleNullableString(
        context: r'PlaceHistory.to_fixture_id',
      ),
      toLevel: _$values[r'to_level'].decodeSimpleNullableInt(
        context: r'PlaceHistory.to_level',
      ),
      toCompartment: _$values[r'to_compartment'].decodeSimpleNullableInt(
        context: r'PlaceHistory.to_compartment',
      ),
      toFloorXCm: _$values[r'to_floor_x_cm'].decodeSimpleNullableInt(
        context: r'PlaceHistory.to_floor_x_cm',
      ),
      toFloorYCm: _$values[r'to_floor_y_cm'].decodeSimpleNullableInt(
        context: r'PlaceHistory.to_floor_y_cm',
      ),
      movedAt: _$values[r'moved_at'].decodeSimpleDateTime(
        context: r'PlaceHistory.moved_at',
      ),
      movedBy: _$values[r'moved_by'].decodeSimpleNullableString(
        context: r'PlaceHistory.moved_by',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'PlaceHistory.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'PlaceHistory.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'PlaceHistory.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'PlaceHistory.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'PlaceHistory.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'PlaceHistory.deleted_at',
      ),
    );
  }

  factory PlaceHistory.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PlaceHistory');
    return PlaceHistory(
      id: _$map[r'id'].decodeJsonString(context: r'PlaceHistory.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'PlaceHistory.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'PlaceHistory.customer_id',
      ),
      entryId: _$map[r'entry_id'].decodeJsonString(
        context: r'PlaceHistory.entry_id',
      ),
      fromSiteId: _$map[r'from_site_id'].decodeJsonNullableString(
        context: r'PlaceHistory.from_site_id',
      ),
      fromRoomId: _$map[r'from_room_id'].decodeJsonNullableString(
        context: r'PlaceHistory.from_room_id',
      ),
      fromFixtureId: _$map[r'from_fixture_id'].decodeJsonNullableString(
        context: r'PlaceHistory.from_fixture_id',
      ),
      fromLevel: _$map[r'from_level'].decodeJsonNullableInt(
        context: r'PlaceHistory.from_level',
      ),
      fromCompartment: _$map[r'from_compartment'].decodeJsonNullableInt(
        context: r'PlaceHistory.from_compartment',
      ),
      fromFloorXCm: _$map[r'from_floor_x_cm'].decodeJsonNullableInt(
        context: r'PlaceHistory.from_floor_x_cm',
      ),
      fromFloorYCm: _$map[r'from_floor_y_cm'].decodeJsonNullableInt(
        context: r'PlaceHistory.from_floor_y_cm',
      ),
      toSiteId: _$map[r'to_site_id'].decodeJsonNullableString(
        context: r'PlaceHistory.to_site_id',
      ),
      toRoomId: _$map[r'to_room_id'].decodeJsonNullableString(
        context: r'PlaceHistory.to_room_id',
      ),
      toFixtureId: _$map[r'to_fixture_id'].decodeJsonNullableString(
        context: r'PlaceHistory.to_fixture_id',
      ),
      toLevel: _$map[r'to_level'].decodeJsonNullableInt(
        context: r'PlaceHistory.to_level',
      ),
      toCompartment: _$map[r'to_compartment'].decodeJsonNullableInt(
        context: r'PlaceHistory.to_compartment',
      ),
      toFloorXCm: _$map[r'to_floor_x_cm'].decodeJsonNullableInt(
        context: r'PlaceHistory.to_floor_x_cm',
      ),
      toFloorYCm: _$map[r'to_floor_y_cm'].decodeJsonNullableInt(
        context: r'PlaceHistory.to_floor_y_cm',
      ),
      movedAt: _$map[r'moved_at'].decodeJsonDateTime(
        context: r'PlaceHistory.moved_at',
      ),
      movedBy: _$map[r'moved_by'].decodeJsonNullableString(
        context: r'PlaceHistory.moved_by',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'PlaceHistory.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'PlaceHistory.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'PlaceHistory.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'PlaceHistory.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(
        context: r'PlaceHistory.revision',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'PlaceHistory.deleted_at',
      ),
    );
  }

  factory PlaceHistory.fromForm(
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
        r'entry_id',
        r'from_site_id',
        r'from_room_id',
        r'from_fixture_id',
        r'from_level',
        r'from_compartment',
        r'from_floor_x_cm',
        r'from_floor_y_cm',
        r'to_site_id',
        r'to_room_id',
        r'to_fixture_id',
        r'to_level',
        r'to_compartment',
        r'to_floor_x_cm',
        r'to_floor_y_cm',
        r'moved_at',
        r'moved_by',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'PlaceHistory',
    );
    return PlaceHistory(
      id: _$values[r'id'].decodeFormString(context: r'PlaceHistory.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'PlaceHistory.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'PlaceHistory.customer_id',
      ),
      entryId: _$values[r'entry_id'].decodeFormString(
        context: r'PlaceHistory.entry_id',
      ),
      fromSiteId: _$values[r'from_site_id'].decodeFormNullableString(
        context: r'PlaceHistory.from_site_id',
      ),
      fromRoomId: _$values[r'from_room_id'].decodeFormNullableString(
        context: r'PlaceHistory.from_room_id',
      ),
      fromFixtureId: _$values[r'from_fixture_id'].decodeFormNullableString(
        context: r'PlaceHistory.from_fixture_id',
      ),
      fromLevel: _$values[r'from_level'].decodeFormNullableInt(
        context: r'PlaceHistory.from_level',
      ),
      fromCompartment: _$values[r'from_compartment'].decodeFormNullableInt(
        context: r'PlaceHistory.from_compartment',
      ),
      fromFloorXCm: _$values[r'from_floor_x_cm'].decodeFormNullableInt(
        context: r'PlaceHistory.from_floor_x_cm',
      ),
      fromFloorYCm: _$values[r'from_floor_y_cm'].decodeFormNullableInt(
        context: r'PlaceHistory.from_floor_y_cm',
      ),
      toSiteId: _$values[r'to_site_id'].decodeFormNullableString(
        context: r'PlaceHistory.to_site_id',
      ),
      toRoomId: _$values[r'to_room_id'].decodeFormNullableString(
        context: r'PlaceHistory.to_room_id',
      ),
      toFixtureId: _$values[r'to_fixture_id'].decodeFormNullableString(
        context: r'PlaceHistory.to_fixture_id',
      ),
      toLevel: _$values[r'to_level'].decodeFormNullableInt(
        context: r'PlaceHistory.to_level',
      ),
      toCompartment: _$values[r'to_compartment'].decodeFormNullableInt(
        context: r'PlaceHistory.to_compartment',
      ),
      toFloorXCm: _$values[r'to_floor_x_cm'].decodeFormNullableInt(
        context: r'PlaceHistory.to_floor_x_cm',
      ),
      toFloorYCm: _$values[r'to_floor_y_cm'].decodeFormNullableInt(
        context: r'PlaceHistory.to_floor_y_cm',
      ),
      movedAt: _$values[r'moved_at'].decodeFormDateTime(
        context: r'PlaceHistory.moved_at',
      ),
      movedBy: _$values[r'moved_by'].decodeFormNullableString(
        context: r'PlaceHistory.moved_by',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'PlaceHistory.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'PlaceHistory.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'PlaceHistory.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'PlaceHistory.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'PlaceHistory.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'PlaceHistory.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i3.String entryId;

  final _i3.String? fromSiteId;

  final _i3.String? fromRoomId;

  final _i3.String? fromFixtureId;

  final _i3.int? fromLevel;

  final _i3.int? fromCompartment;

  final _i3.int? fromFloorXCm;

  final _i3.int? fromFloorYCm;

  final _i3.String? toSiteId;

  final _i3.String? toRoomId;

  final _i3.String? toFixtureId;

  final _i3.int? toLevel;

  final _i3.int? toCompartment;

  final _i3.int? toFloorXCm;

  final _i3.int? toFloorYCm;

  final _i3.DateTime movedAt;

  final _i3.String? movedBy;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'entry_id': this.entryId,
    r'from_site_id': this.fromSiteId,
    r'from_room_id': this.fromRoomId,
    r'from_fixture_id': this.fromFixtureId,
    r'from_level': this.fromLevel,
    r'from_compartment': this.fromCompartment,
    r'from_floor_x_cm': this.fromFloorXCm,
    r'from_floor_y_cm': this.fromFloorYCm,
    r'to_site_id': this.toSiteId,
    r'to_room_id': this.toRoomId,
    r'to_fixture_id': this.toFixtureId,
    r'to_level': this.toLevel,
    r'to_compartment': this.toCompartment,
    r'to_floor_x_cm': this.toFloorXCm,
    r'to_floor_y_cm': this.toFloorYCm,
    r'moved_at': this.movedAt.toTimeZonedIso8601String(),
    r'moved_by': this.movedBy,
  };

  PlaceHistory Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? entryId,
    _i3.String? fromSiteId,
    _i3.String? fromRoomId,
    _i3.String? fromFixtureId,
    _i3.int? fromLevel,
    _i3.int? fromCompartment,
    _i3.int? fromFloorXCm,
    _i3.int? fromFloorYCm,
    _i3.String? toSiteId,
    _i3.String? toRoomId,
    _i3.String? toFixtureId,
    _i3.int? toLevel,
    _i3.int? toCompartment,
    _i3.int? toFloorXCm,
    _i3.int? toFloorYCm,
    _i3.DateTime? movedAt,
    _i3.String? movedBy,
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
      _i3.String? entryId,
      _i3.Object? fromSiteId = _sentinel,
      _i3.Object? fromRoomId = _sentinel,
      _i3.Object? fromFixtureId = _sentinel,
      _i3.Object? fromLevel = _sentinel,
      _i3.Object? fromCompartment = _sentinel,
      _i3.Object? fromFloorXCm = _sentinel,
      _i3.Object? fromFloorYCm = _sentinel,
      _i3.Object? toSiteId = _sentinel,
      _i3.Object? toRoomId = _sentinel,
      _i3.Object? toFixtureId = _sentinel,
      _i3.Object? toLevel = _sentinel,
      _i3.Object? toCompartment = _sentinel,
      _i3.Object? toFloorXCm = _sentinel,
      _i3.Object? toFloorYCm = _sentinel,
      _i3.DateTime? movedAt,
      _i3.Object? movedBy = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => PlaceHistory(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      entryId: entryId ?? this.entryId,
      fromSiteId: _i3.identical(fromSiteId, _sentinel)
          ? this.fromSiteId
          : (fromSiteId as _i3.String?),
      fromRoomId: _i3.identical(fromRoomId, _sentinel)
          ? this.fromRoomId
          : (fromRoomId as _i3.String?),
      fromFixtureId: _i3.identical(fromFixtureId, _sentinel)
          ? this.fromFixtureId
          : (fromFixtureId as _i3.String?),
      fromLevel: _i3.identical(fromLevel, _sentinel)
          ? this.fromLevel
          : (fromLevel as _i3.int?),
      fromCompartment: _i3.identical(fromCompartment, _sentinel)
          ? this.fromCompartment
          : (fromCompartment as _i3.int?),
      fromFloorXCm: _i3.identical(fromFloorXCm, _sentinel)
          ? this.fromFloorXCm
          : (fromFloorXCm as _i3.int?),
      fromFloorYCm: _i3.identical(fromFloorYCm, _sentinel)
          ? this.fromFloorYCm
          : (fromFloorYCm as _i3.int?),
      toSiteId: _i3.identical(toSiteId, _sentinel)
          ? this.toSiteId
          : (toSiteId as _i3.String?),
      toRoomId: _i3.identical(toRoomId, _sentinel)
          ? this.toRoomId
          : (toRoomId as _i3.String?),
      toFixtureId: _i3.identical(toFixtureId, _sentinel)
          ? this.toFixtureId
          : (toFixtureId as _i3.String?),
      toLevel: _i3.identical(toLevel, _sentinel)
          ? this.toLevel
          : (toLevel as _i3.int?),
      toCompartment: _i3.identical(toCompartment, _sentinel)
          ? this.toCompartment
          : (toCompartment as _i3.int?),
      toFloorXCm: _i3.identical(toFloorXCm, _sentinel)
          ? this.toFloorXCm
          : (toFloorXCm as _i3.int?),
      toFloorYCm: _i3.identical(toFloorYCm, _sentinel)
          ? this.toFloorYCm
          : (toFloorYCm as _i3.int?),
      movedAt: movedAt ?? this.movedAt,
      movedBy: _i3.identical(movedBy, _sentinel)
          ? this.movedBy
          : (movedBy as _i3.String?),
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
    return other is PlaceHistory &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.entryId == this.entryId &&
        other.fromSiteId == this.fromSiteId &&
        other.fromRoomId == this.fromRoomId &&
        other.fromFixtureId == this.fromFixtureId &&
        other.fromLevel == this.fromLevel &&
        other.fromCompartment == this.fromCompartment &&
        other.fromFloorXCm == this.fromFloorXCm &&
        other.fromFloorYCm == this.fromFloorYCm &&
        other.toSiteId == this.toSiteId &&
        other.toRoomId == this.toRoomId &&
        other.toFixtureId == this.toFixtureId &&
        other.toLevel == this.toLevel &&
        other.toCompartment == this.toCompartment &&
        other.toFloorXCm == this.toFloorXCm &&
        other.toFloorYCm == this.toFloorYCm &&
        other.movedAt == this.movedAt &&
        other.movedBy == this.movedBy &&
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
      this.entryId,
      this.fromSiteId,
      this.fromRoomId,
      this.fromFixtureId,
      this.fromLevel,
      this.fromCompartment,
      this.fromFloorXCm,
      this.fromFloorYCm,
      this.toSiteId,
      this.toRoomId,
      this.toFixtureId,
      this.toLevel,
      this.toCompartment,
      this.toFloorXCm,
      this.toFloorYCm,
      this.movedAt,
      this.movedBy,
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
    _$result[r'entry_id'] = _i1.PropertyValue.scalar(this.entryId);
    if (this.fromSiteId != null) {
      _$result[r'from_site_id'] = _i1.PropertyValue.scalar(this.fromSiteId!);
    }
    if (this.fromRoomId != null) {
      _$result[r'from_room_id'] = _i1.PropertyValue.scalar(this.fromRoomId!);
    }
    if (this.fromFixtureId != null) {
      _$result[r'from_fixture_id'] = _i1.PropertyValue.scalar(
        this.fromFixtureId!,
      );
    }
    if (this.fromLevel != null) {
      _$result[r'from_level'] = _i1.PropertyValue.scalar(
        this.fromLevel!.toString(),
      );
    }
    if (this.fromCompartment != null) {
      _$result[r'from_compartment'] = _i1.PropertyValue.scalar(
        this.fromCompartment!.toString(),
      );
    }
    if (this.fromFloorXCm != null) {
      _$result[r'from_floor_x_cm'] = _i1.PropertyValue.scalar(
        this.fromFloorXCm!.toString(),
      );
    }
    if (this.fromFloorYCm != null) {
      _$result[r'from_floor_y_cm'] = _i1.PropertyValue.scalar(
        this.fromFloorYCm!.toString(),
      );
    }
    if (this.toSiteId != null) {
      _$result[r'to_site_id'] = _i1.PropertyValue.scalar(this.toSiteId!);
    }
    if (this.toRoomId != null) {
      _$result[r'to_room_id'] = _i1.PropertyValue.scalar(this.toRoomId!);
    }
    if (this.toFixtureId != null) {
      _$result[r'to_fixture_id'] = _i1.PropertyValue.scalar(this.toFixtureId!);
    }
    if (this.toLevel != null) {
      _$result[r'to_level'] = _i1.PropertyValue.scalar(
        this.toLevel!.toString(),
      );
    }
    if (this.toCompartment != null) {
      _$result[r'to_compartment'] = _i1.PropertyValue.scalar(
        this.toCompartment!.toString(),
      );
    }
    if (this.toFloorXCm != null) {
      _$result[r'to_floor_x_cm'] = _i1.PropertyValue.scalar(
        this.toFloorXCm!.toString(),
      );
    }
    if (this.toFloorYCm != null) {
      _$result[r'to_floor_y_cm'] = _i1.PropertyValue.scalar(
        this.toFloorYCm!.toString(),
      );
    }
    _$result[r'moved_at'] = _i1.PropertyValue.scalar(
      this.movedAt.toTimeZonedIso8601String(),
    );
    if (this.movedBy != null) {
      _$result[r'moved_by'] = _i1.PropertyValue.scalar(this.movedBy!);
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
      r'Cannot uriEncode PlaceHistory: complex types cannot be URI-encoded',
    );
  }
}
