// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i1;
import 'package:wio_api/src/model/problem.dart' as _i2;

@_i1.immutable
class Maintenance {
  const Maintenance({required this.body, this.retryAfter});

  final _i2.Problem body;

  final _i3.int? retryAfter;

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is Maintenance &&
        other.body == this.body &&
        other.retryAfter == this.retryAfter;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.body, this.retryAfter]);
  }

  Maintenance Function({_i2.Problem? body, _i3.int? retryAfter}) get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i2.Problem? body, _i3.Object? retryAfter = _sentinel}) =>
        Maintenance(
          body: body ?? this.body,
          retryAfter: _i3.identical(retryAfter, _sentinel)
              ? this.retryAfter
              : (retryAfter as _i3.int?),
        );
  }
}
