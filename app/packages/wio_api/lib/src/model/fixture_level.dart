// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// One level of a fixture, counted from the bottom.
@_i2.immutable
class FixtureLevel extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const FixtureLevel({required this.heightCm, required this.compartments});

  factory FixtureLevel.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'height_cm', r'compartments'},
      listKeys: {},
      context: r'FixtureLevel',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return FixtureLevel(
      heightCm: _$values[r'height_cm'].decodeSimpleInt(
        context: r'FixtureLevel.height_cm',
      ),
      compartments: _$values[r'compartments'].decodeSimpleInt(
        context: r'FixtureLevel.compartments',
      ),
    );
  }

  factory FixtureLevel.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'FixtureLevel');
    return FixtureLevel(
      heightCm: _$map[r'height_cm'].decodeJsonInt(
        context: r'FixtureLevel.height_cm',
      ),
      compartments: _$map[r'compartments'].decodeJsonInt(
        context: r'FixtureLevel.compartments',
      ),
    );
  }

  factory FixtureLevel.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'height_cm', r'compartments'},
      listKeys: {},
      context: r'FixtureLevel',
    );
    return FixtureLevel(
      heightCm: _$values[r'height_cm'].decodeFormInt(
        context: r'FixtureLevel.height_cm',
      ),
      compartments: _$values[r'compartments'].decodeFormInt(
        context: r'FixtureLevel.compartments',
      ),
    );
  }

  final _i3.int heightCm;

  final _i3.int compartments;

  @_i3.override
  _i3.Object? toJson() => {
    r'height_cm': this.heightCm,
    r'compartments': this.compartments,
  };

  FixtureLevel Function({_i3.int? heightCm, _i3.int? compartments})
  get copyWith {
    return ({_i3.int? heightCm, _i3.int? compartments}) => FixtureLevel(
      heightCm: heightCm ?? this.heightCm,
      compartments: compartments ?? this.compartments,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is FixtureLevel &&
        other.heightCm == this.heightCm &&
        other.compartments == this.compartments;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.heightCm, this.compartments]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'height_cm'] = _i1.PropertyValue.scalar(this.heightCm.toString());
    _$result[r'compartments'] = _i1.PropertyValue.scalar(
      this.compartments.toString(),
    );
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
      r'Cannot uriEncode FixtureLevel: complex types cannot be URI-encoded',
    );
  }
}
