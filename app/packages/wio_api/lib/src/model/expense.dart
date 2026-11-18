// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `expenses` record as sync pulls it (D-95).
@_i2.immutable
class Expense extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Expense({
    required this.customerId,
    required this.jobId,
    required this.pictureId,
    required this.amountCents,
    required this.note,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Expense.fromSimple(
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
        r'picture_id',
        r'amount_cents',
        r'note',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Expense',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Expense(
      id: _$values[r'id'].decodeSimpleString(context: r'Expense.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Expense.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleString(
        context: r'Expense.customer_id',
      ),
      jobId: _$values[r'job_id'].decodeSimpleString(context: r'Expense.job_id'),
      pictureId: _$values[r'picture_id'].decodeSimpleNullableString(
        context: r'Expense.picture_id',
      ),
      amountCents: _$values[r'amount_cents'].decodeSimpleNullableInt(
        context: r'Expense.amount_cents',
      ),
      note: _$values[r'note'].decodeSimpleNullableString(
        context: r'Expense.note',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Expense.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Expense.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Expense.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Expense.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Expense.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Expense.deleted_at',
      ),
    );
  }

  factory Expense.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Expense');
    return Expense(
      id: _$map[r'id'].decodeJsonString(context: r'Expense.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Expense.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonString(
        context: r'Expense.customer_id',
      ),
      jobId: _$map[r'job_id'].decodeJsonString(context: r'Expense.job_id'),
      pictureId: _$map[r'picture_id'].decodeJsonNullableString(
        context: r'Expense.picture_id',
      ),
      amountCents: _$map[r'amount_cents'].decodeJsonNullableInt(
        context: r'Expense.amount_cents',
      ),
      note: _$map[r'note'].decodeJsonNullableString(context: r'Expense.note'),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Expense.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Expense.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Expense.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Expense.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Expense.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Expense.deleted_at',
      ),
    );
  }

  factory Expense.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'job_id',
        r'picture_id',
        r'amount_cents',
        r'note',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Expense',
    );
    return Expense(
      id: _$values[r'id'].decodeFormString(context: r'Expense.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Expense.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormString(
        context: r'Expense.customer_id',
      ),
      jobId: _$values[r'job_id'].decodeFormString(context: r'Expense.job_id'),
      pictureId: _$values[r'picture_id'].decodeFormNullableString(
        context: r'Expense.picture_id',
      ),
      amountCents: _$values[r'amount_cents'].decodeFormNullableInt(
        context: r'Expense.amount_cents',
      ),
      note: _$values[r'note'].decodeFormNullableString(
        context: r'Expense.note',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Expense.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Expense.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Expense.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Expense.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'Expense.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Expense.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String customerId;

  final _i3.String jobId;

  final _i3.String? pictureId;

  final _i3.int? amountCents;

  final _i3.String? note;

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
    r'picture_id': this.pictureId,
    r'amount_cents': this.amountCents,
    r'note': this.note,
  };

  Expense Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? jobId,
    _i3.String? pictureId,
    _i3.int? amountCents,
    _i3.String? note,
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
      _i3.Object? pictureId = _sentinel,
      _i3.Object? amountCents = _sentinel,
      _i3.Object? note = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Expense(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: customerId ?? this.customerId,
      jobId: jobId ?? this.jobId,
      pictureId: _i3.identical(pictureId, _sentinel)
          ? this.pictureId
          : (pictureId as _i3.String?),
      amountCents: _i3.identical(amountCents, _sentinel)
          ? this.amountCents
          : (amountCents as _i3.int?),
      note: _i3.identical(note, _sentinel) ? this.note : (note as _i3.String?),
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
    return other is Expense &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.jobId == this.jobId &&
        other.pictureId == this.pictureId &&
        other.amountCents == this.amountCents &&
        other.note == this.note &&
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
      this.pictureId,
      this.amountCents,
      this.note,
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
    if (this.pictureId != null) {
      _$result[r'picture_id'] = _i1.PropertyValue.scalar(this.pictureId!);
    }
    if (this.amountCents != null) {
      _$result[r'amount_cents'] = _i1.PropertyValue.scalar(
        this.amountCents!.toString(),
      );
    }
    if (this.note != null) {
      _$result[r'note'] = _i1.PropertyValue.scalar(this.note!);
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
      r'Cannot uriEncode Expense: complex types cannot be URI-encoded',
    );
  }
}
