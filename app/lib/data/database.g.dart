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

  /// The changed fields only, as a JSON object.
  final String fields;
  final int? baseRevision;
  final String deviceTime;
  const OutboxData({
    required this.seq,
    required this.changeId,
    required this.entity,
    required this.entityId,
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
    String? fields,
    Value<int?> baseRevision = const Value.absent(),
    String? deviceTime,
  }) => OutboxData(
    seq: seq ?? this.seq,
    changeId: changeId ?? this.changeId,
    entity: entity ?? this.entity,
    entityId: entityId ?? this.entityId,
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
          other.fields == this.fields &&
          other.baseRevision == this.baseRevision &&
          other.deviceTime == this.deviceTime);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<int> seq;
  final Value<String> changeId;
  final Value<String> entity;
  final Value<String> entityId;
  final Value<String> fields;
  final Value<int?> baseRevision;
  final Value<String> deviceTime;
  const OutboxCompanion({
    this.seq = const Value.absent(),
    this.changeId = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.fields = const Value.absent(),
    this.baseRevision = const Value.absent(),
    this.deviceTime = const Value.absent(),
  });
  OutboxCompanion.insert({
    this.seq = const Value.absent(),
    required String changeId,
    required String entity,
    required String entityId,
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
    Expression<String>? fields,
    Expression<int>? baseRevision,
    Expression<String>? deviceTime,
  }) {
    return RawValuesInsertable({
      if (seq != null) 'seq': seq,
      if (changeId != null) 'change_id': changeId,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
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
    Value<String>? fields,
    Value<int?>? baseRevision,
    Value<String>? deviceTime,
  }) {
    return OutboxCompanion(
      seq: seq ?? this.seq,
      changeId: changeId ?? this.changeId,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
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

abstract class _$WioDatabase extends GeneratedDatabase {
  _$WioDatabase(QueryExecutor e) : super(e);
  $WioDatabaseManager get managers => $WioDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $SitesTable sites = $SitesTable(this);
  late final $RoomsTable rooms = $RoomsTable(this);
  late final $JobsTable jobs = $JobsTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $SyncStateTable syncState = $SyncStateTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    sites,
    rooms,
    jobs,
    outbox,
    syncState,
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
typedef $$OutboxTableCreateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  required String changeId,
  required String entity,
  required String entityId,
  required String fields,
  Value<int?> baseRevision,
  required String deviceTime,
});
typedef $$OutboxTableUpdateCompanionBuilder = OutboxCompanion Function({
  Value<int> seq,
  Value<String> changeId,
  Value<String> entity,
  Value<String> entityId,
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
                Value<String> fields = const Value.absent(),
                Value<int?> baseRevision = const Value.absent(),
                Value<String> deviceTime = const Value.absent(),
              }) => OutboxCompanion(
                seq: seq,
                changeId: changeId,
                entity: entity,
                entityId: entityId,
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
                required String fields,
                Value<int?> baseRevision = const Value.absent(),
                required String deviceTime,
              }) => OutboxCompanion.insert(
                seq: seq,
                changeId: changeId,
                entity: entity,
                entityId: entityId,
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
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
}
