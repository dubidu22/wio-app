// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i4;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;

@_i2.immutable
class WorkspaceRef extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const WorkspaceRef({required this.id, required this.name});

  factory WorkspaceRef.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'name'},
      listKeys: {},
      context: r'WorkspaceRef',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return WorkspaceRef(
      id: _$values[r'id'].decodeSimpleString(context: r'WorkspaceRef.id'),
      name: _$values[r'name'].decodeSimpleNullableString(
        context: r'WorkspaceRef.name',
      ),
    );
  }

  factory WorkspaceRef.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'WorkspaceRef');
    return WorkspaceRef(
      id: _$map[r'id'].decodeJsonString(context: r'WorkspaceRef.id'),
      name: _$map[r'name'].decodeJsonNullableString(
        context: r'WorkspaceRef.name',
      ),
    );
  }

  factory WorkspaceRef.fromForm(
    _i3.String? value, {
    required _i3.bool explode,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'name'},
      listKeys: {},
      context: r'WorkspaceRef',
    );
    return WorkspaceRef(
      id: _$values[r'id'].decodeFormString(context: r'WorkspaceRef.id'),
      name: _$values[r'name'].decodeFormNullableString(
        context: r'WorkspaceRef.name',
      ),
    );
  }

  final _i3.String id;

  final _i3.String? name;

  @_i3.override
  _i3.Object? toJson() => {r'id': this.id, r'name': this.name};

  WorkspaceRef Function({_i3.String? id, _i3.String? name}) get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({_i3.String? id, _i3.Object? name = _sentinel}) => WorkspaceRef(
      id: id ?? this.id,
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is WorkspaceRef &&
        other.id == this.id &&
        other.name == this.name;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.name]);
  }

  _i1.EncodingShape get currentEncodingShape => _i1.EncodingShape.complex;

  @_i3.override
  _i3.Map<_i3.String, _i1.PropertyValue> parameterProperties({
    _i3.bool allowEmpty = true,
  }) {
    final _$result = <_i3.String, _i1.PropertyValue>{};
    _$result[r'id'] = _i1.PropertyValue.scalar(this.id);
    if (this.name != null) {
      _$result[r'name'] = _i1.PropertyValue.scalar(this.name!);
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
      r'Cannot uriEncode WorkspaceRef: complex types cannot be URI-encoded',
    );
  }
}
