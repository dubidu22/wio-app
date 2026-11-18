// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/change_result.dart' as _i4;

@_i2.immutable
class PushResult extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PushResult({required this.results});

  factory PushResult.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PushResult: contains complex types',
    );
  }

  factory PushResult.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PushResult');
    return PushResult(
      results: _$map[r'results']
          .decodeJsonList<_i3.Object?>(context: r'PushResult.results')
          .map(_i4.ChangeResult.fromJson)
          .toList(),
    );
  }

  factory PushResult.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PushResult: contains complex types',
    );
  }

  final _i3.List<_i4.ChangeResult> results;

  @_i3.override
  _i3.Object? toJson() => {
    r'results': this.results.map((e) => e.toJson()).toList(),
  };

  PushResult Function({_i3.List<_i4.ChangeResult>? results}) get copyWith {
    return ({_i3.List<_i4.ChangeResult>? results}) =>
        PushResult(results: results ?? this.results);
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is PushResult &&
        _$deepEquals.equals(other.results, this.results);
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return deepEquals.hash(this.results);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PushResult: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PushResult: complex types cannot be URI-encoded',
    );
  }
}
