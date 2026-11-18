// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `time_blocks` record as sync pulls it (D-95).
@_i2.immutable
class TimeBlock extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const TimeBlock({
    required this.customerId,
    required this.jobId,
    required this.startedAt,
    required this.endedAt,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory TimeBlock.fromSimple(
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
        r'job_id',
        r'started_at',
        r'ended_at',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'TimeBlock',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return TimeBlock(
      id: _$values[r'id'].decodeSimpleString(context: r'TimeBlock.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'TimeBlock.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleString(
        context: r'TimeBlock.customer_id',
      ),
      jobId: _$values[r'job_id'].decodeSimpleString(
        context: r'TimeBlock.job_id',
      ),
      startedAt: _$values[r'started_at'].decodeSimpleDateTime(
        context: r'TimeBlock.started_at',
      ),
      endedAt: _$values[r'ended_at'].decodeSimpleNullableDateTime(
        context: r'TimeBlock.ended_at',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'TimeBlock.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'TimeBlock.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'TimeBlock.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'TimeBlock.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'TimeBlock.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'TimeBlock.deleted_at',
      ),
    );
  }

  factory TimeBlock.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'TimeBlock');
    return TimeBlock(
      id: _$map[r'id'].decodeJsonString(context: r'TimeBlock.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'TimeBlock.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonString(
        context: r'TimeBlock.customer_id',
      ),
      jobId: _$map[r'job_id'].decodeJsonString(context: r'TimeBlock.job_id'),
      startedAt: _$map[r'started_at'].decodeJsonDateTime(
        context: r'TimeBlock.started_at',
      ),
      endedAt: _$map[r'ended_at'].decodeJsonNullableDateTime(
        context: r'TimeBlock.ended_at',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'TimeBlock.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'TimeBlock.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'TimeBlock.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'TimeBlock.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(
        context: r'TimeBlock.revision',
      ),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'TimeBlock.deleted_at',
      ),
    );
  }

  factory TimeBlock.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'job_id',
        r'started_at',
        r'ended_at',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'TimeBlock',
    );
    return TimeBlock(
      id: _$values[r'id'].decodeFormString(context: r'TimeBlock.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'TimeBlock.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormString(
        context: r'TimeBlock.customer_id',
      ),
      jobId: _$values[r'job_id'].decodeFormString(context: r'TimeBlock.job_id'),
      startedAt: _$values[r'started_at'].decodeFormDateTime(
        context: r'TimeBlock.started_at',
      ),
      endedAt: _$values[r'ended_at'].decodeFormNullableDateTime(
        context: r'TimeBlock.ended_at',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'TimeBlock.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'TimeBlock.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'TimeBlock.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'TimeBlock.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'TimeBlock.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'TimeBlock.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String customerId;

  final _i3.String jobId;

  final _i3.DateTime startedAt;

  final _i3.DateTime? endedAt;

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
    r'started_at': this.startedAt.toTimeZonedIso8601String(),
    r'ended_at': this.endedAt?.toTimeZonedIso8601String(),
  };

  TimeBlock Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? jobId,
    _i3.DateTime? startedAt,
    _i3.DateTime? endedAt,
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
      _i3.DateTime? startedAt,
      _i3.Object? endedAt = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => TimeBlock(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: customerId ?? this.customerId,
      jobId: jobId ?? this.jobId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: _i3.identical(endedAt, _sentinel)
          ? this.endedAt
          : (endedAt as _i3.DateTime?),
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
    return other is TimeBlock &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.jobId == this.jobId &&
        other.startedAt == this.startedAt &&
        other.endedAt == this.endedAt &&
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
      this.jobId,
      this.startedAt,
      this.endedAt,
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
    _$result[r'job_id'] = _i1.PropertyValue.scalar(this.jobId);
    _$result[r'started_at'] = _i1.PropertyValue.scalar(
      this.startedAt.toTimeZonedIso8601String(),
    );
    if (this.endedAt != null) {
      _$result[r'ended_at'] = _i1.PropertyValue.scalar(
        this.endedAt!.toTimeZonedIso8601String(),
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
      r'Cannot uriEncode TimeBlock: complex types cannot be URI-encoded',
    );
  }
}
