// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/file_state.dart' as _i2;
import 'package:wio_api/src/model/problem.dart' as _i4;
import 'package:wio_api/src/response/maintenance.dart' as _i5;

sealed class GetFileStateResponse {
  const GetFileStateResponse();
}

@_i1.immutable
class GetFileStateResponse200 extends GetFileStateResponse {
  const GetFileStateResponse200({required this.body});

  final _i2.FileState body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileStateResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileStateResponse400 extends GetFileStateResponse {
  const GetFileStateResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileStateResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileStateResponse401 extends GetFileStateResponse {
  const GetFileStateResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileStateResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileStateResponse503 extends GetFileStateResponse {
  const GetFileStateResponse503({required this.body});

  final _i5.Maintenance body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileStateResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileStateResponseDefault extends GetFileStateResponse {
  const GetFileStateResponseDefault({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileStateResponseDefault && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
