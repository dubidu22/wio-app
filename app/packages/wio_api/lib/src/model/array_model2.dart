// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class ArrayModel2 extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ArrayModel2({required this.xCm, required this.yCm});

  factory ArrayModel2.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'x_cm', r'y_cm'},
      listKeys: {},
      context: r'ArrayModel2',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ArrayModel2(
      xCm: _$values[r'x_cm'].decodeSimpleInt(context: r'ArrayModel2.x_cm'),
      yCm: _$values[r'y_cm'].decodeSimpleInt(context: r'ArrayModel2.y_cm'),
    );
  }

  factory ArrayModel2.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ArrayModel2');
    return ArrayModel2(
      xCm: _$map[r'x_cm'].decodeJsonInt(context: r'ArrayModel2.x_cm'),
      yCm: _$map[r'y_cm'].decodeJsonInt(context: r'ArrayModel2.y_cm'),
    );
  }

  factory ArrayModel2.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'x_cm', r'y_cm'},
      listKeys: {},
      context: r'ArrayModel2',
    );
    return ArrayModel2(
      xCm: _$values[r'x_cm'].decodeFormInt(context: r'ArrayModel2.x_cm'),
      yCm: _$values[r'y_cm'].decodeFormInt(context: r'ArrayModel2.y_cm'),
    );
  }

  final _i3.int xCm;

  final _i3.int yCm;

  @_i3.override
  _i3.Object? toJson() => {r'x_cm': this.xCm, r'y_cm': this.yCm};

  ArrayModel2 Function({_i3.int? xCm, _i3.int? yCm}) get copyWith {
    return ({_i3.int? xCm, _i3.int? yCm}) =>
        ArrayModel2(xCm: xCm ?? this.xCm, yCm: yCm ?? this.yCm);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ArrayModel2 &&
        other.xCm == this.xCm &&
        other.yCm == this.yCm;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.xCm, this.yCm]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'x_cm'] = _i1.PropertyValue.scalar(this.xCm.toString());
    _$result[r'y_cm'] = _i1.PropertyValue.scalar(this.yCm.toString());
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
      r'Cannot uriEncode ArrayModel2: complex types cannot be URI-encoded',
    );
  }
}
