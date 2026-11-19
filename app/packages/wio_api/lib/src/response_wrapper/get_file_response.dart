// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/problem.dart' as _i6;
import 'package:wio_api/src/response/files_sha256_get200_response.dart' as _i2;
import 'package:wio_api/src/response/files_sha256_get206_response.dart' as _i4;
import 'package:wio_api/src/response/files_sha256_get304_response.dart' as _i5;
import 'package:wio_api/src/response/maintenance.dart' as _i7;

sealed class GetFileResponse {
  const GetFileResponse();
}

@_i1.immutable
class GetFileResponse200 extends GetFileResponse {
  const GetFileResponse200({required this.body});

  final _i2.FilesSha256Get200Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse206 extends GetFileResponse {
  const GetFileResponse206({required this.body});

  final _i4.FilesSha256Get206Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse206 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse304 extends GetFileResponse {
  const GetFileResponse304({required this.body});

  final _i5.FilesSha256Get304Response body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse304 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse400 extends GetFileResponse {
  const GetFileResponse400({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse401 extends GetFileResponse {
  const GetFileResponse401({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse403 extends GetFileResponse {
  const GetFileResponse403({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse404 extends GetFileResponse {
  const GetFileResponse404({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse404 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse416 extends GetFileResponse {
  const GetFileResponse416({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse416 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse426 extends GetFileResponse {
  const GetFileResponse426({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse426 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponse503 extends GetFileResponse {
  const GetFileResponse503({required this.body});

  final _i7.Maintenance body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class GetFileResponseDefault extends GetFileResponse {
  const GetFileResponseDefault({required this.body});

  final _i6.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is GetFileResponseDefault && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
