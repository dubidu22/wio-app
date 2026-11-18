// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/change_op_model.dart' as _i4;
import 'package:wio_api/src/model/entity_name.dart' as _i5;

/// One outbox entry (KB sync.md step 1, D-96, D-97). `fields` holds only the changed fields of the entity's record schema that are not read-only; the server checks them against that schema.
@_i2.immutable
class Change extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Change({
    required this.changeId,
    required this.entity,
    required this.id,
    required this.op,
    required this.fields,
    required this.baseRevision,
    required this.deviceTime,
  });

  factory Change.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Change: contains complex types',
    );
  }

  factory Change.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Change');
    return Change(
      changeId: _$map[r'change_id'].decodeJsonString(
        context: r'Change.change_id',
      ),
      entity: _$map[r'entity'].decodeJsonString(context: r'Change.entity'),
      id: _$map[r'id'].decodeJsonString(context: r'Change.id'),
      op: _i4.ChangeOpModel.fromJson(_$map[r'op']),
      fields: _$map[r'fields'].decodeJsonMap(
        (v) => v,
        context: r'Change.fields',
      ),
      baseRevision: _$map[r'base_revision'].decodeJsonNullableInt(
        context: r'Change.base_revision',
      ),
      deviceTime: _$map[r'device_time'].decodeJsonDateTime(
        context: r'Change.device_time',
      ),
    );
  }

  factory Change.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Change: contains complex types',
    );
  }

  /// UUID v7 made on the device; the idempotency key.
  final _i3.String changeId;

  final _i5.EntityName entity;

  /// Id of the record the change is about.
  final _i3.String id;

  /// upsert creates or changes fields; delete sets the tombstone; restore removes it (undo, D-97); move_entry changes an entry's current place and writes its place history (the only way to do so).
  final _i4.ChangeOpModel op;

  final _i3.Map<_i3.String, _i3.Object?> fields;

  /// The record's revision the device last saw; null when it creates the record.
  final _i3.int? baseRevision;

  /// Device clock, for information only; never decides order.
  final _i3.DateTime deviceTime;

  @_i3.override
  _i3.Object? toJson() => {
    r'change_id': this.changeId,
    r'entity': this.entity,
    r'id': this.id,
    r'op': this.op.toJson(),
    r'fields': this.fields.map(
      (k, v) =>
          _i3.MapEntry(k, _i1.encodeUnknownJson(v, context: r'Change.fields')),
    ),
    r'base_revision': this.baseRevision,
    r'device_time': this.deviceTime.toTimeZonedIso8601String(),
  };

  Change Function({
    _i3.String? changeId,
    _i5.EntityName? entity,
    _i3.String? id,
    _i4.ChangeOpModel? op,
    _i3.Map<_i3.String, _i3.Object?>? fields,
    _i3.int? baseRevision,
    _i3.DateTime? deviceTime,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? changeId,
      _i5.EntityName? entity,
      _i3.String? id,
      _i4.ChangeOpModel? op,
      _i3.Map<_i3.String, _i3.Object?>? fields,
      _i3.Object? baseRevision = _sentinel,
      _i3.DateTime? deviceTime,
    }) => Change(
      changeId: changeId ?? this.changeId,
      entity: entity ?? this.entity,
      id: id ?? this.id,
      op: op ?? this.op,
      fields: fields ?? this.fields,
      baseRevision: _i3.identical(baseRevision, _sentinel)
          ? this.baseRevision
          : (baseRevision as _i3.int?),
      deviceTime: deviceTime ?? this.deviceTime,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is Change &&
        other.changeId == this.changeId &&
        other.entity == this.entity &&
        other.id == this.id &&
        other.op == this.op &&
        _$deepEquals.equals(other.fields, this.fields) &&
        other.baseRevision == this.baseRevision &&
        other.deviceTime == this.deviceTime;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.changeId,
      this.entity,
      this.id,
      this.op,
      deepEquals.hash(this.fields),
      this.baseRevision,
      this.deviceTime,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Change: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Change: complex types cannot be URI-encoded',
    );
  }
}
