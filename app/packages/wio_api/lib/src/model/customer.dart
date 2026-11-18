// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:collection/collection.dart' as _i4;
import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

/// A `customers` record as sync pulls it (D-95).
@_i2.immutable
class Customer extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const Customer({
    required this.name,
    required this.contact,
    required this.externalRef,
    this.id,
    this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
  });

  factory Customer.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    throw _i1.SimpleDecodingException(
      r'Simple encoding not supported for Customer: contains complex types',
    );
  }

  factory Customer.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'Customer');
    return Customer(
      id: _$map[r'id'].decodeJsonString(context: r'Customer.id'),
      workspaceId: _$map[r'workspace_id'].decodeJsonString(
        context: r'Customer.workspace_id',
      ),
      name: _$map[r'name'].decodeJsonNullableString(context: r'Customer.name'),
      contact: _$map[r'contact'].decodeJsonNullableMap(
        (v) => v,
        context: r'Customer.contact',
      ),
      externalRef: _$map[r'external_ref'].decodeJsonNullableString(
        context: r'Customer.external_ref',
      ),
      createdAt: _$map[r'created_at'].decodeJsonDateTime(
        context: r'Customer.created_at',
      ),
      createdBy: _$map[r'created_by'].decodeJsonNullableString(
        context: r'Customer.created_by',
      ),
      updatedAt: _$map[r'updated_at'].decodeJsonDateTime(
        context: r'Customer.updated_at',
      ),
      updatedBy: _$map[r'updated_by'].decodeJsonNullableString(
        context: r'Customer.updated_by',
      ),
      revision: _$map[r'revision'].decodeJsonInt(context: r'Customer.revision'),
      deletedAt: _$map[r'deleted_at'].decodeJsonNullableDateTime(
        context: r'Customer.deleted_at',
      ),
    );
  }

  factory Customer.fromForm(_i3.String? value, {required _i3.bool explode}) {
    throw _i1.FormDecodingException(
      r'Form encoding not supported for Customer: contains complex types',
    );
  }

  final _i3.String? id;

  final _i3.String? workspaceId;

  final _i3.String? name;

  /// Free-form contact details; typed by a later issue (D-95).
  final _i3.Map<_i3.String, _i3.Object?>? contact;

  final _i3.String? externalRef;

  final _i3.DateTime? createdAt;

  final _i3.String? createdBy;

  final _i3.DateTime? updatedAt;

  final _i3.String? updatedBy;

  final _i3.int? revision;

  final _i3.DateTime? deletedAt;

  @_i3.override
  _i3.Object? toJson() => {
    r'name': this.name,
    r'contact': this.contact?.map(
      (k, v) => _i3.MapEntry(
        k,
        _i1.encodeUnknownJson(v, context: r'Customer.contact'),
      ),
    ),
    r'external_ref': this.externalRef,
  };

  Customer Function({
    _i3.String? id,
    _i3.String? workspaceId,
    _i3.String? name,
    _i3.Map<_i3.String, _i3.Object?>? contact,
    _i3.String? externalRef,
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
      _i3.Object? name = _sentinel,
      _i3.Object? contact = _sentinel,
      _i3.Object? externalRef = _sentinel,
      _i3.Object? createdAt = _sentinel,
      _i3.Object? createdBy = _sentinel,
      _i3.Object? updatedAt = _sentinel,
      _i3.Object? updatedBy = _sentinel,
      _i3.Object? revision = _sentinel,
      _i3.Object? deletedAt = _sentinel,
    }) => Customer(
      id: _i3.identical(id, _sentinel) ? this.id : (id as _i3.String?),
      workspaceId: _i3.identical(workspaceId, _sentinel)
          ? this.workspaceId
          : (workspaceId as _i3.String?),
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
      contact: _i3.identical(contact, _sentinel)
          ? this.contact
          : (contact as _i3.Map<_i3.String, _i3.Object?>?),
      externalRef: _i3.identical(externalRef, _sentinel)
          ? this.externalRef
          : (externalRef as _i3.String?),
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
    return other is Customer &&
        other.id == this.id &&
        other.workspaceId == this.workspaceId &&
        other.name == this.name &&
        _$deepEquals.equals(other.contact, this.contact) &&
        other.externalRef == this.externalRef &&
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
      this.name,
      deepEquals.hash(this.contact),
      this.externalRef,
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
    r'parameterProperties not supported for Customer: contains complex types',
  );

  @_i3.override
  _i3.String uriEncode({
    required _i3.bool allowEmpty,
    required _i5.Encoding textEncoding,
    _i3.bool useQueryComponent = false,
    _i3.bool allowReserved = false,
  }) {
    throw _i1.EncodingException(
      r'Cannot uriEncode Customer: complex types cannot be URI-encoded',
    );
  }
}
