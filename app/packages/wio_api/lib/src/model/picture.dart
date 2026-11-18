// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `pictures` record as sync pulls it (D-95).
@_i2.immutable
class Picture extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Picture({
    required this.customerId,
    required this.fileSha256,
    required this.fileBytes,
    required this.fileMime,
    required this.widthPx,
    required this.heightPx,
    required this.takenAt,
    required this.roomId,
    required this.entryId,
    required this.afterOf,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Picture.fromSimple(
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
        r'file_sha256',
        r'file_bytes',
        r'file_mime',
        r'width_px',
        r'height_px',
        r'taken_at',
        r'room_id',
        r'entry_id',
        r'after_of',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Picture',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Picture(
      id: _$values[r'id'].decodeSimpleString(context: r'Picture.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Picture.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'Picture.customer_id',
      ),
      fileSha256: _$values[r'file_sha256'].decodeSimpleString(
        context: r'Picture.file_sha256',
      ),
      fileBytes: _$values[r'file_bytes'].decodeSimpleInt(
        context: r'Picture.file_bytes',
      ),
      fileMime: _$values[r'file_mime'].decodeSimpleString(
        context: r'Picture.file_mime',
      ),
      widthPx: _$values[r'width_px'].decodeSimpleInt(
        context: r'Picture.width_px',
      ),
      heightPx: _$values[r'height_px'].decodeSimpleInt(
        context: r'Picture.height_px',
      ),
      takenAt: _$values[r'taken_at'].decodeSimpleNullableDateTime(
        context: r'Picture.taken_at',
      ),
      roomId: _$values[r'room_id'].decodeSimpleNullableString(
        context: r'Picture.room_id',
      ),
      entryId: _$values[r'entry_id'].decodeSimpleNullableString(
        context: r'Picture.entry_id',
      ),
      afterOf: _$values[r'after_of'].decodeSimpleNullableString(
        context: r'Picture.after_of',
      ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Picture.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Picture.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Picture.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Picture.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Picture.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Picture.deleted_at',
      ),
    );
  }

  factory Picture.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Picture');
    return Picture(
      id: _$map[r'id'].decodeJsonString(context: r'Picture.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Picture.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Picture.customer_id',
      ),
      fileSha256: _$map[r'file_sha256'].decodeJsonString(
        context: r'Picture.file_sha256',
      ),
      fileBytes: _$map[r'file_bytes'].decodeJsonInt(
        context: r'Picture.file_bytes',
      ),
      fileMime: _$map[r'file_mime'].decodeJsonString(
        context: r'Picture.file_mime',
      ),
      widthPx: _$map[r'width_px'].decodeJsonInt(context: r'Picture.width_px'),
      heightPx: _$map[r'height_px'].decodeJsonInt(
        context: r'Picture.height_px',
      ),
      takenAt: _$map[r'taken_at'].decodeJsonNullableDateTime(
        context: r'Picture.taken_at',
      ),
      roomId: _$map[r'room_id'].decodeJsonNullableString(
        context: r'Picture.room_id',
      ),
      entryId: _$map[r'entry_id'].decodeJsonNullableString(
        context: r'Picture.entry_id',
      ),
      afterOf: _$map[r'after_of'].decodeJsonNullableString(
        context: r'Picture.after_of',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Picture.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Picture.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Picture.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Picture.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Picture.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Picture.deleted_at',
      ),
    );
  }

  factory Picture.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'file_sha256',
        r'file_bytes',
        r'file_mime',
        r'width_px',
        r'height_px',
        r'taken_at',
        r'room_id',
        r'entry_id',
        r'after_of',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Picture',
    );
    return Picture(
      id: _$values[r'id'].decodeFormString(context: r'Picture.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Picture.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'Picture.customer_id',
      ),
      fileSha256: _$values[r'file_sha256'].decodeFormString(
        context: r'Picture.file_sha256',
      ),
      fileBytes: _$values[r'file_bytes'].decodeFormInt(
        context: r'Picture.file_bytes',
      ),
      fileMime: _$values[r'file_mime'].decodeFormString(
        context: r'Picture.file_mime',
      ),
      widthPx: _$values[r'width_px'].decodeFormInt(
        context: r'Picture.width_px',
      ),
      heightPx: _$values[r'height_px'].decodeFormInt(
        context: r'Picture.height_px',
      ),
      takenAt: _$values[r'taken_at'].decodeFormNullableDateTime(
        context: r'Picture.taken_at',
      ),
      roomId: _$values[r'room_id'].decodeFormNullableString(
        context: r'Picture.room_id',
      ),
      entryId: _$values[r'entry_id'].decodeFormNullableString(
        context: r'Picture.entry_id',
      ),
      afterOf: _$values[r'after_of'].decodeFormNullableString(
        context: r'Picture.after_of',
      ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Picture.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Picture.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Picture.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Picture.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(
        context: r'Picture.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Picture.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i3.String fileSha256;

  final _i3.int fileBytes;

  final _i3.String fileMime;

  final _i3.int widthPx;

  final _i3.int heightPx;

  final _i3.DateTime? takenAt;

  final _i3.String? roomId;

  final _i3.String? entryId;

  final _i3.String? afterOf;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'file_sha256': this.fileSha256,
    r'file_bytes': this.fileBytes,
    r'file_mime': this.fileMime,
    r'width_px': this.widthPx,
    r'height_px': this.heightPx,
    r'taken_at': this.takenAt?.toTimeZonedIso8601String(),
    r'room_id': this.roomId,
    r'entry_id': this.entryId,
    r'after_of': this.afterOf,
  };

  Picture Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i3.String? fileSha256,
    _i3.int? fileBytes,
    _i3.String? fileMime,
    _i3.int? widthPx,
    _i3.int? heightPx,
    _i3.DateTime? takenAt,
    _i3.String? roomId,
    _i3.String? entryId,
    _i3.String? afterOf,
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
      _i3.Object? customerId = _sentinel,
      _i3.String? fileSha256,
      _i3.int? fileBytes,
      _i3.String? fileMime,
      _i3.int? widthPx,
      _i3.int? heightPx,
      _i3.Object? takenAt = _sentinel,
      _i3.Object? roomId = _sentinel,
      _i3.Object? entryId = _sentinel,
      _i3.Object? afterOf = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Picture(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      fileSha256: fileSha256 ?? this.fileSha256,
      fileBytes: fileBytes ?? this.fileBytes,
      fileMime: fileMime ?? this.fileMime,
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
      takenAt: _i3.identical(takenAt, _sentinel)
          ? this.takenAt
          : (takenAt as _i3.DateTime?),
      roomId: _i3.identical(roomId, _sentinel)
          ? this.roomId
          : (roomId as _i3.String?),
      entryId: _i3.identical(entryId, _sentinel)
          ? this.entryId
          : (entryId as _i3.String?),
      afterOf: _i3.identical(afterOf, _sentinel)
          ? this.afterOf
          : (afterOf as _i3.String?),
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
    return other is Picture &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.fileSha256 == this.fileSha256 &&
        other.fileBytes == this.fileBytes &&
        other.fileMime == this.fileMime &&
        other.widthPx == this.widthPx &&
        other.heightPx == this.heightPx &&
        other.takenAt == this.takenAt &&
        other.roomId == this.roomId &&
        other.entryId == this.entryId &&
        other.afterOf == this.afterOf &&
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
      this.fileSha256,
      this.fileBytes,
      this.fileMime,
      this.widthPx,
      this.heightPx,
      this.takenAt,
      this.roomId,
      this.entryId,
      this.afterOf,
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
    if (this.customerId != null) {
      _$result[r'customer_id'] = _i1.PropertyValue.scalar(this.customerId!);
    }
    _$result[r'file_sha256'] = _i1.PropertyValue.scalar(this.fileSha256);
    _$result[r'file_bytes'] = _i1.PropertyValue.scalar(
      this.fileBytes.toString(),
    );
    _$result[r'file_mime'] = _i1.PropertyValue.scalar(this.fileMime);
    _$result[r'width_px'] = _i1.PropertyValue.scalar(this.widthPx.toString());
    _$result[r'height_px'] = _i1.PropertyValue.scalar(this.heightPx.toString());
    if (this.takenAt != null) {
      _$result[r'taken_at'] = _i1.PropertyValue.scalar(
        this.takenAt!.toTimeZonedIso8601String(),
      );
    }
    if (this.roomId != null) {
      _$result[r'room_id'] = _i1.PropertyValue.scalar(this.roomId!);
    }
    if (this.entryId != null) {
      _$result[r'entry_id'] = _i1.PropertyValue.scalar(this.entryId!);
    }
    if (this.afterOf != null) {
      _$result[r'after_of'] = _i1.PropertyValue.scalar(this.afterOf!);
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
      r'Cannot uriEncode Picture: complex types cannot be URI-encoded',
    );
  }
}
