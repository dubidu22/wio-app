// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i6;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/note_subject_type_model.dart' as _i4;
import 'package:wio_api/src/model/note_transcript_source_model.dart' as _i5;

/// A `notes` record as sync pulls it (D-95).
@_i2.immutable
class Note extends _i1.ObjectParameterEncodable implements _i1.UriEncodable {
  const Note({
    required this.customerId,
    required this.subjectType,
    required this.subjectId,
    required this.text,
    required this.audioSha256,
    required this.audioBytes,
    required this.audioSeconds,
    required this.transcript,
    required this.transcriptSource,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Note.fromSimple(
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
        r'subject_type',
        r'subject_id',
        r'text',
        r'audio_sha256',
        r'audio_bytes',
        r'audio_seconds',
        r'transcript',
        r'transcript_source',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Note',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return Note(
      id: _$values[r'id'].decodeSimpleString(context: r'Note.id'),
      workspaceId: _$values[r'workspace_id'].decodeSimpleString(
        context: r'Note.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeSimpleNullableString(
        context: r'Note.customer_id',
      ),
      subjectType: _i4.NoteSubjectTypeModel.fromSimple(
        _$values[r'subject_type'],
        explode: explode,
      ),
      subjectId: _$values[r'subject_id'].decodeSimpleString(
        context: r'Note.subject_id',
      ),
      text: _$values[r'text'].decodeSimpleNullableString(context: r'Note.text'),
      audioSha256: _$values[r'audio_sha256'].decodeSimpleNullableString(
        context: r'Note.audio_sha256',
      ),
      audioBytes: _$values[r'audio_bytes'].decodeSimpleNullableInt(
        context: r'Note.audio_bytes',
      ),
      audioSeconds: _$values[r'audio_seconds'].decodeSimpleNullableInt(
        context: r'Note.audio_seconds',
      ),
      transcript: _$values[r'transcript'].decodeSimpleNullableString(
        context: r'Note.transcript',
      ),
      transcriptSource: _$values[r'transcript_source'] == null
          ? null
          : _i5.NoteTranscriptSourceModel.fromSimple(
              _$values[r'transcript_source'],
              explode: explode,
            ),
      createdAt: _$values[r'created_at'].decodeSimpleDateTime(
        context: r'Note.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeSimpleNullableString(
        context: r'Note.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeSimpleDateTime(
        context: r'Note.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeSimpleNullableString(
        context: r'Note.updated_by',
      ),
      revision: _$values[r'revision'].decodeSimpleInt(
        context: r'Note.revision',
      ),
      deletedAt: _$values[r'deleted_at'].decodeSimpleNullableDateTime(
        context: r'Note.deleted_at',
      ),
    );
  }

  factory Note.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Note');
    return Note(
      id: _$map[r'id'].decodeJsonString(context: r'Note.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Note.workspace_id',
      ),
      customerId: _$map[r'customer_id'].decodeJsonNullableString(
        context: r'Note.customer_id',
      ),
      subjectType: _i4.NoteSubjectTypeModel.fromJson(_$map[r'subject_type']),
      subjectId: _$map[r'subject_id'].decodeJsonString(
        context: r'Note.subject_id',
      ),
      text: _$map[r'text'].decodeJsonNullableString(context: r'Note.text'),
      audioSha256: _$map[r'audio_sha256'].decodeJsonNullableString(
        context: r'Note.audio_sha256',
      ),
      audioBytes: _$map[r'audio_bytes'].decodeJsonNullableInt(
        context: r'Note.audio_bytes',
      ),
      audioSeconds: _$map[r'audio_seconds'].decodeJsonNullableInt(
        context: r'Note.audio_seconds',
      ),
      transcript: _$map[r'transcript'].decodeJsonNullableString(
        context: r'Note.transcript',
      ),
      transcriptSource: _$map[r'transcript_source'] == null
          ? null
          : _i5.NoteTranscriptSourceModel.fromJson(_$map[r'transcript_source']),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Note.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Note.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Note.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Note.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Note.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Note.deleted_at',
      ),
    );
  }

  factory Note.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {
        r'id',
        r'workspace_id',
        r'customer_id',
        r'subject_type',
        r'subject_id',
        r'text',
        r'audio_sha256',
        r'audio_bytes',
        r'audio_seconds',
        r'transcript',
        r'transcript_source',
        r'created_at',
        r'created_by',
        r'updated_at',
        r'updated_by',
        r'revision',
        r'deleted_at',
      },
      listKeys: {},
      context: r'Note',
    );
    return Note(
      id: _$values[r'id'].decodeFormString(context: r'Note.id'),
      workspaceId: _$values[r'workspace_id'].decodeFormString(
        context: r'Note.workspace_id',
      ),
      customerId: _$values[r'customer_id'].decodeFormNullableString(
        context: r'Note.customer_id',
      ),
      subjectType: _i4.NoteSubjectTypeModel.fromForm(
        _$values[r'subject_type'],
        explode: explode,
      ),
      subjectId: _$values[r'subject_id'].decodeFormString(
        context: r'Note.subject_id',
      ),
      text: _$values[r'text'].decodeFormNullableString(context: r'Note.text'),
      audioSha256: _$values[r'audio_sha256'].decodeFormNullableString(
        context: r'Note.audio_sha256',
      ),
      audioBytes: _$values[r'audio_bytes'].decodeFormNullableInt(
        context: r'Note.audio_bytes',
      ),
      audioSeconds: _$values[r'audio_seconds'].decodeFormNullableInt(
        context: r'Note.audio_seconds',
      ),
      transcript: _$values[r'transcript'].decodeFormNullableString(
        context: r'Note.transcript',
      ),
      transcriptSource: _$values[r'transcript_source'] == null
          ? null
          : _i5.NoteTranscriptSourceModel.fromForm(
              _$values[r'transcript_source'],
              explode: explode,
            ),
      createdAt: _$values[r'created_at'].decodeFormDateTime(
        context: r'Note.created_at',
      ),
      createdBy: _$values[r'created_by'].decodeFormNullableString(
        context: r'Note.created_by',
      ),
      updatedAt: _$values[r'updated_at'].decodeFormDateTime(
        context: r'Note.updated_at',
      ),
      updatedBy: _$values[r'updated_by'].decodeFormNullableString(
        context: r'Note.updated_by',
      ),
      revision: _$values[r'revision'].decodeFormInt(context: r'Note.revision'),
      deletedAt: _$values[r'deleted_at'].decodeFormNullableDateTime(
        context: r'Note.deleted_at',
      ),
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? customerId;

  final _i4.NoteSubjectTypeModel subjectType;

  final _i3.String subjectId;

  final _i3.String? text;

  final _i3.String? audioSha256;

  final _i3.int? audioBytes;

  final _i3.int? audioSeconds;

  final _i3.String? transcript;

  final _i5.NoteTranscriptSourceModel? transcriptSource;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'customer_id': this.customerId,
    r'subject_type': this.subjectType.toJson(),
    r'subject_id': this.subjectId,
    r'text': this.text,
    r'audio_sha256': this.audioSha256,
    r'audio_bytes': this.audioBytes,
    r'audio_seconds': this.audioSeconds,
    r'transcript': this.transcript,
    r'transcript_source': this.transcriptSource?.toJson(),
  };

  Note Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? customerId,
    _i4.NoteSubjectTypeModel? subjectType,
    _i3.String? subjectId,
    _i3.String? text,
    _i3.String? audioSha256,
    _i3.int? audioBytes,
    _i3.int? audioSeconds,
    _i3.String? transcript,
    _i5.NoteTranscriptSourceModel? transcriptSource,
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
      _i4.NoteSubjectTypeModel? subjectType,
      _i3.String? subjectId,
      _i3.Object? text = _sentinel,
      _i3.Object? audioSha256 = _sentinel,
      _i3.Object? audioBytes = _sentinel,
      _i3.Object? audioSeconds = _sentinel,
      _i3.Object? transcript = _sentinel,
      _i3.Object? transcriptSource = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Note(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      customerId: _i3.identical(customerId, _sentinel)
          ? this.customerId
          : (customerId as _i3.String?),
      subjectType: subjectType ?? this.subjectType,
      subjectId: subjectId ?? this.subjectId,
      text: _i3.identical(text, _sentinel) ? this.text : (text as _i3.String?),
      audioSha256: _i3.identical(audioSha256, _sentinel)
          ? this.audioSha256
          : (audioSha256 as _i3.String?),
      audioBytes: _i3.identical(audioBytes, _sentinel)
          ? this.audioBytes
          : (audioBytes as _i3.int?),
      audioSeconds: _i3.identical(audioSeconds, _sentinel)
          ? this.audioSeconds
          : (audioSeconds as _i3.int?),
      transcript: _i3.identical(transcript, _sentinel)
          ? this.transcript
          : (transcript as _i3.String?),
      transcriptSource: _i3.identical(transcriptSource, _sentinel)
          ? this.transcriptSource
          : (transcriptSource as _i5.NoteTranscriptSourceModel?),
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
    return other is Note &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.customerId == this.customerId &&
        other.subjectType == this.subjectType &&
        other.subjectId == this.subjectId &&
        other.text == this.text &&
        other.audioSha256 == this.audioSha256 &&
        other.audioBytes == this.audioBytes &&
        other.audioSeconds == this.audioSeconds &&
        other.transcript == this.transcript &&
        other.transcriptSource == this.transcriptSource &&
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
      this.subjectType,
      this.subjectId,
      this.text,
      this.audioSha256,
      this.audioBytes,
      this.audioSeconds,
      this.transcript,
      this.transcriptSource,
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
    _$result[r'subject_type'] = _i1.PropertyValue.scalar(
      this.subjectType.toJson(),
    );
    _$result[r'subject_id'] = _i1.PropertyValue.scalar(this.subjectId);
    if (this.text != null) {
      _$result[r'text'] = _i1.PropertyValue.scalar(this.text!);
    }
    if (this.audioSha256 != null) {
      _$result[r'audio_sha256'] = _i1.PropertyValue.scalar(this.audioSha256!);
    }
    if (this.audioBytes != null) {
      _$result[r'audio_bytes'] = _i1.PropertyValue.scalar(
        this.audioBytes!.toString(),
      );
    }
    if (this.audioSeconds != null) {
      _$result[r'audio_seconds'] = _i1.PropertyValue.scalar(
        this.audioSeconds!.toString(),
      );
    }
    if (this.transcript != null) {
      _$result[r'transcript'] = _i1.PropertyValue.scalar(this.transcript!);
    }
    if (this.transcriptSource != null) {
      _$result[r'transcript_source'] = _i1.PropertyValue.scalar(
        this.transcriptSource!.toJson(),
      );
    }
    return _$result;
  }

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i6.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Note: complex types cannot be URI-encoded',
    );
  }
}
