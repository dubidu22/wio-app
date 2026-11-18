// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/file_state.dart' as _i2;
import 'package:wio_api/src/model/problem.dart' as _i4;
import 'package:wio_api/src/response/maintenance.dart' as _i5;

sealed class PutFileChunkResponse {
  const PutFileChunkResponse();
}

@_i1.immutable
class PutFileChunkResponse200 extends PutFileChunkResponse {
  const PutFileChunkResponse200({required this.body});

  final _i2.FileState body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse200 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse202 extends PutFileChunkResponse {
  const PutFileChunkResponse202({required this.body});

  final _i2.FileState body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse202 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse400 extends PutFileChunkResponse {
  const PutFileChunkResponse400({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse400 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse401 extends PutFileChunkResponse {
  const PutFileChunkResponse401({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse401 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse403 extends PutFileChunkResponse {
  const PutFileChunkResponse403({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse403 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse409 extends PutFileChunkResponse {
  const PutFileChunkResponse409({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse409 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse413 extends PutFileChunkResponse {
  const PutFileChunkResponse413({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse413 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse422 extends PutFileChunkResponse {
  const PutFileChunkResponse422({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse422 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse426 extends PutFileChunkResponse {
  const PutFileChunkResponse426({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse426 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponse503 extends PutFileChunkResponse {
  const PutFileChunkResponse503({required this.body});

  final _i5.Maintenance body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponse503 && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}

@_i1.immutable
class PutFileChunkResponseDefault extends PutFileChunkResponse {
  const PutFileChunkResponseDefault({required this.body});

  final _i4.Problem body;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is PutFileChunkResponseDefault && other.body == this.body;
  }

  @_i3.override
  _i3.int get hashCode => this.body.hashCode;
}
