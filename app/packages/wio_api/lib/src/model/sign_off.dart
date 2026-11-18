// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `sign_offs` record as sync pulls it (D-95).
@_i2.immutable
class SignOff extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const SignOff({
    required this.customerId,
    required this.jobId,
    required this.minutesConfirmed,
    required this.signature,
    required this.signedAt,
    required this.signedBy,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory SignOff.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for SignOff: contains complex types',
    );
  }

  factory SignOff.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'SignOff');
    return SignOff(
      id: _$map[r'id'].decodeJsonString(context: r'SignOff.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'SignOff.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonString(
        context: r'SignOff.customer_id',
      ),
      jobId: _$map[r'job_id'].decodeJsonString(context: r'SignOff.job_id'),
      minutesConfirmed: _$map[r'minutes_confirmed'].decodeJsonInt(
        context: r'SignOff.minutes_confirmed',
      ),
      signature: _$map[r'signature'].decodeJsonList<_i3.Object?>(
        context: r'SignOff.signature',
      ),
      signedAt: _$map[r'signed_at'].decodeJsonDateTime(
        context: r'SignOff.signed_at',
      ),
      signedBy: _$map[r'signed_by'].decodeJsonNullableString(
        context: r'SignOff.signed_by',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'SignOff.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'SignOff.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'SignOff.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'SignOff.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'SignOff.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'SignOff.deleted_at',
      ),
    );
  }

  factory SignOff.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for SignOff: contains complex types',
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String customerId;

  final _i3.String jobId;

  final _i3.int minutesConfirmed;

  /// Stroke list of the signature; typed by the sign-off issue in M5 (D-95).
  final _i3.List<_i3.Object?> signature;

  final _i3.DateTime signedAt;

  final _i3.String? signedBy;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'job_id': this.jobId,
    r'minutes_confirmed': this.minutesConfirmed,
    r'signature': this.signature
        .map((e) => _i1.encodeUnknownJson(e, context: r'SignOff.signature'))
        .toList(),
    r'signed_at': this.signedAt.toTimeZonedIso8601String(),
    r'signed_by': this.signedBy,
  };

  SignOff Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? jobId,
    _i3.int? minutesConfirmed,
    _i3.List<_i3.Object?>? signature,
    _i3.DateTime? signedAt,
    _i3.String? signedBy,
    _i3.DateTime? createdAt,
    _i3.String? createdBy,
    _i3.DateTime? updatedAt,
    _i3.String? updatedBy,
    _i3.int? revision,
    _i3.DateTime? deletedAt,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.Object? id = _sentinel,
      _i3.Object? workspaceId = _sentinel,
      _i3.String? customerId,
      _i3.String? jobId,
      _i3.int? minutesConfirmed,
      _i3.List<_i3.Object?>? signature,
      _i3.DateTime? signedAt,
      _i3.Object? signedBy = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => SignOff(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: customerId ?? this.customerId,
      jobId: jobId ?? this.jobId,
      minutesConfirmed: minutesConfirmed ?? this.minutesConfirmed,
      signature: signature ?? this.signature,
      signedAt: signedAt ?? this.signedAt,
      signedBy: _i3.identical(signedBy, _sentinel)
          ? this.signedBy
          : (signedBy as _i3.String?),
      createdAt: _i3.identical(createdAt, _sentinel)
          ? this.createdAt
          : (createdAt as _i3.DateTime?),
      createdBy: _i3.identical(createdBy, _sentinel)
          ? this.createdBy
          : (createdBy as _i3.String?),
      updatedAt: _i3.identical(updatedAt, _sentinel)
          ? this.updatedAt
          : (updatedAt as _i3.DateTime?),
      updatedBy: _i3.identical(updatedBy, _sentinel)
          ? this.updatedBy
          : (updatedBy as _i3.String?),
      revision: _i3.identical(revision, _sentinel)
          ? this.revision
          : (revision as _i3.int?),
      deletedAt: _i3.identical(deletedAt, _sentinel)
          ? this.deletedAt
          : (deletedAt as _i3.DateTime?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    const _$deepEquals = _i4.DeepCollectionEquality();
    return other is SignOff &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.jobId == this.jobId &&
        other.minutesConfirmed == this.minutesConfirmed &&
        _$deepEquals.equals(other.signature, this.signature) &&
        other.signedAt == this.signedAt &&
        other.signedBy == this.signedBy &&
        other.createdAt == this.createdAt &&
        other.createdBy == this.createdBy &&
        other.updatedAt == this.updatedAt &&
        other.updatedBy == this.updatedBy &&
        other.revision == this.revision &&
        other.deletedAt == this.deletedAt;
  }

  @_i3.override
  _i3.int get hashCode {
    const deepEquals = _i4.DeepCollectionEquality();
    return _i3.Object.hashAll([
      this.id,
      this.workspaceId,
      this.customerId,
      this.jobId,
      this.minutesConfirmed,
      deepEquals.hash(this.signature),
      this.signedAt,
      this.signedBy,
      this.createdAt,
      this.createdBy,
      this.updatedAt,
      this.updatedBy,
      this.revision,
      this.deletedAt,
    ]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) => throw _i1.EncodingException(
    r'parameterProperties not supported for SignOff: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode SignOff: complex types cannot be URI-encoded',
    );
  }
}
