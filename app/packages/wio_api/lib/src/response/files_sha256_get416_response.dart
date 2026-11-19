// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/problem.dart' as _i2;

@_i1.immutable
class FilesSha256Get416Response {
  const FilesSha256Get416Response({required this.body, this.contentRange});

  final _i2.Problem body;

  final _i3.String? contentRange;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is FilesSha256Get416Response &&
        other.body == this.body &&
        other.contentRange == this.contentRange;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.body, this.contentRange]);
  }

  FilesSha256Get416Response Function({
    _i2.Problem? body,
    _i3.String? contentRange,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i2.Problem? body, _i3.Object? contentRange = _sentinel}) =>
        FilesSha256Get416Response(
          body: body ?? this.body,
          contentRange: _i3.identical(contentRange, _sentinel)
              ? this.contentRange
              : (contentRange as _i3.String?),
        );
  }
}
