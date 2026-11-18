// Generated code - do not modify by hand

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'dart:convert' as _i5;
import 'dart:core' as _i3;

import 'package:meta/meta.dart' as _i2;
import 'package:tonik_util/tonik_util.dart' as _i1;
import 'package:wio_api/src/model/me_workspace_plan_model.dart' as _i4;

@_i2.immutable
class MeWorkspace extends _i1.ObjectParameterEncodable
    implements _i1.UriEncodable {
  const MeWorkspace({required this.id, required this.name, required this.plan});

  factory MeWorkspace.fromSimple(
    _i3.String? value, {
    required _i3.bool explode,
    _i3.bool isHeader = false,
  }) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: ',',
      expectedKeys: {r'id', r'name', r'plan'},
      listKeys: {},
      context: r'MeWorkspace',
      isHeader: isHeader,
      percentDecodeKeys: false,
    );
    return MeWorkspace(
      id: _$values[r'id'].decodeSimpleString(context: r'MeWorkspace.id'),
      name: _$values[r'name'].decodeSimpleNullableString(
        context: r'MeWorkspace.name',
      ),
      plan: _i4.MeWorkspacePlanModel.fromSimple(
        _$values[r'plan'],
        explode: explode,
      ),
    );
  }

  factory MeWorkspace.fromJson(_i3.Object? json) {
    final _$map = json.decodeMap(context: r'MeWorkspace');
    return MeWorkspace(
      id: _$map[r'id'].decodeJsonString(context: r'MeWorkspace.id'),
      name: _$map[r'name'].decodeJsonNullableString(
        context: r'MeWorkspace.name',
      ),
      plan: _i4.MeWorkspacePlanModel.fromJson(_$map[r'plan']),
    );
  }

  factory MeWorkspace.fromForm(_i3.String? value, {required _i3.bool explode}) {
    final _$values = value.decodeObject(
      explode: explode,
      explodeSeparator: '&',
      expectedKeys: {r'id', r'name', r'plan'},
      listKeys: {},
      context: r'MeWorkspace',
    );
    return MeWorkspace(
      id: _$values[r'id'].decodeFormString(context: r'MeWorkspace.id'),
      name: _$values[r'name'].decodeFormNullableString(
        context: r'MeWorkspace.name',
      ),
      plan: _i4.MeWorkspacePlanModel.fromForm(
        _$values[r'plan'],
        explode: explode,
      ),
    );
  }

  final _i3.String id;

  final _i3.String? name;

  final _i4.MeWorkspacePlanModel plan;

  @_i3.override
  _i3.Object? toJson() => {
    r'id': this.id,
    r'name': this.name,
    r'plan': this.plan.toJson(),
  };

  MeWorkspace Function({
    _i3.String? id,
    _i3.String? name,
    _i4.MeWorkspacePlanModel? plan,
  })
  get copyWith {
    const _i3.Object _sentinel = _i3.Object();
    return ({
      _i3.String? id,
      _i3.Object? name = _sentinel,
      _i4.MeWorkspacePlanModel? plan,
    }) => MeWorkspace(
      id: id ?? this.id,
      name: _i3.identical(name, _sentinel) ? this.name : (name as _i3.String?),
      plan: plan ?? this.plan,
    );
  }

  @_i3.override
  _i3.bool operator ==(_i3.Object other) {
    if (_i3.identical(this, other)) return true;
    return other is MeWorkspace &&
        other.id == this.id &&
        other.name == this.name &&
        other.plan == this.plan;
  }

  @_i3.override
  _i3.int get hashCode {
    return _i3.Object.hashAll([this.id, this.name, this.plan]);
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
    _$result[r'plan'] = _i1.PropertyValue.scalar(this.plan.toJson());
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
      r'Cannot uriEncode MeWorkspace: complex types cannot be URI-encoded',
    );
  }
}
