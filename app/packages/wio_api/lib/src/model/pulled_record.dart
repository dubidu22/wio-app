// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/entity_name.dart' as _i4;

@_i2.immutable
class PulledRecord extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PulledRecord({
    required this.entity,
    required this.id,
    required this.revision,
    required this.deletedAt,
    required this.fields,
  });

  factory PulledRecord.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PulledRecord: contains complex types',
    );
  }

  factory PulledRecord.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PulledRecord');
    return PulledRecord(
      entity: _$map[r'entity'].decodeJsonString(
        context: r'PulledRecord.entity',
      ),
      id: _$map[r'id'].decodeJsonString(context: r'PulledRecord.id'),
      revision: _$map[r'revision'].decodeJsonInt(
        context: r'PulledRecord.revision',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'PulledRecord.deleted_at',
      ),
      fields: _$map[r'fields'].decodeJsonMap(
        (v) => v,
        context: r'PulledRecord.fields',
      ),
    );
  }

  factory PulledRecord.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PulledRecord: contains complex types',
    );
  }

  final _i4.EntityName entity;

  final _i3.String id;

  final _i3.int revision;

  final _i3.DateTime? deletedAt;

  /// The whole record as the entity's record schema describes it (D-95).
  final _i3.Map<_i3.String, _i3.Object?> fields;

  @_i3.override
  _i3.Object? toJson() => {
    r'entity': this.entity,
    r'id': this.id,
    r'revision': this.revision,
    r'deleted_at': this.deletedAt?.toTimeZonedIso8601String(),
    r'fields': this.fields.map(
      (k, v) => _i3.MapEntry(
        k,
        _i1.encodeUnknownJson(v, context: r'PulledRecord.fields'),
      ),
    ),
  };

  PulledRecord Function({
    _i4.EntityName? entity,
    _i3.String? id,
    _i3.int? revision,
    _i3.DateTime? deletedAt,
    _i3.Map<_i3.String, _i3.Object?>? fields,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i4.EntityName? entity,
      _i3.String? id,
      _i3.int? revision,
      _i3.Object? deletedAt = _sentinel,
      _i3.Map<_i3.String, _i3.Object?>? fields,
    }) => PulledRecord(
      entity: entity ?? this.entity,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      deletedAt: _i3.identical(deletedAt, _sentinel)
          ? this.deletedAt
          : (deletedAt as _i3.DateTime?),
      fields: fields ?? this.fields,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is PulledRecord &&
        other.entity == this.entity &&
        other.id == this.id &&
        other.revision == this.revision &&
        other.deletedAt == this.deletedAt &&
        _$deepEquals.equals(other.fields, this.fields);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.entity,
      this.id,
      this.revision,
      this.deletedAt,
      deepEquals.hash(this.fields),
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PulledRecord: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PulledRecord: complex types cannot be URI-encoded',
    );
  }
}
