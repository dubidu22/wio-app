// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:meta/meta.dart' as _i1;

@_i1.immutable
class FilesSha256Get304Response {
  const FilesSha256Get304Response({required this.eTag});

  final _i2.String eTag;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get304Response && other.eTag == this.eTag;
  }

  @_i2.override
  _i2.int get hashCode => this.eTag.hashCode;

  FilesSha256Get304Response Function({_i2.String? eTag}) get copyWith {
    return ({_i2.String? eTag}) =>
        FilesSha256Get304Response(eTag: eTag ?? this.eTag);
  }
}
