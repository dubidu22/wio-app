// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class Device extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Device({
    required this.id,
    required this.deviceName,
    required this.createdAt,
    required this.lastUsedAt,
    required this.current,
  });

  factory Device.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'device_name',
        r'created_at',
        r'last_used_at',
        r'current',
      },
      listKeys: {},
      context: r'Device',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Device(
      id: _$values[r'id'].decodeSimpleString(context: r'Device.id'),
      deviceName: _$values[r'device_name'].decodeSimpleString(
        context: r'Device.device_name',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Device.created_at',
      ),
      lastUsedAt: _$values[r'last_used_at'].decodeSimpleNullableDateTime(
        context: r'Device.last_used_at',
      ),
      current: _$values[r'current'].decodeSimpleBool(
        context: r'Device.current',
      ),
    );
  }

  factory Device.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Device');
    return Device(
      id: _$map[r'id'].decodeJsonString(context: r'Device.id'),
      deviceName: _$map[r'device_name'].decodeJsonString(
        context: r'Device.device_name',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Device.created_at',
      ),
      lastUsedAt: _$map[r'last_used_at'].decodeJsonNullableDateTime(
        context: r'Device.last_used_at',
      ),
      current: _$map[r'current'].decodeJsonBool(context: r'Device.current'),
    );
  }

  factory Device.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'device_name',
        r'created_at',
        r'last_used_at',
        r'current',
      },
      listKeys: {},
      context: r'Device',
    );
    return Device(
      id: _$values[r'id'].decodeFormString(context: r'Device.id'),
      deviceName: _$values[r'device_name'].decodeFormString(
        context: r'Device.device_name',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Device.created_at',
      ),
      lastUsedAt: _$values[r'last_used_at'].decodeFormNullableDateTime(
        context: r'Device.last_used_at',
      ),
      current: _$values[r'current'].decodeFormBool(context: r'Device.current'),
    );
  }

  final _i3.String id;

  final _i3.String deviceName;

  final _i3.DateTime createdAt;

  final _i3.DateTime? lastUsedAt;

  /// True for the token that made this request.
  final _i3.bool current;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'device_name': this.deviceName,
    r'created_at': this.createdAt.toTimeZonedIso8601String(),
    r'last_used_at': this.lastUsedAt?.toTimeZonedIso8601String(),
    r'current': this.current,
  };

  Device Function({
    _i3.String? id,
    _i3.String? deviceName,
    _i3.DateTime? createdAt,
    _i3.DateTime? lastUsedAt,
    _i3.bool? current,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.String? deviceName,
      _i3.DateTime? createdAt,
      _i3.Object? lastUsedAt = _sentinel,
      _i3.bool? current,
    }) => Device(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: _i3.identical(lastUsedAt, _sentinel)
          ? this.lastUsedAt
          : (lastUsedAt as _i3.DateTime?),
      current: current ?? this.current,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Device &&
        other.id == this.id &&
        other.deviceName == this.deviceName &&
        other.createdAt == this.createdAt &&
        other.lastUsedAt == this.lastUsedAt &&
        other.current == this.current;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.deviceName,
      this.createdAt,
      this.lastUsedAt,
      this.current,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    _$result[r'device_name'] = _i1.PropertyValue.scalar(this.deviceName);
    _$result[r'created_at'] = _i1.PropertyValue.scalar(
      this.createdAt.toTimeZonedIso8601String(),
    );
    if (this.lastUsedAt != null) {
      _$result[r'last_used_at'] = _i1.PropertyValue.scalar(
        this.lastUsedAt!.toTimeZonedIso8601String(),
      );
    }
    _$result[r'current'] = _i1.PropertyValue.scalar(this.current.toString());
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
      r'Cannot uriEncode Device: complex types cannot be URI-encoded',
    );
  }
}
