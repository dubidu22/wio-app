// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i7;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i6;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/outline_point.dart' as _i4;
import 'package:wio_api/src/model/room_outline.dart' as _i5;

@_i2.immutable
class $RawRoomOutlineAllOfModel
    implements _i1.ParameterEncodable, _i1.UriEncodable {
  const $RawRoomOutlineAllOfModel({required this.roomOutline});

  factory $RawRoomOutlineAllOfModel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    return $RawRoomOutlineAllOfModel(
      roomOutline: throw _i1.SimpleDecodingException(
        'ClassModel is not supported in lists for simple decoding.',
      ),
    );
  }

  factory $RawRoomOutlineAllOfModel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    return $RawRoomOutlineAllOfModel(
      roomOutline: throw _i1.FormDecodingException(
        'ClassModel is not supported in lists for form decoding.',
      ),
    );
  }

  factory $RawRoomOutlineAllOfModel.fromJson(_i3.Object? json) {
    return $RawRoomOutlineAllOfModel(
      roomOutline: json
          .decodeJsonList<_i3.Object?>(context: r'$RawRoomOutlineAllOfModel')
          .map(_i4.OutlinePoint.fromJson)
          .toList(),
    );
  }

  final _i5.RoomOutline roomOutline;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Object? toJson() {
    final _$values = <_i3.Object?>[];
    final _$roomOutlineJson = this.roomOutline.map((e) => e.toJson()).toList();
    _$values.add(_$roomOutlineJson);
    const deepEquals = _i6.DeepCollectionEquality();
    for (var i = 1; i < _$values.length; i++) {
      if (!deepEquals.equals(_$values[0], _$values[i])) {
        throw _i1.EncodingException(
          'Inconsistent allOf JSON encoding: all arrays must encode to the same result',
        );
      }
    }
    return _$values.first;
  }

  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for $RawRoomOutlineAllOfModel: contains array types',
  );

  @_i3.override
  _i3.String toSimple({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool literal = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty)
        .toSimple(explode: explode, allowEmpty: allowEmpty, literal: literal);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toForm(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
    _i3.Map<_i3.String, _i1.FormFieldEncoding> fieldEncodings = const {},
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toForm(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      useQueryComponent: useQueryComponent,
      allowReserved: allowReserved,
      fieldEncodings: fieldEncodings,
      textEncoding: textEncoding,
    );
  }

  @_i3.override
  _i3.String toLabel({
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return parameterProperties(allowEmpty: allowEmpty)
        .toLabel(explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.String toMatrix(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
  }) {
    return parameterProperties(allowEmpty: allowEmpty)
        .toMatrix(paramName, explode: explode, allowEmpty: allowEmpty);
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toDeepObject(
    _i3.String paramName, {
    required _i3.bool explode,
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toDeepObject(
      paramName,
      explode: explode,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toPipeDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toPipeDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.List<_i1.ParameterEntry> toSpaceDelimited(
    _i3.String paramName, {
    required _i3.bool allowEmpty,
    _i3.bool allowReserved = false,
  }) {
    return parameterProperties(allowEmpty: allowEmpty).toSpaceDelimited(
      paramName,
      allowEmpty: allowEmpty,
      allowReserved: allowReserved,
    );
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i7.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode $RawRoomOutlineAllOfModel: contains complex types',
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i6.DeepCollectionEquality();
    return other is $RawRoomOutlineAllOfModel &&
        _$deepEquals.equals(other.roomOutline, this.roomOutline);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i6.DeepCollectionEquality();
    return deepEquals.hash(this.roomOutline);
  }

  $RawRoomOutlineAllOfModel Function({_i5.RoomOutline? roomOutline})
  get copyWith {
    return ({_i5.RoomOutline? roomOutline}) =>
        $RawRoomOutlineAllOfModel(roomOutline: roomOutline ?? this.roomOutline);
  }
}

typedef RoomOutlineAllOfModel = $RawRoomOutlineAllOfModel?;
