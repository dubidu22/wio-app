// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/health_status_model.dart' as _i4;

@_i2.immutable
class Health extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Health({required this.status});

  factory Health.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'status'},
      listKeys: {},
      context: r'Health',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Health(
      status: _i4.HealthStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  factory Health.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Health');
    return Health(status: _i4.HealthStatusModel.fromJson(_$map[r'status']));
  }

  factory Health.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'status'},
      listKeys: {},
      context: r'Health',
    );
    return Health(
      status: _i4.HealthStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
    );
  }

  final _i4.HealthStatusModel status;

  @_i3.override
  _i3.Object? toJson() => {r'status': this.status.toJson()};

  Health Function({_i4.HealthStatusModel? status}) get copyWith {
    return ({_i4.HealthStatusModel? status}) =>
        Health(status: status ?? this.status);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Health && other.status == this.status;
  }

  @_i3.override
  _i3.int get hashCode => this.status.hashCode;

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
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
      r'Cannot uriEncode Health: complex types cannot be URI-encoded',
    );
  }
}
