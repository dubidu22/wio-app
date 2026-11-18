// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/health.dart' as _i2;
import 'package:wio_api/src/model/problem.dart' as _i4;

sealed class GetHealthResponse {
  const GetHealthResponse();
}

@_i1.immutable
class GetHealthResponse200 extends GetHealthResponse {
  const GetHealthResponse200({required this.body});

  final _i2.Health body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetHealthResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetHealthResponse405 extends GetHealthResponse {
  const GetHealthResponse405({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetHealthResponse405 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
