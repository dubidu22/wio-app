// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/me.dart' as _i2;
import 'package:wio_api/src/model/problem.dart' as _i4;
import 'package:wio_api/src/response/maintenance.dart' as _i5;

sealed class GetMeResponse {
  const GetMeResponse();
}

@_i1.immutable
class GetMeResponse200 extends GetMeResponse {
  const GetMeResponse200({required this.body});

  final _i2.Me body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetMeResponse401 extends GetMeResponse {
  const GetMeResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetMeResponse426 extends GetMeResponse {
  const GetMeResponse426({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse426 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetMeResponse503 extends GetMeResponse {
  const GetMeResponse503({required this.body});

  final _i5.Maintenance body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetMeResponseDefault extends GetMeResponse {
  const GetMeResponseDefault({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetMeResponseDefault && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
