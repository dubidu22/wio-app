// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:core' as _i2;

import 'package:meta/meta.dart' as _i1;
import 'package:tonik_util/tonik_util.dart' as _i4;
import 'package:wio_api/src/model/accept_ranges_model.dart' as _i3;

@_i1.immutable
sealed class FilesSha256Get200Response {
  const FilesSha256Get200Response({
    required this.eTag,
    required this.acceptRanges,
    required this.contentLength,
  });

  final _i2.String eTag;

  final _i3.AcceptRangesModel acceptRanges;

  final _i2.int contentLength;
}

@_i1.immutable
class FilesSha256Get200ResponseJpeg extends FilesSha256Get200Response {
  const FilesSha256Get200ResponseJpeg({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get200ResponseJpeg &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.body,
    ]);
  }

  FilesSha256Get200ResponseJpeg Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i4.TonikFile? body,
    }) => FilesSha256Get200ResponseJpeg(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get200ResponsePng extends FilesSha256Get200Response {
  const FilesSha256Get200ResponsePng({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get200ResponsePng &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.body,
    ]);
  }

  FilesSha256Get200ResponsePng Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i4.TonikFile? body,
    }) => FilesSha256Get200ResponsePng(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get200ResponseWebp extends FilesSha256Get200Response {
  const FilesSha256Get200ResponseWebp({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get200ResponseWebp &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.body,
    ]);
  }

  FilesSha256Get200ResponseWebp Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i4.TonikFile? body,
    }) => FilesSha256Get200ResponseWebp(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get200ResponseHeic extends FilesSha256Get200Response {
  const FilesSha256Get200ResponseHeic({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get200ResponseHeic &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.body,
    ]);
  }

  FilesSha256Get200ResponseHeic Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i4.TonikFile? body,
    }) => FilesSha256Get200ResponseHeic(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get200ResponseMp4 extends FilesSha256Get200Response {
  const FilesSha256Get200ResponseMp4({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get200ResponseMp4 &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.body,
    ]);
  }

  FilesSha256Get200ResponseMp4 Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i4.TonikFile? body,
    }) => FilesSha256Get200ResponseMp4(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      body: body ?? this.body,
    );
  }
}

@_i1.immutable
class FilesSha256Get200ResponseOctetStream extends FilesSha256Get200Response {
  const FilesSha256Get200ResponseOctetStream({
    required super.eTag,
    required super.acceptRanges,
    required super.contentLength,
    required this.body,
  });

  final _i4.TonikFile body;

  @_i2.override
  _i2.bool operator ==(_i2.Object other) {
    if (_i2.identical(this, other)) return true;
    return other is FilesSha256Get200ResponseOctetStream &&
        other.eTag == this.eTag &&
        other.acceptRanges == this.acceptRanges &&
        other.contentLength == this.contentLength &&
        other.body == this.body;
  }

  @_i2.override
  _i2.int get hashCode {
    return _i2.Object.hashAll([
      this.eTag,
      this.acceptRanges,
      this.contentLength,
      this.body,
    ]);
  }

  FilesSha256Get200ResponseOctetStream Function({
    _i2.String? eTag,
    _i3.AcceptRangesModel? acceptRanges,
    _i2.int? contentLength,
    _i4.TonikFile? body,
  })
  get copyWith {
    return ({
      _i2.String? eTag,
      _i3.AcceptRangesModel? acceptRanges,
      _i2.int? contentLength,
      _i4.TonikFile? body,
    }) => FilesSha256Get200ResponseOctetStream(
      eTag: eTag ?? this.eTag,
      acceptRanges: acceptRanges ?? this.acceptRanges,
      contentLength: contentLength ?? this.contentLength,
      body: body ?? this.body,
    );
  }
}
