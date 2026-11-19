// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contactMeta = const VerificationMeta(
    'contact',
  );
  @override
  late final GeneratedColumn<String> contact = GeneratedColumn<String>(
    'contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _externalRefMeta = const VerificationMeta(
    'externalRef',
  );
  @override
  late final GeneratedColumn<String> externalRef = GeneratedColumn<String>(
    'external_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    name,
    contact,
    externalRef,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('contact')) {
      context.handle(
        _contactMeta,
        contact.isAcceptableOrUnknown(data['contact']!, _contactMeta),
      );
    }
    if (data.containsKey('external_ref')) {
      context.handle(
        _externalRefMeta,
        externalRef.isAcceptableOrUnknown(
          data['external_ref']!,
          _externalRefMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      contact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact'],
      ),
      externalRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_ref'],
      ),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? name;

  /// JSON object as text.
  final String? contact;
  final String? externalRef;
  const Customer({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.name,
    this.contact,
    this.externalRef,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || contact != null) {
      map['contact'] = Variable<String>(contact);
    }
    if (!nullToAbsent || externalRef != null) {
      map['external_ref'] = Variable<String>(externalRef);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      contact: contact == null && nullToAbsent
          ? const Value.absent()
          : Value(contact),
      externalRef: externalRef == null && nullToAbsent
          ? const Value.absent()
          : Value(externalRef),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String?>(json['name']),
      contact: serializer.fromJson<String?>(json['contact']),
      externalRef: serializer.fromJson<String?>(json['externalRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String?>(name),
      'contact': serializer.toJson<String?>(contact),
      'externalRef': serializer.toJson<String?>(externalRef),
    };
  }

  Customer copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> contact = const Value.absent(),
    Value<String?> externalRef = const Value.absent(),
  }) => Customer(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name.present ? name.value : this.name,
    contact: contact.present ? contact.value : this.contact,
    externalRef: externalRef.present ? externalRef.value : this.externalRef,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      contact: data.contact.present ? data.contact.value : this.contact,
      externalRef: data.externalRef.present
          ? data.externalRef.value
          : this.externalRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('externalRef: $externalRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    name,
    contact,
    externalRef,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.contact == this.contact &&
          other.externalRef == this.externalRef);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> name;
  final Value<String?> contact;
  final Value<String?> externalRef;
  final Value<int> rowid;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.contact = const Value.absent(),
    this.externalRef = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId);
  static Insertable<Customer> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? contact,
    Expression<String>? externalRef,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (contact != null) 'contact': contact,
      if (externalRef != null) 'external_ref': externalRef,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? name,
    Value<String?>? contact,
    Value<String?>? externalRef,
    Value<int>? rowid,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      externalRef: externalRef ?? this.externalRef,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contact.present) {
      map['contact'] = Variable<String>(contact.value);
    }
    if (externalRef.present) {
      map['external_ref'] = Variable<String>(externalRef.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('contact: $contact, ')
          ..write('externalRef: $externalRef, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SitesTable extends Sites with TableInfo<$SitesTable, Site> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SitesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    name,
    address,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sites';
  @override
  VerificationContext validateIntegrity(
    Insertable<Site> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Site map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Site(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
    );
  }

  @override
  $SitesTable createAlias(String alias) {
    return $SitesTable(attachedDatabase, alias);
  }
}

class Site extends DataClass implements Insertable<Site> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;
  final String? name;
  final String? address;
  const Site({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    this.name,
    this.address,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    return map;
  }

  SitesCompanion toCompanion(bool nullToAbsent) {
    return SitesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
    );
  }

  factory Site.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Site(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      name: serializer.fromJson<String?>(json['name']),
      address: serializer.fromJson<String?>(json['address']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'name': serializer.toJson<String?>(name),
      'address': serializer.toJson<String?>(address),
    };
  }

  Site copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    Value<String?> name = const Value.absent(),
    Value<String?> address = const Value.absent(),
  }) => Site(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    name: name.present ? name.value : this.name,
    address: address.present ? address.value : this.address,
  );
  Site copyWithCompanion(SitesCompanion data) {
    return Site(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      name: data.name.present ? data.name.value : this.name,
      address: data.address.present ? data.address.value : this.address,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Site(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('address: $address')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    name,
    address,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Site &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.name == this.name &&
          other.address == this.address);
}

class SitesCompanion extends UpdateCompanion<Site> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String?> name;
  final Value<String?> address;
  final Value<int> rowid;
  const SitesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SitesCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.name = const Value.absent(),
    this.address = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId);
  static Insertable<Site> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? name,
    Expression<String>? address,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (name != null) 'name': name,
      if (address != null) 'address': address,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SitesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String?>? name,
    Value<String?>? address,
    Value<int>? rowid,
  }) {
    return SitesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      address: address ?? this.address,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SitesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('name: $name, ')
          ..write('address: $address, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoomsTable extends Rooms with TableInfo<$RoomsTable, Room> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _outlineMeta = const VerificationMeta(
    'outline',
  );
  @override
  late final GeneratedColumn<String> outline = GeneratedColumn<String>(
    'outline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightCmMeta = const VerificationMeta(
    'heightCm',
  );
  @override
  late final GeneratedColumn<int> heightCm = GeneratedColumn<int>(
    'height_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    siteId,
    name,
    outline,
    heightCm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rooms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Room> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_siteIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('outline')) {
      context.handle(
        _outlineMeta,
        outline.isAcceptableOrUnknown(data['outline']!, _outlineMeta),
      );
    }
    if (data.containsKey('height_cm')) {
      context.handle(
        _heightCmMeta,
        heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Room map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Room(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      outline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}outline'],
      ),
      heightCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_cm'],
      ),
    );
  }

  @override
  $RoomsTable createAlias(String alias) {
    return $RoomsTable(attachedDatabase, alias);
  }
}

class Room extends DataClass implements Insertable<Room> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;
  final String siteId;
  final String? name;

  /// Corner points in cm as a JSON list.
  final String? outline;
  final int? heightCm;
  const Room({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    required this.siteId,
    this.name,
    this.outline,
    this.heightCm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['site_id'] = Variable<String>(siteId);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || outline != null) {
      map['outline'] = Variable<String>(outline);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<int>(heightCm);
    }
    return map;
  }

  RoomsCompanion toCompanion(bool nullToAbsent) {
    return RoomsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      siteId: Value(siteId),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      outline: outline == null && nullToAbsent
          ? const Value.absent()
          : Value(outline),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
    );
  }

  factory Room.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Room(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      siteId: serializer.fromJson<String>(json['siteId']),
      name: serializer.fromJson<String?>(json['name']),
      outline: serializer.fromJson<String?>(json['outline']),
      heightCm: serializer.fromJson<int?>(json['heightCm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'siteId': serializer.toJson<String>(siteId),
      'name': serializer.toJson<String?>(name),
      'outline': serializer.toJson<String?>(outline),
      'heightCm': serializer.toJson<int?>(heightCm),
    };
  }

  Room copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? siteId,
    Value<String?> name = const Value.absent(),
    Value<String?> outline = const Value.absent(),
    Value<int?> heightCm = const Value.absent(),
  }) => Room(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    siteId: siteId ?? this.siteId,
    name: name.present ? name.value : this.name,
    outline: outline.present ? outline.value : this.outline,
    heightCm: heightCm.present ? heightCm.value : this.heightCm,
  );
  Room copyWithCompanion(RoomsCompanion data) {
    return Room(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      name: data.name.present ? data.name.value : this.name,
      outline: data.outline.present ? data.outline.value : this.outline,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Room(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('outline: $outline, ')
          ..write('heightCm: $heightCm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    siteId,
    name,
    outline,
    heightCm,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Room &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.siteId == this.siteId &&
          other.name == this.name &&
          other.outline == this.outline &&
          other.heightCm == this.heightCm);
}

class RoomsCompanion extends UpdateCompanion<Room> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String> siteId;
  final Value<String?> name;
  final Value<String?> outline;
  final Value<int?> heightCm;
  final Value<int> rowid;
  const RoomsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.siteId = const Value.absent(),
    this.name = const Value.absent(),
    this.outline = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoomsCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    required String siteId,
    this.name = const Value.absent(),
    this.outline = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       siteId = Value(siteId);
  static Insertable<Room> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? siteId,
    Expression<String>? name,
    Expression<String>? outline,
    Expression<int>? heightCm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (siteId != null) 'site_id': siteId,
      if (name != null) 'name': name,
      if (outline != null) 'outline': outline,
      if (heightCm != null) 'height_cm': heightCm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoomsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String>? siteId,
    Value<String?>? name,
    Value<String?>? outline,
    Value<int?>? heightCm,
    Value<int>? rowid,
  }) {
    return RoomsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      siteId: siteId ?? this.siteId,
      name: name ?? this.name,
      outline: outline ?? this.outline,
      heightCm: heightCm ?? this.heightCm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (outline.present) {
      map['outline'] = Variable<String>(outline.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<int>(heightCm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoomsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('siteId: $siteId, ')
          ..write('name: $name, ')
          ..write('outline: $outline, ')
          ..write('heightCm: $heightCm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JobsTable extends Jobs with TableInfo<$JobsTable, Job> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _agreedMinutesMeta = const VerificationMeta(
    'agreedMinutes',
  );
  @override
  late final GeneratedColumn<int> agreedMinutes = GeneratedColumn<int>(
    'agreed_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reportSentAtMeta = const VerificationMeta(
    'reportSentAt',
  );
  @override
  late final GeneratedColumn<String> reportSentAt = GeneratedColumn<String>(
    'report_sent_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    date,
    agreedMinutes,
    reportSentAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<Job> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('agreed_minutes')) {
      context.handle(
        _agreedMinutesMeta,
        agreedMinutes.isAcceptableOrUnknown(
          data['agreed_minutes']!,
          _agreedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('report_sent_at')) {
      context.handle(
        _reportSentAtMeta,
        reportSentAt.isAcceptableOrUnknown(
          data['report_sent_at']!,
          _reportSentAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Job map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Job(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      agreedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}agreed_minutes'],
      ),
      reportSentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}report_sent_at'],
      ),
    );
  }

  @override
  $JobsTable createAlias(String alias) {
    return $JobsTable(attachedDatabase, alias);
  }
}

class Job extends DataClass implements Insertable<Job> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String customerId;

  /// Local calendar date, `YYYY-MM-DD`.
  final String date;
  final int? agreedMinutes;
  final String? reportSentAt;
  const Job({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    required this.customerId,
    required this.date,
    this.agreedMinutes,
    this.reportSentAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['customer_id'] = Variable<String>(customerId);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || agreedMinutes != null) {
      map['agreed_minutes'] = Variable<int>(agreedMinutes);
    }
    if (!nullToAbsent || reportSentAt != null) {
      map['report_sent_at'] = Variable<String>(reportSentAt);
    }
    return map;
  }

  JobsCompanion toCompanion(bool nullToAbsent) {
    return JobsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: Value(customerId),
      date: Value(date),
      agreedMinutes: agreedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(agreedMinutes),
      reportSentAt: reportSentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(reportSentAt),
    );
  }

  factory Job.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Job(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String>(json['customerId']),
      date: serializer.fromJson<String>(json['date']),
      agreedMinutes: serializer.fromJson<int?>(json['agreedMinutes']),
      reportSentAt: serializer.fromJson<String?>(json['reportSentAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String>(customerId),
      'date': serializer.toJson<String>(date),
      'agreedMinutes': serializer.toJson<int?>(agreedMinutes),
      'reportSentAt': serializer.toJson<String?>(reportSentAt),
    };
  }

  Job copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    String? customerId,
    String? date,
    Value<int?> agreedMinutes = const Value.absent(),
    Value<String?> reportSentAt = const Value.absent(),
  }) => Job(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId ?? this.customerId,
    date: date ?? this.date,
    agreedMinutes: agreedMinutes.present
        ? agreedMinutes.value
        : this.agreedMinutes,
    reportSentAt: reportSentAt.present ? reportSentAt.value : this.reportSentAt,
  );
  Job copyWithCompanion(JobsCompanion data) {
    return Job(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      date: data.date.present ? data.date.value : this.date,
      agreedMinutes: data.agreedMinutes.present
          ? data.agreedMinutes.value
          : this.agreedMinutes,
      reportSentAt: data.reportSentAt.present
          ? data.reportSentAt.value
          : this.reportSentAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Job(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('date: $date, ')
          ..write('agreedMinutes: $agreedMinutes, ')
          ..write('reportSentAt: $reportSentAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    date,
    agreedMinutes,
    reportSentAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Job &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.date == this.date &&
          other.agreedMinutes == this.agreedMinutes &&
          other.reportSentAt == this.reportSentAt);
}

class JobsCompanion extends UpdateCompanion<Job> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String> customerId;
  final Value<String> date;
  final Value<int?> agreedMinutes;
  final Value<String?> reportSentAt;
  final Value<int> rowid;
  const JobsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.date = const Value.absent(),
    this.agreedMinutes = const Value.absent(),
    this.reportSentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JobsCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String customerId,
    required String date,
    this.agreedMinutes = const Value.absent(),
    this.reportSentAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       customerId = Value(customerId),
       date = Value(date);
  static Insertable<Job> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? date,
    Expression<int>? agreedMinutes,
    Expression<String>? reportSentAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (date != null) 'date': date,
      if (agreedMinutes != null) 'agreed_minutes': agreedMinutes,
      if (reportSentAt != null) 'report_sent_at': reportSentAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JobsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String>? customerId,
    Value<String>? date,
    Value<int?>? agreedMinutes,
    Value<String?>? reportSentAt,
    Value<int>? rowid,
  }) {
    return JobsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      agreedMinutes: agreedMinutes ?? this.agreedMinutes,
      reportSentAt: reportSentAt ?? this.reportSentAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (agreedMinutes.present) {
      map['agreed_minutes'] = Variable<int>(agreedMinutes.value);
    }
    if (reportSentAt.present) {
      map['report_sent_at'] = Variable<String>(reportSentAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JobsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('date: $date, ')
          ..write('agreedMinutes: $agreedMinutes, ')
          ..write('reportSentAt: $reportSentAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PicturesTable extends Pictures with TableInfo<$PicturesTable, Picture> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PicturesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileSha256Meta = const VerificationMeta(
    'fileSha256',
  );
  @override
  late final GeneratedColumn<String> fileSha256 = GeneratedColumn<String>(
    'file_sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileBytesMeta = const VerificationMeta(
    'fileBytes',
  );
  @override
  late final GeneratedColumn<int> fileBytes = GeneratedColumn<int>(
    'file_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileMimeMeta = const VerificationMeta(
    'fileMime',
  );
  @override
  late final GeneratedColumn<String> fileMime = GeneratedColumn<String>(
    'file_mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthPxMeta = const VerificationMeta(
    'widthPx',
  );
  @override
  late final GeneratedColumn<int> widthPx = GeneratedColumn<int>(
    'width_px',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightPxMeta = const VerificationMeta(
    'heightPx',
  );
  @override
  late final GeneratedColumn<int> heightPx = GeneratedColumn<int>(
    'height_px',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _takenAtMeta = const VerificationMeta(
    'takenAt',
  );
  @override
  late final GeneratedColumn<String> takenAt = GeneratedColumn<String>(
    'taken_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterOfMeta = const VerificationMeta(
    'afterOf',
  );
  @override
  late final GeneratedColumn<String> afterOf = GeneratedColumn<String>(
    'after_of',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    fileSha256,
    fileBytes,
    fileMime,
    widthPx,
    heightPx,
    takenAt,
    roomId,
    entryId,
    afterOf,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pictures';
  @override
  VerificationContext validateIntegrity(
    Insertable<Picture> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('file_sha256')) {
      context.handle(
        _fileSha256Meta,
        fileSha256.isAcceptableOrUnknown(data['file_sha256']!, _fileSha256Meta),
      );
    } else if (isInserting) {
      context.missing(_fileSha256Meta);
    }
    if (data.containsKey('file_bytes')) {
      context.handle(
        _fileBytesMeta,
        fileBytes.isAcceptableOrUnknown(data['file_bytes']!, _fileBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_fileBytesMeta);
    }
    if (data.containsKey('file_mime')) {
      context.handle(
        _fileMimeMeta,
        fileMime.isAcceptableOrUnknown(data['file_mime']!, _fileMimeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileMimeMeta);
    }
    if (data.containsKey('width_px')) {
      context.handle(
        _widthPxMeta,
        widthPx.isAcceptableOrUnknown(data['width_px']!, _widthPxMeta),
      );
    } else if (isInserting) {
      context.missing(_widthPxMeta);
    }
    if (data.containsKey('height_px')) {
      context.handle(
        _heightPxMeta,
        heightPx.isAcceptableOrUnknown(data['height_px']!, _heightPxMeta),
      );
    } else if (isInserting) {
      context.missing(_heightPxMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(
        _takenAtMeta,
        takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    }
    if (data.containsKey('after_of')) {
      context.handle(
        _afterOfMeta,
        afterOf.isAcceptableOrUnknown(data['after_of']!, _afterOfMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Picture map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Picture(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      fileSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_sha256'],
      )!,
      fileBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_bytes'],
      )!,
      fileMime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_mime'],
      )!,
      widthPx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width_px'],
      )!,
      heightPx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_px'],
      )!,
      takenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}taken_at'],
      ),
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      ),
      afterOf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_of'],
      ),
    );
  }

  @override
  $PicturesTable createAlias(String alias) {
    return $PicturesTable(attachedDatabase, alias);
  }
}

class Picture extends DataClass implements Insertable<Picture> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;
  final String fileSha256;
  final int fileBytes;
  final String fileMime;
  final int widthPx;
  final int heightPx;

  /// Device time, information only.
  final String? takenAt;
  final String? roomId;
  final String? entryId;

  /// The picture this one is the after picture of (D-7).
  final String? afterOf;
  const Picture({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    required this.fileSha256,
    required this.fileBytes,
    required this.fileMime,
    required this.widthPx,
    required this.heightPx,
    this.takenAt,
    this.roomId,
    this.entryId,
    this.afterOf,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['file_sha256'] = Variable<String>(fileSha256);
    map['file_bytes'] = Variable<int>(fileBytes);
    map['file_mime'] = Variable<String>(fileMime);
    map['width_px'] = Variable<int>(widthPx);
    map['height_px'] = Variable<int>(heightPx);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<String>(takenAt);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || entryId != null) {
      map['entry_id'] = Variable<String>(entryId);
    }
    if (!nullToAbsent || afterOf != null) {
      map['after_of'] = Variable<String>(afterOf);
    }
    return map;
  }

  PicturesCompanion toCompanion(bool nullToAbsent) {
    return PicturesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      fileSha256: Value(fileSha256),
      fileBytes: Value(fileBytes),
      fileMime: Value(fileMime),
      widthPx: Value(widthPx),
      heightPx: Value(heightPx),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      entryId: entryId == null && nullToAbsent
          ? const Value.absent()
          : Value(entryId),
      afterOf: afterOf == null && nullToAbsent
          ? const Value.absent()
          : Value(afterOf),
    );
  }

  factory Picture.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Picture(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      fileSha256: serializer.fromJson<String>(json['fileSha256']),
      fileBytes: serializer.fromJson<int>(json['fileBytes']),
      fileMime: serializer.fromJson<String>(json['fileMime']),
      widthPx: serializer.fromJson<int>(json['widthPx']),
      heightPx: serializer.fromJson<int>(json['heightPx']),
      takenAt: serializer.fromJson<String?>(json['takenAt']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      entryId: serializer.fromJson<String?>(json['entryId']),
      afterOf: serializer.fromJson<String?>(json['afterOf']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'fileSha256': serializer.toJson<String>(fileSha256),
      'fileBytes': serializer.toJson<int>(fileBytes),
      'fileMime': serializer.toJson<String>(fileMime),
      'widthPx': serializer.toJson<int>(widthPx),
      'heightPx': serializer.toJson<int>(heightPx),
      'takenAt': serializer.toJson<String?>(takenAt),
      'roomId': serializer.toJson<String?>(roomId),
      'entryId': serializer.toJson<String?>(entryId),
      'afterOf': serializer.toJson<String?>(afterOf),
    };
  }

  Picture copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? fileSha256,
    int? fileBytes,
    String? fileMime,
    int? widthPx,
    int? heightPx,
    Value<String?> takenAt = const Value.absent(),
    Value<String?> roomId = const Value.absent(),
    Value<String?> entryId = const Value.absent(),
    Value<String?> afterOf = const Value.absent(),
  }) => Picture(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    fileSha256: fileSha256 ?? this.fileSha256,
    fileBytes: fileBytes ?? this.fileBytes,
    fileMime: fileMime ?? this.fileMime,
    widthPx: widthPx ?? this.widthPx,
    heightPx: heightPx ?? this.heightPx,
    takenAt: takenAt.present ? takenAt.value : this.takenAt,
    roomId: roomId.present ? roomId.value : this.roomId,
    entryId: entryId.present ? entryId.value : this.entryId,
    afterOf: afterOf.present ? afterOf.value : this.afterOf,
  );
  Picture copyWithCompanion(PicturesCompanion data) {
    return Picture(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      fileSha256: data.fileSha256.present
          ? data.fileSha256.value
          : this.fileSha256,
      fileBytes: data.fileBytes.present ? data.fileBytes.value : this.fileBytes,
      fileMime: data.fileMime.present ? data.fileMime.value : this.fileMime,
      widthPx: data.widthPx.present ? data.widthPx.value : this.widthPx,
      heightPx: data.heightPx.present ? data.heightPx.value : this.heightPx,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      afterOf: data.afterOf.present ? data.afterOf.value : this.afterOf,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Picture(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('fileSha256: $fileSha256, ')
          ..write('fileBytes: $fileBytes, ')
          ..write('fileMime: $fileMime, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('takenAt: $takenAt, ')
          ..write('roomId: $roomId, ')
          ..write('entryId: $entryId, ')
          ..write('afterOf: $afterOf')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    fileSha256,
    fileBytes,
    fileMime,
    widthPx,
    heightPx,
    takenAt,
    roomId,
    entryId,
    afterOf,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Picture &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.fileSha256 == this.fileSha256 &&
          other.fileBytes == this.fileBytes &&
          other.fileMime == this.fileMime &&
          other.widthPx == this.widthPx &&
          other.heightPx == this.heightPx &&
          other.takenAt == this.takenAt &&
          other.roomId == this.roomId &&
          other.entryId == this.entryId &&
          other.afterOf == this.afterOf);
}

class PicturesCompanion extends UpdateCompanion<Picture> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String> fileSha256;
  final Value<int> fileBytes;
  final Value<String> fileMime;
  final Value<int> widthPx;
  final Value<int> heightPx;
  final Value<String?> takenAt;
  final Value<String?> roomId;
  final Value<String?> entryId;
  final Value<String?> afterOf;
  final Value<int> rowid;
  const PicturesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.fileSha256 = const Value.absent(),
    this.fileBytes = const Value.absent(),
    this.fileMime = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.roomId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.afterOf = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PicturesCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    required String fileSha256,
    required int fileBytes,
    required String fileMime,
    required int widthPx,
    required int heightPx,
    this.takenAt = const Value.absent(),
    this.roomId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.afterOf = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       fileSha256 = Value(fileSha256),
       fileBytes = Value(fileBytes),
       fileMime = Value(fileMime),
       widthPx = Value(widthPx),
       heightPx = Value(heightPx);
  static Insertable<Picture> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? fileSha256,
    Expression<int>? fileBytes,
    Expression<String>? fileMime,
    Expression<int>? widthPx,
    Expression<int>? heightPx,
    Expression<String>? takenAt,
    Expression<String>? roomId,
    Expression<String>? entryId,
    Expression<String>? afterOf,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (fileSha256 != null) 'file_sha256': fileSha256,
      if (fileBytes != null) 'file_bytes': fileBytes,
      if (fileMime != null) 'file_mime': fileMime,
      if (widthPx != null) 'width_px': widthPx,
      if (heightPx != null) 'height_px': heightPx,
      if (takenAt != null) 'taken_at': takenAt,
      if (roomId != null) 'room_id': roomId,
      if (entryId != null) 'entry_id': entryId,
      if (afterOf != null) 'after_of': afterOf,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PicturesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String>? fileSha256,
    Value<int>? fileBytes,
    Value<String>? fileMime,
    Value<int>? widthPx,
    Value<int>? heightPx,
    Value<String?>? takenAt,
    Value<String?>? roomId,
    Value<String?>? entryId,
    Value<String?>? afterOf,
    Value<int>? rowid,
  }) {
    return PicturesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      fileSha256: fileSha256 ?? this.fileSha256,
      fileBytes: fileBytes ?? this.fileBytes,
      fileMime: fileMime ?? this.fileMime,
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
      takenAt: takenAt ?? this.takenAt,
      roomId: roomId ?? this.roomId,
      entryId: entryId ?? this.entryId,
      afterOf: afterOf ?? this.afterOf,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (fileSha256.present) {
      map['file_sha256'] = Variable<String>(fileSha256.value);
    }
    if (fileBytes.present) {
      map['file_bytes'] = Variable<int>(fileBytes.value);
    }
    if (fileMime.present) {
      map['file_mime'] = Variable<String>(fileMime.value);
    }
    if (widthPx.present) {
      map['width_px'] = Variable<int>(widthPx.value);
    }
    if (heightPx.present) {
      map['height_px'] = Variable<int>(heightPx.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<String>(takenAt.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (afterOf.present) {
      map['after_of'] = Variable<String>(afterOf.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PicturesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('fileSha256: $fileSha256, ')
          ..write('fileBytes: $fileBytes, ')
          ..write('fileMime: $fileMime, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('takenAt: $takenAt, ')
          ..write('roomId: $roomId, ')
          ..write('entryId: $entryId, ')
          ..write('afterOf: $afterOf, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _subjectTypeMeta = const VerificationMeta(
    'subjectType',
  );
  @override
  late final GeneratedColumn<String> subjectType = GeneratedColumn<String>(
    'subject_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteTextMeta = const VerificationMeta(
    'noteText',
  );
  @override
  late final GeneratedColumn<String> noteText = GeneratedColumn<String>(
    'text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioSha256Meta = const VerificationMeta(
    'audioSha256',
  );
  @override
  late final GeneratedColumn<String> audioSha256 = GeneratedColumn<String>(
    'audio_sha256',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioBytesMeta = const VerificationMeta(
    'audioBytes',
  );
  @override
  late final GeneratedColumn<int> audioBytes = GeneratedColumn<int>(
    'audio_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioSecondsMeta = const VerificationMeta(
    'audioSeconds',
  );
  @override
  late final GeneratedColumn<int> audioSeconds = GeneratedColumn<int>(
    'audio_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptMeta = const VerificationMeta(
    'transcript',
  );
  @override
  late final GeneratedColumn<String> transcript = GeneratedColumn<String>(
    'transcript',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transcriptSourceMeta = const VerificationMeta(
    'transcriptSource',
  );
  @override
  late final GeneratedColumn<String> transcriptSource = GeneratedColumn<String>(
    'transcript_source',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    subjectType,
    subjectId,
    noteText,
    audioSha256,
    audioBytes,
    audioSeconds,
    transcript,
    transcriptSource,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('subject_type')) {
      context.handle(
        _subjectTypeMeta,
        subjectType.isAcceptableOrUnknown(
          data['subject_type']!,
          _subjectTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_subjectTypeMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _noteTextMeta,
        noteText.isAcceptableOrUnknown(data['text']!, _noteTextMeta),
      );
    }
    if (data.containsKey('audio_sha256')) {
      context.handle(
        _audioSha256Meta,
        audioSha256.isAcceptableOrUnknown(
          data['audio_sha256']!,
          _audioSha256Meta,
        ),
      );
    }
    if (data.containsKey('audio_bytes')) {
      context.handle(
        _audioBytesMeta,
        audioBytes.isAcceptableOrUnknown(data['audio_bytes']!, _audioBytesMeta),
      );
    }
    if (data.containsKey('audio_seconds')) {
      context.handle(
        _audioSecondsMeta,
        audioSeconds.isAcceptableOrUnknown(
          data['audio_seconds']!,
          _audioSecondsMeta,
        ),
      );
    }
    if (data.containsKey('transcript')) {
      context.handle(
        _transcriptMeta,
        transcript.isAcceptableOrUnknown(data['transcript']!, _transcriptMeta),
      );
    }
    if (data.containsKey('transcript_source')) {
      context.handle(
        _transcriptSourceMeta,
        transcriptSource.isAcceptableOrUnknown(
          data['transcript_source']!,
          _transcriptSourceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      subjectType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_type'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      noteText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      ),
      audioSha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_sha256'],
      ),
      audioBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_bytes'],
      ),
      audioSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}audio_seconds'],
      ),
      transcript: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript'],
      ),
      transcriptSource: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transcript_source'],
      ),
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;

  /// `entry`, `room`, `picture`, `job` or `customer`.
  final String subjectType;
  final String subjectId;

  /// The column `text`; the getter cannot be called `text` in drift.
  final String? noteText;
  final String? audioSha256;
  final int? audioBytes;
  final int? audioSeconds;
  final String? transcript;

  /// `device` or `manual`; set exactly when there is a transcript.
  final String? transcriptSource;
  const Note({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    required this.subjectType,
    required this.subjectId,
    this.noteText,
    this.audioSha256,
    this.audioBytes,
    this.audioSeconds,
    this.transcript,
    this.transcriptSource,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['subject_type'] = Variable<String>(subjectType);
    map['subject_id'] = Variable<String>(subjectId);
    if (!nullToAbsent || noteText != null) {
      map['text'] = Variable<String>(noteText);
    }
    if (!nullToAbsent || audioSha256 != null) {
      map['audio_sha256'] = Variable<String>(audioSha256);
    }
    if (!nullToAbsent || audioBytes != null) {
      map['audio_bytes'] = Variable<int>(audioBytes);
    }
    if (!nullToAbsent || audioSeconds != null) {
      map['audio_seconds'] = Variable<int>(audioSeconds);
    }
    if (!nullToAbsent || transcript != null) {
      map['transcript'] = Variable<String>(transcript);
    }
    if (!nullToAbsent || transcriptSource != null) {
      map['transcript_source'] = Variable<String>(transcriptSource);
    }
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      subjectType: Value(subjectType),
      subjectId: Value(subjectId),
      noteText: noteText == null && nullToAbsent
          ? const Value.absent()
          : Value(noteText),
      audioSha256: audioSha256 == null && nullToAbsent
          ? const Value.absent()
          : Value(audioSha256),
      audioBytes: audioBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(audioBytes),
      audioSeconds: audioSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(audioSeconds),
      transcript: transcript == null && nullToAbsent
          ? const Value.absent()
          : Value(transcript),
      transcriptSource: transcriptSource == null && nullToAbsent
          ? const Value.absent()
          : Value(transcriptSource),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      subjectType: serializer.fromJson<String>(json['subjectType']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      noteText: serializer.fromJson<String?>(json['noteText']),
      audioSha256: serializer.fromJson<String?>(json['audioSha256']),
      audioBytes: serializer.fromJson<int?>(json['audioBytes']),
      audioSeconds: serializer.fromJson<int?>(json['audioSeconds']),
      transcript: serializer.fromJson<String?>(json['transcript']),
      transcriptSource: serializer.fromJson<String?>(json['transcriptSource']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'subjectType': serializer.toJson<String>(subjectType),
      'subjectId': serializer.toJson<String>(subjectId),
      'noteText': serializer.toJson<String?>(noteText),
      'audioSha256': serializer.toJson<String?>(audioSha256),
      'audioBytes': serializer.toJson<int?>(audioBytes),
      'audioSeconds': serializer.toJson<int?>(audioSeconds),
      'transcript': serializer.toJson<String?>(transcript),
      'transcriptSource': serializer.toJson<String?>(transcriptSource),
    };
  }

  Note copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? subjectType,
    String? subjectId,
    Value<String?> noteText = const Value.absent(),
    Value<String?> audioSha256 = const Value.absent(),
    Value<int?> audioBytes = const Value.absent(),
    Value<int?> audioSeconds = const Value.absent(),
    Value<String?> transcript = const Value.absent(),
    Value<String?> transcriptSource = const Value.absent(),
  }) => Note(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    subjectType: subjectType ?? this.subjectType,
    subjectId: subjectId ?? this.subjectId,
    noteText: noteText.present ? noteText.value : this.noteText,
    audioSha256: audioSha256.present ? audioSha256.value : this.audioSha256,
    audioBytes: audioBytes.present ? audioBytes.value : this.audioBytes,
    audioSeconds: audioSeconds.present ? audioSeconds.value : this.audioSeconds,
    transcript: transcript.present ? transcript.value : this.transcript,
    transcriptSource: transcriptSource.present
        ? transcriptSource.value
        : this.transcriptSource,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      subjectType: data.subjectType.present
          ? data.subjectType.value
          : this.subjectType,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      noteText: data.noteText.present ? data.noteText.value : this.noteText,
      audioSha256: data.audioSha256.present
          ? data.audioSha256.value
          : this.audioSha256,
      audioBytes: data.audioBytes.present
          ? data.audioBytes.value
          : this.audioBytes,
      audioSeconds: data.audioSeconds.present
          ? data.audioSeconds.value
          : this.audioSeconds,
      transcript: data.transcript.present
          ? data.transcript.value
          : this.transcript,
      transcriptSource: data.transcriptSource.present
          ? data.transcriptSource.value
          : this.transcriptSource,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('noteText: $noteText, ')
          ..write('audioSha256: $audioSha256, ')
          ..write('audioBytes: $audioBytes, ')
          ..write('audioSeconds: $audioSeconds, ')
          ..write('transcript: $transcript, ')
          ..write('transcriptSource: $transcriptSource')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    subjectType,
    subjectId,
    noteText,
    audioSha256,
    audioBytes,
    audioSeconds,
    transcript,
    transcriptSource,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.subjectType == this.subjectType &&
          other.subjectId == this.subjectId &&
          other.noteText == this.noteText &&
          other.audioSha256 == this.audioSha256 &&
          other.audioBytes == this.audioBytes &&
          other.audioSeconds == this.audioSeconds &&
          other.transcript == this.transcript &&
          other.transcriptSource == this.transcriptSource);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String> subjectType;
  final Value<String> subjectId;
  final Value<String?> noteText;
  final Value<String?> audioSha256;
  final Value<int?> audioBytes;
  final Value<int?> audioSeconds;
  final Value<String?> transcript;
  final Value<String?> transcriptSource;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.subjectType = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.noteText = const Value.absent(),
    this.audioSha256 = const Value.absent(),
    this.audioBytes = const Value.absent(),
    this.audioSeconds = const Value.absent(),
    this.transcript = const Value.absent(),
    this.transcriptSource = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    required String subjectType,
    required String subjectId,
    this.noteText = const Value.absent(),
    this.audioSha256 = const Value.absent(),
    this.audioBytes = const Value.absent(),
    this.audioSeconds = const Value.absent(),
    this.transcript = const Value.absent(),
    this.transcriptSource = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       subjectType = Value(subjectType),
       subjectId = Value(subjectId);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? subjectType,
    Expression<String>? subjectId,
    Expression<String>? noteText,
    Expression<String>? audioSha256,
    Expression<int>? audioBytes,
    Expression<int>? audioSeconds,
    Expression<String>? transcript,
    Expression<String>? transcriptSource,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (subjectType != null) 'subject_type': subjectType,
      if (subjectId != null) 'subject_id': subjectId,
      if (noteText != null) 'text': noteText,
      if (audioSha256 != null) 'audio_sha256': audioSha256,
      if (audioBytes != null) 'audio_bytes': audioBytes,
      if (audioSeconds != null) 'audio_seconds': audioSeconds,
      if (transcript != null) 'transcript': transcript,
      if (transcriptSource != null) 'transcript_source': transcriptSource,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String>? subjectType,
    Value<String>? subjectId,
    Value<String?>? noteText,
    Value<String?>? audioSha256,
    Value<int?>? audioBytes,
    Value<int?>? audioSeconds,
    Value<String?>? transcript,
    Value<String?>? transcriptSource,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      subjectType: subjectType ?? this.subjectType,
      subjectId: subjectId ?? this.subjectId,
      noteText: noteText ?? this.noteText,
      audioSha256: audioSha256 ?? this.audioSha256,
      audioBytes: audioBytes ?? this.audioBytes,
      audioSeconds: audioSeconds ?? this.audioSeconds,
      transcript: transcript ?? this.transcript,
      transcriptSource: transcriptSource ?? this.transcriptSource,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (subjectType.present) {
      map['subject_type'] = Variable<String>(subjectType.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (noteText.present) {
      map['text'] = Variable<String>(noteText.value);
    }
    if (audioSha256.present) {
      map['audio_sha256'] = Variable<String>(audioSha256.value);
    }
    if (audioBytes.present) {
      map['audio_bytes'] = Variable<int>(audioBytes.value);
    }
    if (audioSeconds.present) {
      map['audio_seconds'] = Variable<int>(audioSeconds.value);
    }
    if (transcript.present) {
      map['transcript'] = Variable<String>(transcript.value);
    }
    if (transcriptSource.present) {
      map['transcript_source'] = Variable<String>(transcriptSource.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('subjectType: $subjectType, ')
          ..write('subjectId: $subjectId, ')
          ..write('noteText: $noteText, ')
          ..write('audioSha256: $audioSha256, ')
          ..write('audioBytes: $audioBytes, ')
          ..write('audioSeconds: $audioSeconds, ')
          ..write('transcript: $transcript, ')
          ..write('transcriptSource: $transcriptSource, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntriesTable extends Entries with TableInfo<$EntriesTable, Entry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _siteIdMeta = const VerificationMeta('siteId');
  @override
  late final GeneratedColumn<String> siteId = GeneratedColumn<String>(
    'site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomIdMeta = const VerificationMeta('roomId');
  @override
  late final GeneratedColumn<String> roomId = GeneratedColumn<String>(
    'room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fixtureIdMeta = const VerificationMeta(
    'fixtureId',
  );
  @override
  late final GeneratedColumn<String> fixtureId = GeneratedColumn<String>(
    'fixture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _compartmentMeta = const VerificationMeta(
    'compartment',
  );
  @override
  late final GeneratedColumn<int> compartment = GeneratedColumn<int>(
    'compartment',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _floorXCmMeta = const VerificationMeta(
    'floorXCm',
  );
  @override
  late final GeneratedColumn<int> floorXCm = GeneratedColumn<int>(
    'floor_x_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _floorYCmMeta = const VerificationMeta(
    'floorYCm',
  );
  @override
  late final GeneratedColumn<int> floorYCm = GeneratedColumn<int>(
    'floor_y_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetSiteIdMeta = const VerificationMeta(
    'targetSiteId',
  );
  @override
  late final GeneratedColumn<String> targetSiteId = GeneratedColumn<String>(
    'target_site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetRoomIdMeta = const VerificationMeta(
    'targetRoomId',
  );
  @override
  late final GeneratedColumn<String> targetRoomId = GeneratedColumn<String>(
    'target_room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetFixtureIdMeta = const VerificationMeta(
    'targetFixtureId',
  );
  @override
  late final GeneratedColumn<String> targetFixtureId = GeneratedColumn<String>(
    'target_fixture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetLevelMeta = const VerificationMeta(
    'targetLevel',
  );
  @override
  late final GeneratedColumn<int> targetLevel = GeneratedColumn<int>(
    'target_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetCompartmentMeta = const VerificationMeta(
    'targetCompartment',
  );
  @override
  late final GeneratedColumn<int> targetCompartment = GeneratedColumn<int>(
    'target_compartment',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetFloorXCmMeta = const VerificationMeta(
    'targetFloorXCm',
  );
  @override
  late final GeneratedColumn<int> targetFloorXCm = GeneratedColumn<int>(
    'target_floor_x_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _targetFloorYCmMeta = const VerificationMeta(
    'targetFloorYCm',
  );
  @override
  late final GeneratedColumn<int> targetFloorYCm = GeneratedColumn<int>(
    'target_floor_y_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    code,
    title,
    siteId,
    roomId,
    fixtureId,
    level,
    compartment,
    floorXCm,
    floorYCm,
    targetSiteId,
    targetRoomId,
    targetFixtureId,
    targetLevel,
    targetCompartment,
    targetFloorXCm,
    targetFloorYCm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Entry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('site_id')) {
      context.handle(
        _siteIdMeta,
        siteId.isAcceptableOrUnknown(data['site_id']!, _siteIdMeta),
      );
    }
    if (data.containsKey('room_id')) {
      context.handle(
        _roomIdMeta,
        roomId.isAcceptableOrUnknown(data['room_id']!, _roomIdMeta),
      );
    }
    if (data.containsKey('fixture_id')) {
      context.handle(
        _fixtureIdMeta,
        fixtureId.isAcceptableOrUnknown(data['fixture_id']!, _fixtureIdMeta),
      );
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    }
    if (data.containsKey('compartment')) {
      context.handle(
        _compartmentMeta,
        compartment.isAcceptableOrUnknown(
          data['compartment']!,
          _compartmentMeta,
        ),
      );
    }
    if (data.containsKey('floor_x_cm')) {
      context.handle(
        _floorXCmMeta,
        floorXCm.isAcceptableOrUnknown(data['floor_x_cm']!, _floorXCmMeta),
      );
    }
    if (data.containsKey('floor_y_cm')) {
      context.handle(
        _floorYCmMeta,
        floorYCm.isAcceptableOrUnknown(data['floor_y_cm']!, _floorYCmMeta),
      );
    }
    if (data.containsKey('target_site_id')) {
      context.handle(
        _targetSiteIdMeta,
        targetSiteId.isAcceptableOrUnknown(
          data['target_site_id']!,
          _targetSiteIdMeta,
        ),
      );
    }
    if (data.containsKey('target_room_id')) {
      context.handle(
        _targetRoomIdMeta,
        targetRoomId.isAcceptableOrUnknown(
          data['target_room_id']!,
          _targetRoomIdMeta,
        ),
      );
    }
    if (data.containsKey('target_fixture_id')) {
      context.handle(
        _targetFixtureIdMeta,
        targetFixtureId.isAcceptableOrUnknown(
          data['target_fixture_id']!,
          _targetFixtureIdMeta,
        ),
      );
    }
    if (data.containsKey('target_level')) {
      context.handle(
        _targetLevelMeta,
        targetLevel.isAcceptableOrUnknown(
          data['target_level']!,
          _targetLevelMeta,
        ),
      );
    }
    if (data.containsKey('target_compartment')) {
      context.handle(
        _targetCompartmentMeta,
        targetCompartment.isAcceptableOrUnknown(
          data['target_compartment']!,
          _targetCompartmentMeta,
        ),
      );
    }
    if (data.containsKey('target_floor_x_cm')) {
      context.handle(
        _targetFloorXCmMeta,
        targetFloorXCm.isAcceptableOrUnknown(
          data['target_floor_x_cm']!,
          _targetFloorXCmMeta,
        ),
      );
    }
    if (data.containsKey('target_floor_y_cm')) {
      context.handle(
        _targetFloorYCmMeta,
        targetFloorYCm.isAcceptableOrUnknown(
          data['target_floor_y_cm']!,
          _targetFloorYCmMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Entry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Entry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      siteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}site_id'],
      ),
      roomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room_id'],
      ),
      fixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fixture_id'],
      ),
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      ),
      compartment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}compartment'],
      ),
      floorXCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_x_cm'],
      ),
      floorYCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}floor_y_cm'],
      ),
      targetSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_site_id'],
      ),
      targetRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_room_id'],
      ),
      targetFixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_fixture_id'],
      ),
      targetLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_level'],
      ),
      targetCompartment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_compartment'],
      ),
      targetFloorXCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_floor_x_cm'],
      ),
      targetFloorYCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_floor_y_cm'],
      ),
    );
  }

  @override
  $EntriesTable createAlias(String alias) {
    return $EntriesTable(attachedDatabase, alias);
  }
}

class Entry extends DataClass implements Insertable<Entry> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;

  /// Taken byte for byte, at most 255 UTF-8 bytes (D-51).
  final String? code;
  final String? title;
  final String? siteId;
  final String? roomId;
  final String? fixtureId;
  final int? level;
  final int? compartment;
  final int? floorXCm;
  final int? floorYCm;
  final String? targetSiteId;
  final String? targetRoomId;
  final String? targetFixtureId;
  final int? targetLevel;
  final int? targetCompartment;
  final int? targetFloorXCm;
  final int? targetFloorYCm;
  const Entry({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    this.code,
    this.title,
    this.siteId,
    this.roomId,
    this.fixtureId,
    this.level,
    this.compartment,
    this.floorXCm,
    this.floorYCm,
    this.targetSiteId,
    this.targetRoomId,
    this.targetFixtureId,
    this.targetLevel,
    this.targetCompartment,
    this.targetFloorXCm,
    this.targetFloorYCm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || siteId != null) {
      map['site_id'] = Variable<String>(siteId);
    }
    if (!nullToAbsent || roomId != null) {
      map['room_id'] = Variable<String>(roomId);
    }
    if (!nullToAbsent || fixtureId != null) {
      map['fixture_id'] = Variable<String>(fixtureId);
    }
    if (!nullToAbsent || level != null) {
      map['level'] = Variable<int>(level);
    }
    if (!nullToAbsent || compartment != null) {
      map['compartment'] = Variable<int>(compartment);
    }
    if (!nullToAbsent || floorXCm != null) {
      map['floor_x_cm'] = Variable<int>(floorXCm);
    }
    if (!nullToAbsent || floorYCm != null) {
      map['floor_y_cm'] = Variable<int>(floorYCm);
    }
    if (!nullToAbsent || targetSiteId != null) {
      map['target_site_id'] = Variable<String>(targetSiteId);
    }
    if (!nullToAbsent || targetRoomId != null) {
      map['target_room_id'] = Variable<String>(targetRoomId);
    }
    if (!nullToAbsent || targetFixtureId != null) {
      map['target_fixture_id'] = Variable<String>(targetFixtureId);
    }
    if (!nullToAbsent || targetLevel != null) {
      map['target_level'] = Variable<int>(targetLevel);
    }
    if (!nullToAbsent || targetCompartment != null) {
      map['target_compartment'] = Variable<int>(targetCompartment);
    }
    if (!nullToAbsent || targetFloorXCm != null) {
      map['target_floor_x_cm'] = Variable<int>(targetFloorXCm);
    }
    if (!nullToAbsent || targetFloorYCm != null) {
      map['target_floor_y_cm'] = Variable<int>(targetFloorYCm);
    }
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      siteId: siteId == null && nullToAbsent
          ? const Value.absent()
          : Value(siteId),
      roomId: roomId == null && nullToAbsent
          ? const Value.absent()
          : Value(roomId),
      fixtureId: fixtureId == null && nullToAbsent
          ? const Value.absent()
          : Value(fixtureId),
      level: level == null && nullToAbsent
          ? const Value.absent()
          : Value(level),
      compartment: compartment == null && nullToAbsent
          ? const Value.absent()
          : Value(compartment),
      floorXCm: floorXCm == null && nullToAbsent
          ? const Value.absent()
          : Value(floorXCm),
      floorYCm: floorYCm == null && nullToAbsent
          ? const Value.absent()
          : Value(floorYCm),
      targetSiteId: targetSiteId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetSiteId),
      targetRoomId: targetRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetRoomId),
      targetFixtureId: targetFixtureId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetFixtureId),
      targetLevel: targetLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLevel),
      targetCompartment: targetCompartment == null && nullToAbsent
          ? const Value.absent()
          : Value(targetCompartment),
      targetFloorXCm: targetFloorXCm == null && nullToAbsent
          ? const Value.absent()
          : Value(targetFloorXCm),
      targetFloorYCm: targetFloorYCm == null && nullToAbsent
          ? const Value.absent()
          : Value(targetFloorYCm),
    );
  }

  factory Entry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Entry(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      code: serializer.fromJson<String?>(json['code']),
      title: serializer.fromJson<String?>(json['title']),
      siteId: serializer.fromJson<String?>(json['siteId']),
      roomId: serializer.fromJson<String?>(json['roomId']),
      fixtureId: serializer.fromJson<String?>(json['fixtureId']),
      level: serializer.fromJson<int?>(json['level']),
      compartment: serializer.fromJson<int?>(json['compartment']),
      floorXCm: serializer.fromJson<int?>(json['floorXCm']),
      floorYCm: serializer.fromJson<int?>(json['floorYCm']),
      targetSiteId: serializer.fromJson<String?>(json['targetSiteId']),
      targetRoomId: serializer.fromJson<String?>(json['targetRoomId']),
      targetFixtureId: serializer.fromJson<String?>(json['targetFixtureId']),
      targetLevel: serializer.fromJson<int?>(json['targetLevel']),
      targetCompartment: serializer.fromJson<int?>(json['targetCompartment']),
      targetFloorXCm: serializer.fromJson<int?>(json['targetFloorXCm']),
      targetFloorYCm: serializer.fromJson<int?>(json['targetFloorYCm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'code': serializer.toJson<String?>(code),
      'title': serializer.toJson<String?>(title),
      'siteId': serializer.toJson<String?>(siteId),
      'roomId': serializer.toJson<String?>(roomId),
      'fixtureId': serializer.toJson<String?>(fixtureId),
      'level': serializer.toJson<int?>(level),
      'compartment': serializer.toJson<int?>(compartment),
      'floorXCm': serializer.toJson<int?>(floorXCm),
      'floorYCm': serializer.toJson<int?>(floorYCm),
      'targetSiteId': serializer.toJson<String?>(targetSiteId),
      'targetRoomId': serializer.toJson<String?>(targetRoomId),
      'targetFixtureId': serializer.toJson<String?>(targetFixtureId),
      'targetLevel': serializer.toJson<int?>(targetLevel),
      'targetCompartment': serializer.toJson<int?>(targetCompartment),
      'targetFloorXCm': serializer.toJson<int?>(targetFloorXCm),
      'targetFloorYCm': serializer.toJson<int?>(targetFloorYCm),
    };
  }

  Entry copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    Value<String?> code = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<String?> siteId = const Value.absent(),
    Value<String?> roomId = const Value.absent(),
    Value<String?> fixtureId = const Value.absent(),
    Value<int?> level = const Value.absent(),
    Value<int?> compartment = const Value.absent(),
    Value<int?> floorXCm = const Value.absent(),
    Value<int?> floorYCm = const Value.absent(),
    Value<String?> targetSiteId = const Value.absent(),
    Value<String?> targetRoomId = const Value.absent(),
    Value<String?> targetFixtureId = const Value.absent(),
    Value<int?> targetLevel = const Value.absent(),
    Value<int?> targetCompartment = const Value.absent(),
    Value<int?> targetFloorXCm = const Value.absent(),
    Value<int?> targetFloorYCm = const Value.absent(),
  }) => Entry(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    code: code.present ? code.value : this.code,
    title: title.present ? title.value : this.title,
    siteId: siteId.present ? siteId.value : this.siteId,
    roomId: roomId.present ? roomId.value : this.roomId,
    fixtureId: fixtureId.present ? fixtureId.value : this.fixtureId,
    level: level.present ? level.value : this.level,
    compartment: compartment.present ? compartment.value : this.compartment,
    floorXCm: floorXCm.present ? floorXCm.value : this.floorXCm,
    floorYCm: floorYCm.present ? floorYCm.value : this.floorYCm,
    targetSiteId: targetSiteId.present ? targetSiteId.value : this.targetSiteId,
    targetRoomId: targetRoomId.present ? targetRoomId.value : this.targetRoomId,
    targetFixtureId: targetFixtureId.present
        ? targetFixtureId.value
        : this.targetFixtureId,
    targetLevel: targetLevel.present ? targetLevel.value : this.targetLevel,
    targetCompartment: targetCompartment.present
        ? targetCompartment.value
        : this.targetCompartment,
    targetFloorXCm: targetFloorXCm.present
        ? targetFloorXCm.value
        : this.targetFloorXCm,
    targetFloorYCm: targetFloorYCm.present
        ? targetFloorYCm.value
        : this.targetFloorYCm,
  );
  Entry copyWithCompanion(EntriesCompanion data) {
    return Entry(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      siteId: data.siteId.present ? data.siteId.value : this.siteId,
      roomId: data.roomId.present ? data.roomId.value : this.roomId,
      fixtureId: data.fixtureId.present ? data.fixtureId.value : this.fixtureId,
      level: data.level.present ? data.level.value : this.level,
      compartment: data.compartment.present
          ? data.compartment.value
          : this.compartment,
      floorXCm: data.floorXCm.present ? data.floorXCm.value : this.floorXCm,
      floorYCm: data.floorYCm.present ? data.floorYCm.value : this.floorYCm,
      targetSiteId: data.targetSiteId.present
          ? data.targetSiteId.value
          : this.targetSiteId,
      targetRoomId: data.targetRoomId.present
          ? data.targetRoomId.value
          : this.targetRoomId,
      targetFixtureId: data.targetFixtureId.present
          ? data.targetFixtureId.value
          : this.targetFixtureId,
      targetLevel: data.targetLevel.present
          ? data.targetLevel.value
          : this.targetLevel,
      targetCompartment: data.targetCompartment.present
          ? data.targetCompartment.value
          : this.targetCompartment,
      targetFloorXCm: data.targetFloorXCm.present
          ? data.targetFloorXCm.value
          : this.targetFloorXCm,
      targetFloorYCm: data.targetFloorYCm.present
          ? data.targetFloorYCm.value
          : this.targetFloorYCm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Entry(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('siteId: $siteId, ')
          ..write('roomId: $roomId, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('level: $level, ')
          ..write('compartment: $compartment, ')
          ..write('floorXCm: $floorXCm, ')
          ..write('floorYCm: $floorYCm, ')
          ..write('targetSiteId: $targetSiteId, ')
          ..write('targetRoomId: $targetRoomId, ')
          ..write('targetFixtureId: $targetFixtureId, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('targetCompartment: $targetCompartment, ')
          ..write('targetFloorXCm: $targetFloorXCm, ')
          ..write('targetFloorYCm: $targetFloorYCm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    code,
    title,
    siteId,
    roomId,
    fixtureId,
    level,
    compartment,
    floorXCm,
    floorYCm,
    targetSiteId,
    targetRoomId,
    targetFixtureId,
    targetLevel,
    targetCompartment,
    targetFloorXCm,
    targetFloorYCm,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Entry &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.code == this.code &&
          other.title == this.title &&
          other.siteId == this.siteId &&
          other.roomId == this.roomId &&
          other.fixtureId == this.fixtureId &&
          other.level == this.level &&
          other.compartment == this.compartment &&
          other.floorXCm == this.floorXCm &&
          other.floorYCm == this.floorYCm &&
          other.targetSiteId == this.targetSiteId &&
          other.targetRoomId == this.targetRoomId &&
          other.targetFixtureId == this.targetFixtureId &&
          other.targetLevel == this.targetLevel &&
          other.targetCompartment == this.targetCompartment &&
          other.targetFloorXCm == this.targetFloorXCm &&
          other.targetFloorYCm == this.targetFloorYCm);
}

class EntriesCompanion extends UpdateCompanion<Entry> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String?> code;
  final Value<String?> title;
  final Value<String?> siteId;
  final Value<String?> roomId;
  final Value<String?> fixtureId;
  final Value<int?> level;
  final Value<int?> compartment;
  final Value<int?> floorXCm;
  final Value<int?> floorYCm;
  final Value<String?> targetSiteId;
  final Value<String?> targetRoomId;
  final Value<String?> targetFixtureId;
  final Value<int?> targetLevel;
  final Value<int?> targetCompartment;
  final Value<int?> targetFloorXCm;
  final Value<int?> targetFloorYCm;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.siteId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.level = const Value.absent(),
    this.compartment = const Value.absent(),
    this.floorXCm = const Value.absent(),
    this.floorYCm = const Value.absent(),
    this.targetSiteId = const Value.absent(),
    this.targetRoomId = const Value.absent(),
    this.targetFixtureId = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.targetCompartment = const Value.absent(),
    this.targetFloorXCm = const Value.absent(),
    this.targetFloorYCm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.siteId = const Value.absent(),
    this.roomId = const Value.absent(),
    this.fixtureId = const Value.absent(),
    this.level = const Value.absent(),
    this.compartment = const Value.absent(),
    this.floorXCm = const Value.absent(),
    this.floorYCm = const Value.absent(),
    this.targetSiteId = const Value.absent(),
    this.targetRoomId = const Value.absent(),
    this.targetFixtureId = const Value.absent(),
    this.targetLevel = const Value.absent(),
    this.targetCompartment = const Value.absent(),
    this.targetFloorXCm = const Value.absent(),
    this.targetFloorYCm = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId);
  static Insertable<Entry> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? siteId,
    Expression<String>? roomId,
    Expression<String>? fixtureId,
    Expression<int>? level,
    Expression<int>? compartment,
    Expression<int>? floorXCm,
    Expression<int>? floorYCm,
    Expression<String>? targetSiteId,
    Expression<String>? targetRoomId,
    Expression<String>? targetFixtureId,
    Expression<int>? targetLevel,
    Expression<int>? targetCompartment,
    Expression<int>? targetFloorXCm,
    Expression<int>? targetFloorYCm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (siteId != null) 'site_id': siteId,
      if (roomId != null) 'room_id': roomId,
      if (fixtureId != null) 'fixture_id': fixtureId,
      if (level != null) 'level': level,
      if (compartment != null) 'compartment': compartment,
      if (floorXCm != null) 'floor_x_cm': floorXCm,
      if (floorYCm != null) 'floor_y_cm': floorYCm,
      if (targetSiteId != null) 'target_site_id': targetSiteId,
      if (targetRoomId != null) 'target_room_id': targetRoomId,
      if (targetFixtureId != null) 'target_fixture_id': targetFixtureId,
      if (targetLevel != null) 'target_level': targetLevel,
      if (targetCompartment != null) 'target_compartment': targetCompartment,
      if (targetFloorXCm != null) 'target_floor_x_cm': targetFloorXCm,
      if (targetFloorYCm != null) 'target_floor_y_cm': targetFloorYCm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String?>? code,
    Value<String?>? title,
    Value<String?>? siteId,
    Value<String?>? roomId,
    Value<String?>? fixtureId,
    Value<int?>? level,
    Value<int?>? compartment,
    Value<int?>? floorXCm,
    Value<int?>? floorYCm,
    Value<String?>? targetSiteId,
    Value<String?>? targetRoomId,
    Value<String?>? targetFixtureId,
    Value<int?>? targetLevel,
    Value<int?>? targetCompartment,
    Value<int?>? targetFloorXCm,
    Value<int?>? targetFloorYCm,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      code: code ?? this.code,
      title: title ?? this.title,
      siteId: siteId ?? this.siteId,
      roomId: roomId ?? this.roomId,
      fixtureId: fixtureId ?? this.fixtureId,
      level: level ?? this.level,
      compartment: compartment ?? this.compartment,
      floorXCm: floorXCm ?? this.floorXCm,
      floorYCm: floorYCm ?? this.floorYCm,
      targetSiteId: targetSiteId ?? this.targetSiteId,
      targetRoomId: targetRoomId ?? this.targetRoomId,
      targetFixtureId: targetFixtureId ?? this.targetFixtureId,
      targetLevel: targetLevel ?? this.targetLevel,
      targetCompartment: targetCompartment ?? this.targetCompartment,
      targetFloorXCm: targetFloorXCm ?? this.targetFloorXCm,
      targetFloorYCm: targetFloorYCm ?? this.targetFloorYCm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (siteId.present) {
      map['site_id'] = Variable<String>(siteId.value);
    }
    if (roomId.present) {
      map['room_id'] = Variable<String>(roomId.value);
    }
    if (fixtureId.present) {
      map['fixture_id'] = Variable<String>(fixtureId.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (compartment.present) {
      map['compartment'] = Variable<int>(compartment.value);
    }
    if (floorXCm.present) {
      map['floor_x_cm'] = Variable<int>(floorXCm.value);
    }
    if (floorYCm.present) {
      map['floor_y_cm'] = Variable<int>(floorYCm.value);
    }
    if (targetSiteId.present) {
      map['target_site_id'] = Variable<String>(targetSiteId.value);
    }
    if (targetRoomId.present) {
      map['target_room_id'] = Variable<String>(targetRoomId.value);
    }
    if (targetFixtureId.present) {
      map['target_fixture_id'] = Variable<String>(targetFixtureId.value);
    }
    if (targetLevel.present) {
      map['target_level'] = Variable<int>(targetLevel.value);
    }
    if (targetCompartment.present) {
      map['target_compartment'] = Variable<int>(targetCompartment.value);
    }
    if (targetFloorXCm.present) {
      map['target_floor_x_cm'] = Variable<int>(targetFloorXCm.value);
    }
    if (targetFloorYCm.present) {
      map['target_floor_y_cm'] = Variable<int>(targetFloorYCm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('siteId: $siteId, ')
          ..write('roomId: $roomId, ')
          ..write('fixtureId: $fixtureId, ')
          ..write('level: $level, ')
          ..write('compartment: $compartment, ')
          ..write('floorXCm: $floorXCm, ')
          ..write('floorYCm: $floorYCm, ')
          ..write('targetSiteId: $targetSiteId, ')
          ..write('targetRoomId: $targetRoomId, ')
          ..write('targetFixtureId: $targetFixtureId, ')
          ..write('targetLevel: $targetLevel, ')
          ..write('targetCompartment: $targetCompartment, ')
          ..write('targetFloorXCm: $targetFloorXCm, ')
          ..write('targetFloorYCm: $targetFloorYCm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaceHistoryTable extends PlaceHistory
    with TableInfo<$PlaceHistoryTable, PlaceHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaceHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entryIdMeta = const VerificationMeta(
    'entryId',
  );
  @override
  late final GeneratedColumn<String> entryId = GeneratedColumn<String>(
    'entry_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromSiteIdMeta = const VerificationMeta(
    'fromSiteId',
  );
  @override
  late final GeneratedColumn<String> fromSiteId = GeneratedColumn<String>(
    'from_site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromRoomIdMeta = const VerificationMeta(
    'fromRoomId',
  );
  @override
  late final GeneratedColumn<String> fromRoomId = GeneratedColumn<String>(
    'from_room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromFixtureIdMeta = const VerificationMeta(
    'fromFixtureId',
  );
  @override
  late final GeneratedColumn<String> fromFixtureId = GeneratedColumn<String>(
    'from_fixture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromLevelMeta = const VerificationMeta(
    'fromLevel',
  );
  @override
  late final GeneratedColumn<int> fromLevel = GeneratedColumn<int>(
    'from_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromCompartmentMeta = const VerificationMeta(
    'fromCompartment',
  );
  @override
  late final GeneratedColumn<int> fromCompartment = GeneratedColumn<int>(
    'from_compartment',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromFloorXCmMeta = const VerificationMeta(
    'fromFloorXCm',
  );
  @override
  late final GeneratedColumn<int> fromFloorXCm = GeneratedColumn<int>(
    'from_floor_x_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromFloorYCmMeta = const VerificationMeta(
    'fromFloorYCm',
  );
  @override
  late final GeneratedColumn<int> fromFloorYCm = GeneratedColumn<int>(
    'from_floor_y_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toSiteIdMeta = const VerificationMeta(
    'toSiteId',
  );
  @override
  late final GeneratedColumn<String> toSiteId = GeneratedColumn<String>(
    'to_site_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toRoomIdMeta = const VerificationMeta(
    'toRoomId',
  );
  @override
  late final GeneratedColumn<String> toRoomId = GeneratedColumn<String>(
    'to_room_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toFixtureIdMeta = const VerificationMeta(
    'toFixtureId',
  );
  @override
  late final GeneratedColumn<String> toFixtureId = GeneratedColumn<String>(
    'to_fixture_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toLevelMeta = const VerificationMeta(
    'toLevel',
  );
  @override
  late final GeneratedColumn<int> toLevel = GeneratedColumn<int>(
    'to_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toCompartmentMeta = const VerificationMeta(
    'toCompartment',
  );
  @override
  late final GeneratedColumn<int> toCompartment = GeneratedColumn<int>(
    'to_compartment',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toFloorXCmMeta = const VerificationMeta(
    'toFloorXCm',
  );
  @override
  late final GeneratedColumn<int> toFloorXCm = GeneratedColumn<int>(
    'to_floor_x_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toFloorYCmMeta = const VerificationMeta(
    'toFloorYCm',
  );
  @override
  late final GeneratedColumn<int> toFloorYCm = GeneratedColumn<int>(
    'to_floor_y_cm',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _movedAtMeta = const VerificationMeta(
    'movedAt',
  );
  @override
  late final GeneratedColumn<String> movedAt = GeneratedColumn<String>(
    'moved_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movedByMeta = const VerificationMeta(
    'movedBy',
  );
  @override
  late final GeneratedColumn<String> movedBy = GeneratedColumn<String>(
    'moved_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    entryId,
    fromSiteId,
    fromRoomId,
    fromFixtureId,
    fromLevel,
    fromCompartment,
    fromFloorXCm,
    fromFloorYCm,
    toSiteId,
    toRoomId,
    toFixtureId,
    toLevel,
    toCompartment,
    toFloorXCm,
    toFloorYCm,
    movedAt,
    movedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'place_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaceHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('entry_id')) {
      context.handle(
        _entryIdMeta,
        entryId.isAcceptableOrUnknown(data['entry_id']!, _entryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entryIdMeta);
    }
    if (data.containsKey('from_site_id')) {
      context.handle(
        _fromSiteIdMeta,
        fromSiteId.isAcceptableOrUnknown(
          data['from_site_id']!,
          _fromSiteIdMeta,
        ),
      );
    }
    if (data.containsKey('from_room_id')) {
      context.handle(
        _fromRoomIdMeta,
        fromRoomId.isAcceptableOrUnknown(
          data['from_room_id']!,
          _fromRoomIdMeta,
        ),
      );
    }
    if (data.containsKey('from_fixture_id')) {
      context.handle(
        _fromFixtureIdMeta,
        fromFixtureId.isAcceptableOrUnknown(
          data['from_fixture_id']!,
          _fromFixtureIdMeta,
        ),
      );
    }
    if (data.containsKey('from_level')) {
      context.handle(
        _fromLevelMeta,
        fromLevel.isAcceptableOrUnknown(data['from_level']!, _fromLevelMeta),
      );
    }
    if (data.containsKey('from_compartment')) {
      context.handle(
        _fromCompartmentMeta,
        fromCompartment.isAcceptableOrUnknown(
          data['from_compartment']!,
          _fromCompartmentMeta,
        ),
      );
    }
    if (data.containsKey('from_floor_x_cm')) {
      context.handle(
        _fromFloorXCmMeta,
        fromFloorXCm.isAcceptableOrUnknown(
          data['from_floor_x_cm']!,
          _fromFloorXCmMeta,
        ),
      );
    }
    if (data.containsKey('from_floor_y_cm')) {
      context.handle(
        _fromFloorYCmMeta,
        fromFloorYCm.isAcceptableOrUnknown(
          data['from_floor_y_cm']!,
          _fromFloorYCmMeta,
        ),
      );
    }
    if (data.containsKey('to_site_id')) {
      context.handle(
        _toSiteIdMeta,
        toSiteId.isAcceptableOrUnknown(data['to_site_id']!, _toSiteIdMeta),
      );
    }
    if (data.containsKey('to_room_id')) {
      context.handle(
        _toRoomIdMeta,
        toRoomId.isAcceptableOrUnknown(data['to_room_id']!, _toRoomIdMeta),
      );
    }
    if (data.containsKey('to_fixture_id')) {
      context.handle(
        _toFixtureIdMeta,
        toFixtureId.isAcceptableOrUnknown(
          data['to_fixture_id']!,
          _toFixtureIdMeta,
        ),
      );
    }
    if (data.containsKey('to_level')) {
      context.handle(
        _toLevelMeta,
        toLevel.isAcceptableOrUnknown(data['to_level']!, _toLevelMeta),
      );
    }
    if (data.containsKey('to_compartment')) {
      context.handle(
        _toCompartmentMeta,
        toCompartment.isAcceptableOrUnknown(
          data['to_compartment']!,
          _toCompartmentMeta,
        ),
      );
    }
    if (data.containsKey('to_floor_x_cm')) {
      context.handle(
        _toFloorXCmMeta,
        toFloorXCm.isAcceptableOrUnknown(
          data['to_floor_x_cm']!,
          _toFloorXCmMeta,
        ),
      );
    }
    if (data.containsKey('to_floor_y_cm')) {
      context.handle(
        _toFloorYCmMeta,
        toFloorYCm.isAcceptableOrUnknown(
          data['to_floor_y_cm']!,
          _toFloorYCmMeta,
        ),
      );
    }
    if (data.containsKey('moved_at')) {
      context.handle(
        _movedAtMeta,
        movedAt.isAcceptableOrUnknown(data['moved_at']!, _movedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_movedAtMeta);
    }
    if (data.containsKey('moved_by')) {
      context.handle(
        _movedByMeta,
        movedBy.isAcceptableOrUnknown(data['moved_by']!, _movedByMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaceHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      entryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entry_id'],
      )!,
      fromSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_site_id'],
      ),
      fromRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_room_id'],
      ),
      fromFixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_fixture_id'],
      ),
      fromLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_level'],
      ),
      fromCompartment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_compartment'],
      ),
      fromFloorXCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_floor_x_cm'],
      ),
      fromFloorYCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_floor_y_cm'],
      ),
      toSiteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_site_id'],
      ),
      toRoomId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_room_id'],
      ),
      toFixtureId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_fixture_id'],
      ),
      toLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_level'],
      ),
      toCompartment: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_compartment'],
      ),
      toFloorXCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_floor_x_cm'],
      ),
      toFloorYCm: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_floor_y_cm'],
      ),
      movedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moved_at'],
      )!,
      movedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}moved_by'],
      ),
    );
  }

  @override
  $PlaceHistoryTable createAlias(String alias) {
    return $PlaceHistoryTable(attachedDatabase, alias);
  }
}

class PlaceHistoryData extends DataClass
    implements Insertable<PlaceHistoryData> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;
  final String entryId;
  final String? fromSiteId;
  final String? fromRoomId;
  final String? fromFixtureId;
  final int? fromLevel;
  final int? fromCompartment;
  final int? fromFloorXCm;
  final int? fromFloorYCm;
  final String? toSiteId;
  final String? toRoomId;
  final String? toFixtureId;
  final int? toLevel;
  final int? toCompartment;
  final int? toFloorXCm;
  final int? toFloorYCm;
  final String movedAt;
  final String? movedBy;
  const PlaceHistoryData({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    required this.entryId,
    this.fromSiteId,
    this.fromRoomId,
    this.fromFixtureId,
    this.fromLevel,
    this.fromCompartment,
    this.fromFloorXCm,
    this.fromFloorYCm,
    this.toSiteId,
    this.toRoomId,
    this.toFixtureId,
    this.toLevel,
    this.toCompartment,
    this.toFloorXCm,
    this.toFloorYCm,
    required this.movedAt,
    this.movedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['entry_id'] = Variable<String>(entryId);
    if (!nullToAbsent || fromSiteId != null) {
      map['from_site_id'] = Variable<String>(fromSiteId);
    }
    if (!nullToAbsent || fromRoomId != null) {
      map['from_room_id'] = Variable<String>(fromRoomId);
    }
    if (!nullToAbsent || fromFixtureId != null) {
      map['from_fixture_id'] = Variable<String>(fromFixtureId);
    }
    if (!nullToAbsent || fromLevel != null) {
      map['from_level'] = Variable<int>(fromLevel);
    }
    if (!nullToAbsent || fromCompartment != null) {
      map['from_compartment'] = Variable<int>(fromCompartment);
    }
    if (!nullToAbsent || fromFloorXCm != null) {
      map['from_floor_x_cm'] = Variable<int>(fromFloorXCm);
    }
    if (!nullToAbsent || fromFloorYCm != null) {
      map['from_floor_y_cm'] = Variable<int>(fromFloorYCm);
    }
    if (!nullToAbsent || toSiteId != null) {
      map['to_site_id'] = Variable<String>(toSiteId);
    }
    if (!nullToAbsent || toRoomId != null) {
      map['to_room_id'] = Variable<String>(toRoomId);
    }
    if (!nullToAbsent || toFixtureId != null) {
      map['to_fixture_id'] = Variable<String>(toFixtureId);
    }
    if (!nullToAbsent || toLevel != null) {
      map['to_level'] = Variable<int>(toLevel);
    }
    if (!nullToAbsent || toCompartment != null) {
      map['to_compartment'] = Variable<int>(toCompartment);
    }
    if (!nullToAbsent || toFloorXCm != null) {
      map['to_floor_x_cm'] = Variable<int>(toFloorXCm);
    }
    if (!nullToAbsent || toFloorYCm != null) {
      map['to_floor_y_cm'] = Variable<int>(toFloorYCm);
    }
    map['moved_at'] = Variable<String>(movedAt);
    if (!nullToAbsent || movedBy != null) {
      map['moved_by'] = Variable<String>(movedBy);
    }
    return map;
  }

  PlaceHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlaceHistoryCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      entryId: Value(entryId),
      fromSiteId: fromSiteId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromSiteId),
      fromRoomId: fromRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromRoomId),
      fromFixtureId: fromFixtureId == null && nullToAbsent
          ? const Value.absent()
          : Value(fromFixtureId),
      fromLevel: fromLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(fromLevel),
      fromCompartment: fromCompartment == null && nullToAbsent
          ? const Value.absent()
          : Value(fromCompartment),
      fromFloorXCm: fromFloorXCm == null && nullToAbsent
          ? const Value.absent()
          : Value(fromFloorXCm),
      fromFloorYCm: fromFloorYCm == null && nullToAbsent
          ? const Value.absent()
          : Value(fromFloorYCm),
      toSiteId: toSiteId == null && nullToAbsent
          ? const Value.absent()
          : Value(toSiteId),
      toRoomId: toRoomId == null && nullToAbsent
          ? const Value.absent()
          : Value(toRoomId),
      toFixtureId: toFixtureId == null && nullToAbsent
          ? const Value.absent()
          : Value(toFixtureId),
      toLevel: toLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(toLevel),
      toCompartment: toCompartment == null && nullToAbsent
          ? const Value.absent()
          : Value(toCompartment),
      toFloorXCm: toFloorXCm == null && nullToAbsent
          ? const Value.absent()
          : Value(toFloorXCm),
      toFloorYCm: toFloorYCm == null && nullToAbsent
          ? const Value.absent()
          : Value(toFloorYCm),
      movedAt: Value(movedAt),
      movedBy: movedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(movedBy),
    );
  }

  factory PlaceHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceHistoryData(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      entryId: serializer.fromJson<String>(json['entryId']),
      fromSiteId: serializer.fromJson<String?>(json['fromSiteId']),
      fromRoomId: serializer.fromJson<String?>(json['fromRoomId']),
      fromFixtureId: serializer.fromJson<String?>(json['fromFixtureId']),
      fromLevel: serializer.fromJson<int?>(json['fromLevel']),
      fromCompartment: serializer.fromJson<int?>(json['fromCompartment']),
      fromFloorXCm: serializer.fromJson<int?>(json['fromFloorXCm']),
      fromFloorYCm: serializer.fromJson<int?>(json['fromFloorYCm']),
      toSiteId: serializer.fromJson<String?>(json['toSiteId']),
      toRoomId: serializer.fromJson<String?>(json['toRoomId']),
      toFixtureId: serializer.fromJson<String?>(json['toFixtureId']),
      toLevel: serializer.fromJson<int?>(json['toLevel']),
      toCompartment: serializer.fromJson<int?>(json['toCompartment']),
      toFloorXCm: serializer.fromJson<int?>(json['toFloorXCm']),
      toFloorYCm: serializer.fromJson<int?>(json['toFloorYCm']),
      movedAt: serializer.fromJson<String>(json['movedAt']),
      movedBy: serializer.fromJson<String?>(json['movedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'entryId': serializer.toJson<String>(entryId),
      'fromSiteId': serializer.toJson<String?>(fromSiteId),
      'fromRoomId': serializer.toJson<String?>(fromRoomId),
      'fromFixtureId': serializer.toJson<String?>(fromFixtureId),
      'fromLevel': serializer.toJson<int?>(fromLevel),
      'fromCompartment': serializer.toJson<int?>(fromCompartment),
      'fromFloorXCm': serializer.toJson<int?>(fromFloorXCm),
      'fromFloorYCm': serializer.toJson<int?>(fromFloorYCm),
      'toSiteId': serializer.toJson<String?>(toSiteId),
      'toRoomId': serializer.toJson<String?>(toRoomId),
      'toFixtureId': serializer.toJson<String?>(toFixtureId),
      'toLevel': serializer.toJson<int?>(toLevel),
      'toCompartment': serializer.toJson<int?>(toCompartment),
      'toFloorXCm': serializer.toJson<int?>(toFloorXCm),
      'toFloorYCm': serializer.toJson<int?>(toFloorYCm),
      'movedAt': serializer.toJson<String>(movedAt),
      'movedBy': serializer.toJson<String?>(movedBy),
    };
  }

  PlaceHistoryData copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? entryId,
    Value<String?> fromSiteId = const Value.absent(),
    Value<String?> fromRoomId = const Value.absent(),
    Value<String?> fromFixtureId = const Value.absent(),
    Value<int?> fromLevel = const Value.absent(),
    Value<int?> fromCompartment = const Value.absent(),
    Value<int?> fromFloorXCm = const Value.absent(),
    Value<int?> fromFloorYCm = const Value.absent(),
    Value<String?> toSiteId = const Value.absent(),
    Value<String?> toRoomId = const Value.absent(),
    Value<String?> toFixtureId = const Value.absent(),
    Value<int?> toLevel = const Value.absent(),
    Value<int?> toCompartment = const Value.absent(),
    Value<int?> toFloorXCm = const Value.absent(),
    Value<int?> toFloorYCm = const Value.absent(),
    String? movedAt,
    Value<String?> movedBy = const Value.absent(),
  }) => PlaceHistoryData(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    entryId: entryId ?? this.entryId,
    fromSiteId: fromSiteId.present ? fromSiteId.value : this.fromSiteId,
    fromRoomId: fromRoomId.present ? fromRoomId.value : this.fromRoomId,
    fromFixtureId: fromFixtureId.present
        ? fromFixtureId.value
        : this.fromFixtureId,
    fromLevel: fromLevel.present ? fromLevel.value : this.fromLevel,
    fromCompartment: fromCompartment.present
        ? fromCompartment.value
        : this.fromCompartment,
    fromFloorXCm: fromFloorXCm.present ? fromFloorXCm.value : this.fromFloorXCm,
    fromFloorYCm: fromFloorYCm.present ? fromFloorYCm.value : this.fromFloorYCm,
    toSiteId: toSiteId.present ? toSiteId.value : this.toSiteId,
    toRoomId: toRoomId.present ? toRoomId.value : this.toRoomId,
    toFixtureId: toFixtureId.present ? toFixtureId.value : this.toFixtureId,
    toLevel: toLevel.present ? toLevel.value : this.toLevel,
    toCompartment: toCompartment.present
        ? toCompartment.value
        : this.toCompartment,
    toFloorXCm: toFloorXCm.present ? toFloorXCm.value : this.toFloorXCm,
    toFloorYCm: toFloorYCm.present ? toFloorYCm.value : this.toFloorYCm,
    movedAt: movedAt ?? this.movedAt,
    movedBy: movedBy.present ? movedBy.value : this.movedBy,
  );
  PlaceHistoryData copyWithCompanion(PlaceHistoryCompanion data) {
    return PlaceHistoryData(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      entryId: data.entryId.present ? data.entryId.value : this.entryId,
      fromSiteId: data.fromSiteId.present
          ? data.fromSiteId.value
          : this.fromSiteId,
      fromRoomId: data.fromRoomId.present
          ? data.fromRoomId.value
          : this.fromRoomId,
      fromFixtureId: data.fromFixtureId.present
          ? data.fromFixtureId.value
          : this.fromFixtureId,
      fromLevel: data.fromLevel.present ? data.fromLevel.value : this.fromLevel,
      fromCompartment: data.fromCompartment.present
          ? data.fromCompartment.value
          : this.fromCompartment,
      fromFloorXCm: data.fromFloorXCm.present
          ? data.fromFloorXCm.value
          : this.fromFloorXCm,
      fromFloorYCm: data.fromFloorYCm.present
          ? data.fromFloorYCm.value
          : this.fromFloorYCm,
      toSiteId: data.toSiteId.present ? data.toSiteId.value : this.toSiteId,
      toRoomId: data.toRoomId.present ? data.toRoomId.value : this.toRoomId,
      toFixtureId: data.toFixtureId.present
          ? data.toFixtureId.value
          : this.toFixtureId,
      toLevel: data.toLevel.present ? data.toLevel.value : this.toLevel,
      toCompartment: data.toCompartment.present
          ? data.toCompartment.value
          : this.toCompartment,
      toFloorXCm: data.toFloorXCm.present
          ? data.toFloorXCm.value
          : this.toFloorXCm,
      toFloorYCm: data.toFloorYCm.present
          ? data.toFloorYCm.value
          : this.toFloorYCm,
      movedAt: data.movedAt.present ? data.movedAt.value : this.movedAt,
      movedBy: data.movedBy.present ? data.movedBy.value : this.movedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceHistoryData(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('entryId: $entryId, ')
          ..write('fromSiteId: $fromSiteId, ')
          ..write('fromRoomId: $fromRoomId, ')
          ..write('fromFixtureId: $fromFixtureId, ')
          ..write('fromLevel: $fromLevel, ')
          ..write('fromCompartment: $fromCompartment, ')
          ..write('fromFloorXCm: $fromFloorXCm, ')
          ..write('fromFloorYCm: $fromFloorYCm, ')
          ..write('toSiteId: $toSiteId, ')
          ..write('toRoomId: $toRoomId, ')
          ..write('toFixtureId: $toFixtureId, ')
          ..write('toLevel: $toLevel, ')
          ..write('toCompartment: $toCompartment, ')
          ..write('toFloorXCm: $toFloorXCm, ')
          ..write('toFloorYCm: $toFloorYCm, ')
          ..write('movedAt: $movedAt, ')
          ..write('movedBy: $movedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    entryId,
    fromSiteId,
    fromRoomId,
    fromFixtureId,
    fromLevel,
    fromCompartment,
    fromFloorXCm,
    fromFloorYCm,
    toSiteId,
    toRoomId,
    toFixtureId,
    toLevel,
    toCompartment,
    toFloorXCm,
    toFloorYCm,
    movedAt,
    movedBy,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceHistoryData &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.entryId == this.entryId &&
          other.fromSiteId == this.fromSiteId &&
          other.fromRoomId == this.fromRoomId &&
          other.fromFixtureId == this.fromFixtureId &&
          other.fromLevel == this.fromLevel &&
          other.fromCompartment == this.fromCompartment &&
          other.fromFloorXCm == this.fromFloorXCm &&
          other.fromFloorYCm == this.fromFloorYCm &&
          other.toSiteId == this.toSiteId &&
          other.toRoomId == this.toRoomId &&
          other.toFixtureId == this.toFixtureId &&
          other.toLevel == this.toLevel &&
          other.toCompartment == this.toCompartment &&
          other.toFloorXCm == this.toFloorXCm &&
          other.toFloorYCm == this.toFloorYCm &&
          other.movedAt == this.movedAt &&
          other.movedBy == this.movedBy);
}

class PlaceHistoryCompanion extends UpdateCompanion<PlaceHistoryData> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String> entryId;
  final Value<String?> fromSiteId;
  final Value<String?> fromRoomId;
  final Value<String?> fromFixtureId;
  final Value<int?> fromLevel;
  final Value<int?> fromCompartment;
  final Value<int?> fromFloorXCm;
  final Value<int?> fromFloorYCm;
  final Value<String?> toSiteId;
  final Value<String?> toRoomId;
  final Value<String?> toFixtureId;
  final Value<int?> toLevel;
  final Value<int?> toCompartment;
  final Value<int?> toFloorXCm;
  final Value<int?> toFloorYCm;
  final Value<String> movedAt;
  final Value<String?> movedBy;
  final Value<int> rowid;
  const PlaceHistoryCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.entryId = const Value.absent(),
    this.fromSiteId = const Value.absent(),
    this.fromRoomId = const Value.absent(),
    this.fromFixtureId = const Value.absent(),
    this.fromLevel = const Value.absent(),
    this.fromCompartment = const Value.absent(),
    this.fromFloorXCm = const Value.absent(),
    this.fromFloorYCm = const Value.absent(),
    this.toSiteId = const Value.absent(),
    this.toRoomId = const Value.absent(),
    this.toFixtureId = const Value.absent(),
    this.toLevel = const Value.absent(),
    this.toCompartment = const Value.absent(),
    this.toFloorXCm = const Value.absent(),
    this.toFloorYCm = const Value.absent(),
    this.movedAt = const Value.absent(),
    this.movedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaceHistoryCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    required String entryId,
    this.fromSiteId = const Value.absent(),
    this.fromRoomId = const Value.absent(),
    this.fromFixtureId = const Value.absent(),
    this.fromLevel = const Value.absent(),
    this.fromCompartment = const Value.absent(),
    this.fromFloorXCm = const Value.absent(),
    this.fromFloorYCm = const Value.absent(),
    this.toSiteId = const Value.absent(),
    this.toRoomId = const Value.absent(),
    this.toFixtureId = const Value.absent(),
    this.toLevel = const Value.absent(),
    this.toCompartment = const Value.absent(),
    this.toFloorXCm = const Value.absent(),
    this.toFloorYCm = const Value.absent(),
    required String movedAt,
    this.movedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       entryId = Value(entryId),
       movedAt = Value(movedAt);
  static Insertable<PlaceHistoryData> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? entryId,
    Expression<String>? fromSiteId,
    Expression<String>? fromRoomId,
    Expression<String>? fromFixtureId,
    Expression<int>? fromLevel,
    Expression<int>? fromCompartment,
    Expression<int>? fromFloorXCm,
    Expression<int>? fromFloorYCm,
    Expression<String>? toSiteId,
    Expression<String>? toRoomId,
    Expression<String>? toFixtureId,
    Expression<int>? toLevel,
    Expression<int>? toCompartment,
    Expression<int>? toFloorXCm,
    Expression<int>? toFloorYCm,
    Expression<String>? movedAt,
    Expression<String>? movedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (entryId != null) 'entry_id': entryId,
      if (fromSiteId != null) 'from_site_id': fromSiteId,
      if (fromRoomId != null) 'from_room_id': fromRoomId,
      if (fromFixtureId != null) 'from_fixture_id': fromFixtureId,
      if (fromLevel != null) 'from_level': fromLevel,
      if (fromCompartment != null) 'from_compartment': fromCompartment,
      if (fromFloorXCm != null) 'from_floor_x_cm': fromFloorXCm,
      if (fromFloorYCm != null) 'from_floor_y_cm': fromFloorYCm,
      if (toSiteId != null) 'to_site_id': toSiteId,
      if (toRoomId != null) 'to_room_id': toRoomId,
      if (toFixtureId != null) 'to_fixture_id': toFixtureId,
      if (toLevel != null) 'to_level': toLevel,
      if (toCompartment != null) 'to_compartment': toCompartment,
      if (toFloorXCm != null) 'to_floor_x_cm': toFloorXCm,
      if (toFloorYCm != null) 'to_floor_y_cm': toFloorYCm,
      if (movedAt != null) 'moved_at': movedAt,
      if (movedBy != null) 'moved_by': movedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaceHistoryCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String>? entryId,
    Value<String?>? fromSiteId,
    Value<String?>? fromRoomId,
    Value<String?>? fromFixtureId,
    Value<int?>? fromLevel,
    Value<int?>? fromCompartment,
    Value<int?>? fromFloorXCm,
    Value<int?>? fromFloorYCm,
    Value<String?>? toSiteId,
    Value<String?>? toRoomId,
    Value<String?>? toFixtureId,
    Value<int?>? toLevel,
    Value<int?>? toCompartment,
    Value<int?>? toFloorXCm,
    Value<int?>? toFloorYCm,
    Value<String>? movedAt,
    Value<String?>? movedBy,
    Value<int>? rowid,
  }) {
    return PlaceHistoryCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      entryId: entryId ?? this.entryId,
      fromSiteId: fromSiteId ?? this.fromSiteId,
      fromRoomId: fromRoomId ?? this.fromRoomId,
      fromFixtureId: fromFixtureId ?? this.fromFixtureId,
      fromLevel: fromLevel ?? this.fromLevel,
      fromCompartment: fromCompartment ?? this.fromCompartment,
      fromFloorXCm: fromFloorXCm ?? this.fromFloorXCm,
      fromFloorYCm: fromFloorYCm ?? this.fromFloorYCm,
      toSiteId: toSiteId ?? this.toSiteId,
      toRoomId: toRoomId ?? this.toRoomId,
      toFixtureId: toFixtureId ?? this.toFixtureId,
      toLevel: toLevel ?? this.toLevel,
      toCompartment: toCompartment ?? this.toCompartment,
      toFloorXCm: toFloorXCm ?? this.toFloorXCm,
      toFloorYCm: toFloorYCm ?? this.toFloorYCm,
      movedAt: movedAt ?? this.movedAt,
      movedBy: movedBy ?? this.movedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (entryId.present) {
      map['entry_id'] = Variable<String>(entryId.value);
    }
    if (fromSiteId.present) {
      map['from_site_id'] = Variable<String>(fromSiteId.value);
    }
    if (fromRoomId.present) {
      map['from_room_id'] = Variable<String>(fromRoomId.value);
    }
    if (fromFixtureId.present) {
      map['from_fixture_id'] = Variable<String>(fromFixtureId.value);
    }
    if (fromLevel.present) {
      map['from_level'] = Variable<int>(fromLevel.value);
    }
    if (fromCompartment.present) {
      map['from_compartment'] = Variable<int>(fromCompartment.value);
    }
    if (fromFloorXCm.present) {
      map['from_floor_x_cm'] = Variable<int>(fromFloorXCm.value);
    }
    if (fromFloorYCm.present) {
      map['from_floor_y_cm'] = Variable<int>(fromFloorYCm.value);
    }
    if (toSiteId.present) {
      map['to_site_id'] = Variable<String>(toSiteId.value);
    }
    if (toRoomId.present) {
      map['to_room_id'] = Variable<String>(toRoomId.value);
    }
    if (toFixtureId.present) {
      map['to_fixture_id'] = Variable<String>(toFixtureId.value);
    }
    if (toLevel.present) {
      map['to_level'] = Variable<int>(toLevel.value);
    }
    if (toCompartment.present) {
      map['to_compartment'] = Variable<int>(toCompartment.value);
    }
    if (toFloorXCm.present) {
      map['to_floor_x_cm'] = Variable<int>(toFloorXCm.value);
    }
    if (toFloorYCm.present) {
      map['to_floor_y_cm'] = Variable<int>(toFloorYCm.value);
    }
    if (movedAt.present) {
      map['moved_at'] = Variable<String>(movedAt.value);
    }
    if (movedBy.present) {
      map['moved_by'] = Variable<String>(movedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaceHistoryCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('entryId: $entryId, ')
          ..write('fromSiteId: $fromSiteId, ')
          ..write('fromRoomId: $fromRoomId, ')
          ..write('fromFixtureId: $fromFixtureId, ')
          ..write('fromLevel: $fromLevel, ')
          ..write('fromCompartment: $fromCompartment, ')
          ..write('fromFloorXCm: $fromFloorXCm, ')
          ..write('fromFloorYCm: $fromFloorYCm, ')
          ..write('toSiteId: $toSiteId, ')
          ..write('toRoomId: $toRoomId, ')
          ..write('toFixtureId: $toFixtureId, ')
          ..write('toLevel: $toLevel, ')
          ..write('toCompartment: $toCompartment, ')
          ..write('toFloorXCm: $toFloorXCm, ')
          ..write('toFloorYCm: $toFloorYCm, ')
          ..write('movedAt: $movedAt, ')
          ..write('movedBy: $movedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LabelsTable extends Labels with TableInfo<$LabelsTable, Label> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<Label> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Label map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Label(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $LabelsTable createAlias(String alias) {
    return $LabelsTable(attachedDatabase, alias);
  }
}

class Label extends DataClass implements Insertable<Label> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String name;
  const Label({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    return map;
  }

  LabelsCompanion toCompanion(bool nullToAbsent) {
    return LabelsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
    );
  }

  factory Label.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Label(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
    };
  }

  Label copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    String? name,
  }) => Label(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
  );
  Label copyWithCompanion(LabelsCompanion data) {
    return Label(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Label(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    name,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Label &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name);
}

class LabelsCompanion extends UpdateCompanion<Label> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<int> rowid;
  const LabelsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabelsCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name);
  static Insertable<Label> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabelsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return LabelsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabelsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PropertyKeysTable extends PropertyKeys
    with TableInfo<$PropertyKeysTable, PropertyKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PropertyKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    name,
    unit,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'property_keys';
  @override
  VerificationContext validateIntegrity(
    Insertable<PropertyKey> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PropertyKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PropertyKey(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      ),
    );
  }

  @override
  $PropertyKeysTable createAlias(String alias) {
    return $PropertyKeysTable(attachedDatabase, alias);
  }
}

class PropertyKey extends DataClass implements Insertable<PropertyKey> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String name;
  final String? unit;
  const PropertyKey({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    required this.name,
    this.unit,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || unit != null) {
      map['unit'] = Variable<String>(unit);
    }
    return map;
  }

  PropertyKeysCompanion toCompanion(bool nullToAbsent) {
    return PropertyKeysCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      unit: unit == null && nullToAbsent ? const Value.absent() : Value(unit),
    );
  }

  factory PropertyKey.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PropertyKey(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      unit: serializer.fromJson<String?>(json['unit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'unit': serializer.toJson<String?>(unit),
    };
  }

  PropertyKey copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    String? name,
    Value<String?> unit = const Value.absent(),
  }) => PropertyKey(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    unit: unit.present ? unit.value : this.unit,
  );
  PropertyKey copyWithCompanion(PropertyKeysCompanion data) {
    return PropertyKey(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      unit: data.unit.present ? data.unit.value : this.unit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PropertyKey(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('unit: $unit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    name,
    unit,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PropertyKey &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.unit == this.unit);
}

class PropertyKeysCompanion extends UpdateCompanion<PropertyKey> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String> name;
  final Value<String?> unit;
  final Value<int> rowid;
  const PropertyKeysCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PropertyKeysCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required String name,
    this.unit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       name = Value(name);
  static Insertable<PropertyKey> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? name,
    Expression<String>? unit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (unit != null) 'unit': unit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PropertyKeysCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String>? name,
    Value<String?>? unit,
    Value<int>? rowid,
  }) {
    return PropertyKeysCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PropertyKeysCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('unit: $unit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityLabelsTable extends EntityLabels
    with TableInfo<$EntityLabelsTable, EntityLabel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityLabelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelIdMeta = const VerificationMeta(
    'labelId',
  );
  @override
  late final GeneratedColumn<String> labelId = GeneratedColumn<String>(
    'label_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    entityType,
    entityId,
    labelId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_labels';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityLabel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('label_id')) {
      context.handle(
        _labelIdMeta,
        labelId.isAcceptableOrUnknown(data['label_id']!, _labelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_labelIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntityLabel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityLabel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      labelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label_id'],
      )!,
    );
  }

  @override
  $EntityLabelsTable createAlias(String alias) {
    return $EntityLabelsTable(attachedDatabase, alias);
  }
}

class EntityLabel extends DataClass implements Insertable<EntityLabel> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;

  /// `entry`, `room`, `fixture` or `picture`.
  final String entityType;
  final String entityId;
  final String labelId;
  const EntityLabel({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    required this.entityType,
    required this.entityId,
    required this.labelId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['label_id'] = Variable<String>(labelId);
    return map;
  }

  EntityLabelsCompanion toCompanion(bool nullToAbsent) {
    return EntityLabelsCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      labelId: Value(labelId),
    );
  }

  factory EntityLabel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityLabel(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      labelId: serializer.fromJson<String>(json['labelId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'labelId': serializer.toJson<String>(labelId),
    };
  }

  EntityLabel copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? entityType,
    String? entityId,
    String? labelId,
  }) => EntityLabel(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    labelId: labelId ?? this.labelId,
  );
  EntityLabel copyWithCompanion(EntityLabelsCompanion data) {
    return EntityLabel(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      labelId: data.labelId.present ? data.labelId.value : this.labelId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityLabel(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('labelId: $labelId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    entityType,
    entityId,
    labelId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityLabel &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.labelId == this.labelId);
}

class EntityLabelsCompanion extends UpdateCompanion<EntityLabel> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> labelId;
  final Value<int> rowid;
  const EntityLabelsCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.labelId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityLabelsCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String labelId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       labelId = Value(labelId);
  static Insertable<EntityLabel> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? labelId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (labelId != null) 'label_id': labelId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityLabelsCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? labelId,
    Value<int>? rowid,
  }) {
    return EntityLabelsCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      labelId: labelId ?? this.labelId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (labelId.present) {
      map['label_id'] = Variable<String>(labelId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityLabelsCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('labelId: $labelId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntityPropertiesTable extends EntityProperties
    with TableInfo<$EntityPropertiesTable, EntityProperty> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntityPropertiesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByMeta = const VerificationMeta(
    'createdBy',
  );
  @override
  late final GeneratedColumn<String> createdBy = GeneratedColumn<String>(
    'created_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
    'updated_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedByMeta = const VerificationMeta(
    'updatedBy',
  );
  @override
  late final GeneratedColumn<String> updatedBy = GeneratedColumn<String>(
    'updated_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyIdMeta = const VerificationMeta('keyId');
  @override
  late final GeneratedColumn<String> keyId = GeneratedColumn<String>(
    'key_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta(
    'valueText',
  );
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _valueNumberMeta = const VerificationMeta(
    'valueNumber',
  );
  @override
  late final GeneratedColumn<String> valueNumber = GeneratedColumn<String>(
    'value_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    entityType,
    entityId,
    keyId,
    valueText,
    valueNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entity_properties';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntityProperty> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('created_by')) {
      context.handle(
        _createdByMeta,
        createdBy.isAcceptableOrUnknown(data['created_by']!, _createdByMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('updated_by')) {
      context.handle(
        _updatedByMeta,
        updatedBy.isAcceptableOrUnknown(data['updated_by']!, _updatedByMeta),
      );
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('key_id')) {
      context.handle(
        _keyIdMeta,
        keyId.isAcceptableOrUnknown(data['key_id']!, _keyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_keyIdMeta);
    }
    if (data.containsKey('value_text')) {
      context.handle(
        _valueTextMeta,
        valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta),
      );
    }
    if (data.containsKey('value_number')) {
      context.handle(
        _valueNumberMeta,
        valueNumber.isAcceptableOrUnknown(
          data['value_number']!,
          _valueNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntityProperty map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntityProperty(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      ),
      createdBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_at'],
      ),
      updatedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}updated_by'],
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      keyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key_id'],
      )!,
      valueText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_text'],
      ),
      valueNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value_number'],
      ),
    );
  }

  @override
  $EntityPropertiesTable createAlias(String alias) {
    return $EntityPropertiesTable(attachedDatabase, alias);
  }
}

class EntityProperty extends DataClass implements Insertable<EntityProperty> {
  final String id;
  final String workspaceId;
  final String? createdAt;
  final String? createdBy;
  final String? updatedAt;
  final String? updatedBy;
  final int? revision;
  final String? deletedAt;
  final String? customerId;

  /// `entry`, `room`, `fixture` or `picture`.
  final String entityType;
  final String entityId;
  final String keyId;
  final String? valueText;

  /// The contract's decimal as text, never a float (D-434).
  final String? valueNumber;
  const EntityProperty({
    required this.id,
    required this.workspaceId,
    this.createdAt,
    this.createdBy,
    this.updatedAt,
    this.updatedBy,
    this.revision,
    this.deletedAt,
    this.customerId,
    required this.entityType,
    required this.entityId,
    required this.keyId,
    this.valueText,
    this.valueNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['workspace_id'] = Variable<String>(workspaceId);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<String>(createdAt);
    }
    if (!nullToAbsent || createdBy != null) {
      map['created_by'] = Variable<String>(createdBy);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<String>(updatedAt);
    }
    if (!nullToAbsent || updatedBy != null) {
      map['updated_by'] = Variable<String>(updatedBy);
    }
    if (!nullToAbsent || revision != null) {
      map['revision'] = Variable<int>(revision);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['key_id'] = Variable<String>(keyId);
    if (!nullToAbsent || valueText != null) {
      map['value_text'] = Variable<String>(valueText);
    }
    if (!nullToAbsent || valueNumber != null) {
      map['value_number'] = Variable<String>(valueNumber);
    }
    return map;
  }

  EntityPropertiesCompanion toCompanion(bool nullToAbsent) {
    return EntityPropertiesCompanion(
      id: Value(id),
      workspaceId: Value(workspaceId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      createdBy: createdBy == null && nullToAbsent
          ? const Value.absent()
          : Value(createdBy),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      updatedBy: updatedBy == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedBy),
      revision: revision == null && nullToAbsent
          ? const Value.absent()
          : Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      keyId: Value(keyId),
      valueText: valueText == null && nullToAbsent
          ? const Value.absent()
          : Value(valueText),
      valueNumber: valueNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(valueNumber),
    );
  }

  factory EntityProperty.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntityProperty(
      id: serializer.fromJson<String>(json['id']),
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      createdAt: serializer.fromJson<String?>(json['createdAt']),
      createdBy: serializer.fromJson<String?>(json['createdBy']),
      updatedAt: serializer.fromJson<String?>(json['updatedAt']),
      updatedBy: serializer.fromJson<String?>(json['updatedBy']),
      revision: serializer.fromJson<int?>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      keyId: serializer.fromJson<String>(json['keyId']),
      valueText: serializer.fromJson<String?>(json['valueText']),
      valueNumber: serializer.fromJson<String?>(json['valueNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'workspaceId': serializer.toJson<String>(workspaceId),
      'createdAt': serializer.toJson<String?>(createdAt),
      'createdBy': serializer.toJson<String?>(createdBy),
      'updatedAt': serializer.toJson<String?>(updatedAt),
      'updatedBy': serializer.toJson<String?>(updatedBy),
      'revision': serializer.toJson<int?>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'customerId': serializer.toJson<String?>(customerId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'keyId': serializer.toJson<String>(keyId),
      'valueText': serializer.toJson<String?>(valueText),
      'valueNumber': serializer.toJson<String?>(valueNumber),
    };
  }

  EntityProperty copyWith({
    String? id,
    String? workspaceId,
    Value<String?> createdAt = const Value.absent(),
    Value<String?> createdBy = const Value.absent(),
    Value<String?> updatedAt = const Value.absent(),
    Value<String?> updatedBy = const Value.absent(),
    Value<int?> revision = const Value.absent(),
    Value<String?> deletedAt = const Value.absent(),
    Value<String?> customerId = const Value.absent(),
    String? entityType,
    String? entityId,
    String? keyId,
    Value<String?> valueText = const Value.absent(),
    Value<String?> valueNumber = const Value.absent(),
  }) => EntityProperty(
    id: id ?? this.id,
    workspaceId: workspaceId ?? this.workspaceId,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    createdBy: createdBy.present ? createdBy.value : this.createdBy,
    updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
    updatedBy: updatedBy.present ? updatedBy.value : this.updatedBy,
    revision: revision.present ? revision.value : this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    customerId: customerId.present ? customerId.value : this.customerId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    keyId: keyId ?? this.keyId,
    valueText: valueText.present ? valueText.value : this.valueText,
    valueNumber: valueNumber.present ? valueNumber.value : this.valueNumber,
  );
  EntityProperty copyWithCompanion(EntityPropertiesCompanion data) {
    return EntityProperty(
      id: data.id.present ? data.id.value : this.id,
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      createdBy: data.createdBy.present ? data.createdBy.value : this.createdBy,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      updatedBy: data.updatedBy.present ? data.updatedBy.value : this.updatedBy,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      keyId: data.keyId.present ? data.keyId.value : this.keyId,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
      valueNumber: data.valueNumber.present
          ? data.valueNumber.value
          : this.valueNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntityProperty(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('keyId: $keyId, ')
          ..write('valueText: $valueText, ')
          ..write('valueNumber: $valueNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    workspaceId,
    createdAt,
    createdBy,
    updatedAt,
    updatedBy,
    revision,
    deletedAt,
    customerId,
    entityType,
    entityId,
    keyId,
    valueText,
    valueNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntityProperty &&
          other.id == this.id &&
          other.workspaceId == this.workspaceId &&
          other.createdAt == this.createdAt &&
          other.createdBy == this.createdBy &&
          other.updatedAt == this.updatedAt &&
          other.updatedBy == this.updatedBy &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.customerId == this.customerId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.keyId == this.keyId &&
          other.valueText == this.valueText &&
          other.valueNumber == this.valueNumber);
}

class EntityPropertiesCompanion extends UpdateCompanion<EntityProperty> {
  final Value<String> id;
  final Value<String> workspaceId;
  final Value<String?> createdAt;
  final Value<String?> createdBy;
  final Value<String?> updatedAt;
  final Value<String?> updatedBy;
  final Value<int?> revision;
  final Value<String?> deletedAt;
  final Value<String?> customerId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> keyId;
  final Value<String?> valueText;
  final Value<String?> valueNumber;
  final Value<int> rowid;
  const EntityPropertiesCompanion({
    this.id = const Value.absent(),
    this.workspaceId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.keyId = const Value.absent(),
    this.valueText = const Value.absent(),
    this.valueNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntityPropertiesCompanion.insert({
    required String id,
    required String workspaceId,
    this.createdAt = const Value.absent(),
    this.createdBy = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.updatedBy = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.customerId = const Value.absent(),
    required String entityType,
    required String entityId,
    required String keyId,
    this.valueText = const Value.absent(),
    this.valueNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       workspaceId = Value(workspaceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       keyId = Value(keyId);
  static Insertable<EntityProperty> custom({
    Expression<String>? id,
    Expression<String>? workspaceId,
    Expression<String>? createdAt,
    Expression<String>? createdBy,
    Expression<String>? updatedAt,
    Expression<String>? updatedBy,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? customerId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? keyId,
    Expression<String>? valueText,
    Expression<String>? valueNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (createdAt != null) 'created_at': createdAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (updatedBy != null) 'updated_by': updatedBy,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (customerId != null) 'customer_id': customerId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (keyId != null) 'key_id': keyId,
      if (valueText != null) 'value_text': valueText,
      if (valueNumber != null) 'value_number': valueNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntityPropertiesCompanion copyWith({
    Value<String>? id,
    Value<String>? workspaceId,
    Value<String?>? createdAt,
    Value<String?>? createdBy,
    Value<String?>? updatedAt,
    Value<String?>? updatedBy,
    Value<int?>? revision,
    Value<String?>? deletedAt,
    Value<String?>? customerId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? keyId,
    Value<String?>? valueText,
    Value<String?>? valueNumber,
    Value<int>? rowid,
  }) {
    return EntityPropertiesCompanion(
      id: id ?? this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      customerId: customerId ?? this.customerId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      keyId: keyId ?? this.keyId,
      valueText: valueText ?? this.valueText,
      valueNumber: valueNumber ?? this.valueNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (createdBy.present) {
      map['created_by'] = Variable<String>(createdBy.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (updatedBy.present) {
      map['updated_by'] = Variable<String>(updatedBy.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (keyId.present) {
      map['key_id'] = Variable<String>(keyId.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (valueNumber.present) {
      map['value_number'] = Variable<String>(valueNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntityPropertiesCompanion(')
          ..write('id: $id, ')
          ..write('workspaceId: $workspaceId, ')
          ..write('createdAt: $createdAt, ')
          ..write('createdBy: $createdBy, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('updatedBy: $updatedBy, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('customerId: $customerId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('keyId: $keyId, ')
          ..write('valueText: $valueText, ')
          ..write('valueNumber: $valueNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    check: () => op.isIn(outboxOps),
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant<String>('upsert'),
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseRevisionMeta = const VerificationMeta(
    'baseRevision',
  );
  @override
  late final GeneratedColumn<int> baseRevision = GeneratedColumn<int>(
    'base_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta(
    'deviceTime',
  );
  @override
  late final GeneratedColumn<String> deviceTime = GeneratedColumn<String>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    seq,
    changeId,
    entity,
    entityId,
    op,
    fields,
    baseRevision,
    deviceTime,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    }
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_changeIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('base_revision')) {
      context.handle(
        _baseRevisionMeta,
        baseRevision.isAcceptableOrUnknown(
          data['base_revision']!,
          _baseRevisionMeta,
        ),
      );
    }
    if (data.containsKey('device_time')) {
      context.handle(
        _deviceTimeMeta,
        deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {seq};
  @override
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      baseRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_revision'],
      ),
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_time'],
      )!,
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  /// Insertion order; the order changes are pushed in.
  final int seq;
  final String changeId;
  final String entity;
  final String entityId;

  /// What the change does; rows of schema v1 were all upserts. The check
  /// names its own column, drift's documented form for a column check.
  final String op;

  /// The changed fields only, as a JSON object.
  final String fields;
  final int? baseRevision;
  final String deviceTime;
  const OutboxData({
    required this.seq,
    required this.changeId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.fields,
    this.baseRevision,
    required this.deviceTime,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['seq'] = Variable<int>(seq);
    map['change_id'] = Variable<String>(changeId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['fields'] = Variable<String>(fields);
    if (!nullToAbsent || baseRevision != null) {
      map['base_revision'] = Variable<int>(baseRevision);
    }
    map['device_time'] = Variable<String>(deviceTime);
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      seq: Value(seq),
      changeId: Value(changeId),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      fields: Value(fields),
      baseRevision: baseRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(baseRevision),
      deviceTime: Value(deviceTime),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      seq: serializer.fromJson<int>(json['seq']),
      changeId: serializer.fromJson<String>(json['changeId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      fields: serializer.fromJson<String>(json['fields']),
      baseRevision: serializer.fromJson<int?>(json['baseRevision']),
      deviceTime: serializer.fromJson<String>(json['deviceTime']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'seq': serializer.toJson<int>(seq),
      'changeId': serializer.toJson<String>(changeId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'fields': serializer.toJson<String>(fields),
      'baseRevision': serializer.toJson<int?>(baseRevision),
      'deviceTime': serializer.toJson<String>(deviceTime),
    };
  }

  OutboxData copyWith({
    int? seq,
    String? changeId,
    String? entity,
    String? entityId,
    String? op,
    String? fields,
    Value<int?> baseRevision = const Value.absent(),
    String? deviceTime,
  }) => OutboxData(
    seq: seq ?? this.seq,
    changeId: changeId ?? this.changeId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    fields: fields ?? this.fields,
    baseRevision: baseRevision.present ? baseRevision.value : this.baseRevision,
    deviceTime: deviceTime ?? this.deviceTime,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      seq: data.seq.present ? data.seq.value : this.seq,
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      fields: data.fields.present ? data.fields.value : this.fields,
      baseRevision: data.baseRevision.present
          ? data.baseRevision.value
          : this.baseRevision,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('seq: $seq, ')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('deviceTime: $deviceTime')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    seq,
    changeId,
    entity,
    entityId,
    op,
    fields,
    baseRevision,
    deviceTime,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.seq == this.seq &&
          other.changeId == this.changeId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.fields == this.fields &&
          other.baseRevision == this.baseRevision &&
          other.deviceTime == this.deviceTime);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> seq;
  final Value<String> changeId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> fields;
  final Value<int?> baseRevision;
  final Value<String> deviceTime;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.changeId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.fields = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.deviceTime = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String changeId,
    required String entity,
    required String entityId,
    this.op = const Value.absent(),
    required String fields,
    this.baseRevision = const Value.absent(),
    required String deviceTime,
  }) : changeId = Value(changeId),
       entity = Value(entity),
       entityId = Value(entityId),
       fields = Value(fields),
       deviceTime = Value(deviceTime);
  static Insertable<OutboxData> custom({
    Expression<int>? seq,
    Expression<String>? changeId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? fields,
    Expression<int>? baseRevision,
    Expression<String>? deviceTime,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (changeId != null) 'change_id': changeId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (fields != null) 'fields': fields,
      if (baseRevision != null) 'base_revision': baseRevision,
      if (deviceTime != null) 'device_time': deviceTime,
    });
  }

  OutboxCompanion copyWith({
    Value<int>? seq,
    Value<String>? changeId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? fields,
    Value<int?>? baseRevision,
    Value<String>? deviceTime,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      changeId: changeId ?? this.changeId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      fields: fields ?? this.fields,
      baseRevision: baseRevision ?? this.baseRevision,
      deviceTime: deviceTime ?? this.deviceTime,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (baseRevision.present) {
      map['base_revision'] = Variable<int>(baseRevision.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<String>(deviceTime.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('seq: $seq, ')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('baseRevision: $baseRevision, ')
          ..write('deviceTime: $deviceTime')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _workspaceIdMeta = const VerificationMeta(
    'workspaceId',
  );
  @override
  late final GeneratedColumn<String> workspaceId = GeneratedColumn<String>(
    'workspace_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastRevisionMeta = const VerificationMeta(
    'lastRevision',
  );
  @override
  late final GeneratedColumn<int> lastRevision = GeneratedColumn<int>(
    'last_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [workspaceId, lastRevision];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('workspace_id')) {
      context.handle(
        _workspaceIdMeta,
        workspaceId.isAcceptableOrUnknown(
          data['workspace_id']!,
          _workspaceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_workspaceIdMeta);
    }
    if (data.containsKey('last_revision')) {
      context.handle(
        _lastRevisionMeta,
        lastRevision.isAcceptableOrUnknown(
          data['last_revision']!,
          _lastRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastRevisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {workspaceId};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      workspaceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}workspace_id'],
      )!,
      lastRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_revision'],
      )!,
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String workspaceId;
  final int lastRevision;
  const SyncStateData({required this.workspaceId, required this.lastRevision});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['workspace_id'] = Variable<String>(workspaceId);
    map['last_revision'] = Variable<int>(lastRevision);
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      workspaceId: Value(workspaceId),
      lastRevision: Value(lastRevision),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      workspaceId: serializer.fromJson<String>(json['workspaceId']),
      lastRevision: serializer.fromJson<int>(json['lastRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'workspaceId': serializer.toJson<String>(workspaceId),
      'lastRevision': serializer.toJson<int>(lastRevision),
    };
  }

  SyncStateData copyWith({String? workspaceId, int? lastRevision}) =>
      SyncStateData(
        workspaceId: workspaceId ?? this.workspaceId,
        lastRevision: lastRevision ?? this.lastRevision,
      );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      workspaceId: data.workspaceId.present
          ? data.workspaceId.value
          : this.workspaceId,
      lastRevision: data.lastRevision.present
          ? data.lastRevision.value
          : this.lastRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('workspaceId: $workspaceId, ')
          ..write('lastRevision: $lastRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(workspaceId, lastRevision);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.workspaceId == this.workspaceId &&
          other.lastRevision == this.lastRevision);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> workspaceId;
  final Value<int> lastRevision;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.workspaceId = const Value.absent(),
    this.lastRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String workspaceId,
    required int lastRevision,
    this.rowid = const Value.absent(),
  }) : workspaceId = Value(workspaceId),
       lastRevision = Value(lastRevision);
  static Insertable<SyncStateData> custom({
    Expression<String>? workspaceId,
    Expression<int>? lastRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (workspaceId != null) 'workspace_id': workspaceId,
      if (lastRevision != null) 'last_revision': lastRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? workspaceId,
    Value<int>? lastRevision,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      workspaceId: workspaceId ?? this.workspaceId,
      lastRevision: lastRevision ?? this.lastRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (workspaceId.present) {
      map['workspace_id'] = Variable<String>(workspaceId.value);
    }
    if (lastRevision.present) {
      map['last_revision'] = Variable<int>(lastRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('workspaceId: $workspaceId, ')
          ..write('lastRevision: $lastRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ServerRecordsTable extends ServerRecords
    with TableInfo<$ServerRecordsTable, ServerRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServerRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<String> deletedAt = GeneratedColumn<String>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    entity,
    id,
    revision,
    deletedAt,
    fields,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'server_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServerRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity, id};
  @override
  ServerRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServerRecord(
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deleted_at'],
      ),
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
    );
  }

  @override
  $ServerRecordsTable createAlias(String alias) {
    return $ServerRecordsTable(attachedDatabase, alias);
  }
}

class ServerRecord extends DataClass implements Insertable<ServerRecord> {
  final String entity;
  final String id;
  final int revision;
  final String? deletedAt;

  /// The whole record as a JSON object.
  final String fields;
  const ServerRecord({
    required this.entity,
    required this.id,
    required this.revision,
    this.deletedAt,
    required this.fields,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['id'] = Variable<String>(id);
    map['revision'] = Variable<int>(revision);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<String>(deletedAt);
    }
    map['fields'] = Variable<String>(fields);
    return map;
  }

  ServerRecordsCompanion toCompanion(bool nullToAbsent) {
    return ServerRecordsCompanion(
      entity: Value(entity),
      id: Value(id),
      revision: Value(revision),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      fields: Value(fields),
    );
  }

  factory ServerRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServerRecord(
      entity: serializer.fromJson<String>(json['entity']),
      id: serializer.fromJson<String>(json['id']),
      revision: serializer.fromJson<int>(json['revision']),
      deletedAt: serializer.fromJson<String?>(json['deletedAt']),
      fields: serializer.fromJson<String>(json['fields']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'id': serializer.toJson<String>(id),
      'revision': serializer.toJson<int>(revision),
      'deletedAt': serializer.toJson<String?>(deletedAt),
      'fields': serializer.toJson<String>(fields),
    };
  }

  ServerRecord copyWith({
    String? entity,
    String? id,
    int? revision,
    Value<String?> deletedAt = const Value.absent(),
    String? fields,
  }) => ServerRecord(
    entity: entity ?? this.entity,
    id: id ?? this.id,
    revision: revision ?? this.revision,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    fields: fields ?? this.fields,
  );
  ServerRecord copyWithCompanion(ServerRecordsCompanion data) {
    return ServerRecord(
      entity: data.entity.present ? data.entity.value : this.entity,
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      fields: data.fields.present ? data.fields.value : this.fields,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServerRecord(')
          ..write('entity: $entity, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fields: $fields')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, id, revision, deletedAt, fields);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServerRecord &&
          other.entity == this.entity &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.deletedAt == this.deletedAt &&
          other.fields == this.fields);
}

class ServerRecordsCompanion extends UpdateCompanion<ServerRecord> {
  final Value<String> entity;
  final Value<String> id;
  final Value<int> revision;
  final Value<String?> deletedAt;
  final Value<String> fields;
  final Value<int> rowid;
  const ServerRecordsCompanion({
    this.entity = const Value.absent(),
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.fields = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ServerRecordsCompanion.insert({
    required String entity,
    required String id,
    required int revision,
    this.deletedAt = const Value.absent(),
    required String fields,
    this.rowid = const Value.absent(),
  }) : entity = Value(entity),
       id = Value(id),
       revision = Value(revision),
       fields = Value(fields);
  static Insertable<ServerRecord> custom({
    Expression<String>? entity,
    Expression<String>? id,
    Expression<int>? revision,
    Expression<String>? deletedAt,
    Expression<String>? fields,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (fields != null) 'fields': fields,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ServerRecordsCompanion copyWith({
    Value<String>? entity,
    Value<String>? id,
    Value<int>? revision,
    Value<String?>? deletedAt,
    Value<String>? fields,
    Value<int>? rowid,
  }) {
    return ServerRecordsCompanion(
      entity: entity ?? this.entity,
      id: id ?? this.id,
      revision: revision ?? this.revision,
      deletedAt: deletedAt ?? this.deletedAt,
      fields: fields ?? this.fields,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<String>(deletedAt.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServerRecordsCompanion(')
          ..write('entity: $entity, ')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('fields: $fields, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RejectedChangesTable extends RejectedChanges
    with TableInfo<$RejectedChangesTable, RejectedChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RejectedChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _changeIdMeta = const VerificationMeta(
    'changeId',
  );
  @override
  late final GeneratedColumn<String> changeId = GeneratedColumn<String>(
    'change_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
    'fields',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceTimeMeta = const VerificationMeta(
    'deviceTime',
  );
  @override
  late final GeneratedColumn<String> deviceTime = GeneratedColumn<String>(
    'device_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _existingIdMeta = const VerificationMeta(
    'existingId',
  );
  @override
  late final GeneratedColumn<String> existingId = GeneratedColumn<String>(
    'existing_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rejectedAtMeta = const VerificationMeta(
    'rejectedAt',
  );
  @override
  late final GeneratedColumn<String> rejectedAt = GeneratedColumn<String>(
    'rejected_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    changeId,
    entity,
    entityId,
    op,
    fields,
    deviceTime,
    reason,
    existingId,
    rejectedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rejected_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RejectedChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('change_id')) {
      context.handle(
        _changeIdMeta,
        changeId.isAcceptableOrUnknown(data['change_id']!, _changeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_changeIdMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('fields')) {
      context.handle(
        _fieldsMeta,
        fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('device_time')) {
      context.handle(
        _deviceTimeMeta,
        deviceTime.isAcceptableOrUnknown(data['device_time']!, _deviceTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceTimeMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('existing_id')) {
      context.handle(
        _existingIdMeta,
        existingId.isAcceptableOrUnknown(data['existing_id']!, _existingIdMeta),
      );
    }
    if (data.containsKey('rejected_at')) {
      context.handle(
        _rejectedAtMeta,
        rejectedAt.isAcceptableOrUnknown(data['rejected_at']!, _rejectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_rejectedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {changeId};
  @override
  RejectedChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RejectedChange(
      changeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}change_id'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      fields: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fields'],
      )!,
      deviceTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_time'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      existingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}existing_id'],
      ),
      rejectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rejected_at'],
      )!,
    );
  }

  @override
  $RejectedChangesTable createAlias(String alias) {
    return $RejectedChangesTable(attachedDatabase, alias);
  }
}

class RejectedChange extends DataClass implements Insertable<RejectedChange> {
  final String changeId;
  final String entity;
  final String entityId;
  final String op;

  /// The changed fields as a JSON object, as they were queued.
  final String fields;
  final String deviceTime;

  /// The server's reason, or a local one (`too_large`) (D-199).
  final String reason;

  /// With `duplicate`: the record that already held the value (D-198).
  final String? existingId;
  final String rejectedAt;
  const RejectedChange({
    required this.changeId,
    required this.entity,
    required this.entityId,
    required this.op,
    required this.fields,
    required this.deviceTime,
    required this.reason,
    this.existingId,
    required this.rejectedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['change_id'] = Variable<String>(changeId);
    map['entity'] = Variable<String>(entity);
    map['entity_id'] = Variable<String>(entityId);
    map['op'] = Variable<String>(op);
    map['fields'] = Variable<String>(fields);
    map['device_time'] = Variable<String>(deviceTime);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || existingId != null) {
      map['existing_id'] = Variable<String>(existingId);
    }
    map['rejected_at'] = Variable<String>(rejectedAt);
    return map;
  }

  RejectedChangesCompanion toCompanion(bool nullToAbsent) {
    return RejectedChangesCompanion(
      changeId: Value(changeId),
      entity: Value(entity),
      entityId: Value(entityId),
      op: Value(op),
      fields: Value(fields),
      deviceTime: Value(deviceTime),
      reason: Value(reason),
      existingId: existingId == null && nullToAbsent
          ? const Value.absent()
          : Value(existingId),
      rejectedAt: Value(rejectedAt),
    );
  }

  factory RejectedChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RejectedChange(
      changeId: serializer.fromJson<String>(json['changeId']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<String>(json['entityId']),
      op: serializer.fromJson<String>(json['op']),
      fields: serializer.fromJson<String>(json['fields']),
      deviceTime: serializer.fromJson<String>(json['deviceTime']),
      reason: serializer.fromJson<String>(json['reason']),
      existingId: serializer.fromJson<String?>(json['existingId']),
      rejectedAt: serializer.fromJson<String>(json['rejectedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'changeId': serializer.toJson<String>(changeId),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<String>(entityId),
      'op': serializer.toJson<String>(op),
      'fields': serializer.toJson<String>(fields),
      'deviceTime': serializer.toJson<String>(deviceTime),
      'reason': serializer.toJson<String>(reason),
      'existingId': serializer.toJson<String?>(existingId),
      'rejectedAt': serializer.toJson<String>(rejectedAt),
    };
  }

  RejectedChange copyWith({
    String? changeId,
    String? entity,
    String? entityId,
    String? op,
    String? fields,
    String? deviceTime,
    String? reason,
    Value<String?> existingId = const Value.absent(),
    String? rejectedAt,
  }) => RejectedChange(
    changeId: changeId ?? this.changeId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
    op: op ?? this.op,
    fields: fields ?? this.fields,
    deviceTime: deviceTime ?? this.deviceTime,
    reason: reason ?? this.reason,
    existingId: existingId.present ? existingId.value : this.existingId,
    rejectedAt: rejectedAt ?? this.rejectedAt,
  );
  RejectedChange copyWithCompanion(RejectedChangesCompanion data) {
    return RejectedChange(
      changeId: data.changeId.present ? data.changeId.value : this.changeId,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      op: data.op.present ? data.op.value : this.op,
      fields: data.fields.present ? data.fields.value : this.fields,
      deviceTime: data.deviceTime.present
          ? data.deviceTime.value
          : this.deviceTime,
      reason: data.reason.present ? data.reason.value : this.reason,
      existingId: data.existingId.present
          ? data.existingId.value
          : this.existingId,
      rejectedAt: data.rejectedAt.present
          ? data.rejectedAt.value
          : this.rejectedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RejectedChange(')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('reason: $reason, ')
          ..write('existingId: $existingId, ')
          ..write('rejectedAt: $rejectedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    changeId,
    entity,
    entityId,
    op,
    fields,
    deviceTime,
    reason,
    existingId,
    rejectedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RejectedChange &&
          other.changeId == this.changeId &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.op == this.op &&
          other.fields == this.fields &&
          other.deviceTime == this.deviceTime &&
          other.reason == this.reason &&
          other.existingId == this.existingId &&
          other.rejectedAt == this.rejectedAt);
}

class RejectedChangesCompanion extends UpdateCompanion<RejectedChange> {
  final Value<String> changeId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> op;
  final Value<String> fields;
  final Value<String> deviceTime;
  final Value<String> reason;
  final Value<String?> existingId;
  final Value<String> rejectedAt;
  final Value<int> rowid;
  const RejectedChangesCompanion({
    this.changeId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.op = const Value.absent(),
    this.fields = const Value.absent(),
    this.deviceTime = const Value.absent(),
    this.reason = const Value.absent(),
    this.existingId = const Value.absent(),
    this.rejectedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RejectedChangesCompanion.insert({
    required String changeId,
    required String entity,
    required String entityId,
    required String op,
    required String fields,
    required String deviceTime,
    required String reason,
    this.existingId = const Value.absent(),
    required String rejectedAt,
    this.rowid = const Value.absent(),
  }) : changeId = Value(changeId),
       entity = Value(entity),
       entityId = Value(entityId),
       op = Value(op),
       fields = Value(fields),
       deviceTime = Value(deviceTime),
       reason = Value(reason),
       rejectedAt = Value(rejectedAt);
  static Insertable<RejectedChange> custom({
    Expression<String>? changeId,
    Expression<String>? entity,
    Expression<String>? entityId,
    Expression<String>? op,
    Expression<String>? fields,
    Expression<String>? deviceTime,
    Expression<String>? reason,
    Expression<String>? existingId,
    Expression<String>? rejectedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (changeId != null) 'change_id': changeId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (op != null) 'op': op,
      if (fields != null) 'fields': fields,
      if (deviceTime != null) 'device_time': deviceTime,
      if (reason != null) 'reason': reason,
      if (existingId != null) 'existing_id': existingId,
      if (rejectedAt != null) 'rejected_at': rejectedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RejectedChangesCompanion copyWith({
    Value<String>? changeId,
    Value<String>? entity,
    Value<String>? entityId,
    Value<String>? op,
    Value<String>? fields,
    Value<String>? deviceTime,
    Value<String>? reason,
    Value<String?>? existingId,
    Value<String>? rejectedAt,
    Value<int>? rowid,
  }) {
    return RejectedChangesCompanion(
      changeId: changeId ?? this.changeId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      op: op ?? this.op,
      fields: fields ?? this.fields,
      deviceTime: deviceTime ?? this.deviceTime,
      reason: reason ?? this.reason,
      existingId: existingId ?? this.existingId,
      rejectedAt: rejectedAt ?? this.rejectedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (changeId.present) {
      map['change_id'] = Variable<String>(changeId.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (deviceTime.present) {
      map['device_time'] = Variable<String>(deviceTime.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (existingId.present) {
      map['existing_id'] = Variable<String>(existingId.value);
    }
    if (rejectedAt.present) {
      map['rejected_at'] = Variable<String>(rejectedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RejectedChangesCompanion(')
          ..write('changeId: $changeId, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('op: $op, ')
          ..write('fields: $fields, ')
          ..write('deviceTime: $deviceTime, ')
          ..write('reason: $reason, ')
          ..write('existingId: $existingId, ')
          ..write('rejectedAt: $rejectedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UploadsTable extends Uploads with TableInfo<$UploadsTable, Upload> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UploadsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _sha256Meta = const VerificationMeta('sha256');
  @override
  late final GeneratedColumn<String> sha256 = GeneratedColumn<String>(
    'sha256',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeMeta = const VerificationMeta('size');
  @override
  late final GeneratedColumn<int> size = GeneratedColumn<int>(
    'size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _failedReasonMeta = const VerificationMeta(
    'failedReason',
  );
  @override
  late final GeneratedColumn<String> failedReason = GeneratedColumn<String>(
    'failed_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    sha256,
    path,
    size,
    createdAt,
    failedReason,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uploads';
  @override
  VerificationContext validateIntegrity(
    Insertable<Upload> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('sha256')) {
      context.handle(
        _sha256Meta,
        sha256.isAcceptableOrUnknown(data['sha256']!, _sha256Meta),
      );
    } else if (isInserting) {
      context.missing(_sha256Meta);
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('size')) {
      context.handle(
        _sizeMeta,
        size.isAcceptableOrUnknown(data['size']!, _sizeMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('failed_reason')) {
      context.handle(
        _failedReasonMeta,
        failedReason.isAcceptableOrUnknown(
          data['failed_reason']!,
          _failedReasonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {sha256};
  @override
  Upload map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Upload(
      sha256: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sha256'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      size: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_at'],
      )!,
      failedReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}failed_reason'],
      ),
    );
  }

  @override
  $UploadsTable createAlias(String alias) {
    return $UploadsTable(attachedDatabase, alias);
  }
}

class Upload extends DataClass implements Insertable<Upload> {
  final String sha256;

  /// The app's own copy of the file.
  final String path;
  final int size;
  final String createdAt;

  /// Null while the upload is pending.
  final String? failedReason;
  const Upload({
    required this.sha256,
    required this.path,
    required this.size,
    required this.createdAt,
    this.failedReason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['sha256'] = Variable<String>(sha256);
    map['path'] = Variable<String>(path);
    map['size'] = Variable<int>(size);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || failedReason != null) {
      map['failed_reason'] = Variable<String>(failedReason);
    }
    return map;
  }

  UploadsCompanion toCompanion(bool nullToAbsent) {
    return UploadsCompanion(
      sha256: Value(sha256),
      path: Value(path),
      size: Value(size),
      createdAt: Value(createdAt),
      failedReason: failedReason == null && nullToAbsent
          ? const Value.absent()
          : Value(failedReason),
    );
  }

  factory Upload.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Upload(
      sha256: serializer.fromJson<String>(json['sha256']),
      path: serializer.fromJson<String>(json['path']),
      size: serializer.fromJson<int>(json['size']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      failedReason: serializer.fromJson<String?>(json['failedReason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'sha256': serializer.toJson<String>(sha256),
      'path': serializer.toJson<String>(path),
      'size': serializer.toJson<int>(size),
      'createdAt': serializer.toJson<String>(createdAt),
      'failedReason': serializer.toJson<String?>(failedReason),
    };
  }

  Upload copyWith({
    String? sha256,
    String? path,
    int? size,
    String? createdAt,
    Value<String?> failedReason = const Value.absent(),
  }) => Upload(
    sha256: sha256 ?? this.sha256,
    path: path ?? this.path,
    size: size ?? this.size,
    createdAt: createdAt ?? this.createdAt,
    failedReason: failedReason.present ? failedReason.value : this.failedReason,
  );
  Upload copyWithCompanion(UploadsCompanion data) {
    return Upload(
      sha256: data.sha256.present ? data.sha256.value : this.sha256,
      path: data.path.present ? data.path.value : this.path,
      size: data.size.present ? data.size.value : this.size,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      failedReason: data.failedReason.present
          ? data.failedReason.value
          : this.failedReason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Upload(')
          ..write('sha256: $sha256, ')
          ..write('path: $path, ')
          ..write('size: $size, ')
          ..write('createdAt: $createdAt, ')
          ..write('failedReason: $failedReason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(sha256, path, size, createdAt, failedReason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Upload &&
          other.sha256 == this.sha256 &&
          other.path == this.path &&
          other.size == this.size &&
          other.createdAt == this.createdAt &&
          other.failedReason == this.failedReason);
}

class UploadsCompanion extends UpdateCompanion<Upload> {
  final Value<String> sha256;
  final Value<String> path;
  final Value<int> size;
  final Value<String> createdAt;
  final Value<String?> failedReason;
  final Value<int> rowid;
  const UploadsCompanion({
    this.sha256 = const Value.absent(),
    this.path = const Value.absent(),
    this.size = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.failedReason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UploadsCompanion.insert({
    required String sha256,
    required String path,
    required int size,
    required String createdAt,
    this.failedReason = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : sha256 = Value(sha256),
       path = Value(path),
       size = Value(size),
       createdAt = Value(createdAt);
  static Insertable<Upload> custom({
    Expression<String>? sha256,
    Expression<String>? path,
    Expression<int>? size,
    Expression<String>? createdAt,
    Expression<String>? failedReason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (sha256 != null) 'sha256': sha256,
      if (path != null) 'path': path,
      if (size != null) 'size': size,
      if (createdAt != null) 'created_at': createdAt,
      if (failedReason != null) 'failed_reason': failedReason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UploadsCompanion copyWith({
    Value<String>? sha256,
    Value<String>? path,
    Value<int>? size,
    Value<String>? createdAt,
    Value<String?>? failedReason,
    Value<int>? rowid,
  }) {
    return UploadsCompanion(
      sha256: sha256 ?? this.sha256,
      path: path ?? this.path,
      size: size ?? this.size,
      createdAt: createdAt ?? this.createdAt,
      failedReason: failedReason ?? this.failedReason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (sha256.present) {
      map['sha256'] = Variable<String>(sha256.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (size.present) {
      map['size'] = Variable<int>(size.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (failedReason.present) {
      map['failed_reason'] = Variable<String>(failedReason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UploadsCompanion(')
          ..write('sha256: $sha256, ')
          ..write('path: $path, ')
          ..write('size: $size, ')
          ..write('createdAt: $createdAt, ')
          ..write('failedReason: $failedReason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$WioDatabase extends GeneratedDatabase {
  _$WioDatabase(QueryExecutor e) : super(e);
  $WioDatabaseManager get managers => $WioDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $PicturesTable pictures = $PicturesTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $EntriesTable entries = $EntriesTable(this);
  late final $PlaceHistoryTable placeHistory = $PlaceHistoryTable(this);
  late final $LabelsTable labels = $LabelsTable(this);
  late final $PropertyKeysTable propertyKeys = $PropertyKeysTable(this);
  late final $EntityLabelsTable entityLabels = $EntityLabelsTable(this);
  late final $EntityPropertiesTable entityProperties = $EntityPropertiesTable(
    this,
  );
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $ServerRecordsTable serverRecords = $ServerRecordsTable(this);
  late final $RejectedChangesTable rejectedChanges = $RejectedChangesTable(
    this,
  );
  late final $UploadsTable uploads = $UploadsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    sites,
    rooms,
    jobs,
    pictures,
    notes,
    entries,
    placeHistory,
    labels,
    propertyKeys,
    entityLabels,
    entityProperties,
    outbox,
    syncState,
    serverRecords,
    rejectedChanges,
    uploads,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> name,
  Value<String?> contact,
  Value<String?> externalRef,
  Value<int> rowid,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> name,
  Value<String?> contact,
  Value<String?> externalRef,
  Value<int> rowid,
});

class $$CustomersTableFilterComposer
    extends Composer<_$WioDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableOrderingComposer
    extends Composer<_$WioDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contact => $composableBuilder(
    column: $table.contact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$WioDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contact =>
      $composableBuilder(column: $table.contact, builder: (column) => column);

  GeneratedColumn<String> get externalRef => $composableBuilder(
    column: $table.externalRef,
    builder: (column) => column,
  );
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, BaseReferences<_$WioDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableManager(_$WioDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> contact = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                name: name,
                contact: contact,
                externalRef: externalRef,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> contact = const Value.absent(),
                Value<String?> externalRef = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                name: name,
                contact: contact,
                externalRef: externalRef,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CustomersTable, Customer>(table),
                  BaseReferences<_$WioDatabase, $CustomersTable, Customer>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, BaseReferences<_$WioDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
    >;
typedef $$SitesTableCreateCompanionBuilder = SitesCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String?> name,
  Value<String?> address,
  Value<int> rowid,
});
typedef $$SitesTableUpdateCompanionBuilder = SitesCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String?> name,
  Value<String?> address,
  Value<int> rowid,
});

class $$SitesTableFilterComposer extends Composer<_$WioDatabase, $SitesTable> {
  $$SitesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SitesTableOrderingComposer
    extends Composer<_$WioDatabase, $SitesTable> {
  $$SitesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SitesTableAnnotationComposer
    extends Composer<_$WioDatabase, $SitesTable> {
  $$SitesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);
}

class $$SitesTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $SitesTable,
          Site,
          $$SitesTableFilterComposer,
          $$SitesTableOrderingComposer,
          $$SitesTableAnnotationComposer,
          $$SitesTableCreateCompanionBuilder,
          $$SitesTableUpdateCompanionBuilder,
          (Site, BaseReferences<_$WioDatabase, $SitesTable, Site>),
          Site,
          PrefetchHooks Function()
        > {
  $$SitesTableTableManager(_$WioDatabase db, $SitesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SitesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SitesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SitesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitesCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                name: name,
                address: address,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SitesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                name: name,
                address: address,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SitesTable, Site>(table),
                  BaseReferences<_$WioDatabase, $SitesTable, Site>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SitesTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $SitesTable,
      Site,
      $$SitesTableFilterComposer,
      $$SitesTableOrderingComposer,
      $$SitesTableAnnotationComposer,
      $$SitesTableCreateCompanionBuilder,
      $$SitesTableUpdateCompanionBuilder,
      (Site, BaseReferences<_$WioDatabase, $SitesTable, Site>),
      Site,
      PrefetchHooks Function()
    >;
typedef $$RoomsTableCreateCompanionBuilder = RoomsCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  required String siteId,
  Value<String?> name,
  Value<String?> outline,
  Value<int?> heightCm,
  Value<int> rowid,
});
typedef $$RoomsTableUpdateCompanionBuilder = RoomsCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String> siteId,
  Value<String?> name,
  Value<String?> outline,
  Value<int?> heightCm,
  Value<int> rowid,
});

class $$RoomsTableFilterComposer extends Composer<_$WioDatabase, $RoomsTable> {
  $$RoomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outline => $composableBuilder(
    column: $table.outline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoomsTableOrderingComposer
    extends Composer<_$WioDatabase, $RoomsTable> {
  $$RoomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outline => $composableBuilder(
    column: $table.outline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightCm => $composableBuilder(
    column: $table.heightCm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoomsTableAnnotationComposer
    extends Composer<_$WioDatabase, $RoomsTable> {
  $$RoomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get outline =>
      $composableBuilder(column: $table.outline, builder: (column) => column);

  GeneratedColumn<int> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);
}

class $$RoomsTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $RoomsTable,
          Room,
          $$RoomsTableFilterComposer,
          $$RoomsTableOrderingComposer,
          $$RoomsTableAnnotationComposer,
          $$RoomsTableCreateCompanionBuilder,
          $$RoomsTableUpdateCompanionBuilder,
          (Room, BaseReferences<_$WioDatabase, $RoomsTable, Room>),
          Room,
          PrefetchHooks Function()
        > {
  $$RoomsTableTableManager(_$WioDatabase db, $RoomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> siteId = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<String?> outline = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                siteId: siteId,
                name: name,
                outline: outline,
                heightCm: heightCm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String siteId,
                Value<String?> name = const Value.absent(),
                Value<String?> outline = const Value.absent(),
                Value<int?> heightCm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoomsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                siteId: siteId,
                name: name,
                outline: outline,
                heightCm: heightCm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoomsTable, Room>(table),
                  BaseReferences<_$WioDatabase, $RoomsTable, Room>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoomsTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $RoomsTable,
      Room,
      $$RoomsTableFilterComposer,
      $$RoomsTableOrderingComposer,
      $$RoomsTableAnnotationComposer,
      $$RoomsTableCreateCompanionBuilder,
      $$RoomsTableUpdateCompanionBuilder,
      (Room, BaseReferences<_$WioDatabase, $RoomsTable, Room>),
      Room,
      PrefetchHooks Function()
    >;
typedef $$JobsTableCreateCompanionBuilder = JobsCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  required String customerId,
  required String date,
  Value<int?> agreedMinutes,
  Value<String?> reportSentAt,
  Value<int> rowid,
});
typedef $$JobsTableUpdateCompanionBuilder = JobsCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String> customerId,
  Value<String> date,
  Value<int?> agreedMinutes,
  Value<String?> reportSentAt,
  Value<int> rowid,
});

class $$JobsTableFilterComposer extends Composer<_$WioDatabase, $JobsTable> {
  $$JobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get agreedMinutes => $composableBuilder(
    column: $table.agreedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reportSentAt => $composableBuilder(
    column: $table.reportSentAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$JobsTableOrderingComposer extends Composer<_$WioDatabase, $JobsTable> {
  $$JobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get agreedMinutes => $composableBuilder(
    column: $table.agreedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reportSentAt => $composableBuilder(
    column: $table.reportSentAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$JobsTableAnnotationComposer
    extends Composer<_$WioDatabase, $JobsTable> {
  $$JobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get agreedMinutes => $composableBuilder(
    column: $table.agreedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reportSentAt => $composableBuilder(
    column: $table.reportSentAt,
    builder: (column) => column,
  );
}

class $$JobsTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $JobsTable,
          Job,
          $$JobsTableFilterComposer,
          $$JobsTableOrderingComposer,
          $$JobsTableAnnotationComposer,
          $$JobsTableCreateCompanionBuilder,
          $$JobsTableUpdateCompanionBuilder,
          (Job, BaseReferences<_$WioDatabase, $JobsTable, Job>),
          Job,
          PrefetchHooks Function()
        > {
  $$JobsTableTableManager(_$WioDatabase db, $JobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$JobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$JobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$JobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int?> agreedMinutes = const Value.absent(),
                Value<String?> reportSentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                date: date,
                agreedMinutes: agreedMinutes,
                reportSentAt: reportSentAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                required String customerId,
                required String date,
                Value<int?> agreedMinutes = const Value.absent(),
                Value<String?> reportSentAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => JobsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                date: date,
                agreedMinutes: agreedMinutes,
                reportSentAt: reportSentAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$JobsTable, Job>(table),
                  BaseReferences<_$WioDatabase, $JobsTable, Job>(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$JobsTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $JobsTable,
      Job,
      $$JobsTableFilterComposer,
      $$JobsTableOrderingComposer,
      $$JobsTableAnnotationComposer,
      $$JobsTableCreateCompanionBuilder,
      $$JobsTableUpdateCompanionBuilder,
      (Job, BaseReferences<_$WioDatabase, $JobsTable, Job>),
      Job,
      PrefetchHooks Function()
    >;
typedef $$PicturesTableCreateCompanionBuilder = PicturesCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  required String fileSha256,
  required int fileBytes,
  required String fileMime,
  required int widthPx,
  required int heightPx,
  Value<String?> takenAt,
  Value<String?> roomId,
  Value<String?> entryId,
  Value<String?> afterOf,
  Value<int> rowid,
});
typedef $$PicturesTableUpdateCompanionBuilder = PicturesCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String> fileSha256,
  Value<int> fileBytes,
  Value<String> fileMime,
  Value<int> widthPx,
  Value<int> heightPx,
  Value<String?> takenAt,
  Value<String?> roomId,
  Value<String?> entryId,
  Value<String?> afterOf,
  Value<int> rowid,
});

class $$PicturesTableFilterComposer
    extends Composer<_$WioDatabase, $PicturesTable> {
  $$PicturesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileSha256 => $composableBuilder(
    column: $table.fileSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileBytes => $composableBuilder(
    column: $table.fileBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileMime => $composableBuilder(
    column: $table.fileMime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widthPx => $composableBuilder(
    column: $table.widthPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightPx => $composableBuilder(
    column: $table.heightPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterOf => $composableBuilder(
    column: $table.afterOf,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PicturesTableOrderingComposer
    extends Composer<_$WioDatabase, $PicturesTable> {
  $$PicturesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileSha256 => $composableBuilder(
    column: $table.fileSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileBytes => $composableBuilder(
    column: $table.fileBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileMime => $composableBuilder(
    column: $table.fileMime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widthPx => $composableBuilder(
    column: $table.widthPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightPx => $composableBuilder(
    column: $table.heightPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get takenAt => $composableBuilder(
    column: $table.takenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterOf => $composableBuilder(
    column: $table.afterOf,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PicturesTableAnnotationComposer
    extends Composer<_$WioDatabase, $PicturesTable> {
  $$PicturesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileSha256 => $composableBuilder(
    column: $table.fileSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileBytes =>
      $composableBuilder(column: $table.fileBytes, builder: (column) => column);

  GeneratedColumn<String> get fileMime =>
      $composableBuilder(column: $table.fileMime, builder: (column) => column);

  GeneratedColumn<int> get widthPx =>
      $composableBuilder(column: $table.widthPx, builder: (column) => column);

  GeneratedColumn<int> get heightPx =>
      $composableBuilder(column: $table.heightPx, builder: (column) => column);

  GeneratedColumn<String> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get afterOf =>
      $composableBuilder(column: $table.afterOf, builder: (column) => column);
}

class $$PicturesTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $PicturesTable,
          Picture,
          $$PicturesTableFilterComposer,
          $$PicturesTableOrderingComposer,
          $$PicturesTableAnnotationComposer,
          $$PicturesTableCreateCompanionBuilder,
          $$PicturesTableUpdateCompanionBuilder,
          (Picture, BaseReferences<_$WioDatabase, $PicturesTable, Picture>),
          Picture,
          PrefetchHooks Function()
        > {
  $$PicturesTableTableManager(_$WioDatabase db, $PicturesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PicturesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PicturesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PicturesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> fileSha256 = const Value.absent(),
                Value<int> fileBytes = const Value.absent(),
                Value<String> fileMime = const Value.absent(),
                Value<int> widthPx = const Value.absent(),
                Value<int> heightPx = const Value.absent(),
                Value<String?> takenAt = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<String?> afterOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PicturesCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                fileSha256: fileSha256,
                fileBytes: fileBytes,
                fileMime: fileMime,
                widthPx: widthPx,
                heightPx: heightPx,
                takenAt: takenAt,
                roomId: roomId,
                entryId: entryId,
                afterOf: afterOf,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String fileSha256,
                required int fileBytes,
                required String fileMime,
                required int widthPx,
                required int heightPx,
                Value<String?> takenAt = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> entryId = const Value.absent(),
                Value<String?> afterOf = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PicturesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                fileSha256: fileSha256,
                fileBytes: fileBytes,
                fileMime: fileMime,
                widthPx: widthPx,
                heightPx: heightPx,
                takenAt: takenAt,
                roomId: roomId,
                entryId: entryId,
                afterOf: afterOf,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PicturesTable, Picture>(table),
                  BaseReferences<_$WioDatabase, $PicturesTable, Picture>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PicturesTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $PicturesTable,
      Picture,
      $$PicturesTableFilterComposer,
      $$PicturesTableOrderingComposer,
      $$PicturesTableAnnotationComposer,
      $$PicturesTableCreateCompanionBuilder,
      $$PicturesTableUpdateCompanionBuilder,
      (Picture, BaseReferences<_$WioDatabase, $PicturesTable, Picture>),
      Picture,
      PrefetchHooks Function()
    >;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  required String subjectType,
  required String subjectId,
  Value<String?> noteText,
  Value<String?> audioSha256,
  Value<int?> audioBytes,
  Value<int?> audioSeconds,
  Value<String?> transcript,
  Value<String?> transcriptSource,
  Value<int> rowid,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String> subjectType,
  Value<String> subjectId,
  Value<String?> noteText,
  Value<String?> audioSha256,
  Value<int?> audioBytes,
  Value<int?> audioSeconds,
  Value<String?> transcript,
  Value<String?> transcriptSource,
  Value<int> rowid,
});

class $$NotesTableFilterComposer extends Composer<_$WioDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioSha256 => $composableBuilder(
    column: $table.audioSha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get audioSeconds => $composableBuilder(
    column: $table.audioSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transcriptSource => $composableBuilder(
    column: $table.transcriptSource,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotesTableOrderingComposer
    extends Composer<_$WioDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get noteText => $composableBuilder(
    column: $table.noteText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioSha256 => $composableBuilder(
    column: $table.audioSha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get audioSeconds => $composableBuilder(
    column: $table.audioSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transcriptSource => $composableBuilder(
    column: $table.transcriptSource,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotesTableAnnotationComposer
    extends Composer<_$WioDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectType => $composableBuilder(
    column: $table.subjectType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get noteText =>
      $composableBuilder(column: $table.noteText, builder: (column) => column);

  GeneratedColumn<String> get audioSha256 => $composableBuilder(
    column: $table.audioSha256,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioBytes => $composableBuilder(
    column: $table.audioBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get audioSeconds => $composableBuilder(
    column: $table.audioSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcript => $composableBuilder(
    column: $table.transcript,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transcriptSource => $composableBuilder(
    column: $table.transcriptSource,
    builder: (column) => column,
  );
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, BaseReferences<_$WioDatabase, $NotesTable, Note>),
          Note,
          PrefetchHooks Function()
        > {
  $$NotesTableTableManager(_$WioDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> subjectType = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String?> noteText = const Value.absent(),
                Value<String?> audioSha256 = const Value.absent(),
                Value<int?> audioBytes = const Value.absent(),
                Value<int?> audioSeconds = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> transcriptSource = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                subjectType: subjectType,
                subjectId: subjectId,
                noteText: noteText,
                audioSha256: audioSha256,
                audioBytes: audioBytes,
                audioSeconds: audioSeconds,
                transcript: transcript,
                transcriptSource: transcriptSource,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String subjectType,
                required String subjectId,
                Value<String?> noteText = const Value.absent(),
                Value<String?> audioSha256 = const Value.absent(),
                Value<int?> audioBytes = const Value.absent(),
                Value<int?> audioSeconds = const Value.absent(),
                Value<String?> transcript = const Value.absent(),
                Value<String?> transcriptSource = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                subjectType: subjectType,
                subjectId: subjectId,
                noteText: noteText,
                audioSha256: audioSha256,
                audioBytes: audioBytes,
                audioSeconds: audioSeconds,
                transcript: transcript,
                transcriptSource: transcriptSource,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NotesTable, Note>(table),
                  BaseReferences<_$WioDatabase, $NotesTable, Note>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, BaseReferences<_$WioDatabase, $NotesTable, Note>),
      Note,
      PrefetchHooks Function()
    >;
typedef $$EntriesTableCreateCompanionBuilder = EntriesCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String?> code,
  Value<String?> title,
  Value<String?> siteId,
  Value<String?> roomId,
  Value<String?> fixtureId,
  Value<int?> level,
  Value<int?> compartment,
  Value<int?> floorXCm,
  Value<int?> floorYCm,
  Value<String?> targetSiteId,
  Value<String?> targetRoomId,
  Value<String?> targetFixtureId,
  Value<int?> targetLevel,
  Value<int?> targetCompartment,
  Value<int?> targetFloorXCm,
  Value<int?> targetFloorYCm,
  Value<int> rowid,
});
typedef $$EntriesTableUpdateCompanionBuilder = EntriesCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String?> customerId,
  Value<String?> code,
  Value<String?> title,
  Value<String?> siteId,
  Value<String?> roomId,
  Value<String?> fixtureId,
  Value<int?> level,
  Value<int?> compartment,
  Value<int?> floorXCm,
  Value<int?> floorYCm,
  Value<String?> targetSiteId,
  Value<String?> targetRoomId,
  Value<String?> targetFixtureId,
  Value<int?> targetLevel,
  Value<int?> targetCompartment,
  Value<int?> targetFloorXCm,
  Value<int?> targetFloorYCm,
  Value<int> rowid,
});

class $$EntriesTableFilterComposer
    extends Composer<_$WioDatabase, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fixtureId => $composableBuilder(
    column: $table.fixtureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get compartment => $composableBuilder(
    column: $table.compartment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorXCm => $composableBuilder(
    column: $table.floorXCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get floorYCm => $composableBuilder(
    column: $table.floorYCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetSiteId => $composableBuilder(
    column: $table.targetSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetRoomId => $composableBuilder(
    column: $table.targetRoomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetFixtureId => $composableBuilder(
    column: $table.targetFixtureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetCompartment => $composableBuilder(
    column: $table.targetCompartment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFloorXCm => $composableBuilder(
    column: $table.targetFloorXCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetFloorYCm => $composableBuilder(
    column: $table.targetFloorYCm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer
    extends Composer<_$WioDatabase, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteId => $composableBuilder(
    column: $table.siteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roomId => $composableBuilder(
    column: $table.roomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fixtureId => $composableBuilder(
    column: $table.fixtureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get compartment => $composableBuilder(
    column: $table.compartment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorXCm => $composableBuilder(
    column: $table.floorXCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get floorYCm => $composableBuilder(
    column: $table.floorYCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetSiteId => $composableBuilder(
    column: $table.targetSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetRoomId => $composableBuilder(
    column: $table.targetRoomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetFixtureId => $composableBuilder(
    column: $table.targetFixtureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetCompartment => $composableBuilder(
    column: $table.targetCompartment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFloorXCm => $composableBuilder(
    column: $table.targetFloorXCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetFloorYCm => $composableBuilder(
    column: $table.targetFloorYCm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$WioDatabase, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get siteId =>
      $composableBuilder(column: $table.siteId, builder: (column) => column);

  GeneratedColumn<String> get roomId =>
      $composableBuilder(column: $table.roomId, builder: (column) => column);

  GeneratedColumn<String> get fixtureId =>
      $composableBuilder(column: $table.fixtureId, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get compartment => $composableBuilder(
    column: $table.compartment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get floorXCm =>
      $composableBuilder(column: $table.floorXCm, builder: (column) => column);

  GeneratedColumn<int> get floorYCm =>
      $composableBuilder(column: $table.floorYCm, builder: (column) => column);

  GeneratedColumn<String> get targetSiteId => $composableBuilder(
    column: $table.targetSiteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetRoomId => $composableBuilder(
    column: $table.targetRoomId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetFixtureId => $composableBuilder(
    column: $table.targetFixtureId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetLevel => $composableBuilder(
    column: $table.targetLevel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetCompartment => $composableBuilder(
    column: $table.targetCompartment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetFloorXCm => $composableBuilder(
    column: $table.targetFloorXCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetFloorYCm => $composableBuilder(
    column: $table.targetFloorYCm,
    builder: (column) => column,
  );
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $EntriesTable,
          Entry,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (Entry, BaseReferences<_$WioDatabase, $EntriesTable, Entry>),
          Entry,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$WioDatabase db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> fixtureId = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> compartment = const Value.absent(),
                Value<int?> floorXCm = const Value.absent(),
                Value<int?> floorYCm = const Value.absent(),
                Value<String?> targetSiteId = const Value.absent(),
                Value<String?> targetRoomId = const Value.absent(),
                Value<String?> targetFixtureId = const Value.absent(),
                Value<int?> targetLevel = const Value.absent(),
                Value<int?> targetCompartment = const Value.absent(),
                Value<int?> targetFloorXCm = const Value.absent(),
                Value<int?> targetFloorYCm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                code: code,
                title: title,
                siteId: siteId,
                roomId: roomId,
                fixtureId: fixtureId,
                level: level,
                compartment: compartment,
                floorXCm: floorXCm,
                floorYCm: floorYCm,
                targetSiteId: targetSiteId,
                targetRoomId: targetRoomId,
                targetFixtureId: targetFixtureId,
                targetLevel: targetLevel,
                targetCompartment: targetCompartment,
                targetFloorXCm: targetFloorXCm,
                targetFloorYCm: targetFloorYCm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> siteId = const Value.absent(),
                Value<String?> roomId = const Value.absent(),
                Value<String?> fixtureId = const Value.absent(),
                Value<int?> level = const Value.absent(),
                Value<int?> compartment = const Value.absent(),
                Value<int?> floorXCm = const Value.absent(),
                Value<int?> floorYCm = const Value.absent(),
                Value<String?> targetSiteId = const Value.absent(),
                Value<String?> targetRoomId = const Value.absent(),
                Value<String?> targetFixtureId = const Value.absent(),
                Value<int?> targetLevel = const Value.absent(),
                Value<int?> targetCompartment = const Value.absent(),
                Value<int?> targetFloorXCm = const Value.absent(),
                Value<int?> targetFloorYCm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                code: code,
                title: title,
                siteId: siteId,
                roomId: roomId,
                fixtureId: fixtureId,
                level: level,
                compartment: compartment,
                floorXCm: floorXCm,
                floorYCm: floorYCm,
                targetSiteId: targetSiteId,
                targetRoomId: targetRoomId,
                targetFixtureId: targetFixtureId,
                targetLevel: targetLevel,
                targetCompartment: targetCompartment,
                targetFloorXCm: targetFloorXCm,
                targetFloorYCm: targetFloorYCm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntriesTable, Entry>(table),
                  BaseReferences<_$WioDatabase, $EntriesTable, Entry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $EntriesTable,
      Entry,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (Entry, BaseReferences<_$WioDatabase, $EntriesTable, Entry>),
      Entry,
      PrefetchHooks Function()
    >;
typedef $$PlaceHistoryTableCreateCompanionBuilder =
    PlaceHistoryCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String?> customerId,
      required String entryId,
      Value<String?> fromSiteId,
      Value<String?> fromRoomId,
      Value<String?> fromFixtureId,
      Value<int?> fromLevel,
      Value<int?> fromCompartment,
      Value<int?> fromFloorXCm,
      Value<int?> fromFloorYCm,
      Value<String?> toSiteId,
      Value<String?> toRoomId,
      Value<String?> toFixtureId,
      Value<int?> toLevel,
      Value<int?> toCompartment,
      Value<int?> toFloorXCm,
      Value<int?> toFloorYCm,
      required String movedAt,
      Value<String?> movedBy,
      Value<int> rowid,
    });
typedef $$PlaceHistoryTableUpdateCompanionBuilder =
    PlaceHistoryCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String?> customerId,
      Value<String> entryId,
      Value<String?> fromSiteId,
      Value<String?> fromRoomId,
      Value<String?> fromFixtureId,
      Value<int?> fromLevel,
      Value<int?> fromCompartment,
      Value<int?> fromFloorXCm,
      Value<int?> fromFloorYCm,
      Value<String?> toSiteId,
      Value<String?> toRoomId,
      Value<String?> toFixtureId,
      Value<int?> toLevel,
      Value<int?> toCompartment,
      Value<int?> toFloorXCm,
      Value<int?> toFloorYCm,
      Value<String> movedAt,
      Value<String?> movedBy,
      Value<int> rowid,
    });

class $$PlaceHistoryTableFilterComposer
    extends Composer<_$WioDatabase, $PlaceHistoryTable> {
  $$PlaceHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromSiteId => $composableBuilder(
    column: $table.fromSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromRoomId => $composableBuilder(
    column: $table.fromRoomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromFixtureId => $composableBuilder(
    column: $table.fromFixtureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromLevel => $composableBuilder(
    column: $table.fromLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromCompartment => $composableBuilder(
    column: $table.fromCompartment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromFloorXCm => $composableBuilder(
    column: $table.fromFloorXCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromFloorYCm => $composableBuilder(
    column: $table.fromFloorYCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toSiteId => $composableBuilder(
    column: $table.toSiteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toRoomId => $composableBuilder(
    column: $table.toRoomId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toFixtureId => $composableBuilder(
    column: $table.toFixtureId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toLevel => $composableBuilder(
    column: $table.toLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toCompartment => $composableBuilder(
    column: $table.toCompartment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toFloorXCm => $composableBuilder(
    column: $table.toFloorXCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toFloorYCm => $composableBuilder(
    column: $table.toFloorYCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movedAt => $composableBuilder(
    column: $table.movedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movedBy => $composableBuilder(
    column: $table.movedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaceHistoryTableOrderingComposer
    extends Composer<_$WioDatabase, $PlaceHistoryTable> {
  $$PlaceHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entryId => $composableBuilder(
    column: $table.entryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromSiteId => $composableBuilder(
    column: $table.fromSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromRoomId => $composableBuilder(
    column: $table.fromRoomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromFixtureId => $composableBuilder(
    column: $table.fromFixtureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromLevel => $composableBuilder(
    column: $table.fromLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromCompartment => $composableBuilder(
    column: $table.fromCompartment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromFloorXCm => $composableBuilder(
    column: $table.fromFloorXCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromFloorYCm => $composableBuilder(
    column: $table.fromFloorYCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toSiteId => $composableBuilder(
    column: $table.toSiteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toRoomId => $composableBuilder(
    column: $table.toRoomId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toFixtureId => $composableBuilder(
    column: $table.toFixtureId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toLevel => $composableBuilder(
    column: $table.toLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toCompartment => $composableBuilder(
    column: $table.toCompartment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toFloorXCm => $composableBuilder(
    column: $table.toFloorXCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toFloorYCm => $composableBuilder(
    column: $table.toFloorYCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movedAt => $composableBuilder(
    column: $table.movedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movedBy => $composableBuilder(
    column: $table.movedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaceHistoryTableAnnotationComposer
    extends Composer<_$WioDatabase, $PlaceHistoryTable> {
  $$PlaceHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entryId =>
      $composableBuilder(column: $table.entryId, builder: (column) => column);

  GeneratedColumn<String> get fromSiteId => $composableBuilder(
    column: $table.fromSiteId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromRoomId => $composableBuilder(
    column: $table.fromRoomId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fromFixtureId => $composableBuilder(
    column: $table.fromFixtureId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fromLevel =>
      $composableBuilder(column: $table.fromLevel, builder: (column) => column);

  GeneratedColumn<int> get fromCompartment => $composableBuilder(
    column: $table.fromCompartment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fromFloorXCm => $composableBuilder(
    column: $table.fromFloorXCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fromFloorYCm => $composableBuilder(
    column: $table.fromFloorYCm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toSiteId =>
      $composableBuilder(column: $table.toSiteId, builder: (column) => column);

  GeneratedColumn<String> get toRoomId =>
      $composableBuilder(column: $table.toRoomId, builder: (column) => column);

  GeneratedColumn<String> get toFixtureId => $composableBuilder(
    column: $table.toFixtureId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toLevel =>
      $composableBuilder(column: $table.toLevel, builder: (column) => column);

  GeneratedColumn<int> get toCompartment => $composableBuilder(
    column: $table.toCompartment,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toFloorXCm => $composableBuilder(
    column: $table.toFloorXCm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get toFloorYCm => $composableBuilder(
    column: $table.toFloorYCm,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movedAt =>
      $composableBuilder(column: $table.movedAt, builder: (column) => column);

  GeneratedColumn<String> get movedBy =>
      $composableBuilder(column: $table.movedBy, builder: (column) => column);
}

class $$PlaceHistoryTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $PlaceHistoryTable,
          PlaceHistoryData,
          $$PlaceHistoryTableFilterComposer,
          $$PlaceHistoryTableOrderingComposer,
          $$PlaceHistoryTableAnnotationComposer,
          $$PlaceHistoryTableCreateCompanionBuilder,
          $$PlaceHistoryTableUpdateCompanionBuilder,
          (
            PlaceHistoryData,
            BaseReferences<_$WioDatabase, $PlaceHistoryTable, PlaceHistoryData>,
          ),
          PlaceHistoryData,
          PrefetchHooks Function()
        > {
  $$PlaceHistoryTableTableManager(_$WioDatabase db, $PlaceHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaceHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaceHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaceHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> entryId = const Value.absent(),
                Value<String?> fromSiteId = const Value.absent(),
                Value<String?> fromRoomId = const Value.absent(),
                Value<String?> fromFixtureId = const Value.absent(),
                Value<int?> fromLevel = const Value.absent(),
                Value<int?> fromCompartment = const Value.absent(),
                Value<int?> fromFloorXCm = const Value.absent(),
                Value<int?> fromFloorYCm = const Value.absent(),
                Value<String?> toSiteId = const Value.absent(),
                Value<String?> toRoomId = const Value.absent(),
                Value<String?> toFixtureId = const Value.absent(),
                Value<int?> toLevel = const Value.absent(),
                Value<int?> toCompartment = const Value.absent(),
                Value<int?> toFloorXCm = const Value.absent(),
                Value<int?> toFloorYCm = const Value.absent(),
                Value<String> movedAt = const Value.absent(),
                Value<String?> movedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaceHistoryCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                entryId: entryId,
                fromSiteId: fromSiteId,
                fromRoomId: fromRoomId,
                fromFixtureId: fromFixtureId,
                fromLevel: fromLevel,
                fromCompartment: fromCompartment,
                fromFloorXCm: fromFloorXCm,
                fromFloorYCm: fromFloorYCm,
                toSiteId: toSiteId,
                toRoomId: toRoomId,
                toFixtureId: toFixtureId,
                toLevel: toLevel,
                toCompartment: toCompartment,
                toFloorXCm: toFloorXCm,
                toFloorYCm: toFloorYCm,
                movedAt: movedAt,
                movedBy: movedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String entryId,
                Value<String?> fromSiteId = const Value.absent(),
                Value<String?> fromRoomId = const Value.absent(),
                Value<String?> fromFixtureId = const Value.absent(),
                Value<int?> fromLevel = const Value.absent(),
                Value<int?> fromCompartment = const Value.absent(),
                Value<int?> fromFloorXCm = const Value.absent(),
                Value<int?> fromFloorYCm = const Value.absent(),
                Value<String?> toSiteId = const Value.absent(),
                Value<String?> toRoomId = const Value.absent(),
                Value<String?> toFixtureId = const Value.absent(),
                Value<int?> toLevel = const Value.absent(),
                Value<int?> toCompartment = const Value.absent(),
                Value<int?> toFloorXCm = const Value.absent(),
                Value<int?> toFloorYCm = const Value.absent(),
                required String movedAt,
                Value<String?> movedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaceHistoryCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                entryId: entryId,
                fromSiteId: fromSiteId,
                fromRoomId: fromRoomId,
                fromFixtureId: fromFixtureId,
                fromLevel: fromLevel,
                fromCompartment: fromCompartment,
                fromFloorXCm: fromFloorXCm,
                fromFloorYCm: fromFloorYCm,
                toSiteId: toSiteId,
                toRoomId: toRoomId,
                toFixtureId: toFixtureId,
                toLevel: toLevel,
                toCompartment: toCompartment,
                toFloorXCm: toFloorXCm,
                toFloorYCm: toFloorYCm,
                movedAt: movedAt,
                movedBy: movedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaceHistoryTable, PlaceHistoryData>(table),
                  BaseReferences<
                    _$WioDatabase,
                    $PlaceHistoryTable,
                    PlaceHistoryData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaceHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $PlaceHistoryTable,
      PlaceHistoryData,
      $$PlaceHistoryTableFilterComposer,
      $$PlaceHistoryTableOrderingComposer,
      $$PlaceHistoryTableAnnotationComposer,
      $$PlaceHistoryTableCreateCompanionBuilder,
      $$PlaceHistoryTableUpdateCompanionBuilder,
      (
        PlaceHistoryData,
        BaseReferences<_$WioDatabase, $PlaceHistoryTable, PlaceHistoryData>,
      ),
      PlaceHistoryData,
      PrefetchHooks Function()
    >;
typedef $$LabelsTableCreateCompanionBuilder = LabelsCompanion Function({
  required String id,
  required String workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  required String name,
  Value<int> rowid,
});
typedef $$LabelsTableUpdateCompanionBuilder = LabelsCompanion Function({
  Value<String> id,
  Value<String> workspaceId,
  Value<String?> createdAt,
  Value<String?> createdBy,
  Value<String?> updatedAt,
  Value<String?> updatedBy,
  Value<int?> revision,
  Value<String?> deletedAt,
  Value<String> name,
  Value<int> rowid,
});

class $$LabelsTableFilterComposer
    extends Composer<_$WioDatabase, $LabelsTable> {
  $$LabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LabelsTableOrderingComposer
    extends Composer<_$WioDatabase, $LabelsTable> {
  $$LabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LabelsTableAnnotationComposer
    extends Composer<_$WioDatabase, $LabelsTable> {
  $$LabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$LabelsTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $LabelsTable,
          Label,
          $$LabelsTableFilterComposer,
          $$LabelsTableOrderingComposer,
          $$LabelsTableAnnotationComposer,
          $$LabelsTableCreateCompanionBuilder,
          $$LabelsTableUpdateCompanionBuilder,
          (Label, BaseReferences<_$WioDatabase, $LabelsTable, Label>),
          Label,
          PrefetchHooks Function()
        > {
  $$LabelsTableTableManager(_$WioDatabase db, $LabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LabelsCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => LabelsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LabelsTable, Label>(table),
                  BaseReferences<_$WioDatabase, $LabelsTable, Label>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $LabelsTable,
      Label,
      $$LabelsTableFilterComposer,
      $$LabelsTableOrderingComposer,
      $$LabelsTableAnnotationComposer,
      $$LabelsTableCreateCompanionBuilder,
      $$LabelsTableUpdateCompanionBuilder,
      (Label, BaseReferences<_$WioDatabase, $LabelsTable, Label>),
      Label,
      PrefetchHooks Function()
    >;
typedef $$PropertyKeysTableCreateCompanionBuilder =
    PropertyKeysCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      required String name,
      Value<String?> unit,
      Value<int> rowid,
    });
typedef $$PropertyKeysTableUpdateCompanionBuilder =
    PropertyKeysCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String> name,
      Value<String?> unit,
      Value<int> rowid,
    });

class $$PropertyKeysTableFilterComposer
    extends Composer<_$WioDatabase, $PropertyKeysTable> {
  $$PropertyKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PropertyKeysTableOrderingComposer
    extends Composer<_$WioDatabase, $PropertyKeysTable> {
  $$PropertyKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PropertyKeysTableAnnotationComposer
    extends Composer<_$WioDatabase, $PropertyKeysTable> {
  $$PropertyKeysTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);
}

class $$PropertyKeysTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $PropertyKeysTable,
          PropertyKey,
          $$PropertyKeysTableFilterComposer,
          $$PropertyKeysTableOrderingComposer,
          $$PropertyKeysTableAnnotationComposer,
          $$PropertyKeysTableCreateCompanionBuilder,
          $$PropertyKeysTableUpdateCompanionBuilder,
          (
            PropertyKey,
            BaseReferences<_$WioDatabase, $PropertyKeysTable, PropertyKey>,
          ),
          PropertyKey,
          PrefetchHooks Function()
        > {
  $$PropertyKeysTableTableManager(_$WioDatabase db, $PropertyKeysTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PropertyKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PropertyKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PropertyKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> unit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertyKeysCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                name: name,
                unit: unit,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                required String name,
                Value<String?> unit = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PropertyKeysCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                name: name,
                unit: unit,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PropertyKeysTable, PropertyKey>(table),
                  BaseReferences<
                    _$WioDatabase,
                    $PropertyKeysTable,
                    PropertyKey
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PropertyKeysTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $PropertyKeysTable,
      PropertyKey,
      $$PropertyKeysTableFilterComposer,
      $$PropertyKeysTableOrderingComposer,
      $$PropertyKeysTableAnnotationComposer,
      $$PropertyKeysTableCreateCompanionBuilder,
      $$PropertyKeysTableUpdateCompanionBuilder,
      (
        PropertyKey,
        BaseReferences<_$WioDatabase, $PropertyKeysTable, PropertyKey>,
      ),
      PropertyKey,
      PrefetchHooks Function()
    >;
typedef $$EntityLabelsTableCreateCompanionBuilder =
    EntityLabelsCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String?> customerId,
      required String entityType,
      required String entityId,
      required String labelId,
      Value<int> rowid,
    });
typedef $$EntityLabelsTableUpdateCompanionBuilder =
    EntityLabelsCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String?> customerId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> labelId,
      Value<int> rowid,
    });

class $$EntityLabelsTableFilterComposer
    extends Composer<_$WioDatabase, $EntityLabelsTable> {
  $$EntityLabelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityLabelsTableOrderingComposer
    extends Composer<_$WioDatabase, $EntityLabelsTable> {
  $$EntityLabelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelId => $composableBuilder(
    column: $table.labelId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityLabelsTableAnnotationComposer
    extends Composer<_$WioDatabase, $EntityLabelsTable> {
  $$EntityLabelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get labelId =>
      $composableBuilder(column: $table.labelId, builder: (column) => column);
}

class $$EntityLabelsTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $EntityLabelsTable,
          EntityLabel,
          $$EntityLabelsTableFilterComposer,
          $$EntityLabelsTableOrderingComposer,
          $$EntityLabelsTableAnnotationComposer,
          $$EntityLabelsTableCreateCompanionBuilder,
          $$EntityLabelsTableUpdateCompanionBuilder,
          (
            EntityLabel,
            BaseReferences<_$WioDatabase, $EntityLabelsTable, EntityLabel>,
          ),
          EntityLabel,
          PrefetchHooks Function()
        > {
  $$EntityLabelsTableTableManager(_$WioDatabase db, $EntityLabelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityLabelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityLabelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityLabelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> labelId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityLabelsCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                entityType: entityType,
                entityId: entityId,
                labelId: labelId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String labelId,
                Value<int> rowid = const Value.absent(),
              }) => EntityLabelsCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                entityType: entityType,
                entityId: entityId,
                labelId: labelId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntityLabelsTable, EntityLabel>(table),
                  BaseReferences<
                    _$WioDatabase,
                    $EntityLabelsTable,
                    EntityLabel
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityLabelsTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $EntityLabelsTable,
      EntityLabel,
      $$EntityLabelsTableFilterComposer,
      $$EntityLabelsTableOrderingComposer,
      $$EntityLabelsTableAnnotationComposer,
      $$EntityLabelsTableCreateCompanionBuilder,
      $$EntityLabelsTableUpdateCompanionBuilder,
      (
        EntityLabel,
        BaseReferences<_$WioDatabase, $EntityLabelsTable, EntityLabel>,
      ),
      EntityLabel,
      PrefetchHooks Function()
    >;
typedef $$EntityPropertiesTableCreateCompanionBuilder =
    EntityPropertiesCompanion Function({
      required String id,
      required String workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String?> customerId,
      required String entityType,
      required String entityId,
      required String keyId,
      Value<String?> valueText,
      Value<String?> valueNumber,
      Value<int> rowid,
    });
typedef $$EntityPropertiesTableUpdateCompanionBuilder =
    EntityPropertiesCompanion Function({
      Value<String> id,
      Value<String> workspaceId,
      Value<String?> createdAt,
      Value<String?> createdBy,
      Value<String?> updatedAt,
      Value<String?> updatedBy,
      Value<int?> revision,
      Value<String?> deletedAt,
      Value<String?> customerId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> keyId,
      Value<String?> valueText,
      Value<String?> valueNumber,
      Value<int> rowid,
    });

class $$EntityPropertiesTableFilterComposer
    extends Composer<_$WioDatabase, $EntityPropertiesTable> {
  $$EntityPropertiesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valueNumber => $composableBuilder(
    column: $table.valueNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntityPropertiesTableOrderingComposer
    extends Composer<_$WioDatabase, $EntityPropertiesTable> {
  $$EntityPropertiesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdBy => $composableBuilder(
    column: $table.createdBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get updatedBy => $composableBuilder(
    column: $table.updatedBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get keyId => $composableBuilder(
    column: $table.keyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueText => $composableBuilder(
    column: $table.valueText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valueNumber => $composableBuilder(
    column: $table.valueNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntityPropertiesTableAnnotationComposer
    extends Composer<_$WioDatabase, $EntityPropertiesTable> {
  $$EntityPropertiesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get createdBy =>
      $composableBuilder(column: $table.createdBy, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get updatedBy =>
      $composableBuilder(column: $table.updatedBy, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get keyId =>
      $composableBuilder(column: $table.keyId, builder: (column) => column);

  GeneratedColumn<String> get valueText =>
      $composableBuilder(column: $table.valueText, builder: (column) => column);

  GeneratedColumn<String> get valueNumber => $composableBuilder(
    column: $table.valueNumber,
    builder: (column) => column,
  );
}

class $$EntityPropertiesTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $EntityPropertiesTable,
          EntityProperty,
          $$EntityPropertiesTableFilterComposer,
          $$EntityPropertiesTableOrderingComposer,
          $$EntityPropertiesTableAnnotationComposer,
          $$EntityPropertiesTableCreateCompanionBuilder,
          $$EntityPropertiesTableUpdateCompanionBuilder,
          (
            EntityProperty,
            BaseReferences<
              _$WioDatabase,
              $EntityPropertiesTable,
              EntityProperty
            >,
          ),
          EntityProperty,
          PrefetchHooks Function()
        > {
  $$EntityPropertiesTableTableManager(
    _$WioDatabase db,
    $EntityPropertiesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntityPropertiesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntityPropertiesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntityPropertiesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> workspaceId = const Value.absent(),
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> keyId = const Value.absent(),
                Value<String?> valueText = const Value.absent(),
                Value<String?> valueNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityPropertiesCompanion(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                entityType: entityType,
                entityId: entityId,
                keyId: keyId,
                valueText: valueText,
                valueNumber: valueNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String workspaceId,
                Value<String?> createdAt = const Value.absent(),
                Value<String?> createdBy = const Value.absent(),
                Value<String?> updatedAt = const Value.absent(),
                Value<String?> updatedBy = const Value.absent(),
                Value<int?> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                required String entityType,
                required String entityId,
                required String keyId,
                Value<String?> valueText = const Value.absent(),
                Value<String?> valueNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntityPropertiesCompanion.insert(
                id: id,
                workspaceId: workspaceId,
                createdAt: createdAt,
                createdBy: createdBy,
                updatedAt: updatedAt,
                updatedBy: updatedBy,
                revision: revision,
                deletedAt: deletedAt,
                customerId: customerId,
                entityType: entityType,
                entityId: entityId,
                keyId: keyId,
                valueText: valueText,
                valueNumber: valueNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EntityPropertiesTable, EntityProperty>(table),
                  BaseReferences<
                    _$WioDatabase,
                    $EntityPropertiesTable,
                    EntityProperty
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntityPropertiesTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $EntityPropertiesTable,
      EntityProperty,
      $$EntityPropertiesTableFilterComposer,
      $$EntityPropertiesTableOrderingComposer,
      $$EntityPropertiesTableAnnotationComposer,
      $$EntityPropertiesTableCreateCompanionBuilder,
      $$EntityPropertiesTableUpdateCompanionBuilder,
      (
        EntityProperty,
        BaseReferences<_$WioDatabase, $EntityPropertiesTable, EntityProperty>,
      ),
      EntityProperty,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String changeId,
  required String entity,
  required String entityId,
  Value<String> op,
  required String fields,
  Value<int?> baseRevision,
  required String deviceTime,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> changeId,
  Value<String> entity,
  Value<String> entityId,
  Value<String> op,
  Value<String> fields,
  Value<int?> baseRevision,
  Value<String> deviceTime,
});

class $$OutboxTableFilterComposer
    extends Composer<_$WioDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$WioDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$WioDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<int> get baseRevision => $composableBuilder(
    column: $table.baseRevision,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (OutboxData, BaseReferences<_$WioDatabase, $OutboxTable, OutboxData>),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$WioDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                Value<String> changeId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<String> deviceTime = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                changeId: changeId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                baseRevision: baseRevision,
                deviceTime: deviceTime,
              ),
          createCompanionCallback:
              ({
                Value<int> seq = const Value.absent(),
                required String changeId,
                required String entity,
                required String entityId,
                Value<String> op = const Value.absent(),
                required String fields,
                Value<int?> baseRevision = const Value.absent(),
                required String deviceTime,
              }) => OutboxCompanion.insert(
                seq: seq,
                changeId: changeId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                baseRevision: baseRevision,
                deviceTime: deviceTime,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OutboxTable, OutboxData>(table),
                  BaseReferences<_$WioDatabase, $OutboxTable, OutboxData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$WioDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder = SyncStateCompanion Function({
  required String workspaceId,
  required int lastRevision,
  Value<int> rowid,
});
typedef $$SyncStateTableUpdateCompanionBuilder = SyncStateCompanion Function({
  Value<String> workspaceId,
  Value<int> lastRevision,
  Value<int> rowid,
});

class $$SyncStateTableFilterComposer
    extends Composer<_$WioDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastRevision => $composableBuilder(
    column: $table.lastRevision,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$WioDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastRevision => $composableBuilder(
    column: $table.lastRevision,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$WioDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get workspaceId => $composableBuilder(
    column: $table.workspaceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastRevision => $composableBuilder(
    column: $table.lastRevision,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$WioDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$WioDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> workspaceId = const Value.absent(),
                Value<int> lastRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                workspaceId: workspaceId,
                lastRevision: lastRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String workspaceId,
                required int lastRevision,
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                workspaceId: workspaceId,
                lastRevision: lastRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncStateTable, SyncStateData>(table),
                  BaseReferences<_$WioDatabase, $SyncStateTable, SyncStateData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$WioDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$ServerRecordsTableCreateCompanionBuilder =
    ServerRecordsCompanion Function({
      required String entity,
      required String id,
      required int revision,
      Value<String?> deletedAt,
      required String fields,
      Value<int> rowid,
    });
typedef $$ServerRecordsTableUpdateCompanionBuilder =
    ServerRecordsCompanion Function({
      Value<String> entity,
      Value<String> id,
      Value<int> revision,
      Value<String?> deletedAt,
      Value<String> fields,
      Value<int> rowid,
    });

class $$ServerRecordsTableFilterComposer
    extends Composer<_$WioDatabase, $ServerRecordsTable> {
  $$ServerRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ServerRecordsTableOrderingComposer
    extends Composer<_$WioDatabase, $ServerRecordsTable> {
  $$ServerRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServerRecordsTableAnnotationComposer
    extends Composer<_$WioDatabase, $ServerRecordsTable> {
  $$ServerRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);
}

class $$ServerRecordsTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $ServerRecordsTable,
          ServerRecord,
          $$ServerRecordsTableFilterComposer,
          $$ServerRecordsTableOrderingComposer,
          $$ServerRecordsTableAnnotationComposer,
          $$ServerRecordsTableCreateCompanionBuilder,
          $$ServerRecordsTableUpdateCompanionBuilder,
          (
            ServerRecord,
            BaseReferences<_$WioDatabase, $ServerRecordsTable, ServerRecord>,
          ),
          ServerRecord,
          PrefetchHooks Function()
        > {
  $$ServerRecordsTableTableManager(_$WioDatabase db, $ServerRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServerRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServerRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServerRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> entity = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<String?> deletedAt = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ServerRecordsCompanion(
                entity: entity,
                id: id,
                revision: revision,
                deletedAt: deletedAt,
                fields: fields,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String entity,
                required String id,
                required int revision,
                Value<String?> deletedAt = const Value.absent(),
                required String fields,
                Value<int> rowid = const Value.absent(),
              }) => ServerRecordsCompanion.insert(
                entity: entity,
                id: id,
                revision: revision,
                deletedAt: deletedAt,
                fields: fields,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ServerRecordsTable, ServerRecord>(table),
                  BaseReferences<
                    _$WioDatabase,
                    $ServerRecordsTable,
                    ServerRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ServerRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $ServerRecordsTable,
      ServerRecord,
      $$ServerRecordsTableFilterComposer,
      $$ServerRecordsTableOrderingComposer,
      $$ServerRecordsTableAnnotationComposer,
      $$ServerRecordsTableCreateCompanionBuilder,
      $$ServerRecordsTableUpdateCompanionBuilder,
      (
        ServerRecord,
        BaseReferences<_$WioDatabase, $ServerRecordsTable, ServerRecord>,
      ),
      ServerRecord,
      PrefetchHooks Function()
    >;
typedef $$RejectedChangesTableCreateCompanionBuilder =
    RejectedChangesCompanion Function({
      required String changeId,
      required String entity,
      required String entityId,
      required String op,
      required String fields,
      required String deviceTime,
      required String reason,
      Value<String?> existingId,
      required String rejectedAt,
      Value<int> rowid,
    });
typedef $$RejectedChangesTableUpdateCompanionBuilder =
    RejectedChangesCompanion Function({
      Value<String> changeId,
      Value<String> entity,
      Value<String> entityId,
      Value<String> op,
      Value<String> fields,
      Value<String> deviceTime,
      Value<String> reason,
      Value<String?> existingId,
      Value<String> rejectedAt,
      Value<int> rowid,
    });

class $$RejectedChangesTableFilterComposer
    extends Composer<_$WioDatabase, $RejectedChangesTable> {
  $$RejectedChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get existingId => $composableBuilder(
    column: $table.existingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RejectedChangesTableOrderingComposer
    extends Composer<_$WioDatabase, $RejectedChangesTable> {
  $$RejectedChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get changeId => $composableBuilder(
    column: $table.changeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fields => $composableBuilder(
    column: $table.fields,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get existingId => $composableBuilder(
    column: $table.existingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RejectedChangesTableAnnotationComposer
    extends Composer<_$WioDatabase, $RejectedChangesTable> {
  $$RejectedChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get changeId =>
      $composableBuilder(column: $table.changeId, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<String> get deviceTime => $composableBuilder(
    column: $table.deviceTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get existingId => $composableBuilder(
    column: $table.existingId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rejectedAt => $composableBuilder(
    column: $table.rejectedAt,
    builder: (column) => column,
  );
}

class $$RejectedChangesTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $RejectedChangesTable,
          RejectedChange,
          $$RejectedChangesTableFilterComposer,
          $$RejectedChangesTableOrderingComposer,
          $$RejectedChangesTableAnnotationComposer,
          $$RejectedChangesTableCreateCompanionBuilder,
          $$RejectedChangesTableUpdateCompanionBuilder,
          (
            RejectedChange,
            BaseReferences<
              _$WioDatabase,
              $RejectedChangesTable,
              RejectedChange
            >,
          ),
          RejectedChange,
          PrefetchHooks Function()
        > {
  $$RejectedChangesTableTableManager(
    _$WioDatabase db,
    $RejectedChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RejectedChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RejectedChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RejectedChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> changeId = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> fields = const Value.absent(),
                Value<String> deviceTime = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> existingId = const Value.absent(),
                Value<String> rejectedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RejectedChangesCompanion(
                changeId: changeId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                deviceTime: deviceTime,
                reason: reason,
                existingId: existingId,
                rejectedAt: rejectedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String changeId,
                required String entity,
                required String entityId,
                required String op,
                required String fields,
                required String deviceTime,
                required String reason,
                Value<String?> existingId = const Value.absent(),
                required String rejectedAt,
                Value<int> rowid = const Value.absent(),
              }) => RejectedChangesCompanion.insert(
                changeId: changeId,
                entity: entity,
                entityId: entityId,
                op: op,
                fields: fields,
                deviceTime: deviceTime,
                reason: reason,
                existingId: existingId,
                rejectedAt: rejectedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RejectedChangesTable, RejectedChange>(table),
                  BaseReferences<
                    _$WioDatabase,
                    $RejectedChangesTable,
                    RejectedChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RejectedChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $RejectedChangesTable,
      RejectedChange,
      $$RejectedChangesTableFilterComposer,
      $$RejectedChangesTableOrderingComposer,
      $$RejectedChangesTableAnnotationComposer,
      $$RejectedChangesTableCreateCompanionBuilder,
      $$RejectedChangesTableUpdateCompanionBuilder,
      (
        RejectedChange,
        BaseReferences<_$WioDatabase, $RejectedChangesTable, RejectedChange>,
      ),
      RejectedChange,
      PrefetchHooks Function()
    >;
typedef $$UploadsTableCreateCompanionBuilder = UploadsCompanion Function({
  required String sha256,
  required String path,
  required int size,
  required String createdAt,
  Value<String?> failedReason,
  Value<int> rowid,
});
typedef $$UploadsTableUpdateCompanionBuilder = UploadsCompanion Function({
  Value<String> sha256,
  Value<String> path,
  Value<int> size,
  Value<String> createdAt,
  Value<String?> failedReason,
  Value<int> rowid,
});

class $$UploadsTableFilterComposer
    extends Composer<_$WioDatabase, $UploadsTable> {
  $$UploadsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get failedReason => $composableBuilder(
    column: $table.failedReason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UploadsTableOrderingComposer
    extends Composer<_$WioDatabase, $UploadsTable> {
  $$UploadsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sha256 => $composableBuilder(
    column: $table.sha256,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get size => $composableBuilder(
    column: $table.size,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get failedReason => $composableBuilder(
    column: $table.failedReason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UploadsTableAnnotationComposer
    extends Composer<_$WioDatabase, $UploadsTable> {
  $$UploadsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sha256 =>
      $composableBuilder(column: $table.sha256, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<int> get size =>
      $composableBuilder(column: $table.size, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get failedReason => $composableBuilder(
    column: $table.failedReason,
    builder: (column) => column,
  );
}

class $$UploadsTableTableManager
    extends
        RootTableManager<
          _$WioDatabase,
          $UploadsTable,
          Upload,
          $$UploadsTableFilterComposer,
          $$UploadsTableOrderingComposer,
          $$UploadsTableAnnotationComposer,
          $$UploadsTableCreateCompanionBuilder,
          $$UploadsTableUpdateCompanionBuilder,
          (Upload, BaseReferences<_$WioDatabase, $UploadsTable, Upload>),
          Upload,
          PrefetchHooks Function()
        > {
  $$UploadsTableTableManager(_$WioDatabase db, $UploadsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UploadsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UploadsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UploadsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> sha256 = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<int> size = const Value.absent(),
                Value<String> createdAt = const Value.absent(),
                Value<String?> failedReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UploadsCompanion(
                sha256: sha256,
                path: path,
                size: size,
                createdAt: createdAt,
                failedReason: failedReason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sha256,
                required String path,
                required int size,
                required String createdAt,
                Value<String?> failedReason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UploadsCompanion.insert(
                sha256: sha256,
                path: path,
                size: size,
                createdAt: createdAt,
                failedReason: failedReason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UploadsTable, Upload>(table),
                  BaseReferences<_$WioDatabase, $UploadsTable, Upload>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UploadsTableProcessedTableManager =
    ProcessedTableManager<
      _$WioDatabase,
      $UploadsTable,
      Upload,
      $$UploadsTableFilterComposer,
      $$UploadsTableOrderingComposer,
      $$UploadsTableAnnotationComposer,
      $$UploadsTableCreateCompanionBuilder,
      $$UploadsTableUpdateCompanionBuilder,
      (Upload, BaseReferences<_$WioDatabase, $UploadsTable, Upload>),
      Upload,
      PrefetchHooks Function()
    >;

class $WioDatabaseManager {
  final _$WioDatabase _db;
  $WioDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$SitesTableTableManager get sites =>
      $$SitesTableTableManager(_db, _db.sites);
  $$RoomsTableTableManager get rooms =>
      $$RoomsTableTableManager(_db, _db.rooms);
  $$JobsTableTableManager get jobs => $$JobsTableTableManager(_db, _db.jobs);
  $$PicturesTableTableManager get pictures =>
      $$PicturesTableTableManager(_db, _db.pictures);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
  $$PlaceHistoryTableTableManager get placeHistory =>
      $$PlaceHistoryTableTableManager(_db, _db.placeHistory);
  $$LabelsTableTableManager get labels =>
      $$LabelsTableTableManager(_db, _db.labels);
  $$PropertyKeysTableTableManager get propertyKeys =>
      $$PropertyKeysTableTableManager(_db, _db.propertyKeys);
  $$EntityLabelsTableTableManager get entityLabels =>
      $$EntityLabelsTableTableManager(_db, _db.entityLabels);
  $$EntityPropertiesTableTableManager get entityProperties =>
      $$EntityPropertiesTableTableManager(_db, _db.entityProperties);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$ServerRecordsTableTableManager get serverRecords =>
      $$ServerRecordsTableTableManager(_db, _db.serverRecords);
  $$RejectedChangesTableTableManager get rejectedChanges =>
      $$RejectedChangesTableTableManager(_db, _db.rejectedChanges);
  $$UploadsTableTableManager get uploads =>
      $$UploadsTableTableManager(_db, _db.uploads);
}
