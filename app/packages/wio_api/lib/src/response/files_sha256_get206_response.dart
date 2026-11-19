// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:meta/meta.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/model/accept_ranges_model.dart' as _i3;

@_i1.immutable
sealed class FilesSha256Get206Response {
  const FilesSha256Get206Response({
    required this.eTag,
    required this.acceptRanges,
    required this.contentLength,
    required this.contentRange,
  });

  final _i2.String eTag;

  final _i3.AcceptRangesModel acceptRanges;

  final _i2.int contentLength;

  final _i2.String contentRange;
}

@_i1.immutable
class FilesSha256Get206ResponseJpeg extends FilesSha256Get206Response {
  const FilesSha256Get206ResponseJpeg({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required super.contentRange,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get206ResponseJpeg &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.contentRange == this.contentRange &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.contentRange,
      this.body,
    ]);
  }

  FilesSha256Get206ResponseJpeg Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i2.String? contentRange,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i2.String? contentRange,
      _i4.TonikFile? body,
    }) => FilesSha256Get206ResponseJpeg(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      contentRange: contentRange ?? this.contentRange,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get206ResponsePng extends FilesSha256Get206Response {
  const FilesSha256Get206ResponsePng({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required super.contentRange,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get206ResponsePng &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.contentRange == this.contentRange &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.contentRange,
      this.body,
    ]);
  }

  FilesSha256Get206ResponsePng Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i2.String? contentRange,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i2.String? contentRange,
      _i4.TonikFile? body,
    }) => FilesSha256Get206ResponsePng(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      contentRange: contentRange ?? this.contentRange,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get206ResponseWebp extends FilesSha256Get206Response {
  const FilesSha256Get206ResponseWebp({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required super.contentRange,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get206ResponseWebp &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.contentRange == this.contentRange &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.contentRange,
      this.body,
    ]);
  }

  FilesSha256Get206ResponseWebp Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i2.String? contentRange,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i2.String? contentRange,
      _i4.TonikFile? body,
    }) => FilesSha256Get206ResponseWebp(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      contentRange: contentRange ?? this.contentRange,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get206ResponseHeic extends FilesSha256Get206Response {
  const FilesSha256Get206ResponseHeic({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required super.contentRange,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get206ResponseHeic &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.contentRange == this.contentRange &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.contentRange,
      this.body,
    ]);
  }

  FilesSha256Get206ResponseHeic Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i2.String? contentRange,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i2.String? contentRange,
      _i4.TonikFile? body,
    }) => FilesSha256Get206ResponseHeic(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      contentRange: contentRange ?? this.contentRange,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get206ResponseMp4 extends FilesSha256Get206Response {
  const FilesSha256Get206ResponseMp4({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required super.contentRange,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get206ResponseMp4 &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.contentRange == this.contentRange &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.contentRange,
      this.body,
    ]);
  }

  FilesSha256Get206ResponseMp4 Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i2.String? contentRange,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i2.String? contentRange,
      _i4.TonikFile? body,
    }) => FilesSha256Get206ResponseMp4(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      contentRange: contentRange ?? this.contentRange,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get206ResponseOctetStream extends FilesSha256Get206Response {
  const FilesSha256Get206ResponseOctetStream({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required super.contentRange,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get206ResponseOctetStream &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.contentRange == this.contentRange &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.contentRange,
      this.body,
    ]);
  }

  FilesSha256Get206ResponseOctetStream Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i2.String? contentRange,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i2.String? contentRange,
      _i4.TonikFile? body,
    }) => FilesSha256Get206ResponseOctetStream(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      contentRange: contentRange ?? this.contentRange,
      body: body ?? this.body,
    );
  }
}
