// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `jobs` record as sync pulls it (D-95).
@_i2.immutable
class Job extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Job({
    required this.customerId,
    required this.date,
    required this.agreedMinutes,
    required this.reportSentAt,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Job.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'date',
        r'agreed_minutes',
        r'report_sent_at',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Job',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Job(
      id: _$values[r'id'].decodeSimpleString(context: r'Job.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Job.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleString(
        context: r'Job.customer_id',
      ),
      date: _$values[r'date'].decodeSimpleDate(context: r'Job.date'),
      agreedMinutes: _$values[r'agreed_minutes'].decodeSimpleNullableInt(
        context: r'Job.agreed_minutes',
      ),
      reportSentAt: _$values[r'report_sent_at'].decodeSimpleNullableDateTime(
        context: r'Job.report_sent_at',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Job.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Job.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Job.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Job.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(context: r'Job.revision'),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Job.deleted_at',
      ),
    );
  }

  factory Job.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Job');
    return Job(
      id: _$map[r'id'].decodeJsonString(context: r'Job.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Job.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonString(
        context: r'Job.customer_id',
      ),
      date: _$map[r'date'].decodeJsonDate(context: r'Job.date'),
      agreedMinutes: _$map[r'agreed_minutes'].decodeJsonNullableInt(
        context: r'Job.agreed_minutes',
      ),
      reportSentAt: _$map[r'report_sent_at'].decodeJsonNullableDateTime(
        context: r'Job.report_sent_at',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Job.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Job.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Job.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Job.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Job.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Job.deleted_at',
      ),
    );
  }

  factory Job.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'date',
        r'agreed_minutes',
        r'report_sent_at',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Job',
    );
    return Job(
      id: _$values[r'id'].decodeFormString(context: r'Job.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Job.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormString(
        context: r'Job.customer_id',
      ),
      date: _$values[r'date'].decodeFormDate(context: r'Job.date'),
      agreedMinutes: _$values[r'agreed_minutes'].decodeFormNullableInt(
        context: r'Job.agreed_minutes',
      ),
      reportSentAt: _$values[r'report_sent_at'].decodeFormNullableDateTime(
        context: r'Job.report_sent_at',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Job.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Job.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Job.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Job.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(context: r'Job.revision'),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Job.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String customerId;

  final _i1.Date date;

  final _i3.int? agreedMinutes;

  final _i3.DateTime? reportSentAt;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'date': this.date.toJson(),
    r'agreed_minutes': this.agreedMinutes,
    r'report_sent_at': this.reportSentAt?.toTimeZonedIso8601String(),
  };

  Job Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i1.Date? date,
    _i3.int? agreedMinutes,
    _i3.DateTime? reportSentAt,
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
      _i1.Date? date,
      _i3.Object? agreedMinutes = _sentinel,
      _i3.Object? reportSentAt = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Job(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      agreedMinutes: _i3.identical(agreedMinutes, _sentinel)
          ? this.agreedMinutes
          : (agreedMinutes as _i3.int?),
      reportSentAt: _i3.identical(reportSentAt, _sentinel)
          ? this.reportSentAt
          : (reportSentAt as _i3.DateTime?),
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
    return other is Job &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.date == this.date &&
        other.agreedMinutes == this.agreedMinutes &&
        other.reportSentAt == this.reportSentAt &&
        other.createdAt == this.createdAt &&
        other.createdBy == this.createdBy &&
        other.updatedAt == this.updatedAt &&
        other.updatedBy == this.updatedBy &&
        other.revision == this.revision &&
        other.deletedAt == this.deletedAt;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([
      this.id,
      this.workspaceId,
      this.customerId,
      this.date,
      this.agreedMinutes,
      this.reportSentAt,
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
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'customer_id'] = _i1.PropertyValue.scalar(this.customerId);
    _$result[r'date'] = _i1.PropertyValue.scalar(this.date.toString());
    if (this.agreedMinutes != null) {
      _$result[r'agreed_minutes'] = _i1.PropertyValue.scalar(
        this.agreedMinutes!.toString(),
      );
    }
    if (this.reportSentAt != null) {
      _$result[r'report_sent_at'] = _i1.PropertyValue.scalar(
        this.reportSentAt!.toTimeZonedIso8601String(),
      );
    }
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
      r'Cannot uriEncode Job: complex types cannot be URI-encoded',
    );
  }
}
