// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/pulled_record.dart' as _i4;

@_i2.immutable
class PullResult extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const PullResult({
    required this.records,
    required this.hasMore,
    required this.lastRevision,
  });

  factory PullResult.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for PullResult: contains complex types',
    );
  }

  factory PullResult.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'PullResult');
    return PullResult(
      records: _$map[r'records']
          .decodeJsonList<_i3.Object?>(context: r'PullResult.records')
          .map(_i4.PulledRecord.fromJson)
          .toList(),
      hasMore: _$map[r'has_more'].decodeJsonBool(
        context: r'PullResult.has_more',
      ),
      lastRevision: _$map[r'last_revision'].decodeJsonInt(
        context: r'PullResult.last_revision',
      ),
    );
  }

  factory PullResult.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for PullResult: contains complex types',
    );
  }

  final _i3.List<_i4.PulledRecord> records;

  final _i3.bool hasMore;

  /// The highest revision the server examined for this page. It can be higher than the last returned record, because records this token may not read are skipped. Store it and pass it as `since`. When `has_more` is true it is greater than `since`.
  final _i3.int lastRevision;

  @_i3.override
  _i3.Object? toJson() => {
    r'records': this.records.map((e) => e.toJson()).toList(),
    r'has_more': this.hasMore,
    r'last_revision': this.lastRevision,
  };

  PullResult Function({
    _i3.List<_i4.PulledRecord>? records,
    _i3.bool? hasMore,
    _i3.int? lastRevision,
  })
  get copyWith {
    return ({
      _i3.List<_i4.PulledRecord>? records,
      _i3.bool? hasMore,
      _i3.int? lastRevision,
    }) => PullResult(
      records: records ?? this.records,
      hasMore: hasMore ?? this.hasMore,
      lastRevision: lastRevision ?? this.lastRevision,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is PullResult &&
        _$deepEquals.equals(other.records, this.records) &&
        other.hasMore == this.hasMore &&
        other.lastRevision == this.lastRevision;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      deepEquals.hash(this.records),
      this.hasMore,
      this.lastRevision,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for PullResult: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode PullResult: complex types cannot be URI-encoded',
    );
  }
}
