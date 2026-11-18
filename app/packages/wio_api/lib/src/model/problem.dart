// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i5;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/workspace_ref.dart' as _i4;

/// RFC 9457 problem details (D-98). `code` is an open string; documented values: invalid_request, token_invalid, invalid_credentials, forbidden, workspace_choice_required, too_many_attempts, too_many_changes, payload_too_large, offset_mismatch, hash_mismatch, maintenance, not_found, method_not_allowed, resync_required (410 on pull: drop pulled records, keep the outbox, pull from 0), upgrade_required (426: update the app; local data stays), internal. Apps treat an unknown code as a server error.
@_i2.immutable
class Problem extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Problem({
    required this.$type,
    required this.title,
    required this.status,
    required this.code,
    this.detail,
    this.workspaces,
    this.receivedBytes,
    this.minimumAppVersion,
  });

  factory Problem.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Problem: contains complex types',
    );
  }

  factory Problem.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Problem');
    return Problem(
      $type: _$map[r'type'].decodeJsonString(context: r'Problem.type'),
      title: _$map[r'title'].decodeJsonString(context: r'Problem.title'),
      status: _$map[r'status'].decodeJsonInt(context: r'Problem.status'),
      detail: _$map[r'detail'].decodeJsonNullableString(
        context: r'Problem.detail',
      ),
      code: _$map[r'code'].decodeJsonString(context: r'Problem.code'),
      workspaces: _$map[r'workspaces']
          .decodeJsonNullableList<_i3.Object?>(context: r'Problem.workspaces')
          ?.map(_i4.WorkspaceRef.fromJson)
          .toList(),
      receivedBytes: _$map[r'received_bytes'].decodeJsonNullableInt(
        context: r'Problem.received_bytes',
      ),
      minimumAppVersion: _$map[r'minimum_app_version'].decodeJsonNullableString(
        context: r'Problem.minimum_app_version',
      ),
    );
  }

  factory Problem.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Problem: contains complex types',
    );
  }

  /// Always `about:blank`; the machine meaning is in `code`.
  final _i3.String $type;

  final _i3.String title;

  final _i3.int status;

  final _i3.String? detail;

  final _i3.String code;

  /// Only with `workspace_choice_required`.
  final _i3.List<_i4.WorkspaceRef>? workspaces;

  /// Only with `offset_mismatch`.
  final _i3.int? receivedBytes;

  /// Only with `upgrade_required`; the oldest version the server serves.
  final _i3.String? minimumAppVersion;

  @_i3.override
  _i3.Object? toJson() => {
    r'type': this.$type,
    r'title': this.title,
    r'status': this.status,
    if (this.detail != null) r'detail': this.detail,
    r'code': this.code,
    if (this.workspaces != null)
      r'workspaces': this.workspaces?.map((e) => e.toJson()).toList(),
    if (this.receivedBytes != null) r'received_bytes': this.receivedBytes,
    if (this.minimumAppVersion != null)
      r'minimum_app_version': this.minimumAppVersion,
  };

  Problem Function({
    _i3.String? $type,
    _i3.String? title,
    _i3.int? status,
    _i3.String? detail,
    _i3.String? code,
    _i3.List<_i4.WorkspaceRef>? workspaces,
    _i3.int? receivedBytes,
    _i3.String? minimumAppVersion,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? $type,
      _i3.String? title,
      _i3.int? status,
      _i3.Object? detail = _sentinel,
      _i3.String? code,
      _i3.Object? workspaces = _sentinel,
      _i3.Object? receivedBytes = _sentinel,
      _i3.Object? minimumAppVersion = _sentinel,
    }) => Problem(
      $type: $type ?? this.$type,
      title: title ?? this.title,
      status: status ?? this.status,
      detail: _i3.identical(detail, _sentinel)
          ? this.detail
          : (detail as _i3.String?),
      code: code ?? this.code,
      workspaces: _i3.identical(workspaces, _sentinel)
          ? this.workspaces
          : (workspaces as _i3.List<_i4.WorkspaceRef>?),
      receivedBytes: _i3.identical(receivedBytes, _sentinel)
          ? this.receivedBytes
          : (receivedBytes as _i3.int?),
      minimumAppVersion: _i3.identical(minimumAppVersion, _sentinel)
          ? this.minimumAppVersion
          : (minimumAppVersion as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i5.DeepCollectionEquality();
    return other is Problem &&
        other.$type == this.$type &&
        other.title == this.title &&
        other.status == this.status &&
        other.detail == this.detail &&
        other.code == this.code &&
        _$deepEquals.equals(other.workspaces, this.workspaces) &&
        other.receivedBytes == this.receivedBytes &&
        other.minimumAppVersion == this.minimumAppVersion;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i5.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.$type,
      this.title,
      this.status,
      this.detail,
      this.code,
      deepEquals.hash(this.workspaces),
      this.receivedBytes,
      this.minimumAppVersion,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for Problem: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Problem: complex types cannot be URI-encoded',
    );
  }
}
