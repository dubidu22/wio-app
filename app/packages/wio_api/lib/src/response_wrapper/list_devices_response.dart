// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/device_list.dart' as _i2;
import 'package:wio_api/src/model/problem.dart' as _i4;
import 'package:wio_api/src/response/maintenance.dart' as _i5;

sealed class ListDevicesResponse {
  const ListDevicesResponse();
}

@_i1.immutable
class ListDevicesResponse200 extends ListDevicesResponse {
  const ListDevicesResponse200({required this.body});

  final _i2.DeviceList body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDevicesResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListDevicesResponse401 extends ListDevicesResponse {
  const ListDevicesResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDevicesResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListDevicesResponse503 extends ListDevicesResponse {
  const ListDevicesResponse503({required this.body});

  final _i5.Maintenance body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDevicesResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class ListDevicesResponseDefault extends ListDevicesResponse {
  const ListDevicesResponseDefault({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ListDevicesResponseDefault && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
