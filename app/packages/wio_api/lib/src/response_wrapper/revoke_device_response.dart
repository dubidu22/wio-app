// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/problem.dart' as _i3;
import 'package:wio_api/src/response/maintenance.dart' as _i4;

sealed class RevokeDeviceResponse {
  const RevokeDeviceResponse();
}

@_i1.immutable
class RevokeDeviceResponse204 extends RevokeDeviceResponse {
  const RevokeDeviceResponse204();

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeDeviceResponse204;
  }

  @_i2.override
  _i2.int get hashCode => this.runtimeType.hashCode;
}

@_i1.immutable
class RevokeDeviceResponse401 extends RevokeDeviceResponse {
  const RevokeDeviceResponse401({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeDeviceResponse401 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RevokeDeviceResponse404 extends RevokeDeviceResponse {
  const RevokeDeviceResponse404({required this.body});

  final _i3.Problem body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeDeviceResponse404 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class RevokeDeviceResponse503 extends RevokeDeviceResponse {
  const RevokeDeviceResponse503({required this.body});

  final _i4.Maintenance body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is RevokeDeviceResponse503 && other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode => this.body.hashCode;
}
