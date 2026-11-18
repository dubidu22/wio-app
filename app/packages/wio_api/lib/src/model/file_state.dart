// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class FileState extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const FileState({
    required this.sha256,
    required this.receivedBytes,
    required this.complete,
    this.size,
  });

  factory FileState.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'sha256', r'size', r'received_bytes', r'complete'},
      listKeys: {},
      context: r'FileState',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return FileState(
      sha256: _$values[r'sha256'].decodeSimpleString(
        context: r'FileState.sha256',
      ),
      size: _$values[r'size'].decodeSimpleNullableInt(
        context: r'FileState.size',
      ),
      receivedBytes: _$values[r'received_bytes'].decodeSimpleInt(
        context: r'FileState.received_bytes',
      ),
      complete: _$values[r'complete'].decodeSimpleBool(
        context: r'FileState.complete',
      ),
    );
  }

  factory FileState.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'FileState');
    return FileState(
      sha256: _$map[r'sha256'].decodeJsonString(context: r'FileState.sha256'),
      size: _$map[r'size'].decodeJsonNullableInt(context: r'FileState.size'),
      receivedBytes: _$map[r'received_bytes'].decodeJsonInt(
        context: r'FileState.received_bytes',
      ),
      complete: _$map[r'complete'].decodeJsonBool(
        context: r'FileState.complete',
      ),
    );
  }

  factory FileState.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'sha256', r'size', r'received_bytes', r'complete'},
      listKeys: {},
      context: r'FileState',
    );
    return FileState(
      sha256: _$values[r'sha256'].decodeFormString(
        context: r'FileState.sha256',
      ),
      size: _$values[r'size'].decodeFormNullableInt(context: r'FileState.size'),
      receivedBytes: _$values[r'received_bytes'].decodeFormInt(
        context: r'FileState.received_bytes',
      ),
      complete: _$values[r'complete'].decodeFormBool(
        context: r'FileState.complete',
      ),
    );
  }

  final _i3.String sha256;

  /// Total size from the first chunk's Content-Range; null before any chunk.
  final _i3.int? size;

  final _i3.int receivedBytes;

  final _i3.bool complete;

  @_i3.override
  _i3.Object? toJson() => {
    r'sha256': this.sha256,
    r'size': this.size,
    r'received_bytes': this.receivedBytes,
    r'complete': this.complete,
  };

  FileState Function({
    _i3.String? sha256,
    _i3.int? size,
    _i3.int? receivedBytes,
    _i3.bool? complete,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? sha256,
      _i3.Object? size = _sentinel,
      _i3.int? receivedBytes,
      _i3.bool? complete,
    }) => FileState(
      sha256: sha256 ?? this.sha256,
      size: _i3.identical(size, _sentinel) ? this.size : (size as _i3.int?),
      receivedBytes: receivedBytes ?? this.receivedBytes,
      complete: complete ?? this.complete,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is FileState &&
        other.sha256 == this.sha256 &&
        other.size == this.size &&
        other.receivedBytes == this.receivedBytes &&
        other.complete == this.complete;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.sha256,
      this.size,
      this.receivedBytes,
      this.complete,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'sha256'] = _i1.PropertyValue.scalar(this.sha256);
    if (this.size != null) {
      _$result[r'size'] = _i1.PropertyValue.scalar(this.size!.toString());
    }
    _$result[r'received_bytes'] = _i1.PropertyValue.scalar(
      this.receivedBytes.toString(),
    );
    _$result[r'complete'] = _i1.PropertyValue.scalar(this.complete.toString());
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i4.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode FileState: complex types cannot be URI-encoded',
    );
  }
}
