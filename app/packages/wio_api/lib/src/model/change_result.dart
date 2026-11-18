// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/change_result_status_model.dart' as _i4;

@_i2.immutable
class ChangeResult extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const ChangeResult({
    required this.changeId,
    required this.status,
    this.revision,
    this.reason,
    this.existingId,
    this.detail,
  });

  factory ChangeResult.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'change_id',
        r'status',
        r'revision',
        r'reason',
        r'existing_id',
        r'detail',
      },
      listKeys: {},
      context: r'ChangeResult',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return ChangeResult(
      changeId: _$values[r'change_id'].decodeSimpleString(
        context: r'ChangeResult.change_id',
      ),
      status: _i4.ChangeResultStatusModel.fromSimple(
        _$values[r'status'],
        explode: explode,
      ),
      revision: _$values[r'revision'].decodeSimpleNullableInt(
        context: r'ChangeResult.revision',
      ),
      reason: _$values[r'reason'].decodeSimpleNullableString(
        context: r'ChangeResult.reason',
      ),
      existingId: _$values[r'existing_id'].decodeSimpleNullableString(
        context: r'ChangeResult.existing_id',
      ),
      detail: _$values[r'detail'].decodeSimpleNullableString(
        context: r'ChangeResult.detail',
      ),
    );
  }

  factory ChangeResult.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'ChangeResult');
    return ChangeResult(
      changeId: _$map[r'change_id'].decodeJsonString(
        context: r'ChangeResult.change_id',
      ),
      status: _i4.ChangeResultStatusModel.fromJson(_$map[r'status']),
      revision: _$map[r'revision'].decodeJsonNullableInt(
        context: r'ChangeResult.revision',
      ),
      reason: _$map[r'reason'].decodeJsonNullableString(
        context: r'ChangeResult.reason',
      ),
      existingId: _$map[r'existing_id'].decodeJsonNullableString(
        context: r'ChangeResult.existing_id',
      ),
      detail: _$map[r'detail'].decodeJsonNullableString(
        context: r'ChangeResult.detail',
      ),
    );
  }

  factory ChangeResult.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'change_id',
        r'status',
        r'revision',
        r'reason',
        r'existing_id',
        r'detail',
      },
      listKeys: {},
      context: r'ChangeResult',
    );
    return ChangeResult(
      changeId: _$values[r'change_id'].decodeFormString(
        context: r'ChangeResult.change_id',
      ),
      status: _i4.ChangeResultStatusModel.fromForm(
        _$values[r'status'],
        explode: explode,
      ),
      revision: _$values[r'revision'].decodeFormNullableInt(
        context: r'ChangeResult.revision',
      ),
      reason: _$values[r'reason'].decodeFormNullableString(
        context: r'ChangeResult.reason',
      ),
      existingId: _$values[r'existing_id'].decodeFormNullableString(
        context: r'ChangeResult.existing_id',
      ),
      detail: _$values[r'detail'].decodeFormNullableString(
        context: r'ChangeResult.detail',
      ),
    );
  }

  final _i3.String changeId;

  final _i4.ChangeResultStatusModel status;

  /// The record's new revision for applied and merged.
  final _i3.int? revision;

  /// Only for rejected (open string, D-96). Documented values: permission, deleted, duplicate, invalid, not_found, stale_base. Apps treat an unknown reason as a plain rejection.
  final _i3.String? reason;

  /// Only with duplicate, the id of the live record that holds the value.
  final _i3.String? existingId;

  /// Text for logs, never shown to users.
  final _i3.String? detail;

  @_i3.override
  _i3.Object? toJson() => {
    r'change_id': this.changeId,
    r'status': this.status.toJson(),
    r'revision': this.revision,
    r'reason': this.reason,
    r'existing_id': this.existingId,
    r'detail': this.detail,
  };

  ChangeResult Function({
    _i3.String? changeId,
    _i4.ChangeResultStatusModel? status,
    _i3.int? revision,
    _i3.String? reason,
    _i3.String? existingId,
    _i3.String? detail,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? changeId,
      _i4.ChangeResultStatusModel? status,
      _i3.Object? revision = _sentinel,
      _i3.Object? reason = _sentinel,
      _i3.Object? existingId = _sentinel,
      _i3.Object? detail = _sentinel,
    }) => ChangeResult(
      changeId: changeId ?? this.changeId,
      status: status ?? this.status,
      revision: _i3.identical(revision, _sentinel)
          ? this.revision
          : (revision as _i3.int?),
      reason: _i3.identical(reason, _sentinel)
          ? this.reason
          : (reason as _i3.String?),
      existingId: _i3.identical(existingId, _sentinel)
          ? this.existingId
          : (existingId as _i3.String?),
      detail: _i3.identical(detail, _sentinel)
          ? this.detail
          : (detail as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is ChangeResult &&
        other.changeId == this.changeId &&
        other.status == this.status &&
        other.revision == this.revision &&
        other.reason == this.reason &&
        other.existingId == this.existingId &&
        other.detail == this.detail;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.changeId,
      this.status,
      this.revision,
      this.reason,
      this.existingId,
      this.detail,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'change_id'] = _i1.PropertyValue.scalar(this.changeId);
    _$result[r'status'] = _i1.PropertyValue.scalar(this.status.toJson());
    if (this.revision != null) {
      _$result[r'revision'] = _i1.PropertyValue.scalar(
        this.revision!.toString(),
      );
    }
    if (this.reason != null) {
      _$result[r'reason'] = _i1.PropertyValue.scalar(this.reason!);
    }
    if (this.existingId != null) {
      _$result[r'existing_id'] = _i1.PropertyValue.scalar(this.existingId!);
    }
    if (this.detail != null) {
      _$result[r'detail'] = _i1.PropertyValue.scalar(this.detail!);
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode ChangeResult: complex types cannot be URI-encoded',
    );
  }
}
