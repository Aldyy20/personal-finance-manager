// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocalSyncStateTable extends LocalSyncState
    with TableInfo<$LocalSyncStateTable, LocalSyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastCursorMeta = const VerificationMeta(
    'lastCursor',
  );
  @override
  late final GeneratedColumn<int> lastCursor = GeneratedColumn<int>(
    'last_cursor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncAtMsMeta = const VerificationMeta(
    'lastSyncAtMs',
  );
  @override
  late final GeneratedColumn<int> lastSyncAtMs = GeneratedColumn<int>(
    'last_sync_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceId,
    lastCursor,
    lastSyncAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('last_cursor')) {
      context.handle(
        _lastCursorMeta,
        lastCursor.isAcceptableOrUnknown(data['last_cursor']!, _lastCursorMeta),
      );
    }
    if (data.containsKey('last_sync_at_ms')) {
      context.handle(
        _lastSyncAtMsMeta,
        lastSyncAtMs.isAcceptableOrUnknown(
          data['last_sync_at_ms']!,
          _lastSyncAtMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalSyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      lastCursor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_cursor'],
      )!,
      lastSyncAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_at_ms'],
      ),
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $LocalSyncStateTable createAlias(String alias) {
    return $LocalSyncStateTable(attachedDatabase, alias);
  }
}

class LocalSyncStateData extends DataClass
    implements Insertable<LocalSyncStateData> {
  final String id;
  final String userId;
  final String deviceId;
  final int lastCursor;
  final int? lastSyncAtMs;
  final int updatedAtMs;
  const LocalSyncStateData({
    required this.id,
    required this.userId,
    required this.deviceId,
    required this.lastCursor,
    this.lastSyncAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['device_id'] = Variable<String>(deviceId);
    map['last_cursor'] = Variable<int>(lastCursor);
    if (!nullToAbsent || lastSyncAtMs != null) {
      map['last_sync_at_ms'] = Variable<int>(lastSyncAtMs);
    }
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LocalSyncStateCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncStateCompanion(
      id: Value(id),
      userId: Value(userId),
      deviceId: Value(deviceId),
      lastCursor: Value(lastCursor),
      lastSyncAtMs: lastSyncAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory LocalSyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncStateData(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      lastCursor: serializer.fromJson<int>(json['lastCursor']),
      lastSyncAtMs: serializer.fromJson<int?>(json['lastSyncAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'deviceId': serializer.toJson<String>(deviceId),
      'lastCursor': serializer.toJson<int>(lastCursor),
      'lastSyncAtMs': serializer.toJson<int?>(lastSyncAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LocalSyncStateData copyWith({
    String? id,
    String? userId,
    String? deviceId,
    int? lastCursor,
    Value<int?> lastSyncAtMs = const Value.absent(),
    int? updatedAtMs,
  }) => LocalSyncStateData(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    deviceId: deviceId ?? this.deviceId,
    lastCursor: lastCursor ?? this.lastCursor,
    lastSyncAtMs: lastSyncAtMs.present ? lastSyncAtMs.value : this.lastSyncAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  LocalSyncStateData copyWithCompanion(LocalSyncStateCompanion data) {
    return LocalSyncStateData(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      lastCursor: data.lastCursor.present
          ? data.lastCursor.value
          : this.lastCursor,
      lastSyncAtMs: data.lastSyncAtMs.present
          ? data.lastSyncAtMs.value
          : this.lastSyncAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncStateData(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastCursor: $lastCursor, ')
          ..write('lastSyncAtMs: $lastSyncAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, deviceId, lastCursor, lastSyncAtMs, updatedAtMs);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncStateData &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.lastCursor == this.lastCursor &&
          other.lastSyncAtMs == this.lastSyncAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class LocalSyncStateCompanion extends UpdateCompanion<LocalSyncStateData> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> deviceId;
  final Value<int> lastCursor;
  final Value<int?> lastSyncAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const LocalSyncStateCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.lastCursor = const Value.absent(),
    this.lastSyncAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncStateCompanion.insert({
    required String id,
    required String userId,
    required String deviceId,
    this.lastCursor = const Value.absent(),
    this.lastSyncAtMs = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       deviceId = Value(deviceId),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalSyncStateData> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<int>? lastCursor,
    Expression<int>? lastSyncAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (lastCursor != null) 'last_cursor': lastCursor,
      if (lastSyncAtMs != null) 'last_sync_at_ms': lastSyncAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncStateCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? deviceId,
    Value<int>? lastCursor,
    Value<int?>? lastSyncAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return LocalSyncStateCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      lastCursor: lastCursor ?? this.lastCursor,
      lastSyncAtMs: lastSyncAtMs ?? this.lastSyncAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (lastCursor.present) {
      map['last_cursor'] = Variable<int>(lastCursor.value);
    }
    if (lastSyncAtMs.present) {
      map['last_sync_at_ms'] = Variable<int>(lastSyncAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncStateCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('lastCursor: $lastCursor, ')
          ..write('lastSyncAtMs: $lastSyncAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUsersTable extends LocalUsers
    with TableInfo<$LocalUsersTable, LocalUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailVerifiedAtMsMeta = const VerificationMeta(
    'emailVerifiedAtMs',
  );
  @override
  late final GeneratedColumn<int> emailVerifiedAtMs = GeneratedColumn<int>(
    'email_verified_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    email,
    emailVerifiedAtMs,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('email_verified_at_ms')) {
      context.handle(
        _emailVerifiedAtMsMeta,
        emailVerifiedAtMs.isAcceptableOrUnknown(
          data['email_verified_at_ms']!,
          _emailVerifiedAtMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      emailVerifiedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}email_verified_at_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalUsersTable createAlias(String alias) {
    return $LocalUsersTable(attachedDatabase, alias);
  }
}

class LocalUser extends DataClass implements Insertable<LocalUser> {
  final String id;
  final String name;
  final String email;
  final int? emailVerifiedAtMs;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalUser({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAtMs,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    if (!nullToAbsent || emailVerifiedAtMs != null) {
      map['email_verified_at_ms'] = Variable<int>(emailVerifiedAtMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalUsersCompanion toCompanion(bool nullToAbsent) {
    return LocalUsersCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      emailVerifiedAtMs: emailVerifiedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(emailVerifiedAtMs),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUser(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      emailVerifiedAtMs: serializer.fromJson<int?>(json['emailVerifiedAtMs']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'emailVerifiedAtMs': serializer.toJson<int?>(emailVerifiedAtMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalUser copyWith({
    String? id,
    String? name,
    String? email,
    Value<int?> emailVerifiedAtMs = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalUser(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    emailVerifiedAtMs: emailVerifiedAtMs.present
        ? emailVerifiedAtMs.value
        : this.emailVerifiedAtMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalUser copyWithCompanion(LocalUsersCompanion data) {
    return LocalUser(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      emailVerifiedAtMs: data.emailVerifiedAtMs.present
          ? data.emailVerifiedAtMs.value
          : this.emailVerifiedAtMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUser(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('emailVerifiedAtMs: $emailVerifiedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    email,
    emailVerifiedAtMs,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUser &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.emailVerifiedAtMs == this.emailVerifiedAtMs &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalUsersCompanion extends UpdateCompanion<LocalUser> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<int?> emailVerifiedAtMs;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalUsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.emailVerifiedAtMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUsersCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.emailVerifiedAtMs = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       email = Value(email),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalUser> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<int>? emailVerifiedAtMs,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (emailVerifiedAtMs != null) 'email_verified_at_ms': emailVerifiedAtMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUsersCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? email,
    Value<int?>? emailVerifiedAtMs,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalUsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      emailVerifiedAtMs: emailVerifiedAtMs ?? this.emailVerifiedAtMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (emailVerifiedAtMs.present) {
      map['email_verified_at_ms'] = Variable<int>(emailVerifiedAtMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('emailVerifiedAtMs: $emailVerifiedAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalUserSettingsTable extends LocalUserSettings
    with TableInfo<$LocalUserSettingsTable, LocalUserSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalUserSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('system'),
  );
  static const VerificationMeta _currencyMeta = const VerificationMeta(
    'currency',
  );
  @override
  late final GeneratedColumn<String> currency = GeneratedColumn<String>(
    'currency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('IDR'),
  );
  static const VerificationMeta _timezoneMeta = const VerificationMeta(
    'timezone',
  );
  @override
  late final GeneratedColumn<String> timezone = GeneratedColumn<String>(
    'timezone',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Asia/Jakarta'),
  );
  static const VerificationMeta _budgetWarningPercentMeta =
      const VerificationMeta('budgetWarningPercent');
  @override
  late final GeneratedColumn<int> budgetWarningPercent = GeneratedColumn<int>(
    'budget_warning_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(80),
  );
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
    'notifications_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("notifications_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    themeMode,
    currency,
    timezone,
    budgetWarningPercent,
    notificationsEnabled,
    version,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_user_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalUserSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('currency')) {
      context.handle(
        _currencyMeta,
        currency.isAcceptableOrUnknown(data['currency']!, _currencyMeta),
      );
    }
    if (data.containsKey('timezone')) {
      context.handle(
        _timezoneMeta,
        timezone.isAcceptableOrUnknown(data['timezone']!, _timezoneMeta),
      );
    }
    if (data.containsKey('budget_warning_percent')) {
      context.handle(
        _budgetWarningPercentMeta,
        budgetWarningPercent.isAcceptableOrUnknown(
          data['budget_warning_percent']!,
          _budgetWarningPercentMeta,
        ),
      );
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
        _notificationsEnabledMeta,
        notificationsEnabled.isAcceptableOrUnknown(
          data['notifications_enabled']!,
          _notificationsEnabledMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalUserSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalUserSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      currency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency'],
      )!,
      timezone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}timezone'],
      )!,
      budgetWarningPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}budget_warning_percent'],
      )!,
      notificationsEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}notifications_enabled'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $LocalUserSettingsTable createAlias(String alias) {
    return $LocalUserSettingsTable(attachedDatabase, alias);
  }
}

class LocalUserSetting extends DataClass
    implements Insertable<LocalUserSetting> {
  final String id;
  final String userId;
  final String themeMode;
  final String currency;
  final String timezone;
  final int budgetWarningPercent;
  final bool notificationsEnabled;
  final int version;
  final int updatedAtMs;
  const LocalUserSetting({
    required this.id,
    required this.userId,
    required this.themeMode,
    required this.currency,
    required this.timezone,
    required this.budgetWarningPercent,
    required this.notificationsEnabled,
    required this.version,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['theme_mode'] = Variable<String>(themeMode);
    map['currency'] = Variable<String>(currency);
    map['timezone'] = Variable<String>(timezone);
    map['budget_warning_percent'] = Variable<int>(budgetWarningPercent);
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['version'] = Variable<int>(version);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LocalUserSettingsCompanion toCompanion(bool nullToAbsent) {
    return LocalUserSettingsCompanion(
      id: Value(id),
      userId: Value(userId),
      themeMode: Value(themeMode),
      currency: Value(currency),
      timezone: Value(timezone),
      budgetWarningPercent: Value(budgetWarningPercent),
      notificationsEnabled: Value(notificationsEnabled),
      version: Value(version),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory LocalUserSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalUserSetting(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      currency: serializer.fromJson<String>(json['currency']),
      timezone: serializer.fromJson<String>(json['timezone']),
      budgetWarningPercent: serializer.fromJson<int>(
        json['budgetWarningPercent'],
      ),
      notificationsEnabled: serializer.fromJson<bool>(
        json['notificationsEnabled'],
      ),
      version: serializer.fromJson<int>(json['version']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'themeMode': serializer.toJson<String>(themeMode),
      'currency': serializer.toJson<String>(currency),
      'timezone': serializer.toJson<String>(timezone),
      'budgetWarningPercent': serializer.toJson<int>(budgetWarningPercent),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'version': serializer.toJson<int>(version),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LocalUserSetting copyWith({
    String? id,
    String? userId,
    String? themeMode,
    String? currency,
    String? timezone,
    int? budgetWarningPercent,
    bool? notificationsEnabled,
    int? version,
    int? updatedAtMs,
  }) => LocalUserSetting(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    themeMode: themeMode ?? this.themeMode,
    currency: currency ?? this.currency,
    timezone: timezone ?? this.timezone,
    budgetWarningPercent: budgetWarningPercent ?? this.budgetWarningPercent,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    version: version ?? this.version,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  LocalUserSetting copyWithCompanion(LocalUserSettingsCompanion data) {
    return LocalUserSetting(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      currency: data.currency.present ? data.currency.value : this.currency,
      timezone: data.timezone.present ? data.timezone.value : this.timezone,
      budgetWarningPercent: data.budgetWarningPercent.present
          ? data.budgetWarningPercent.value
          : this.budgetWarningPercent,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      version: data.version.present ? data.version.value : this.version,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSetting(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('themeMode: $themeMode, ')
          ..write('currency: $currency, ')
          ..write('timezone: $timezone, ')
          ..write('budgetWarningPercent: $budgetWarningPercent, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('version: $version, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    themeMode,
    currency,
    timezone,
    budgetWarningPercent,
    notificationsEnabled,
    version,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalUserSetting &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.themeMode == this.themeMode &&
          other.currency == this.currency &&
          other.timezone == this.timezone &&
          other.budgetWarningPercent == this.budgetWarningPercent &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.version == this.version &&
          other.updatedAtMs == this.updatedAtMs);
}

class LocalUserSettingsCompanion extends UpdateCompanion<LocalUserSetting> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> themeMode;
  final Value<String> currency;
  final Value<String> timezone;
  final Value<int> budgetWarningPercent;
  final Value<bool> notificationsEnabled;
  final Value<int> version;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const LocalUserSettingsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.currency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.budgetWarningPercent = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.version = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalUserSettingsCompanion.insert({
    required String id,
    required String userId,
    this.themeMode = const Value.absent(),
    this.currency = const Value.absent(),
    this.timezone = const Value.absent(),
    this.budgetWarningPercent = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.version = const Value.absent(),
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalUserSetting> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? themeMode,
    Expression<String>? currency,
    Expression<String>? timezone,
    Expression<int>? budgetWarningPercent,
    Expression<bool>? notificationsEnabled,
    Expression<int>? version,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (themeMode != null) 'theme_mode': themeMode,
      if (currency != null) 'currency': currency,
      if (timezone != null) 'timezone': timezone,
      if (budgetWarningPercent != null)
        'budget_warning_percent': budgetWarningPercent,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (version != null) 'version': version,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalUserSettingsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? themeMode,
    Value<String>? currency,
    Value<String>? timezone,
    Value<int>? budgetWarningPercent,
    Value<bool>? notificationsEnabled,
    Value<int>? version,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return LocalUserSettingsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      currency: currency ?? this.currency,
      timezone: timezone ?? this.timezone,
      budgetWarningPercent: budgetWarningPercent ?? this.budgetWarningPercent,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      version: version ?? this.version,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (currency.present) {
      map['currency'] = Variable<String>(currency.value);
    }
    if (timezone.present) {
      map['timezone'] = Variable<String>(timezone.value);
    }
    if (budgetWarningPercent.present) {
      map['budget_warning_percent'] = Variable<int>(budgetWarningPercent.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalUserSettingsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('themeMode: $themeMode, ')
          ..write('currency: $currency, ')
          ..write('timezone: $timezone, ')
          ..write('budgetWarningPercent: $budgetWarningPercent, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('version: $version, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalDevicesTable extends LocalDevices
    with TableInfo<$LocalDevicesTable, LocalDevice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalDevicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceNameMeta = const VerificationMeta(
    'deviceName',
  );
  @override
  late final GeneratedColumn<String> deviceName = GeneratedColumn<String>(
    'device_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('android'),
  );
  static const VerificationMeta _appVersionMeta = const VerificationMeta(
    'appVersion',
  );
  @override
  late final GeneratedColumn<String> appVersion = GeneratedColumn<String>(
    'app_version',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastSyncAtMsMeta = const VerificationMeta(
    'lastSyncAtMs',
  );
  @override
  late final GeneratedColumn<int> lastSyncAtMs = GeneratedColumn<int>(
    'last_sync_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    deviceName,
    platform,
    appVersion,
    isActive,
    lastSyncAtMs,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalDevice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_name')) {
      context.handle(
        _deviceNameMeta,
        deviceName.isAcceptableOrUnknown(data['device_name']!, _deviceNameMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceNameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('app_version')) {
      context.handle(
        _appVersionMeta,
        appVersion.isAcceptableOrUnknown(data['app_version']!, _appVersionMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_sync_at_ms')) {
      context.handle(
        _lastSyncAtMsMeta,
        lastSyncAtMs.isAcceptableOrUnknown(
          data['last_sync_at_ms']!,
          _lastSyncAtMsMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalDevice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalDevice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_name'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      appVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_version'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastSyncAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_sync_at_ms'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $LocalDevicesTable createAlias(String alias) {
    return $LocalDevicesTable(attachedDatabase, alias);
  }
}

class LocalDevice extends DataClass implements Insertable<LocalDevice> {
  final String id;
  final String userId;
  final String deviceName;
  final String platform;
  final String? appVersion;
  final bool isActive;
  final int? lastSyncAtMs;
  final int createdAtMs;
  final int updatedAtMs;
  const LocalDevice({
    required this.id,
    required this.userId,
    required this.deviceName,
    required this.platform,
    this.appVersion,
    required this.isActive,
    this.lastSyncAtMs,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['device_name'] = Variable<String>(deviceName);
    map['platform'] = Variable<String>(platform);
    if (!nullToAbsent || appVersion != null) {
      map['app_version'] = Variable<String>(appVersion);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastSyncAtMs != null) {
      map['last_sync_at_ms'] = Variable<int>(lastSyncAtMs);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  LocalDevicesCompanion toCompanion(bool nullToAbsent) {
    return LocalDevicesCompanion(
      id: Value(id),
      userId: Value(userId),
      deviceName: Value(deviceName),
      platform: Value(platform),
      appVersion: appVersion == null && nullToAbsent
          ? const Value.absent()
          : Value(appVersion),
      isActive: Value(isActive),
      lastSyncAtMs: lastSyncAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAtMs),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory LocalDevice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalDevice(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceName: serializer.fromJson<String>(json['deviceName']),
      platform: serializer.fromJson<String>(json['platform']),
      appVersion: serializer.fromJson<String?>(json['appVersion']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastSyncAtMs: serializer.fromJson<int?>(json['lastSyncAtMs']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'deviceName': serializer.toJson<String>(deviceName),
      'platform': serializer.toJson<String>(platform),
      'appVersion': serializer.toJson<String?>(appVersion),
      'isActive': serializer.toJson<bool>(isActive),
      'lastSyncAtMs': serializer.toJson<int?>(lastSyncAtMs),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  LocalDevice copyWith({
    String? id,
    String? userId,
    String? deviceName,
    String? platform,
    Value<String?> appVersion = const Value.absent(),
    bool? isActive,
    Value<int?> lastSyncAtMs = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => LocalDevice(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    deviceName: deviceName ?? this.deviceName,
    platform: platform ?? this.platform,
    appVersion: appVersion.present ? appVersion.value : this.appVersion,
    isActive: isActive ?? this.isActive,
    lastSyncAtMs: lastSyncAtMs.present ? lastSyncAtMs.value : this.lastSyncAtMs,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  LocalDevice copyWithCompanion(LocalDevicesCompanion data) {
    return LocalDevice(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceName: data.deviceName.present
          ? data.deviceName.value
          : this.deviceName,
      platform: data.platform.present ? data.platform.value : this.platform,
      appVersion: data.appVersion.present
          ? data.appVersion.value
          : this.appVersion,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastSyncAtMs: data.lastSyncAtMs.present
          ? data.lastSyncAtMs.value
          : this.lastSyncAtMs,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalDevice(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceName: $deviceName, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncAtMs: $lastSyncAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    deviceName,
    platform,
    appVersion,
    isActive,
    lastSyncAtMs,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalDevice &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.deviceName == this.deviceName &&
          other.platform == this.platform &&
          other.appVersion == this.appVersion &&
          other.isActive == this.isActive &&
          other.lastSyncAtMs == this.lastSyncAtMs &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class LocalDevicesCompanion extends UpdateCompanion<LocalDevice> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> deviceName;
  final Value<String> platform;
  final Value<String?> appVersion;
  final Value<bool> isActive;
  final Value<int?> lastSyncAtMs;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const LocalDevicesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceName = const Value.absent(),
    this.platform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncAtMs = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalDevicesCompanion.insert({
    required String id,
    required String userId,
    required String deviceName,
    this.platform = const Value.absent(),
    this.appVersion = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastSyncAtMs = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       deviceName = Value(deviceName),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalDevice> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? deviceName,
    Expression<String>? platform,
    Expression<String>? appVersion,
    Expression<bool>? isActive,
    Expression<int>? lastSyncAtMs,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (deviceName != null) 'device_name': deviceName,
      if (platform != null) 'platform': platform,
      if (appVersion != null) 'app_version': appVersion,
      if (isActive != null) 'is_active': isActive,
      if (lastSyncAtMs != null) 'last_sync_at_ms': lastSyncAtMs,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalDevicesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? deviceName,
    Value<String>? platform,
    Value<String?>? appVersion,
    Value<bool>? isActive,
    Value<int?>? lastSyncAtMs,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return LocalDevicesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      deviceName: deviceName ?? this.deviceName,
      platform: platform ?? this.platform,
      appVersion: appVersion ?? this.appVersion,
      isActive: isActive ?? this.isActive,
      lastSyncAtMs: lastSyncAtMs ?? this.lastSyncAtMs,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceName.present) {
      map['device_name'] = Variable<String>(deviceName.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (appVersion.present) {
      map['app_version'] = Variable<String>(appVersion.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastSyncAtMs.present) {
      map['last_sync_at_ms'] = Variable<int>(lastSyncAtMs.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalDevicesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('deviceName: $deviceName, ')
          ..write('platform: $platform, ')
          ..write('appVersion: $appVersion, ')
          ..write('isActive: $isActive, ')
          ..write('lastSyncAtMs: $lastSyncAtMs, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAccountsTable extends LocalAccounts
    with TableInfo<$LocalAccountsTable, LocalAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountTypeMeta = const VerificationMeta(
    'accountType',
  );
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
    'account_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _institutionNameMeta = const VerificationMeta(
    'institutionName',
  );
  @override
  late final GeneratedColumn<String> institutionName = GeneratedColumn<String>(
    'institution_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _openingBalanceMeta = const VerificationMeta(
    'openingBalance',
  );
  @override
  late final GeneratedColumn<int> openingBalance = GeneratedColumn<int>(
    'opening_balance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _openingBalanceDateMeta =
      const VerificationMeta('openingBalanceDate');
  @override
  late final GeneratedColumn<String> openingBalanceDate =
      GeneratedColumn<String>(
        'opening_balance_date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _balanceCacheMeta = const VerificationMeta(
    'balanceCache',
  );
  @override
  late final GeneratedColumn<int> balanceCache = GeneratedColumn<int>(
    'balance_cache',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    accountType,
    institutionName,
    accountNumber,
    openingBalance,
    openingBalanceDate,
    balanceCache,
    icon,
    color,
    isActive,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_accounts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccount> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('account_type')) {
      context.handle(
        _accountTypeMeta,
        accountType.isAcceptableOrUnknown(
          data['account_type']!,
          _accountTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accountTypeMeta);
    }
    if (data.containsKey('institution_name')) {
      context.handle(
        _institutionNameMeta,
        institutionName.isAcceptableOrUnknown(
          data['institution_name']!,
          _institutionNameMeta,
        ),
      );
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance')) {
      context.handle(
        _openingBalanceMeta,
        openingBalance.isAcceptableOrUnknown(
          data['opening_balance']!,
          _openingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('opening_balance_date')) {
      context.handle(
        _openingBalanceDateMeta,
        openingBalanceDate.isAcceptableOrUnknown(
          data['opening_balance_date']!,
          _openingBalanceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_openingBalanceDateMeta);
    }
    if (data.containsKey('balance_cache')) {
      context.handle(
        _balanceCacheMeta,
        balanceCache.isAcceptableOrUnknown(
          data['balance_cache']!,
          _balanceCacheMeta,
        ),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccount(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      accountType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_type'],
      )!,
      institutionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}institution_name'],
      ),
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      ),
      openingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}opening_balance'],
      )!,
      openingBalanceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opening_balance_date'],
      )!,
      balanceCache: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}balance_cache'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalAccountsTable createAlias(String alias) {
    return $LocalAccountsTable(attachedDatabase, alias);
  }
}

class LocalAccount extends DataClass implements Insertable<LocalAccount> {
  final String id;
  final String userId;
  final String name;
  final String accountType;
  final String? institutionName;
  final String? accountNumber;
  final int openingBalance;
  final String openingBalanceDate;
  final int balanceCache;
  final String? icon;
  final String? color;
  final bool isActive;
  final int version;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalAccount({
    required this.id,
    required this.userId,
    required this.name,
    required this.accountType,
    this.institutionName,
    this.accountNumber,
    required this.openingBalance,
    required this.openingBalanceDate,
    required this.balanceCache,
    this.icon,
    this.color,
    required this.isActive,
    required this.version,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['account_type'] = Variable<String>(accountType);
    if (!nullToAbsent || institutionName != null) {
      map['institution_name'] = Variable<String>(institutionName);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    map['opening_balance'] = Variable<int>(openingBalance);
    map['opening_balance_date'] = Variable<String>(openingBalanceDate);
    map['balance_cache'] = Variable<int>(balanceCache);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalAccountsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      accountType: Value(accountType),
      institutionName: institutionName == null && nullToAbsent
          ? const Value.absent()
          : Value(institutionName),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      openingBalance: Value(openingBalance),
      openingBalanceDate: Value(openingBalanceDate),
      balanceCache: Value(balanceCache),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isActive: Value(isActive),
      version: Value(version),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalAccount.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccount(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      accountType: serializer.fromJson<String>(json['accountType']),
      institutionName: serializer.fromJson<String?>(json['institutionName']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      openingBalance: serializer.fromJson<int>(json['openingBalance']),
      openingBalanceDate: serializer.fromJson<String>(
        json['openingBalanceDate'],
      ),
      balanceCache: serializer.fromJson<int>(json['balanceCache']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'accountType': serializer.toJson<String>(accountType),
      'institutionName': serializer.toJson<String?>(institutionName),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'openingBalance': serializer.toJson<int>(openingBalance),
      'openingBalanceDate': serializer.toJson<String>(openingBalanceDate),
      'balanceCache': serializer.toJson<int>(balanceCache),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalAccount copyWith({
    String? id,
    String? userId,
    String? name,
    String? accountType,
    Value<String?> institutionName = const Value.absent(),
    Value<String?> accountNumber = const Value.absent(),
    int? openingBalance,
    String? openingBalanceDate,
    int? balanceCache,
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isActive,
    int? version,
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalAccount(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    accountType: accountType ?? this.accountType,
    institutionName: institutionName.present
        ? institutionName.value
        : this.institutionName,
    accountNumber: accountNumber.present
        ? accountNumber.value
        : this.accountNumber,
    openingBalance: openingBalance ?? this.openingBalance,
    openingBalanceDate: openingBalanceDate ?? this.openingBalanceDate,
    balanceCache: balanceCache ?? this.balanceCache,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalAccount copyWithCompanion(LocalAccountsCompanion data) {
    return LocalAccount(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      accountType: data.accountType.present
          ? data.accountType.value
          : this.accountType,
      institutionName: data.institutionName.present
          ? data.institutionName.value
          : this.institutionName,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      openingBalance: data.openingBalance.present
          ? data.openingBalance.value
          : this.openingBalance,
      openingBalanceDate: data.openingBalanceDate.present
          ? data.openingBalanceDate.value
          : this.openingBalanceDate,
      balanceCache: data.balanceCache.present
          ? data.balanceCache.value
          : this.balanceCache,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccount(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('institutionName: $institutionName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('openingBalanceDate: $openingBalanceDate, ')
          ..write('balanceCache: $balanceCache, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    accountType,
    institutionName,
    accountNumber,
    openingBalance,
    openingBalanceDate,
    balanceCache,
    icon,
    color,
    isActive,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccount &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.accountType == this.accountType &&
          other.institutionName == this.institutionName &&
          other.accountNumber == this.accountNumber &&
          other.openingBalance == this.openingBalance &&
          other.openingBalanceDate == this.openingBalanceDate &&
          other.balanceCache == this.balanceCache &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalAccountsCompanion extends UpdateCompanion<LocalAccount> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> accountType;
  final Value<String?> institutionName;
  final Value<String?> accountNumber;
  final Value<int> openingBalance;
  final Value<String> openingBalanceDate;
  final Value<int> balanceCache;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalAccountsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.accountType = const Value.absent(),
    this.institutionName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.openingBalance = const Value.absent(),
    this.openingBalanceDate = const Value.absent(),
    this.balanceCache = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String accountType,
    this.institutionName = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.openingBalance = const Value.absent(),
    required String openingBalanceDate,
    this.balanceCache = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       accountType = Value(accountType),
       openingBalanceDate = Value(openingBalanceDate),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalAccount> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? accountType,
    Expression<String>? institutionName,
    Expression<String>? accountNumber,
    Expression<int>? openingBalance,
    Expression<String>? openingBalanceDate,
    Expression<int>? balanceCache,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (accountType != null) 'account_type': accountType,
      if (institutionName != null) 'institution_name': institutionName,
      if (accountNumber != null) 'account_number': accountNumber,
      if (openingBalance != null) 'opening_balance': openingBalance,
      if (openingBalanceDate != null)
        'opening_balance_date': openingBalanceDate,
      if (balanceCache != null) 'balance_cache': balanceCache,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? accountType,
    Value<String?>? institutionName,
    Value<String?>? accountNumber,
    Value<int>? openingBalance,
    Value<String>? openingBalanceDate,
    Value<int>? balanceCache,
    Value<String?>? icon,
    Value<String?>? color,
    Value<bool>? isActive,
    Value<int>? version,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalAccountsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      institutionName: institutionName ?? this.institutionName,
      accountNumber: accountNumber ?? this.accountNumber,
      openingBalance: openingBalance ?? this.openingBalance,
      openingBalanceDate: openingBalanceDate ?? this.openingBalanceDate,
      balanceCache: balanceCache ?? this.balanceCache,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (institutionName.present) {
      map['institution_name'] = Variable<String>(institutionName.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (openingBalance.present) {
      map['opening_balance'] = Variable<int>(openingBalance.value);
    }
    if (openingBalanceDate.present) {
      map['opening_balance_date'] = Variable<String>(openingBalanceDate.value);
    }
    if (balanceCache.present) {
      map['balance_cache'] = Variable<int>(balanceCache.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('accountType: $accountType, ')
          ..write('institutionName: $institutionName, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('openingBalance: $openingBalance, ')
          ..write('openingBalanceDate: $openingBalanceDate, ')
          ..write('balanceCache: $balanceCache, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCategoriesTable extends LocalCategories
    with TableInfo<$LocalCategoriesTable, LocalCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<String> color = GeneratedColumn<String>(
    'color',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    type,
    icon,
    color,
    isDefault,
    isActive,
    sortOrder,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color'],
      ),
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalCategoriesTable createAlias(String alias) {
    return $LocalCategoriesTable(attachedDatabase, alias);
  }
}

class LocalCategory extends DataClass implements Insertable<LocalCategory> {
  final String id;
  final String userId;
  final String name;
  final String type;
  final String? icon;
  final String? color;
  final bool isDefault;
  final bool isActive;
  final int sortOrder;
  final int version;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalCategory({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    this.icon,
    this.color,
    required this.isDefault,
    required this.isActive,
    required this.sortOrder,
    required this.version,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || color != null) {
      map['color'] = Variable<String>(color);
    }
    map['is_default'] = Variable<bool>(isDefault);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    map['version'] = Variable<int>(version);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalCategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      type: Value(type),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      color: color == null && nullToAbsent
          ? const Value.absent()
          : Value(color),
      isDefault: Value(isDefault),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
      version: Value(version),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCategory(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String?>(json['icon']),
      color: serializer.fromJson<String?>(json['color']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      version: serializer.fromJson<int>(json['version']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String?>(icon),
      'color': serializer.toJson<String?>(color),
      'isDefault': serializer.toJson<bool>(isDefault),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'version': serializer.toJson<int>(version),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalCategory copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    Value<String?> icon = const Value.absent(),
    Value<String?> color = const Value.absent(),
    bool? isDefault,
    bool? isActive,
    int? sortOrder,
    int? version,
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalCategory(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon.present ? icon.value : this.icon,
    color: color.present ? color.value : this.color,
    isDefault: isDefault ?? this.isDefault,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
    version: version ?? this.version,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalCategory copyWithCompanion(LocalCategoriesCompanion data) {
    return LocalCategory(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      color: data.color.present ? data.color.value : this.color,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      version: data.version.present ? data.version.value : this.version,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategory(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    type,
    icon,
    color,
    isDefault,
    isActive,
    sortOrder,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCategory &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.color == this.color &&
          other.isDefault == this.isDefault &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder &&
          other.version == this.version &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalCategoriesCompanion extends UpdateCompanion<LocalCategory> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> icon;
  final Value<String?> color;
  final Value<bool> isDefault;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> version;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalCategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCategoriesCompanion.insert({
    required String id,
    required String userId,
    required String name,
    required String type,
    this.icon = const Value.absent(),
    this.color = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.version = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       type = Value(type),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalCategory> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<String>? color,
    Expression<bool>? isDefault,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? version,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (color != null) 'color': color,
      if (isDefault != null) 'is_default': isDefault,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (version != null) 'version': version,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? type,
    Value<String?>? icon,
    Value<String?>? color,
    Value<bool>? isDefault,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? version,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalCategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      version: version ?? this.version,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (color.present) {
      map['color'] = Variable<String>(color.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('color: $color, ')
          ..write('isDefault: $isDefault, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionsTable extends LocalTransactions
    with TableInfo<$LocalTransactionsTable, LocalTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryTypeMeta = const VerificationMeta(
    'categoryType',
  );
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
    'category_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionDateMsMeta = const VerificationMeta(
    'transactionDateMs',
  );
  @override
  late final GeneratedColumn<int> transactionDateMs = GeneratedColumn<int>(
    'transaction_date_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('posted'),
  );
  static const VerificationMeta _createdByDeviceIdMeta = const VerificationMeta(
    'createdByDeviceId',
  );
  @override
  late final GeneratedColumn<String> createdByDeviceId =
      GeneratedColumn<String>(
        'created_by_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    type,
    categoryId,
    categoryType,
    amount,
    transactionDateMs,
    description,
    notes,
    status,
    createdByDeviceId,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    }
    if (data.containsKey('category_type')) {
      context.handle(
        _categoryTypeMeta,
        categoryType.isAcceptableOrUnknown(
          data['category_type']!,
          _categoryTypeMeta,
        ),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_date_ms')) {
      context.handle(
        _transactionDateMsMeta,
        transactionDateMs.isAcceptableOrUnknown(
          data['transaction_date_ms']!,
          _transactionDateMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionDateMsMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_by_device_id')) {
      context.handle(
        _createdByDeviceIdMeta,
        createdByDeviceId.isAcceptableOrUnknown(
          data['created_by_device_id']!,
          _createdByDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      ),
      categoryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_type'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      transactionDateMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}transaction_date_ms'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_device_id'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalTransactionsTable createAlias(String alias) {
    return $LocalTransactionsTable(attachedDatabase, alias);
  }
}

class LocalTransaction extends DataClass
    implements Insertable<LocalTransaction> {
  final String id;
  final String userId;
  final String type;
  final String? categoryId;
  final String? categoryType;
  final int amount;
  final int transactionDateMs;
  final String? description;
  final String? notes;
  final String status;
  final String? createdByDeviceId;
  final int version;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalTransaction({
    required this.id,
    required this.userId,
    required this.type,
    this.categoryId,
    this.categoryType,
    required this.amount,
    required this.transactionDateMs,
    this.description,
    this.notes,
    required this.status,
    this.createdByDeviceId,
    required this.version,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    if (!nullToAbsent || categoryType != null) {
      map['category_type'] = Variable<String>(categoryType);
    }
    map['amount'] = Variable<int>(amount);
    map['transaction_date_ms'] = Variable<int>(transactionDateMs);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || createdByDeviceId != null) {
      map['created_by_device_id'] = Variable<String>(createdByDeviceId);
    }
    map['version'] = Variable<int>(version);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalTransactionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionsCompanion(
      id: Value(id),
      userId: Value(userId),
      type: Value(type),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      categoryType: categoryType == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryType),
      amount: Value(amount),
      transactionDateMs: Value(transactionDateMs),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      status: Value(status),
      createdByDeviceId: createdByDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByDeviceId),
      version: Value(version),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransaction(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      type: serializer.fromJson<String>(json['type']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      categoryType: serializer.fromJson<String?>(json['categoryType']),
      amount: serializer.fromJson<int>(json['amount']),
      transactionDateMs: serializer.fromJson<int>(json['transactionDateMs']),
      description: serializer.fromJson<String?>(json['description']),
      notes: serializer.fromJson<String?>(json['notes']),
      status: serializer.fromJson<String>(json['status']),
      createdByDeviceId: serializer.fromJson<String?>(
        json['createdByDeviceId'],
      ),
      version: serializer.fromJson<int>(json['version']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'type': serializer.toJson<String>(type),
      'categoryId': serializer.toJson<String?>(categoryId),
      'categoryType': serializer.toJson<String?>(categoryType),
      'amount': serializer.toJson<int>(amount),
      'transactionDateMs': serializer.toJson<int>(transactionDateMs),
      'description': serializer.toJson<String?>(description),
      'notes': serializer.toJson<String?>(notes),
      'status': serializer.toJson<String>(status),
      'createdByDeviceId': serializer.toJson<String?>(createdByDeviceId),
      'version': serializer.toJson<int>(version),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalTransaction copyWith({
    String? id,
    String? userId,
    String? type,
    Value<String?> categoryId = const Value.absent(),
    Value<String?> categoryType = const Value.absent(),
    int? amount,
    int? transactionDateMs,
    Value<String?> description = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    String? status,
    Value<String?> createdByDeviceId = const Value.absent(),
    int? version,
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalTransaction(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    type: type ?? this.type,
    categoryId: categoryId.present ? categoryId.value : this.categoryId,
    categoryType: categoryType.present ? categoryType.value : this.categoryType,
    amount: amount ?? this.amount,
    transactionDateMs: transactionDateMs ?? this.transactionDateMs,
    description: description.present ? description.value : this.description,
    notes: notes.present ? notes.value : this.notes,
    status: status ?? this.status,
    createdByDeviceId: createdByDeviceId.present
        ? createdByDeviceId.value
        : this.createdByDeviceId,
    version: version ?? this.version,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalTransaction copyWithCompanion(LocalTransactionsCompanion data) {
    return LocalTransaction(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      type: data.type.present ? data.type.value : this.type,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionDateMs: data.transactionDateMs.present
          ? data.transactionDateMs.value
          : this.transactionDateMs,
      description: data.description.present
          ? data.description.value
          : this.description,
      notes: data.notes.present ? data.notes.value : this.notes,
      status: data.status.present ? data.status.value : this.status,
      createdByDeviceId: data.createdByDeviceId.present
          ? data.createdByDeviceId.value
          : this.createdByDeviceId,
      version: data.version.present ? data.version.value : this.version,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransaction(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryType: $categoryType, ')
          ..write('amount: $amount, ')
          ..write('transactionDateMs: $transactionDateMs, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    type,
    categoryId,
    categoryType,
    amount,
    transactionDateMs,
    description,
    notes,
    status,
    createdByDeviceId,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransaction &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.type == this.type &&
          other.categoryId == this.categoryId &&
          other.categoryType == this.categoryType &&
          other.amount == this.amount &&
          other.transactionDateMs == this.transactionDateMs &&
          other.description == this.description &&
          other.notes == this.notes &&
          other.status == this.status &&
          other.createdByDeviceId == this.createdByDeviceId &&
          other.version == this.version &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalTransactionsCompanion extends UpdateCompanion<LocalTransaction> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> type;
  final Value<String?> categoryId;
  final Value<String?> categoryType;
  final Value<int> amount;
  final Value<int> transactionDateMs;
  final Value<String?> description;
  final Value<String?> notes;
  final Value<String> status;
  final Value<String?> createdByDeviceId;
  final Value<int> version;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalTransactionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.type = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionDateMs = const Value.absent(),
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdByDeviceId = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionsCompanion.insert({
    required String id,
    required String userId,
    required String type,
    this.categoryId = const Value.absent(),
    this.categoryType = const Value.absent(),
    required int amount,
    required int transactionDateMs,
    this.description = const Value.absent(),
    this.notes = const Value.absent(),
    this.status = const Value.absent(),
    this.createdByDeviceId = const Value.absent(),
    this.version = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       type = Value(type),
       amount = Value(amount),
       transactionDateMs = Value(transactionDateMs),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalTransaction> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? type,
    Expression<String>? categoryId,
    Expression<String>? categoryType,
    Expression<int>? amount,
    Expression<int>? transactionDateMs,
    Expression<String>? description,
    Expression<String>? notes,
    Expression<String>? status,
    Expression<String>? createdByDeviceId,
    Expression<int>? version,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (type != null) 'type': type,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryType != null) 'category_type': categoryType,
      if (amount != null) 'amount': amount,
      if (transactionDateMs != null) 'transaction_date_ms': transactionDateMs,
      if (description != null) 'description': description,
      if (notes != null) 'notes': notes,
      if (status != null) 'status': status,
      if (createdByDeviceId != null) 'created_by_device_id': createdByDeviceId,
      if (version != null) 'version': version,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? type,
    Value<String?>? categoryId,
    Value<String?>? categoryType,
    Value<int>? amount,
    Value<int>? transactionDateMs,
    Value<String?>? description,
    Value<String?>? notes,
    Value<String>? status,
    Value<String?>? createdByDeviceId,
    Value<int>? version,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalTransactionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      categoryType: categoryType ?? this.categoryType,
      amount: amount ?? this.amount,
      transactionDateMs: transactionDateMs ?? this.transactionDateMs,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
      version: version ?? this.version,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (transactionDateMs.present) {
      map['transaction_date_ms'] = Variable<int>(transactionDateMs.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdByDeviceId.present) {
      map['created_by_device_id'] = Variable<String>(createdByDeviceId.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('type: $type, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryType: $categoryType, ')
          ..write('amount: $amount, ')
          ..write('transactionDateMs: $transactionDateMs, ')
          ..write('description: $description, ')
          ..write('notes: $notes, ')
          ..write('status: $status, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAccountMovementsTable extends LocalAccountMovements
    with TableInfo<$LocalAccountMovementsTable, LocalAccountMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjustmentIdMeta = const VerificationMeta(
    'adjustmentId',
  );
  @override
  late final GeneratedColumn<String> adjustmentId = GeneratedColumn<String>(
    'adjustment_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _postingGroupIdMeta = const VerificationMeta(
    'postingGroupId',
  );
  @override
  late final GeneratedColumn<String> postingGroupId = GeneratedColumn<String>(
    'posting_group_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementTypeMeta = const VerificationMeta(
    'movementType',
  );
  @override
  late final GeneratedColumn<String> movementType = GeneratedColumn<String>(
    'movement_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountSignedMeta = const VerificationMeta(
    'amountSigned',
  );
  @override
  late final GeneratedColumn<int> amountSigned = GeneratedColumn<int>(
    'amount_signed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reversalOfIdMeta = const VerificationMeta(
    'reversalOfId',
  );
  @override
  late final GeneratedColumn<String> reversalOfId = GeneratedColumn<String>(
    'reversal_of_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    transactionId,
    adjustmentId,
    postingGroupId,
    movementType,
    amountSigned,
    reversalOfId,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_account_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccountMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    }
    if (data.containsKey('adjustment_id')) {
      context.handle(
        _adjustmentIdMeta,
        adjustmentId.isAcceptableOrUnknown(
          data['adjustment_id']!,
          _adjustmentIdMeta,
        ),
      );
    }
    if (data.containsKey('posting_group_id')) {
      context.handle(
        _postingGroupIdMeta,
        postingGroupId.isAcceptableOrUnknown(
          data['posting_group_id']!,
          _postingGroupIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postingGroupIdMeta);
    }
    if (data.containsKey('movement_type')) {
      context.handle(
        _movementTypeMeta,
        movementType.isAcceptableOrUnknown(
          data['movement_type']!,
          _movementTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_movementTypeMeta);
    }
    if (data.containsKey('amount_signed')) {
      context.handle(
        _amountSignedMeta,
        amountSigned.isAcceptableOrUnknown(
          data['amount_signed']!,
          _amountSignedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountSignedMeta);
    }
    if (data.containsKey('reversal_of_id')) {
      context.handle(
        _reversalOfIdMeta,
        reversalOfId.isAcceptableOrUnknown(
          data['reversal_of_id']!,
          _reversalOfIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccountMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccountMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      ),
      adjustmentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}adjustment_id'],
      ),
      postingGroupId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}posting_group_id'],
      )!,
      movementType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}movement_type'],
      )!,
      amountSigned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_signed'],
      )!,
      reversalOfId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reversal_of_id'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $LocalAccountMovementsTable createAlias(String alias) {
    return $LocalAccountMovementsTable(attachedDatabase, alias);
  }
}

class LocalAccountMovement extends DataClass
    implements Insertable<LocalAccountMovement> {
  final String id;
  final String userId;
  final String accountId;
  final String? transactionId;
  final String? adjustmentId;
  final String postingGroupId;
  final String movementType;
  final int amountSigned;
  final String? reversalOfId;
  final int createdAtMs;
  const LocalAccountMovement({
    required this.id,
    required this.userId,
    required this.accountId,
    this.transactionId,
    this.adjustmentId,
    required this.postingGroupId,
    required this.movementType,
    required this.amountSigned,
    this.reversalOfId,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    if (!nullToAbsent || transactionId != null) {
      map['transaction_id'] = Variable<String>(transactionId);
    }
    if (!nullToAbsent || adjustmentId != null) {
      map['adjustment_id'] = Variable<String>(adjustmentId);
    }
    map['posting_group_id'] = Variable<String>(postingGroupId);
    map['movement_type'] = Variable<String>(movementType);
    map['amount_signed'] = Variable<int>(amountSigned);
    if (!nullToAbsent || reversalOfId != null) {
      map['reversal_of_id'] = Variable<String>(reversalOfId);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  LocalAccountMovementsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountMovementsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      transactionId: transactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(transactionId),
      adjustmentId: adjustmentId == null && nullToAbsent
          ? const Value.absent()
          : Value(adjustmentId),
      postingGroupId: Value(postingGroupId),
      movementType: Value(movementType),
      amountSigned: Value(amountSigned),
      reversalOfId: reversalOfId == null && nullToAbsent
          ? const Value.absent()
          : Value(reversalOfId),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory LocalAccountMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccountMovement(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      transactionId: serializer.fromJson<String?>(json['transactionId']),
      adjustmentId: serializer.fromJson<String?>(json['adjustmentId']),
      postingGroupId: serializer.fromJson<String>(json['postingGroupId']),
      movementType: serializer.fromJson<String>(json['movementType']),
      amountSigned: serializer.fromJson<int>(json['amountSigned']),
      reversalOfId: serializer.fromJson<String?>(json['reversalOfId']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'transactionId': serializer.toJson<String?>(transactionId),
      'adjustmentId': serializer.toJson<String?>(adjustmentId),
      'postingGroupId': serializer.toJson<String>(postingGroupId),
      'movementType': serializer.toJson<String>(movementType),
      'amountSigned': serializer.toJson<int>(amountSigned),
      'reversalOfId': serializer.toJson<String?>(reversalOfId),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  LocalAccountMovement copyWith({
    String? id,
    String? userId,
    String? accountId,
    Value<String?> transactionId = const Value.absent(),
    Value<String?> adjustmentId = const Value.absent(),
    String? postingGroupId,
    String? movementType,
    int? amountSigned,
    Value<String?> reversalOfId = const Value.absent(),
    int? createdAtMs,
  }) => LocalAccountMovement(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    transactionId: transactionId.present
        ? transactionId.value
        : this.transactionId,
    adjustmentId: adjustmentId.present ? adjustmentId.value : this.adjustmentId,
    postingGroupId: postingGroupId ?? this.postingGroupId,
    movementType: movementType ?? this.movementType,
    amountSigned: amountSigned ?? this.amountSigned,
    reversalOfId: reversalOfId.present ? reversalOfId.value : this.reversalOfId,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  LocalAccountMovement copyWithCompanion(LocalAccountMovementsCompanion data) {
    return LocalAccountMovement(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      adjustmentId: data.adjustmentId.present
          ? data.adjustmentId.value
          : this.adjustmentId,
      postingGroupId: data.postingGroupId.present
          ? data.postingGroupId.value
          : this.postingGroupId,
      movementType: data.movementType.present
          ? data.movementType.value
          : this.movementType,
      amountSigned: data.amountSigned.present
          ? data.amountSigned.value
          : this.amountSigned,
      reversalOfId: data.reversalOfId.present
          ? data.reversalOfId.value
          : this.reversalOfId,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountMovement(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('transactionId: $transactionId, ')
          ..write('adjustmentId: $adjustmentId, ')
          ..write('postingGroupId: $postingGroupId, ')
          ..write('movementType: $movementType, ')
          ..write('amountSigned: $amountSigned, ')
          ..write('reversalOfId: $reversalOfId, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    transactionId,
    adjustmentId,
    postingGroupId,
    movementType,
    amountSigned,
    reversalOfId,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccountMovement &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.transactionId == this.transactionId &&
          other.adjustmentId == this.adjustmentId &&
          other.postingGroupId == this.postingGroupId &&
          other.movementType == this.movementType &&
          other.amountSigned == this.amountSigned &&
          other.reversalOfId == this.reversalOfId &&
          other.createdAtMs == this.createdAtMs);
}

class LocalAccountMovementsCompanion
    extends UpdateCompanion<LocalAccountMovement> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<String?> transactionId;
  final Value<String?> adjustmentId;
  final Value<String> postingGroupId;
  final Value<String> movementType;
  final Value<int> amountSigned;
  final Value<String?> reversalOfId;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const LocalAccountMovementsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.adjustmentId = const Value.absent(),
    this.postingGroupId = const Value.absent(),
    this.movementType = const Value.absent(),
    this.amountSigned = const Value.absent(),
    this.reversalOfId = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountMovementsCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    this.transactionId = const Value.absent(),
    this.adjustmentId = const Value.absent(),
    required String postingGroupId,
    required String movementType,
    required int amountSigned,
    this.reversalOfId = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       postingGroupId = Value(postingGroupId),
       movementType = Value(movementType),
       amountSigned = Value(amountSigned),
       createdAtMs = Value(createdAtMs);
  static Insertable<LocalAccountMovement> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<String>? transactionId,
    Expression<String>? adjustmentId,
    Expression<String>? postingGroupId,
    Expression<String>? movementType,
    Expression<int>? amountSigned,
    Expression<String>? reversalOfId,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (transactionId != null) 'transaction_id': transactionId,
      if (adjustmentId != null) 'adjustment_id': adjustmentId,
      if (postingGroupId != null) 'posting_group_id': postingGroupId,
      if (movementType != null) 'movement_type': movementType,
      if (amountSigned != null) 'amount_signed': amountSigned,
      if (reversalOfId != null) 'reversal_of_id': reversalOfId,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountMovementsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<String?>? transactionId,
    Value<String?>? adjustmentId,
    Value<String>? postingGroupId,
    Value<String>? movementType,
    Value<int>? amountSigned,
    Value<String?>? reversalOfId,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return LocalAccountMovementsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      transactionId: transactionId ?? this.transactionId,
      adjustmentId: adjustmentId ?? this.adjustmentId,
      postingGroupId: postingGroupId ?? this.postingGroupId,
      movementType: movementType ?? this.movementType,
      amountSigned: amountSigned ?? this.amountSigned,
      reversalOfId: reversalOfId ?? this.reversalOfId,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (adjustmentId.present) {
      map['adjustment_id'] = Variable<String>(adjustmentId.value);
    }
    if (postingGroupId.present) {
      map['posting_group_id'] = Variable<String>(postingGroupId.value);
    }
    if (movementType.present) {
      map['movement_type'] = Variable<String>(movementType.value);
    }
    if (amountSigned.present) {
      map['amount_signed'] = Variable<int>(amountSigned.value);
    }
    if (reversalOfId.present) {
      map['reversal_of_id'] = Variable<String>(reversalOfId.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountMovementsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('transactionId: $transactionId, ')
          ..write('adjustmentId: $adjustmentId, ')
          ..write('postingGroupId: $postingGroupId, ')
          ..write('movementType: $movementType, ')
          ..write('amountSigned: $amountSigned, ')
          ..write('reversalOfId: $reversalOfId, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalAccountAdjustmentsTable extends LocalAccountAdjustments
    with TableInfo<$LocalAccountAdjustmentsTable, LocalAccountAdjustment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalAccountAdjustmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accountIdMeta = const VerificationMeta(
    'accountId',
  );
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
    'account_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountSignedMeta = const VerificationMeta(
    'amountSigned',
  );
  @override
  late final GeneratedColumn<int> amountSigned = GeneratedColumn<int>(
    'amount_signed',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _createdByDeviceIdMeta = const VerificationMeta(
    'createdByDeviceId',
  );
  @override
  late final GeneratedColumn<String> createdByDeviceId =
      GeneratedColumn<String>(
        'created_by_device_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    accountId,
    amountSigned,
    reason,
    createdByDeviceId,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_account_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalAccountAdjustment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(
        _accountIdMeta,
        accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta),
      );
    } else if (isInserting) {
      context.missing(_accountIdMeta);
    }
    if (data.containsKey('amount_signed')) {
      context.handle(
        _amountSignedMeta,
        amountSigned.isAcceptableOrUnknown(
          data['amount_signed']!,
          _amountSignedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountSignedMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('created_by_device_id')) {
      context.handle(
        _createdByDeviceIdMeta,
        createdByDeviceId.isAcceptableOrUnknown(
          data['created_by_device_id']!,
          _createdByDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalAccountAdjustment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalAccountAdjustment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      accountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_id'],
      )!,
      amountSigned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_signed'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      createdByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_by_device_id'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $LocalAccountAdjustmentsTable createAlias(String alias) {
    return $LocalAccountAdjustmentsTable(attachedDatabase, alias);
  }
}

class LocalAccountAdjustment extends DataClass
    implements Insertable<LocalAccountAdjustment> {
  final String id;
  final String userId;
  final String accountId;
  final int amountSigned;
  final String reason;
  final String? createdByDeviceId;
  final int createdAtMs;
  const LocalAccountAdjustment({
    required this.id,
    required this.userId,
    required this.accountId,
    required this.amountSigned,
    required this.reason,
    this.createdByDeviceId,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['account_id'] = Variable<String>(accountId);
    map['amount_signed'] = Variable<int>(amountSigned);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || createdByDeviceId != null) {
      map['created_by_device_id'] = Variable<String>(createdByDeviceId);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  LocalAccountAdjustmentsCompanion toCompanion(bool nullToAbsent) {
    return LocalAccountAdjustmentsCompanion(
      id: Value(id),
      userId: Value(userId),
      accountId: Value(accountId),
      amountSigned: Value(amountSigned),
      reason: Value(reason),
      createdByDeviceId: createdByDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByDeviceId),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory LocalAccountAdjustment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalAccountAdjustment(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      accountId: serializer.fromJson<String>(json['accountId']),
      amountSigned: serializer.fromJson<int>(json['amountSigned']),
      reason: serializer.fromJson<String>(json['reason']),
      createdByDeviceId: serializer.fromJson<String?>(
        json['createdByDeviceId'],
      ),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'accountId': serializer.toJson<String>(accountId),
      'amountSigned': serializer.toJson<int>(amountSigned),
      'reason': serializer.toJson<String>(reason),
      'createdByDeviceId': serializer.toJson<String?>(createdByDeviceId),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  LocalAccountAdjustment copyWith({
    String? id,
    String? userId,
    String? accountId,
    int? amountSigned,
    String? reason,
    Value<String?> createdByDeviceId = const Value.absent(),
    int? createdAtMs,
  }) => LocalAccountAdjustment(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    accountId: accountId ?? this.accountId,
    amountSigned: amountSigned ?? this.amountSigned,
    reason: reason ?? this.reason,
    createdByDeviceId: createdByDeviceId.present
        ? createdByDeviceId.value
        : this.createdByDeviceId,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  LocalAccountAdjustment copyWithCompanion(
    LocalAccountAdjustmentsCompanion data,
  ) {
    return LocalAccountAdjustment(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amountSigned: data.amountSigned.present
          ? data.amountSigned.value
          : this.amountSigned,
      reason: data.reason.present ? data.reason.value : this.reason,
      createdByDeviceId: data.createdByDeviceId.present
          ? data.createdByDeviceId.value
          : this.createdByDeviceId,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountAdjustment(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('amountSigned: $amountSigned, ')
          ..write('reason: $reason, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    accountId,
    amountSigned,
    reason,
    createdByDeviceId,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalAccountAdjustment &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.accountId == this.accountId &&
          other.amountSigned == this.amountSigned &&
          other.reason == this.reason &&
          other.createdByDeviceId == this.createdByDeviceId &&
          other.createdAtMs == this.createdAtMs);
}

class LocalAccountAdjustmentsCompanion
    extends UpdateCompanion<LocalAccountAdjustment> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> accountId;
  final Value<int> amountSigned;
  final Value<String> reason;
  final Value<String?> createdByDeviceId;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const LocalAccountAdjustmentsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amountSigned = const Value.absent(),
    this.reason = const Value.absent(),
    this.createdByDeviceId = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalAccountAdjustmentsCompanion.insert({
    required String id,
    required String userId,
    required String accountId,
    required int amountSigned,
    required String reason,
    this.createdByDeviceId = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       accountId = Value(accountId),
       amountSigned = Value(amountSigned),
       reason = Value(reason),
       createdAtMs = Value(createdAtMs);
  static Insertable<LocalAccountAdjustment> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? accountId,
    Expression<int>? amountSigned,
    Expression<String>? reason,
    Expression<String>? createdByDeviceId,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (accountId != null) 'account_id': accountId,
      if (amountSigned != null) 'amount_signed': amountSigned,
      if (reason != null) 'reason': reason,
      if (createdByDeviceId != null) 'created_by_device_id': createdByDeviceId,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalAccountAdjustmentsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? accountId,
    Value<int>? amountSigned,
    Value<String>? reason,
    Value<String?>? createdByDeviceId,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return LocalAccountAdjustmentsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      accountId: accountId ?? this.accountId,
      amountSigned: amountSigned ?? this.amountSigned,
      reason: reason ?? this.reason,
      createdByDeviceId: createdByDeviceId ?? this.createdByDeviceId,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amountSigned.present) {
      map['amount_signed'] = Variable<int>(amountSigned.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (createdByDeviceId.present) {
      map['created_by_device_id'] = Variable<String>(createdByDeviceId.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalAccountAdjustmentsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('accountId: $accountId, ')
          ..write('amountSigned: $amountSigned, ')
          ..write('reason: $reason, ')
          ..write('createdByDeviceId: $createdByDeviceId, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTransactionRevisionsTable extends LocalTransactionRevisions
    with TableInfo<$LocalTransactionRevisionsTable, LocalTransactionRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTransactionRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionNumberMeta = const VerificationMeta(
    'revisionNumber',
  );
  @override
  late final GeneratedColumn<int> revisionNumber = GeneratedColumn<int>(
    'revision_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beforeDataJsonMeta = const VerificationMeta(
    'beforeDataJson',
  );
  @override
  late final GeneratedColumn<String> beforeDataJson = GeneratedColumn<String>(
    'before_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _afterDataJsonMeta = const VerificationMeta(
    'afterDataJson',
  );
  @override
  late final GeneratedColumn<String> afterDataJson = GeneratedColumn<String>(
    'after_data_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    userId,
    revisionNumber,
    action,
    beforeDataJson,
    afterDataJson,
    reason,
    deviceId,
    createdAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_transaction_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTransactionRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('revision_number')) {
      context.handle(
        _revisionNumberMeta,
        revisionNumber.isAcceptableOrUnknown(
          data['revision_number']!,
          _revisionNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_revisionNumberMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('before_data_json')) {
      context.handle(
        _beforeDataJsonMeta,
        beforeDataJson.isAcceptableOrUnknown(
          data['before_data_json']!,
          _beforeDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('after_data_json')) {
      context.handle(
        _afterDataJsonMeta,
        afterDataJson.isAcceptableOrUnknown(
          data['after_data_json']!,
          _afterDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTransactionRevision map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTransactionRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      revisionNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_number'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      beforeDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}before_data_json'],
      ),
      afterDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}after_data_json'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
    );
  }

  @override
  $LocalTransactionRevisionsTable createAlias(String alias) {
    return $LocalTransactionRevisionsTable(attachedDatabase, alias);
  }
}

class LocalTransactionRevision extends DataClass
    implements Insertable<LocalTransactionRevision> {
  final String id;
  final String transactionId;
  final String userId;
  final int revisionNumber;
  final String action;
  final String? beforeDataJson;
  final String? afterDataJson;
  final String? reason;
  final String? deviceId;
  final int createdAtMs;
  const LocalTransactionRevision({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.revisionNumber,
    required this.action,
    this.beforeDataJson,
    this.afterDataJson,
    this.reason,
    this.deviceId,
    required this.createdAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['user_id'] = Variable<String>(userId);
    map['revision_number'] = Variable<int>(revisionNumber);
    map['action'] = Variable<String>(action);
    if (!nullToAbsent || beforeDataJson != null) {
      map['before_data_json'] = Variable<String>(beforeDataJson);
    }
    if (!nullToAbsent || afterDataJson != null) {
      map['after_data_json'] = Variable<String>(afterDataJson);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || deviceId != null) {
      map['device_id'] = Variable<String>(deviceId);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    return map;
  }

  LocalTransactionRevisionsCompanion toCompanion(bool nullToAbsent) {
    return LocalTransactionRevisionsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      userId: Value(userId),
      revisionNumber: Value(revisionNumber),
      action: Value(action),
      beforeDataJson: beforeDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(beforeDataJson),
      afterDataJson: afterDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(afterDataJson),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      deviceId: deviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(deviceId),
      createdAtMs: Value(createdAtMs),
    );
  }

  factory LocalTransactionRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTransactionRevision(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      userId: serializer.fromJson<String>(json['userId']),
      revisionNumber: serializer.fromJson<int>(json['revisionNumber']),
      action: serializer.fromJson<String>(json['action']),
      beforeDataJson: serializer.fromJson<String?>(json['beforeDataJson']),
      afterDataJson: serializer.fromJson<String?>(json['afterDataJson']),
      reason: serializer.fromJson<String?>(json['reason']),
      deviceId: serializer.fromJson<String?>(json['deviceId']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'userId': serializer.toJson<String>(userId),
      'revisionNumber': serializer.toJson<int>(revisionNumber),
      'action': serializer.toJson<String>(action),
      'beforeDataJson': serializer.toJson<String?>(beforeDataJson),
      'afterDataJson': serializer.toJson<String?>(afterDataJson),
      'reason': serializer.toJson<String?>(reason),
      'deviceId': serializer.toJson<String?>(deviceId),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
    };
  }

  LocalTransactionRevision copyWith({
    String? id,
    String? transactionId,
    String? userId,
    int? revisionNumber,
    String? action,
    Value<String?> beforeDataJson = const Value.absent(),
    Value<String?> afterDataJson = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    Value<String?> deviceId = const Value.absent(),
    int? createdAtMs,
  }) => LocalTransactionRevision(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    userId: userId ?? this.userId,
    revisionNumber: revisionNumber ?? this.revisionNumber,
    action: action ?? this.action,
    beforeDataJson: beforeDataJson.present
        ? beforeDataJson.value
        : this.beforeDataJson,
    afterDataJson: afterDataJson.present
        ? afterDataJson.value
        : this.afterDataJson,
    reason: reason.present ? reason.value : this.reason,
    deviceId: deviceId.present ? deviceId.value : this.deviceId,
    createdAtMs: createdAtMs ?? this.createdAtMs,
  );
  LocalTransactionRevision copyWithCompanion(
    LocalTransactionRevisionsCompanion data,
  ) {
    return LocalTransactionRevision(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      revisionNumber: data.revisionNumber.present
          ? data.revisionNumber.value
          : this.revisionNumber,
      action: data.action.present ? data.action.value : this.action,
      beforeDataJson: data.beforeDataJson.present
          ? data.beforeDataJson.value
          : this.beforeDataJson,
      afterDataJson: data.afterDataJson.present
          ? data.afterDataJson.value
          : this.afterDataJson,
      reason: data.reason.present ? data.reason.value : this.reason,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionRevision(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('action: $action, ')
          ..write('beforeDataJson: $beforeDataJson, ')
          ..write('afterDataJson: $afterDataJson, ')
          ..write('reason: $reason, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAtMs: $createdAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    userId,
    revisionNumber,
    action,
    beforeDataJson,
    afterDataJson,
    reason,
    deviceId,
    createdAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTransactionRevision &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.userId == this.userId &&
          other.revisionNumber == this.revisionNumber &&
          other.action == this.action &&
          other.beforeDataJson == this.beforeDataJson &&
          other.afterDataJson == this.afterDataJson &&
          other.reason == this.reason &&
          other.deviceId == this.deviceId &&
          other.createdAtMs == this.createdAtMs);
}

class LocalTransactionRevisionsCompanion
    extends UpdateCompanion<LocalTransactionRevision> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> userId;
  final Value<int> revisionNumber;
  final Value<String> action;
  final Value<String?> beforeDataJson;
  final Value<String?> afterDataJson;
  final Value<String?> reason;
  final Value<String?> deviceId;
  final Value<int> createdAtMs;
  final Value<int> rowid;
  const LocalTransactionRevisionsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.revisionNumber = const Value.absent(),
    this.action = const Value.absent(),
    this.beforeDataJson = const Value.absent(),
    this.afterDataJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTransactionRevisionsCompanion.insert({
    required String id,
    required String transactionId,
    required String userId,
    required int revisionNumber,
    required String action,
    this.beforeDataJson = const Value.absent(),
    this.afterDataJson = const Value.absent(),
    this.reason = const Value.absent(),
    this.deviceId = const Value.absent(),
    required int createdAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       userId = Value(userId),
       revisionNumber = Value(revisionNumber),
       action = Value(action),
       createdAtMs = Value(createdAtMs);
  static Insertable<LocalTransactionRevision> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? userId,
    Expression<int>? revisionNumber,
    Expression<String>? action,
    Expression<String>? beforeDataJson,
    Expression<String>? afterDataJson,
    Expression<String>? reason,
    Expression<String>? deviceId,
    Expression<int>? createdAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (userId != null) 'user_id': userId,
      if (revisionNumber != null) 'revision_number': revisionNumber,
      if (action != null) 'action': action,
      if (beforeDataJson != null) 'before_data_json': beforeDataJson,
      if (afterDataJson != null) 'after_data_json': afterDataJson,
      if (reason != null) 'reason': reason,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTransactionRevisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? userId,
    Value<int>? revisionNumber,
    Value<String>? action,
    Value<String?>? beforeDataJson,
    Value<String?>? afterDataJson,
    Value<String?>? reason,
    Value<String?>? deviceId,
    Value<int>? createdAtMs,
    Value<int>? rowid,
  }) {
    return LocalTransactionRevisionsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      revisionNumber: revisionNumber ?? this.revisionNumber,
      action: action ?? this.action,
      beforeDataJson: beforeDataJson ?? this.beforeDataJson,
      afterDataJson: afterDataJson ?? this.afterDataJson,
      reason: reason ?? this.reason,
      deviceId: deviceId ?? this.deviceId,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (revisionNumber.present) {
      map['revision_number'] = Variable<int>(revisionNumber.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (beforeDataJson.present) {
      map['before_data_json'] = Variable<String>(beforeDataJson.value);
    }
    if (afterDataJson.present) {
      map['after_data_json'] = Variable<String>(afterDataJson.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTransactionRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('revisionNumber: $revisionNumber, ')
          ..write('action: $action, ')
          ..write('beforeDataJson: $beforeDataJson, ')
          ..write('afterDataJson: $afterDataJson, ')
          ..write('reason: $reason, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalReceiptsTable extends LocalReceipts
    with TableInfo<$LocalReceiptsTable, LocalReceipt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalReceiptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionIdMeta = const VerificationMeta(
    'transactionId',
  );
  @override
  late final GeneratedColumn<String> transactionId = GeneratedColumn<String>(
    'transaction_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localFilePathMeta = const VerificationMeta(
    'localFilePath',
  );
  @override
  late final GeneratedColumn<String> localFilePath = GeneratedColumn<String>(
    'local_file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ocrTextMeta = const VerificationMeta(
    'ocrText',
  );
  @override
  late final GeneratedColumn<String> ocrText = GeneratedColumn<String>(
    'ocr_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _extractedDataJsonMeta = const VerificationMeta(
    'extractedDataJson',
  );
  @override
  late final GeneratedColumn<String> extractedDataJson =
      GeneratedColumn<String>(
        'extracted_data_json',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _isUploadedMeta = const VerificationMeta(
    'isUploaded',
  );
  @override
  late final GeneratedColumn<bool> isUploaded = GeneratedColumn<bool>(
    'is_uploaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_uploaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    transactionId,
    userId,
    filePath,
    localFilePath,
    fileName,
    mimeType,
    fileSize,
    checksum,
    ocrText,
    extractedDataJson,
    isUploaded,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_receipts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalReceipt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('transaction_id')) {
      context.handle(
        _transactionIdMeta,
        transactionId.isAcceptableOrUnknown(
          data['transaction_id']!,
          _transactionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('local_file_path')) {
      context.handle(
        _localFilePathMeta,
        localFilePath.isAcceptableOrUnknown(
          data['local_file_path']!,
          _localFilePathMeta,
        ),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    }
    if (data.containsKey('ocr_text')) {
      context.handle(
        _ocrTextMeta,
        ocrText.isAcceptableOrUnknown(data['ocr_text']!, _ocrTextMeta),
      );
    }
    if (data.containsKey('extracted_data_json')) {
      context.handle(
        _extractedDataJsonMeta,
        extractedDataJson.isAcceptableOrUnknown(
          data['extracted_data_json']!,
          _extractedDataJsonMeta,
        ),
      );
    }
    if (data.containsKey('is_uploaded')) {
      context.handle(
        _isUploadedMeta,
        isUploaded.isAcceptableOrUnknown(data['is_uploaded']!, _isUploadedMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalReceipt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalReceipt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      transactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      localFilePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_file_path'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      ),
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      ),
      ocrText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ocr_text'],
      ),
      extractedDataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_data_json'],
      ),
      isUploaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_uploaded'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalReceiptsTable createAlias(String alias) {
    return $LocalReceiptsTable(attachedDatabase, alias);
  }
}

class LocalReceipt extends DataClass implements Insertable<LocalReceipt> {
  final String id;
  final String transactionId;
  final String userId;
  final String filePath;
  final String? localFilePath;
  final String? fileName;
  final String mimeType;
  final int fileSize;
  final String? checksum;
  final String? ocrText;
  final String? extractedDataJson;
  final bool isUploaded;
  final int version;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalReceipt({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.filePath,
    this.localFilePath,
    this.fileName,
    required this.mimeType,
    required this.fileSize,
    this.checksum,
    this.ocrText,
    this.extractedDataJson,
    required this.isUploaded,
    required this.version,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['transaction_id'] = Variable<String>(transactionId);
    map['user_id'] = Variable<String>(userId);
    map['file_path'] = Variable<String>(filePath);
    if (!nullToAbsent || localFilePath != null) {
      map['local_file_path'] = Variable<String>(localFilePath);
    }
    if (!nullToAbsent || fileName != null) {
      map['file_name'] = Variable<String>(fileName);
    }
    map['mime_type'] = Variable<String>(mimeType);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || checksum != null) {
      map['checksum'] = Variable<String>(checksum);
    }
    if (!nullToAbsent || ocrText != null) {
      map['ocr_text'] = Variable<String>(ocrText);
    }
    if (!nullToAbsent || extractedDataJson != null) {
      map['extracted_data_json'] = Variable<String>(extractedDataJson);
    }
    map['is_uploaded'] = Variable<bool>(isUploaded);
    map['version'] = Variable<int>(version);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalReceiptsCompanion toCompanion(bool nullToAbsent) {
    return LocalReceiptsCompanion(
      id: Value(id),
      transactionId: Value(transactionId),
      userId: Value(userId),
      filePath: Value(filePath),
      localFilePath: localFilePath == null && nullToAbsent
          ? const Value.absent()
          : Value(localFilePath),
      fileName: fileName == null && nullToAbsent
          ? const Value.absent()
          : Value(fileName),
      mimeType: Value(mimeType),
      fileSize: Value(fileSize),
      checksum: checksum == null && nullToAbsent
          ? const Value.absent()
          : Value(checksum),
      ocrText: ocrText == null && nullToAbsent
          ? const Value.absent()
          : Value(ocrText),
      extractedDataJson: extractedDataJson == null && nullToAbsent
          ? const Value.absent()
          : Value(extractedDataJson),
      isUploaded: Value(isUploaded),
      version: Value(version),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalReceipt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalReceipt(
      id: serializer.fromJson<String>(json['id']),
      transactionId: serializer.fromJson<String>(json['transactionId']),
      userId: serializer.fromJson<String>(json['userId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      localFilePath: serializer.fromJson<String?>(json['localFilePath']),
      fileName: serializer.fromJson<String?>(json['fileName']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      checksum: serializer.fromJson<String?>(json['checksum']),
      ocrText: serializer.fromJson<String?>(json['ocrText']),
      extractedDataJson: serializer.fromJson<String?>(
        json['extractedDataJson'],
      ),
      isUploaded: serializer.fromJson<bool>(json['isUploaded']),
      version: serializer.fromJson<int>(json['version']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'transactionId': serializer.toJson<String>(transactionId),
      'userId': serializer.toJson<String>(userId),
      'filePath': serializer.toJson<String>(filePath),
      'localFilePath': serializer.toJson<String?>(localFilePath),
      'fileName': serializer.toJson<String?>(fileName),
      'mimeType': serializer.toJson<String>(mimeType),
      'fileSize': serializer.toJson<int>(fileSize),
      'checksum': serializer.toJson<String?>(checksum),
      'ocrText': serializer.toJson<String?>(ocrText),
      'extractedDataJson': serializer.toJson<String?>(extractedDataJson),
      'isUploaded': serializer.toJson<bool>(isUploaded),
      'version': serializer.toJson<int>(version),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalReceipt copyWith({
    String? id,
    String? transactionId,
    String? userId,
    String? filePath,
    Value<String?> localFilePath = const Value.absent(),
    Value<String?> fileName = const Value.absent(),
    String? mimeType,
    int? fileSize,
    Value<String?> checksum = const Value.absent(),
    Value<String?> ocrText = const Value.absent(),
    Value<String?> extractedDataJson = const Value.absent(),
    bool? isUploaded,
    int? version,
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalReceipt(
    id: id ?? this.id,
    transactionId: transactionId ?? this.transactionId,
    userId: userId ?? this.userId,
    filePath: filePath ?? this.filePath,
    localFilePath: localFilePath.present
        ? localFilePath.value
        : this.localFilePath,
    fileName: fileName.present ? fileName.value : this.fileName,
    mimeType: mimeType ?? this.mimeType,
    fileSize: fileSize ?? this.fileSize,
    checksum: checksum.present ? checksum.value : this.checksum,
    ocrText: ocrText.present ? ocrText.value : this.ocrText,
    extractedDataJson: extractedDataJson.present
        ? extractedDataJson.value
        : this.extractedDataJson,
    isUploaded: isUploaded ?? this.isUploaded,
    version: version ?? this.version,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalReceipt copyWithCompanion(LocalReceiptsCompanion data) {
    return LocalReceipt(
      id: data.id.present ? data.id.value : this.id,
      transactionId: data.transactionId.present
          ? data.transactionId.value
          : this.transactionId,
      userId: data.userId.present ? data.userId.value : this.userId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      localFilePath: data.localFilePath.present
          ? data.localFilePath.value
          : this.localFilePath,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      ocrText: data.ocrText.present ? data.ocrText.value : this.ocrText,
      extractedDataJson: data.extractedDataJson.present
          ? data.extractedDataJson.value
          : this.extractedDataJson,
      isUploaded: data.isUploaded.present
          ? data.isUploaded.value
          : this.isUploaded,
      version: data.version.present ? data.version.value : this.version,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalReceipt(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('filePath: $filePath, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('ocrText: $ocrText, ')
          ..write('extractedDataJson: $extractedDataJson, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    transactionId,
    userId,
    filePath,
    localFilePath,
    fileName,
    mimeType,
    fileSize,
    checksum,
    ocrText,
    extractedDataJson,
    isUploaded,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalReceipt &&
          other.id == this.id &&
          other.transactionId == this.transactionId &&
          other.userId == this.userId &&
          other.filePath == this.filePath &&
          other.localFilePath == this.localFilePath &&
          other.fileName == this.fileName &&
          other.mimeType == this.mimeType &&
          other.fileSize == this.fileSize &&
          other.checksum == this.checksum &&
          other.ocrText == this.ocrText &&
          other.extractedDataJson == this.extractedDataJson &&
          other.isUploaded == this.isUploaded &&
          other.version == this.version &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalReceiptsCompanion extends UpdateCompanion<LocalReceipt> {
  final Value<String> id;
  final Value<String> transactionId;
  final Value<String> userId;
  final Value<String> filePath;
  final Value<String?> localFilePath;
  final Value<String?> fileName;
  final Value<String> mimeType;
  final Value<int> fileSize;
  final Value<String?> checksum;
  final Value<String?> ocrText;
  final Value<String?> extractedDataJson;
  final Value<bool> isUploaded;
  final Value<int> version;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalReceiptsCompanion({
    this.id = const Value.absent(),
    this.transactionId = const Value.absent(),
    this.userId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.localFilePath = const Value.absent(),
    this.fileName = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.checksum = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.extractedDataJson = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalReceiptsCompanion.insert({
    required String id,
    required String transactionId,
    required String userId,
    required String filePath,
    this.localFilePath = const Value.absent(),
    this.fileName = const Value.absent(),
    required String mimeType,
    required int fileSize,
    this.checksum = const Value.absent(),
    this.ocrText = const Value.absent(),
    this.extractedDataJson = const Value.absent(),
    this.isUploaded = const Value.absent(),
    this.version = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionId = Value(transactionId),
       userId = Value(userId),
       filePath = Value(filePath),
       mimeType = Value(mimeType),
       fileSize = Value(fileSize),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalReceipt> custom({
    Expression<String>? id,
    Expression<String>? transactionId,
    Expression<String>? userId,
    Expression<String>? filePath,
    Expression<String>? localFilePath,
    Expression<String>? fileName,
    Expression<String>? mimeType,
    Expression<int>? fileSize,
    Expression<String>? checksum,
    Expression<String>? ocrText,
    Expression<String>? extractedDataJson,
    Expression<bool>? isUploaded,
    Expression<int>? version,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (transactionId != null) 'transaction_id': transactionId,
      if (userId != null) 'user_id': userId,
      if (filePath != null) 'file_path': filePath,
      if (localFilePath != null) 'local_file_path': localFilePath,
      if (fileName != null) 'file_name': fileName,
      if (mimeType != null) 'mime_type': mimeType,
      if (fileSize != null) 'file_size': fileSize,
      if (checksum != null) 'checksum': checksum,
      if (ocrText != null) 'ocr_text': ocrText,
      if (extractedDataJson != null) 'extracted_data_json': extractedDataJson,
      if (isUploaded != null) 'is_uploaded': isUploaded,
      if (version != null) 'version': version,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalReceiptsCompanion copyWith({
    Value<String>? id,
    Value<String>? transactionId,
    Value<String>? userId,
    Value<String>? filePath,
    Value<String?>? localFilePath,
    Value<String?>? fileName,
    Value<String>? mimeType,
    Value<int>? fileSize,
    Value<String?>? checksum,
    Value<String?>? ocrText,
    Value<String?>? extractedDataJson,
    Value<bool>? isUploaded,
    Value<int>? version,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalReceiptsCompanion(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      filePath: filePath ?? this.filePath,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      fileSize: fileSize ?? this.fileSize,
      checksum: checksum ?? this.checksum,
      ocrText: ocrText ?? this.ocrText,
      extractedDataJson: extractedDataJson ?? this.extractedDataJson,
      isUploaded: isUploaded ?? this.isUploaded,
      version: version ?? this.version,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (transactionId.present) {
      map['transaction_id'] = Variable<String>(transactionId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (localFilePath.present) {
      map['local_file_path'] = Variable<String>(localFilePath.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (ocrText.present) {
      map['ocr_text'] = Variable<String>(ocrText.value);
    }
    if (extractedDataJson.present) {
      map['extracted_data_json'] = Variable<String>(extractedDataJson.value);
    }
    if (isUploaded.present) {
      map['is_uploaded'] = Variable<bool>(isUploaded.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalReceiptsCompanion(')
          ..write('id: $id, ')
          ..write('transactionId: $transactionId, ')
          ..write('userId: $userId, ')
          ..write('filePath: $filePath, ')
          ..write('localFilePath: $localFilePath, ')
          ..write('fileName: $fileName, ')
          ..write('mimeType: $mimeType, ')
          ..write('fileSize: $fileSize, ')
          ..write('checksum: $checksum, ')
          ..write('ocrText: $ocrText, ')
          ..write('extractedDataJson: $extractedDataJson, ')
          ..write('isUploaded: $isUploaded, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBudgetsTable extends LocalBudgets
    with TableInfo<$LocalBudgetsTable, LocalBudget> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
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
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodTypeMeta = const VerificationMeta(
    'periodType',
  );
  @override
  late final GeneratedColumn<String> periodType = GeneratedColumn<String>(
    'period_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('monthly'),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'start_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDateMeta = const VerificationMeta(
    'endDate',
  );
  @override
  late final GeneratedColumn<String> endDate = GeneratedColumn<String>(
    'end_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalLimitMeta = const VerificationMeta(
    'totalLimit',
  );
  @override
  late final GeneratedColumn<int> totalLimit = GeneratedColumn<int>(
    'total_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _warningPercentMeta = const VerificationMeta(
    'warningPercent',
  );
  @override
  late final GeneratedColumn<int> warningPercent = GeneratedColumn<int>(
    'warning_percent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(80),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    name,
    periodType,
    startDate,
    endDate,
    totalLimit,
    warningPercent,
    isActive,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_budgets';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBudget> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('period_type')) {
      context.handle(
        _periodTypeMeta,
        periodType.isAcceptableOrUnknown(data['period_type']!, _periodTypeMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('end_date')) {
      context.handle(
        _endDateMeta,
        endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta),
      );
    } else if (isInserting) {
      context.missing(_endDateMeta);
    }
    if (data.containsKey('total_limit')) {
      context.handle(
        _totalLimitMeta,
        totalLimit.isAcceptableOrUnknown(data['total_limit']!, _totalLimitMeta),
      );
    }
    if (data.containsKey('warning_percent')) {
      context.handle(
        _warningPercentMeta,
        warningPercent.isAcceptableOrUnknown(
          data['warning_percent']!,
          _warningPercentMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBudget map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBudget(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      periodType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period_type'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_date'],
      )!,
      endDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_date'],
      )!,
      totalLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_limit'],
      ),
      warningPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warning_percent'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalBudgetsTable createAlias(String alias) {
    return $LocalBudgetsTable(attachedDatabase, alias);
  }
}

class LocalBudget extends DataClass implements Insertable<LocalBudget> {
  final String id;
  final String userId;
  final String name;
  final String periodType;
  final String startDate;
  final String endDate;
  final int? totalLimit;
  final int warningPercent;
  final bool isActive;
  final int version;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalBudget({
    required this.id,
    required this.userId,
    required this.name,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    this.totalLimit,
    required this.warningPercent,
    required this.isActive,
    required this.version,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['period_type'] = Variable<String>(periodType);
    map['start_date'] = Variable<String>(startDate);
    map['end_date'] = Variable<String>(endDate);
    if (!nullToAbsent || totalLimit != null) {
      map['total_limit'] = Variable<int>(totalLimit);
    }
    map['warning_percent'] = Variable<int>(warningPercent);
    map['is_active'] = Variable<bool>(isActive);
    map['version'] = Variable<int>(version);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalBudgetsCompanion toCompanion(bool nullToAbsent) {
    return LocalBudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      periodType: Value(periodType),
      startDate: Value(startDate),
      endDate: Value(endDate),
      totalLimit: totalLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(totalLimit),
      warningPercent: Value(warningPercent),
      isActive: Value(isActive),
      version: Value(version),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalBudget.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBudget(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      periodType: serializer.fromJson<String>(json['periodType']),
      startDate: serializer.fromJson<String>(json['startDate']),
      endDate: serializer.fromJson<String>(json['endDate']),
      totalLimit: serializer.fromJson<int?>(json['totalLimit']),
      warningPercent: serializer.fromJson<int>(json['warningPercent']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      version: serializer.fromJson<int>(json['version']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'periodType': serializer.toJson<String>(periodType),
      'startDate': serializer.toJson<String>(startDate),
      'endDate': serializer.toJson<String>(endDate),
      'totalLimit': serializer.toJson<int?>(totalLimit),
      'warningPercent': serializer.toJson<int>(warningPercent),
      'isActive': serializer.toJson<bool>(isActive),
      'version': serializer.toJson<int>(version),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalBudget copyWith({
    String? id,
    String? userId,
    String? name,
    String? periodType,
    String? startDate,
    String? endDate,
    Value<int?> totalLimit = const Value.absent(),
    int? warningPercent,
    bool? isActive,
    int? version,
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalBudget(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    periodType: periodType ?? this.periodType,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    totalLimit: totalLimit.present ? totalLimit.value : this.totalLimit,
    warningPercent: warningPercent ?? this.warningPercent,
    isActive: isActive ?? this.isActive,
    version: version ?? this.version,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalBudget copyWithCompanion(LocalBudgetsCompanion data) {
    return LocalBudget(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      periodType: data.periodType.present
          ? data.periodType.value
          : this.periodType,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      totalLimit: data.totalLimit.present
          ? data.totalLimit.value
          : this.totalLimit,
      warningPercent: data.warningPercent.present
          ? data.warningPercent.value
          : this.warningPercent,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      version: data.version.present ? data.version.value : this.version,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudget(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('periodType: $periodType, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('warningPercent: $warningPercent, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    name,
    periodType,
    startDate,
    endDate,
    totalLimit,
    warningPercent,
    isActive,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBudget &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.periodType == this.periodType &&
          other.startDate == this.startDate &&
          other.endDate == this.endDate &&
          other.totalLimit == this.totalLimit &&
          other.warningPercent == this.warningPercent &&
          other.isActive == this.isActive &&
          other.version == this.version &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalBudgetsCompanion extends UpdateCompanion<LocalBudget> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> periodType;
  final Value<String> startDate;
  final Value<String> endDate;
  final Value<int?> totalLimit;
  final Value<int> warningPercent;
  final Value<bool> isActive;
  final Value<int> version;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalBudgetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.periodType = const Value.absent(),
    this.startDate = const Value.absent(),
    this.endDate = const Value.absent(),
    this.totalLimit = const Value.absent(),
    this.warningPercent = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBudgetsCompanion.insert({
    required String id,
    required String userId,
    required String name,
    this.periodType = const Value.absent(),
    required String startDate,
    required String endDate,
    this.totalLimit = const Value.absent(),
    this.warningPercent = const Value.absent(),
    this.isActive = const Value.absent(),
    this.version = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       name = Value(name),
       startDate = Value(startDate),
       endDate = Value(endDate),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalBudget> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? periodType,
    Expression<String>? startDate,
    Expression<String>? endDate,
    Expression<int>? totalLimit,
    Expression<int>? warningPercent,
    Expression<bool>? isActive,
    Expression<int>? version,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (periodType != null) 'period_type': periodType,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (totalLimit != null) 'total_limit': totalLimit,
      if (warningPercent != null) 'warning_percent': warningPercent,
      if (isActive != null) 'is_active': isActive,
      if (version != null) 'version': version,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBudgetsCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? name,
    Value<String>? periodType,
    Value<String>? startDate,
    Value<String>? endDate,
    Value<int?>? totalLimit,
    Value<int>? warningPercent,
    Value<bool>? isActive,
    Value<int>? version,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalBudgetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      periodType: periodType ?? this.periodType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalLimit: totalLimit ?? this.totalLimit,
      warningPercent: warningPercent ?? this.warningPercent,
      isActive: isActive ?? this.isActive,
      version: version ?? this.version,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (periodType.present) {
      map['period_type'] = Variable<String>(periodType.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<String>(endDate.value);
    }
    if (totalLimit.present) {
      map['total_limit'] = Variable<int>(totalLimit.value);
    }
    if (warningPercent.present) {
      map['warning_percent'] = Variable<int>(warningPercent.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudgetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('periodType: $periodType, ')
          ..write('startDate: $startDate, ')
          ..write('endDate: $endDate, ')
          ..write('totalLimit: $totalLimit, ')
          ..write('warningPercent: $warningPercent, ')
          ..write('isActive: $isActive, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalBudgetCategoriesTable extends LocalBudgetCategories
    with TableInfo<$LocalBudgetCategoriesTable, LocalBudgetCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalBudgetCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _budgetIdMeta = const VerificationMeta(
    'budgetId',
  );
  @override
  late final GeneratedColumn<String> budgetId = GeneratedColumn<String>(
    'budget_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
    'category_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryTypeMeta = const VerificationMeta(
    'categoryType',
  );
  @override
  late final GeneratedColumn<String> categoryType = GeneratedColumn<String>(
    'category_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('expense'),
  );
  static const VerificationMeta _amountLimitMeta = const VerificationMeta(
    'amountLimit',
  );
  @override
  late final GeneratedColumn<int> amountLimit = GeneratedColumn<int>(
    'amount_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMsMeta = const VerificationMeta(
    'deletedAtMs',
  );
  @override
  late final GeneratedColumn<int> deletedAtMs = GeneratedColumn<int>(
    'deleted_at_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    budgetId,
    categoryId,
    categoryType,
    amountLimit,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_budget_categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalBudgetCategory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('budget_id')) {
      context.handle(
        _budgetIdMeta,
        budgetId.isAcceptableOrUnknown(data['budget_id']!, _budgetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_budgetIdMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['category_id']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('category_type')) {
      context.handle(
        _categoryTypeMeta,
        categoryType.isAcceptableOrUnknown(
          data['category_type']!,
          _categoryTypeMeta,
        ),
      );
    }
    if (data.containsKey('amount_limit')) {
      context.handle(
        _amountLimitMeta,
        amountLimit.isAcceptableOrUnknown(
          data['amount_limit']!,
          _amountLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_amountLimitMeta);
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    if (data.containsKey('deleted_at_ms')) {
      context.handle(
        _deletedAtMsMeta,
        deletedAtMs.isAcceptableOrUnknown(
          data['deleted_at_ms']!,
          _deletedAtMsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalBudgetCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalBudgetCategory(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      budgetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}budget_id'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_id'],
      )!,
      categoryType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category_type'],
      )!,
      amountLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount_limit'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
      deletedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deleted_at_ms'],
      ),
    );
  }

  @override
  $LocalBudgetCategoriesTable createAlias(String alias) {
    return $LocalBudgetCategoriesTable(attachedDatabase, alias);
  }
}

class LocalBudgetCategory extends DataClass
    implements Insertable<LocalBudgetCategory> {
  final String id;
  final String userId;
  final String budgetId;
  final String categoryId;
  final String categoryType;
  final int amountLimit;
  final int version;
  final int createdAtMs;
  final int updatedAtMs;
  final int? deletedAtMs;
  const LocalBudgetCategory({
    required this.id,
    required this.userId,
    required this.budgetId,
    required this.categoryId,
    required this.categoryType,
    required this.amountLimit,
    required this.version,
    required this.createdAtMs,
    required this.updatedAtMs,
    this.deletedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['budget_id'] = Variable<String>(budgetId);
    map['category_id'] = Variable<String>(categoryId);
    map['category_type'] = Variable<String>(categoryType);
    map['amount_limit'] = Variable<int>(amountLimit);
    map['version'] = Variable<int>(version);
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    if (!nullToAbsent || deletedAtMs != null) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs);
    }
    return map;
  }

  LocalBudgetCategoriesCompanion toCompanion(bool nullToAbsent) {
    return LocalBudgetCategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      budgetId: Value(budgetId),
      categoryId: Value(categoryId),
      categoryType: Value(categoryType),
      amountLimit: Value(amountLimit),
      version: Value(version),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
      deletedAtMs: deletedAtMs == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAtMs),
    );
  }

  factory LocalBudgetCategory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalBudgetCategory(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      budgetId: serializer.fromJson<String>(json['budgetId']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      categoryType: serializer.fromJson<String>(json['categoryType']),
      amountLimit: serializer.fromJson<int>(json['amountLimit']),
      version: serializer.fromJson<int>(json['version']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
      deletedAtMs: serializer.fromJson<int?>(json['deletedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'budgetId': serializer.toJson<String>(budgetId),
      'categoryId': serializer.toJson<String>(categoryId),
      'categoryType': serializer.toJson<String>(categoryType),
      'amountLimit': serializer.toJson<int>(amountLimit),
      'version': serializer.toJson<int>(version),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
      'deletedAtMs': serializer.toJson<int?>(deletedAtMs),
    };
  }

  LocalBudgetCategory copyWith({
    String? id,
    String? userId,
    String? budgetId,
    String? categoryId,
    String? categoryType,
    int? amountLimit,
    int? version,
    int? createdAtMs,
    int? updatedAtMs,
    Value<int?> deletedAtMs = const Value.absent(),
  }) => LocalBudgetCategory(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    budgetId: budgetId ?? this.budgetId,
    categoryId: categoryId ?? this.categoryId,
    categoryType: categoryType ?? this.categoryType,
    amountLimit: amountLimit ?? this.amountLimit,
    version: version ?? this.version,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
    deletedAtMs: deletedAtMs.present ? deletedAtMs.value : this.deletedAtMs,
  );
  LocalBudgetCategory copyWithCompanion(LocalBudgetCategoriesCompanion data) {
    return LocalBudgetCategory(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      budgetId: data.budgetId.present ? data.budgetId.value : this.budgetId,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      categoryType: data.categoryType.present
          ? data.categoryType.value
          : this.categoryType,
      amountLimit: data.amountLimit.present
          ? data.amountLimit.value
          : this.amountLimit,
      version: data.version.present ? data.version.value : this.version,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
      deletedAtMs: data.deletedAtMs.present
          ? data.deletedAtMs.value
          : this.deletedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudgetCategory(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryType: $categoryType, ')
          ..write('amountLimit: $amountLimit, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    budgetId,
    categoryId,
    categoryType,
    amountLimit,
    version,
    createdAtMs,
    updatedAtMs,
    deletedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalBudgetCategory &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.budgetId == this.budgetId &&
          other.categoryId == this.categoryId &&
          other.categoryType == this.categoryType &&
          other.amountLimit == this.amountLimit &&
          other.version == this.version &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs &&
          other.deletedAtMs == this.deletedAtMs);
}

class LocalBudgetCategoriesCompanion
    extends UpdateCompanion<LocalBudgetCategory> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> budgetId;
  final Value<String> categoryId;
  final Value<String> categoryType;
  final Value<int> amountLimit;
  final Value<int> version;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int?> deletedAtMs;
  final Value<int> rowid;
  const LocalBudgetCategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.budgetId = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.categoryType = const Value.absent(),
    this.amountLimit = const Value.absent(),
    this.version = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalBudgetCategoriesCompanion.insert({
    required String id,
    required String userId,
    required String budgetId,
    required String categoryId,
    this.categoryType = const Value.absent(),
    required int amountLimit,
    this.version = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.deletedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       userId = Value(userId),
       budgetId = Value(budgetId),
       categoryId = Value(categoryId),
       amountLimit = Value(amountLimit),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<LocalBudgetCategory> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? budgetId,
    Expression<String>? categoryId,
    Expression<String>? categoryType,
    Expression<int>? amountLimit,
    Expression<int>? version,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? deletedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (budgetId != null) 'budget_id': budgetId,
      if (categoryId != null) 'category_id': categoryId,
      if (categoryType != null) 'category_type': categoryType,
      if (amountLimit != null) 'amount_limit': amountLimit,
      if (version != null) 'version': version,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (deletedAtMs != null) 'deleted_at_ms': deletedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalBudgetCategoriesCompanion copyWith({
    Value<String>? id,
    Value<String>? userId,
    Value<String>? budgetId,
    Value<String>? categoryId,
    Value<String>? categoryType,
    Value<int>? amountLimit,
    Value<int>? version,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int?>? deletedAtMs,
    Value<int>? rowid,
  }) {
    return LocalBudgetCategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      budgetId: budgetId ?? this.budgetId,
      categoryId: categoryId ?? this.categoryId,
      categoryType: categoryType ?? this.categoryType,
      amountLimit: amountLimit ?? this.amountLimit,
      version: version ?? this.version,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      deletedAtMs: deletedAtMs ?? this.deletedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (budgetId.present) {
      map['budget_id'] = Variable<String>(budgetId.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (categoryType.present) {
      map['category_type'] = Variable<String>(categoryType.value);
    }
    if (amountLimit.present) {
      map['amount_limit'] = Variable<int>(amountLimit.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (deletedAtMs.present) {
      map['deleted_at_ms'] = Variable<int>(deletedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalBudgetCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('budgetId: $budgetId, ')
          ..write('categoryId: $categoryId, ')
          ..write('categoryType: $categoryType, ')
          ..write('amountLimit: $amountLimit, ')
          ..write('version: $version, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('deletedAtMs: $deletedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncOutboxTable extends SyncOutbox
    with TableInfo<$SyncOutboxTable, SyncOutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncOutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationIdMeta = const VerificationMeta(
    'operationId',
  );
  @override
  late final GeneratedColumn<String> operationId = GeneratedColumn<String>(
    'operation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _operationTypeMeta = const VerificationMeta(
    'operationType',
  );
  @override
  late final GeneratedColumn<String> operationType = GeneratedColumn<String>(
    'operation_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _baseVersionMeta = const VerificationMeta(
    'baseVersion',
  );
  @override
  late final GeneratedColumn<int> baseVersion = GeneratedColumn<int>(
    'base_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMsMeta = const VerificationMeta(
    'createdAtMs',
  );
  @override
  late final GeneratedColumn<int> createdAtMs = GeneratedColumn<int>(
    'created_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMsMeta = const VerificationMeta(
    'updatedAtMs',
  );
  @override
  late final GeneratedColumn<int> updatedAtMs = GeneratedColumn<int>(
    'updated_at_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    operationId,
    userId,
    deviceId,
    entityType,
    entityId,
    operationType,
    baseVersion,
    payloadJson,
    status,
    retryCount,
    lastError,
    createdAtMs,
    updatedAtMs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncOutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('operation_id')) {
      context.handle(
        _operationIdMeta,
        operationId.isAcceptableOrUnknown(
          data['operation_id']!,
          _operationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
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
    if (data.containsKey('operation_type')) {
      context.handle(
        _operationTypeMeta,
        operationType.isAcceptableOrUnknown(
          data['operation_type']!,
          _operationTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_operationTypeMeta);
    }
    if (data.containsKey('base_version')) {
      context.handle(
        _baseVersionMeta,
        baseVersion.isAcceptableOrUnknown(
          data['base_version']!,
          _baseVersionMeta,
        ),
      );
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('created_at_ms')) {
      context.handle(
        _createdAtMsMeta,
        createdAtMs.isAcceptableOrUnknown(
          data['created_at_ms']!,
          _createdAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_createdAtMsMeta);
    }
    if (data.containsKey('updated_at_ms')) {
      context.handle(
        _updatedAtMsMeta,
        updatedAtMs.isAcceptableOrUnknown(
          data['updated_at_ms']!,
          _updatedAtMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncOutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncOutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      operationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operationType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation_type'],
      )!,
      baseVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}base_version'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      createdAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at_ms'],
      )!,
      updatedAtMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at_ms'],
      )!,
    );
  }

  @override
  $SyncOutboxTable createAlias(String alias) {
    return $SyncOutboxTable(attachedDatabase, alias);
  }
}

class SyncOutboxData extends DataClass implements Insertable<SyncOutboxData> {
  final String id;
  final String operationId;
  final String userId;
  final String deviceId;
  final String entityType;
  final String entityId;
  final String operationType;
  final int baseVersion;
  final String payloadJson;
  final String status;
  final int retryCount;
  final String? lastError;
  final int createdAtMs;
  final int updatedAtMs;
  const SyncOutboxData({
    required this.id,
    required this.operationId,
    required this.userId,
    required this.deviceId,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.baseVersion,
    required this.payloadJson,
    required this.status,
    required this.retryCount,
    this.lastError,
    required this.createdAtMs,
    required this.updatedAtMs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['operation_id'] = Variable<String>(operationId);
    map['user_id'] = Variable<String>(userId);
    map['device_id'] = Variable<String>(deviceId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation_type'] = Variable<String>(operationType);
    map['base_version'] = Variable<int>(baseVersion);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    map['created_at_ms'] = Variable<int>(createdAtMs);
    map['updated_at_ms'] = Variable<int>(updatedAtMs);
    return map;
  }

  SyncOutboxCompanion toCompanion(bool nullToAbsent) {
    return SyncOutboxCompanion(
      id: Value(id),
      operationId: Value(operationId),
      userId: Value(userId),
      deviceId: Value(deviceId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operationType: Value(operationType),
      baseVersion: Value(baseVersion),
      payloadJson: Value(payloadJson),
      status: Value(status),
      retryCount: Value(retryCount),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      createdAtMs: Value(createdAtMs),
      updatedAtMs: Value(updatedAtMs),
    );
  }

  factory SyncOutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncOutboxData(
      id: serializer.fromJson<String>(json['id']),
      operationId: serializer.fromJson<String>(json['operationId']),
      userId: serializer.fromJson<String>(json['userId']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operationType: serializer.fromJson<String>(json['operationType']),
      baseVersion: serializer.fromJson<int>(json['baseVersion']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      createdAtMs: serializer.fromJson<int>(json['createdAtMs']),
      updatedAtMs: serializer.fromJson<int>(json['updatedAtMs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'operationId': serializer.toJson<String>(operationId),
      'userId': serializer.toJson<String>(userId),
      'deviceId': serializer.toJson<String>(deviceId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operationType': serializer.toJson<String>(operationType),
      'baseVersion': serializer.toJson<int>(baseVersion),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastError': serializer.toJson<String?>(lastError),
      'createdAtMs': serializer.toJson<int>(createdAtMs),
      'updatedAtMs': serializer.toJson<int>(updatedAtMs),
    };
  }

  SyncOutboxData copyWith({
    String? id,
    String? operationId,
    String? userId,
    String? deviceId,
    String? entityType,
    String? entityId,
    String? operationType,
    int? baseVersion,
    String? payloadJson,
    String? status,
    int? retryCount,
    Value<String?> lastError = const Value.absent(),
    int? createdAtMs,
    int? updatedAtMs,
  }) => SyncOutboxData(
    id: id ?? this.id,
    operationId: operationId ?? this.operationId,
    userId: userId ?? this.userId,
    deviceId: deviceId ?? this.deviceId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operationType: operationType ?? this.operationType,
    baseVersion: baseVersion ?? this.baseVersion,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastError: lastError.present ? lastError.value : this.lastError,
    createdAtMs: createdAtMs ?? this.createdAtMs,
    updatedAtMs: updatedAtMs ?? this.updatedAtMs,
  );
  SyncOutboxData copyWithCompanion(SyncOutboxCompanion data) {
    return SyncOutboxData(
      id: data.id.present ? data.id.value : this.id,
      operationId: data.operationId.present
          ? data.operationId.value
          : this.operationId,
      userId: data.userId.present ? data.userId.value : this.userId,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operationType: data.operationType.present
          ? data.operationType.value
          : this.operationType,
      baseVersion: data.baseVersion.present
          ? data.baseVersion.value
          : this.baseVersion,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      createdAtMs: data.createdAtMs.present
          ? data.createdAtMs.value
          : this.createdAtMs,
      updatedAtMs: data.updatedAtMs.present
          ? data.updatedAtMs.value
          : this.updatedAtMs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxData(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    operationId,
    userId,
    deviceId,
    entityType,
    entityId,
    operationType,
    baseVersion,
    payloadJson,
    status,
    retryCount,
    lastError,
    createdAtMs,
    updatedAtMs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncOutboxData &&
          other.id == this.id &&
          other.operationId == this.operationId &&
          other.userId == this.userId &&
          other.deviceId == this.deviceId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operationType == this.operationType &&
          other.baseVersion == this.baseVersion &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastError == this.lastError &&
          other.createdAtMs == this.createdAtMs &&
          other.updatedAtMs == this.updatedAtMs);
}

class SyncOutboxCompanion extends UpdateCompanion<SyncOutboxData> {
  final Value<String> id;
  final Value<String> operationId;
  final Value<String> userId;
  final Value<String> deviceId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operationType;
  final Value<int> baseVersion;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<String?> lastError;
  final Value<int> createdAtMs;
  final Value<int> updatedAtMs;
  final Value<int> rowid;
  const SyncOutboxCompanion({
    this.id = const Value.absent(),
    this.operationId = const Value.absent(),
    this.userId = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operationType = const Value.absent(),
    this.baseVersion = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    this.createdAtMs = const Value.absent(),
    this.updatedAtMs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncOutboxCompanion.insert({
    required String id,
    required String operationId,
    required String userId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operationType,
    this.baseVersion = const Value.absent(),
    required String payloadJson,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastError = const Value.absent(),
    required int createdAtMs,
    required int updatedAtMs,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       operationId = Value(operationId),
       userId = Value(userId),
       deviceId = Value(deviceId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operationType = Value(operationType),
       payloadJson = Value(payloadJson),
       createdAtMs = Value(createdAtMs),
       updatedAtMs = Value(updatedAtMs);
  static Insertable<SyncOutboxData> custom({
    Expression<String>? id,
    Expression<String>? operationId,
    Expression<String>? userId,
    Expression<String>? deviceId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operationType,
    Expression<int>? baseVersion,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<String>? lastError,
    Expression<int>? createdAtMs,
    Expression<int>? updatedAtMs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (operationId != null) 'operation_id': operationId,
      if (userId != null) 'user_id': userId,
      if (deviceId != null) 'device_id': deviceId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operationType != null) 'operation_type': operationType,
      if (baseVersion != null) 'base_version': baseVersion,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastError != null) 'last_error': lastError,
      if (createdAtMs != null) 'created_at_ms': createdAtMs,
      if (updatedAtMs != null) 'updated_at_ms': updatedAtMs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncOutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? operationId,
    Value<String>? userId,
    Value<String>? deviceId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operationType,
    Value<int>? baseVersion,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<int>? retryCount,
    Value<String?>? lastError,
    Value<int>? createdAtMs,
    Value<int>? updatedAtMs,
    Value<int>? rowid,
  }) {
    return SyncOutboxCompanion(
      id: id ?? this.id,
      operationId: operationId ?? this.operationId,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      baseVersion: baseVersion ?? this.baseVersion,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAtMs: createdAtMs ?? this.createdAtMs,
      updatedAtMs: updatedAtMs ?? this.updatedAtMs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (operationId.present) {
      map['operation_id'] = Variable<String>(operationId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operationType.present) {
      map['operation_type'] = Variable<String>(operationType.value);
    }
    if (baseVersion.present) {
      map['base_version'] = Variable<int>(baseVersion.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (createdAtMs.present) {
      map['created_at_ms'] = Variable<int>(createdAtMs.value);
    }
    if (updatedAtMs.present) {
      map['updated_at_ms'] = Variable<int>(updatedAtMs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncOutboxCompanion(')
          ..write('id: $id, ')
          ..write('operationId: $operationId, ')
          ..write('userId: $userId, ')
          ..write('deviceId: $deviceId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operationType: $operationType, ')
          ..write('baseVersion: $baseVersion, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastError: $lastError, ')
          ..write('createdAtMs: $createdAtMs, ')
          ..write('updatedAtMs: $updatedAtMs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSyncStateTable localSyncState = $LocalSyncStateTable(this);
  late final $LocalUsersTable localUsers = $LocalUsersTable(this);
  late final $LocalUserSettingsTable localUserSettings =
      $LocalUserSettingsTable(this);
  late final $LocalDevicesTable localDevices = $LocalDevicesTable(this);
  late final $LocalAccountsTable localAccounts = $LocalAccountsTable(this);
  late final $LocalCategoriesTable localCategories = $LocalCategoriesTable(
    this,
  );
  late final $LocalTransactionsTable localTransactions =
      $LocalTransactionsTable(this);
  late final $LocalAccountMovementsTable localAccountMovements =
      $LocalAccountMovementsTable(this);
  late final $LocalAccountAdjustmentsTable localAccountAdjustments =
      $LocalAccountAdjustmentsTable(this);
  late final $LocalTransactionRevisionsTable localTransactionRevisions =
      $LocalTransactionRevisionsTable(this);
  late final $LocalReceiptsTable localReceipts = $LocalReceiptsTable(this);
  late final $LocalBudgetsTable localBudgets = $LocalBudgetsTable(this);
  late final $LocalBudgetCategoriesTable localBudgetCategories =
      $LocalBudgetCategoriesTable(this);
  late final $SyncOutboxTable syncOutbox = $SyncOutboxTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localSyncState,
    localUsers,
    localUserSettings,
    localDevices,
    localAccounts,
    localCategories,
    localTransactions,
    localAccountMovements,
    localAccountAdjustments,
    localTransactionRevisions,
    localReceipts,
    localBudgets,
    localBudgetCategories,
    syncOutbox,
  ];
}

typedef $$LocalSyncStateTableCreateCompanionBuilder =
    LocalSyncStateCompanion Function({
      required String id,
      required String userId,
      required String deviceId,
      Value<int> lastCursor,
      Value<int?> lastSyncAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$LocalSyncStateTableUpdateCompanionBuilder =
    LocalSyncStateCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> deviceId,
      Value<int> lastCursor,
      Value<int?> lastSyncAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$LocalSyncStateTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncStateTable> {
  $$LocalSyncStateTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastCursor => $composableBuilder(
    column: $table.lastCursor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncAtMs => $composableBuilder(
    column: $table.lastSyncAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncStateTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncStateTable> {
  $$LocalSyncStateTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastCursor => $composableBuilder(
    column: $table.lastCursor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncAtMs => $composableBuilder(
    column: $table.lastSyncAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncStateTable> {
  $$LocalSyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get lastCursor => $composableBuilder(
    column: $table.lastCursor,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSyncAtMs => $composableBuilder(
    column: $table.lastSyncAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$LocalSyncStateTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncStateTable,
          LocalSyncStateData,
          $$LocalSyncStateTableFilterComposer,
          $$LocalSyncStateTableOrderingComposer,
          $$LocalSyncStateTableAnnotationComposer,
          $$LocalSyncStateTableCreateCompanionBuilder,
          $$LocalSyncStateTableUpdateCompanionBuilder,
          (
            LocalSyncStateData,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncStateTable,
              LocalSyncStateData
            >,
          ),
          LocalSyncStateData,
          PrefetchHooks Function()
        > {
  $$LocalSyncStateTableTableManager(
    _$AppDatabase db,
    $LocalSyncStateTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> lastCursor = const Value.absent(),
                Value<int?> lastSyncAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncStateCompanion(
                id: id,
                userId: userId,
                deviceId: deviceId,
                lastCursor: lastCursor,
                lastSyncAtMs: lastSyncAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String deviceId,
                Value<int> lastCursor = const Value.absent(),
                Value<int?> lastSyncAtMs = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncStateCompanion.insert(
                id: id,
                userId: userId,
                deviceId: deviceId,
                lastCursor: lastCursor,
                lastSyncAtMs: lastSyncAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncStateTable,
      LocalSyncStateData,
      $$LocalSyncStateTableFilterComposer,
      $$LocalSyncStateTableOrderingComposer,
      $$LocalSyncStateTableAnnotationComposer,
      $$LocalSyncStateTableCreateCompanionBuilder,
      $$LocalSyncStateTableUpdateCompanionBuilder,
      (
        LocalSyncStateData,
        BaseReferences<_$AppDatabase, $LocalSyncStateTable, LocalSyncStateData>,
      ),
      LocalSyncStateData,
      PrefetchHooks Function()
    >;
typedef $$LocalUsersTableCreateCompanionBuilder =
    LocalUsersCompanion Function({
      required String id,
      required String name,
      required String email,
      Value<int?> emailVerifiedAtMs,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalUsersTableUpdateCompanionBuilder =
    LocalUsersCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> email,
      Value<int?> emailVerifiedAtMs,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalUsersTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emailVerifiedAtMs => $composableBuilder(
    column: $table.emailVerifiedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emailVerifiedAtMs => $composableBuilder(
    column: $table.emailVerifiedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUsersTable> {
  $$LocalUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<int> get emailVerifiedAtMs => $composableBuilder(
    column: $table.emailVerifiedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUsersTable,
          LocalUser,
          $$LocalUsersTableFilterComposer,
          $$LocalUsersTableOrderingComposer,
          $$LocalUsersTableAnnotationComposer,
          $$LocalUsersTableCreateCompanionBuilder,
          $$LocalUsersTableUpdateCompanionBuilder,
          (
            LocalUser,
            BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>,
          ),
          LocalUser,
          PrefetchHooks Function()
        > {
  $$LocalUsersTableTableManager(_$AppDatabase db, $LocalUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int?> emailVerifiedAtMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion(
                id: id,
                name: name,
                email: email,
                emailVerifiedAtMs: emailVerifiedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String email,
                Value<int?> emailVerifiedAtMs = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUsersCompanion.insert(
                id: id,
                name: name,
                email: email,
                emailVerifiedAtMs: emailVerifiedAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUsersTable,
      LocalUser,
      $$LocalUsersTableFilterComposer,
      $$LocalUsersTableOrderingComposer,
      $$LocalUsersTableAnnotationComposer,
      $$LocalUsersTableCreateCompanionBuilder,
      $$LocalUsersTableUpdateCompanionBuilder,
      (LocalUser, BaseReferences<_$AppDatabase, $LocalUsersTable, LocalUser>),
      LocalUser,
      PrefetchHooks Function()
    >;
typedef $$LocalUserSettingsTableCreateCompanionBuilder =
    LocalUserSettingsCompanion Function({
      required String id,
      required String userId,
      Value<String> themeMode,
      Value<String> currency,
      Value<String> timezone,
      Value<int> budgetWarningPercent,
      Value<bool> notificationsEnabled,
      Value<int> version,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$LocalUserSettingsTableUpdateCompanionBuilder =
    LocalUserSettingsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> themeMode,
      Value<String> currency,
      Value<String> timezone,
      Value<int> budgetWarningPercent,
      Value<bool> notificationsEnabled,
      Value<int> version,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$LocalUserSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get budgetWarningPercent => $composableBuilder(
    column: $table.budgetWarningPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalUserSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currency => $composableBuilder(
    column: $table.currency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get timezone => $composableBuilder(
    column: $table.timezone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get budgetWarningPercent => $composableBuilder(
    column: $table.budgetWarningPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalUserSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalUserSettingsTable> {
  $$LocalUserSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get currency =>
      $composableBuilder(column: $table.currency, builder: (column) => column);

  GeneratedColumn<String> get timezone =>
      $composableBuilder(column: $table.timezone, builder: (column) => column);

  GeneratedColumn<int> get budgetWarningPercent => $composableBuilder(
    column: $table.budgetWarningPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
    column: $table.notificationsEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$LocalUserSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalUserSettingsTable,
          LocalUserSetting,
          $$LocalUserSettingsTableFilterComposer,
          $$LocalUserSettingsTableOrderingComposer,
          $$LocalUserSettingsTableAnnotationComposer,
          $$LocalUserSettingsTableCreateCompanionBuilder,
          $$LocalUserSettingsTableUpdateCompanionBuilder,
          (
            LocalUserSetting,
            BaseReferences<
              _$AppDatabase,
              $LocalUserSettingsTable,
              LocalUserSetting
            >,
          ),
          LocalUserSetting,
          PrefetchHooks Function()
        > {
  $$LocalUserSettingsTableTableManager(
    _$AppDatabase db,
    $LocalUserSettingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalUserSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalUserSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalUserSettingsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> budgetWarningPercent = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalUserSettingsCompanion(
                id: id,
                userId: userId,
                themeMode: themeMode,
                currency: currency,
                timezone: timezone,
                budgetWarningPercent: budgetWarningPercent,
                notificationsEnabled: notificationsEnabled,
                version: version,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                Value<String> themeMode = const Value.absent(),
                Value<String> currency = const Value.absent(),
                Value<String> timezone = const Value.absent(),
                Value<int> budgetWarningPercent = const Value.absent(),
                Value<bool> notificationsEnabled = const Value.absent(),
                Value<int> version = const Value.absent(),
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LocalUserSettingsCompanion.insert(
                id: id,
                userId: userId,
                themeMode: themeMode,
                currency: currency,
                timezone: timezone,
                budgetWarningPercent: budgetWarningPercent,
                notificationsEnabled: notificationsEnabled,
                version: version,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalUserSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalUserSettingsTable,
      LocalUserSetting,
      $$LocalUserSettingsTableFilterComposer,
      $$LocalUserSettingsTableOrderingComposer,
      $$LocalUserSettingsTableAnnotationComposer,
      $$LocalUserSettingsTableCreateCompanionBuilder,
      $$LocalUserSettingsTableUpdateCompanionBuilder,
      (
        LocalUserSetting,
        BaseReferences<
          _$AppDatabase,
          $LocalUserSettingsTable,
          LocalUserSetting
        >,
      ),
      LocalUserSetting,
      PrefetchHooks Function()
    >;
typedef $$LocalDevicesTableCreateCompanionBuilder =
    LocalDevicesCompanion Function({
      required String id,
      required String userId,
      required String deviceName,
      Value<String> platform,
      Value<String?> appVersion,
      Value<bool> isActive,
      Value<int?> lastSyncAtMs,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$LocalDevicesTableUpdateCompanionBuilder =
    LocalDevicesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> deviceName,
      Value<String> platform,
      Value<String?> appVersion,
      Value<bool> isActive,
      Value<int?> lastSyncAtMs,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$LocalDevicesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalDevicesTable> {
  $$LocalDevicesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSyncAtMs => $composableBuilder(
    column: $table.lastSyncAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalDevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalDevicesTable> {
  $$LocalDevicesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSyncAtMs => $composableBuilder(
    column: $table.lastSyncAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalDevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalDevicesTable> {
  $$LocalDevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceName => $composableBuilder(
    column: $table.deviceName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get appVersion => $composableBuilder(
    column: $table.appVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get lastSyncAtMs => $composableBuilder(
    column: $table.lastSyncAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$LocalDevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalDevicesTable,
          LocalDevice,
          $$LocalDevicesTableFilterComposer,
          $$LocalDevicesTableOrderingComposer,
          $$LocalDevicesTableAnnotationComposer,
          $$LocalDevicesTableCreateCompanionBuilder,
          $$LocalDevicesTableUpdateCompanionBuilder,
          (
            LocalDevice,
            BaseReferences<_$AppDatabase, $LocalDevicesTable, LocalDevice>,
          ),
          LocalDevice,
          PrefetchHooks Function()
        > {
  $$LocalDevicesTableTableManager(_$AppDatabase db, $LocalDevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalDevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalDevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalDevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> deviceName = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastSyncAtMs = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalDevicesCompanion(
                id: id,
                userId: userId,
                deviceName: deviceName,
                platform: platform,
                appVersion: appVersion,
                isActive: isActive,
                lastSyncAtMs: lastSyncAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String deviceName,
                Value<String> platform = const Value.absent(),
                Value<String?> appVersion = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int?> lastSyncAtMs = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LocalDevicesCompanion.insert(
                id: id,
                userId: userId,
                deviceName: deviceName,
                platform: platform,
                appVersion: appVersion,
                isActive: isActive,
                lastSyncAtMs: lastSyncAtMs,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalDevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalDevicesTable,
      LocalDevice,
      $$LocalDevicesTableFilterComposer,
      $$LocalDevicesTableOrderingComposer,
      $$LocalDevicesTableAnnotationComposer,
      $$LocalDevicesTableCreateCompanionBuilder,
      $$LocalDevicesTableUpdateCompanionBuilder,
      (
        LocalDevice,
        BaseReferences<_$AppDatabase, $LocalDevicesTable, LocalDevice>,
      ),
      LocalDevice,
      PrefetchHooks Function()
    >;
typedef $$LocalAccountsTableCreateCompanionBuilder =
    LocalAccountsCompanion Function({
      required String id,
      required String userId,
      required String name,
      required String accountType,
      Value<String?> institutionName,
      Value<String?> accountNumber,
      Value<int> openingBalance,
      required String openingBalanceDate,
      Value<int> balanceCache,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isActive,
      Value<int> version,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalAccountsTableUpdateCompanionBuilder =
    LocalAccountsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> accountType,
      Value<String?> institutionName,
      Value<String?> accountNumber,
      Value<int> openingBalance,
      Value<String> openingBalanceDate,
      Value<int> balanceCache,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isActive,
      Value<int> version,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get openingBalanceDate => $composableBuilder(
    column: $table.openingBalanceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get balanceCache => $composableBuilder(
    column: $table.balanceCache,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openingBalanceDate => $composableBuilder(
    column: $table.openingBalanceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get balanceCache => $composableBuilder(
    column: $table.balanceCache,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountsTable> {
  $$LocalAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
    column: $table.accountType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get institutionName => $composableBuilder(
    column: $table.institutionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get openingBalance => $composableBuilder(
    column: $table.openingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get openingBalanceDate => $composableBuilder(
    column: $table.openingBalanceDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get balanceCache => $composableBuilder(
    column: $table.balanceCache,
    builder: (column) => column,
  );

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalAccountsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAccountsTable,
          LocalAccount,
          $$LocalAccountsTableFilterComposer,
          $$LocalAccountsTableOrderingComposer,
          $$LocalAccountsTableAnnotationComposer,
          $$LocalAccountsTableCreateCompanionBuilder,
          $$LocalAccountsTableUpdateCompanionBuilder,
          (
            LocalAccount,
            BaseReferences<_$AppDatabase, $LocalAccountsTable, LocalAccount>,
          ),
          LocalAccount,
          PrefetchHooks Function()
        > {
  $$LocalAccountsTableTableManager(_$AppDatabase db, $LocalAccountsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> accountType = const Value.absent(),
                Value<String?> institutionName = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<int> openingBalance = const Value.absent(),
                Value<String> openingBalanceDate = const Value.absent(),
                Value<int> balanceCache = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion(
                id: id,
                userId: userId,
                name: name,
                accountType: accountType,
                institutionName: institutionName,
                accountNumber: accountNumber,
                openingBalance: openingBalance,
                openingBalanceDate: openingBalanceDate,
                balanceCache: balanceCache,
                icon: icon,
                color: color,
                isActive: isActive,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String accountType,
                Value<String?> institutionName = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<int> openingBalance = const Value.absent(),
                required String openingBalanceDate,
                Value<int> balanceCache = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                accountType: accountType,
                institutionName: institutionName,
                accountNumber: accountNumber,
                openingBalance: openingBalance,
                openingBalanceDate: openingBalanceDate,
                balanceCache: balanceCache,
                icon: icon,
                color: color,
                isActive: isActive,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAccountsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAccountsTable,
      LocalAccount,
      $$LocalAccountsTableFilterComposer,
      $$LocalAccountsTableOrderingComposer,
      $$LocalAccountsTableAnnotationComposer,
      $$LocalAccountsTableCreateCompanionBuilder,
      $$LocalAccountsTableUpdateCompanionBuilder,
      (
        LocalAccount,
        BaseReferences<_$AppDatabase, $LocalAccountsTable, LocalAccount>,
      ),
      LocalAccount,
      PrefetchHooks Function()
    >;
typedef $$LocalCategoriesTableCreateCompanionBuilder =
    LocalCategoriesCompanion Function({
      required String id,
      required String userId,
      required String name,
      required String type,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> version,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalCategoriesTableUpdateCompanionBuilder =
    LocalCategoriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> type,
      Value<String?> icon,
      Value<String?> color,
      Value<bool> isDefault,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> version,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalCategoriesTable> {
  $$LocalCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalCategoriesTable,
          LocalCategory,
          $$LocalCategoriesTableFilterComposer,
          $$LocalCategoriesTableOrderingComposer,
          $$LocalCategoriesTableAnnotationComposer,
          $$LocalCategoriesTableCreateCompanionBuilder,
          $$LocalCategoriesTableUpdateCompanionBuilder,
          (
            LocalCategory,
            BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
          ),
          LocalCategory,
          PrefetchHooks Function()
        > {
  $$LocalCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion(
                id: id,
                userId: userId,
                name: name,
                type: type,
                icon: icon,
                color: color,
                isDefault: isDefault,
                isActive: isActive,
                sortOrder: sortOrder,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                required String type,
                Value<String?> icon = const Value.absent(),
                Value<String?> color = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> version = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCategoriesCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                type: type,
                icon: icon,
                color: color,
                isDefault: isDefault,
                isActive: isActive,
                sortOrder: sortOrder,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalCategoriesTable,
      LocalCategory,
      $$LocalCategoriesTableFilterComposer,
      $$LocalCategoriesTableOrderingComposer,
      $$LocalCategoriesTableAnnotationComposer,
      $$LocalCategoriesTableCreateCompanionBuilder,
      $$LocalCategoriesTableUpdateCompanionBuilder,
      (
        LocalCategory,
        BaseReferences<_$AppDatabase, $LocalCategoriesTable, LocalCategory>,
      ),
      LocalCategory,
      PrefetchHooks Function()
    >;
typedef $$LocalTransactionsTableCreateCompanionBuilder =
    LocalTransactionsCompanion Function({
      required String id,
      required String userId,
      required String type,
      Value<String?> categoryId,
      Value<String?> categoryType,
      required int amount,
      required int transactionDateMs,
      Value<String?> description,
      Value<String?> notes,
      Value<String> status,
      Value<String?> createdByDeviceId,
      Value<int> version,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalTransactionsTableUpdateCompanionBuilder =
    LocalTransactionsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> type,
      Value<String?> categoryId,
      Value<String?> categoryType,
      Value<int> amount,
      Value<int> transactionDateMs,
      Value<String?> description,
      Value<String?> notes,
      Value<String> status,
      Value<String?> createdByDeviceId,
      Value<int> version,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get transactionDateMs => $composableBuilder(
    column: $table.transactionDateMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get transactionDateMs => $composableBuilder(
    column: $table.transactionDateMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionsTable> {
  $$LocalTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<int> get transactionDateMs => $composableBuilder(
    column: $table.transactionDateMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction,
          $$LocalTransactionsTableFilterComposer,
          $$LocalTransactionsTableOrderingComposer,
          $$LocalTransactionsTableAnnotationComposer,
          $$LocalTransactionsTableCreateCompanionBuilder,
          $$LocalTransactionsTableUpdateCompanionBuilder,
          (
            LocalTransaction,
            BaseReferences<
              _$AppDatabase,
              $LocalTransactionsTable,
              LocalTransaction
            >,
          ),
          LocalTransaction,
          PrefetchHooks Function()
        > {
  $$LocalTransactionsTableTableManager(
    _$AppDatabase db,
    $LocalTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> categoryId = const Value.absent(),
                Value<String?> categoryType = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<int> transactionDateMs = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> createdByDeviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionsCompanion(
                id: id,
                userId: userId,
                type: type,
                categoryId: categoryId,
                categoryType: categoryType,
                amount: amount,
                transactionDateMs: transactionDateMs,
                description: description,
                notes: notes,
                status: status,
                createdByDeviceId: createdByDeviceId,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String type,
                Value<String?> categoryId = const Value.absent(),
                Value<String?> categoryType = const Value.absent(),
                required int amount,
                required int transactionDateMs,
                Value<String?> description = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> createdByDeviceId = const Value.absent(),
                Value<int> version = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionsCompanion.insert(
                id: id,
                userId: userId,
                type: type,
                categoryId: categoryId,
                categoryType: categoryType,
                amount: amount,
                transactionDateMs: transactionDateMs,
                description: description,
                notes: notes,
                status: status,
                createdByDeviceId: createdByDeviceId,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransactionsTable,
      LocalTransaction,
      $$LocalTransactionsTableFilterComposer,
      $$LocalTransactionsTableOrderingComposer,
      $$LocalTransactionsTableAnnotationComposer,
      $$LocalTransactionsTableCreateCompanionBuilder,
      $$LocalTransactionsTableUpdateCompanionBuilder,
      (
        LocalTransaction,
        BaseReferences<
          _$AppDatabase,
          $LocalTransactionsTable,
          LocalTransaction
        >,
      ),
      LocalTransaction,
      PrefetchHooks Function()
    >;
typedef $$LocalAccountMovementsTableCreateCompanionBuilder =
    LocalAccountMovementsCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      Value<String?> transactionId,
      Value<String?> adjustmentId,
      required String postingGroupId,
      required String movementType,
      required int amountSigned,
      Value<String?> reversalOfId,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$LocalAccountMovementsTableUpdateCompanionBuilder =
    LocalAccountMovementsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<String?> transactionId,
      Value<String?> adjustmentId,
      Value<String> postingGroupId,
      Value<String> movementType,
      Value<int> amountSigned,
      Value<String?> reversalOfId,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$LocalAccountMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountMovementsTable> {
  $$LocalAccountMovementsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get adjustmentId => $composableBuilder(
    column: $table.adjustmentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postingGroupId => $composableBuilder(
    column: $table.postingGroupId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountSigned => $composableBuilder(
    column: $table.amountSigned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reversalOfId => $composableBuilder(
    column: $table.reversalOfId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountMovementsTable> {
  $$LocalAccountMovementsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get adjustmentId => $composableBuilder(
    column: $table.adjustmentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postingGroupId => $composableBuilder(
    column: $table.postingGroupId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountSigned => $composableBuilder(
    column: $table.amountSigned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reversalOfId => $composableBuilder(
    column: $table.reversalOfId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountMovementsTable> {
  $$LocalAccountMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get adjustmentId => $composableBuilder(
    column: $table.adjustmentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postingGroupId => $composableBuilder(
    column: $table.postingGroupId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get movementType => $composableBuilder(
    column: $table.movementType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountSigned => $composableBuilder(
    column: $table.amountSigned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reversalOfId => $composableBuilder(
    column: $table.reversalOfId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$LocalAccountMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAccountMovementsTable,
          LocalAccountMovement,
          $$LocalAccountMovementsTableFilterComposer,
          $$LocalAccountMovementsTableOrderingComposer,
          $$LocalAccountMovementsTableAnnotationComposer,
          $$LocalAccountMovementsTableCreateCompanionBuilder,
          $$LocalAccountMovementsTableUpdateCompanionBuilder,
          (
            LocalAccountMovement,
            BaseReferences<
              _$AppDatabase,
              $LocalAccountMovementsTable,
              LocalAccountMovement
            >,
          ),
          LocalAccountMovement,
          PrefetchHooks Function()
        > {
  $$LocalAccountMovementsTableTableManager(
    _$AppDatabase db,
    $LocalAccountMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountMovementsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAccountMovementsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAccountMovementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<String?> transactionId = const Value.absent(),
                Value<String?> adjustmentId = const Value.absent(),
                Value<String> postingGroupId = const Value.absent(),
                Value<String> movementType = const Value.absent(),
                Value<int> amountSigned = const Value.absent(),
                Value<String?> reversalOfId = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountMovementsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                transactionId: transactionId,
                adjustmentId: adjustmentId,
                postingGroupId: postingGroupId,
                movementType: movementType,
                amountSigned: amountSigned,
                reversalOfId: reversalOfId,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                Value<String?> transactionId = const Value.absent(),
                Value<String?> adjustmentId = const Value.absent(),
                required String postingGroupId,
                required String movementType,
                required int amountSigned,
                Value<String?> reversalOfId = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountMovementsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                transactionId: transactionId,
                adjustmentId: adjustmentId,
                postingGroupId: postingGroupId,
                movementType: movementType,
                amountSigned: amountSigned,
                reversalOfId: reversalOfId,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAccountMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAccountMovementsTable,
      LocalAccountMovement,
      $$LocalAccountMovementsTableFilterComposer,
      $$LocalAccountMovementsTableOrderingComposer,
      $$LocalAccountMovementsTableAnnotationComposer,
      $$LocalAccountMovementsTableCreateCompanionBuilder,
      $$LocalAccountMovementsTableUpdateCompanionBuilder,
      (
        LocalAccountMovement,
        BaseReferences<
          _$AppDatabase,
          $LocalAccountMovementsTable,
          LocalAccountMovement
        >,
      ),
      LocalAccountMovement,
      PrefetchHooks Function()
    >;
typedef $$LocalAccountAdjustmentsTableCreateCompanionBuilder =
    LocalAccountAdjustmentsCompanion Function({
      required String id,
      required String userId,
      required String accountId,
      required int amountSigned,
      required String reason,
      Value<String?> createdByDeviceId,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$LocalAccountAdjustmentsTableUpdateCompanionBuilder =
    LocalAccountAdjustmentsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> accountId,
      Value<int> amountSigned,
      Value<String> reason,
      Value<String?> createdByDeviceId,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$LocalAccountAdjustmentsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalAccountAdjustmentsTable> {
  $$LocalAccountAdjustmentsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountSigned => $composableBuilder(
    column: $table.amountSigned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalAccountAdjustmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalAccountAdjustmentsTable> {
  $$LocalAccountAdjustmentsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountId => $composableBuilder(
    column: $table.accountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountSigned => $composableBuilder(
    column: $table.amountSigned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalAccountAdjustmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalAccountAdjustmentsTable> {
  $$LocalAccountAdjustmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get accountId =>
      $composableBuilder(column: $table.accountId, builder: (column) => column);

  GeneratedColumn<int> get amountSigned => $composableBuilder(
    column: $table.amountSigned,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get createdByDeviceId => $composableBuilder(
    column: $table.createdByDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$LocalAccountAdjustmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalAccountAdjustmentsTable,
          LocalAccountAdjustment,
          $$LocalAccountAdjustmentsTableFilterComposer,
          $$LocalAccountAdjustmentsTableOrderingComposer,
          $$LocalAccountAdjustmentsTableAnnotationComposer,
          $$LocalAccountAdjustmentsTableCreateCompanionBuilder,
          $$LocalAccountAdjustmentsTableUpdateCompanionBuilder,
          (
            LocalAccountAdjustment,
            BaseReferences<
              _$AppDatabase,
              $LocalAccountAdjustmentsTable,
              LocalAccountAdjustment
            >,
          ),
          LocalAccountAdjustment,
          PrefetchHooks Function()
        > {
  $$LocalAccountAdjustmentsTableTableManager(
    _$AppDatabase db,
    $LocalAccountAdjustmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalAccountAdjustmentsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalAccountAdjustmentsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalAccountAdjustmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> accountId = const Value.absent(),
                Value<int> amountSigned = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> createdByDeviceId = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountAdjustmentsCompanion(
                id: id,
                userId: userId,
                accountId: accountId,
                amountSigned: amountSigned,
                reason: reason,
                createdByDeviceId: createdByDeviceId,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String accountId,
                required int amountSigned,
                required String reason,
                Value<String?> createdByDeviceId = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LocalAccountAdjustmentsCompanion.insert(
                id: id,
                userId: userId,
                accountId: accountId,
                amountSigned: amountSigned,
                reason: reason,
                createdByDeviceId: createdByDeviceId,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalAccountAdjustmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalAccountAdjustmentsTable,
      LocalAccountAdjustment,
      $$LocalAccountAdjustmentsTableFilterComposer,
      $$LocalAccountAdjustmentsTableOrderingComposer,
      $$LocalAccountAdjustmentsTableAnnotationComposer,
      $$LocalAccountAdjustmentsTableCreateCompanionBuilder,
      $$LocalAccountAdjustmentsTableUpdateCompanionBuilder,
      (
        LocalAccountAdjustment,
        BaseReferences<
          _$AppDatabase,
          $LocalAccountAdjustmentsTable,
          LocalAccountAdjustment
        >,
      ),
      LocalAccountAdjustment,
      PrefetchHooks Function()
    >;
typedef $$LocalTransactionRevisionsTableCreateCompanionBuilder =
    LocalTransactionRevisionsCompanion Function({
      required String id,
      required String transactionId,
      required String userId,
      required int revisionNumber,
      required String action,
      Value<String?> beforeDataJson,
      Value<String?> afterDataJson,
      Value<String?> reason,
      Value<String?> deviceId,
      required int createdAtMs,
      Value<int> rowid,
    });
typedef $$LocalTransactionRevisionsTableUpdateCompanionBuilder =
    LocalTransactionRevisionsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> userId,
      Value<int> revisionNumber,
      Value<String> action,
      Value<String?> beforeDataJson,
      Value<String?> afterDataJson,
      Value<String?> reason,
      Value<String?> deviceId,
      Value<int> createdAtMs,
      Value<int> rowid,
    });

class $$LocalTransactionRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalTransactionRevisionsTable> {
  $$LocalTransactionRevisionsTableFilterComposer({
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

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get beforeDataJson => $composableBuilder(
    column: $table.beforeDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get afterDataJson => $composableBuilder(
    column: $table.afterDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTransactionRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalTransactionRevisionsTable> {
  $$LocalTransactionRevisionsTableOrderingComposer({
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

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get beforeDataJson => $composableBuilder(
    column: $table.beforeDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get afterDataJson => $composableBuilder(
    column: $table.afterDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTransactionRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalTransactionRevisionsTable> {
  $$LocalTransactionRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<int> get revisionNumber => $composableBuilder(
    column: $table.revisionNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get beforeDataJson => $composableBuilder(
    column: $table.beforeDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get afterDataJson => $composableBuilder(
    column: $table.afterDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );
}

class $$LocalTransactionRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalTransactionRevisionsTable,
          LocalTransactionRevision,
          $$LocalTransactionRevisionsTableFilterComposer,
          $$LocalTransactionRevisionsTableOrderingComposer,
          $$LocalTransactionRevisionsTableAnnotationComposer,
          $$LocalTransactionRevisionsTableCreateCompanionBuilder,
          $$LocalTransactionRevisionsTableUpdateCompanionBuilder,
          (
            LocalTransactionRevision,
            BaseReferences<
              _$AppDatabase,
              $LocalTransactionRevisionsTable,
              LocalTransactionRevision
            >,
          ),
          LocalTransactionRevision,
          PrefetchHooks Function()
        > {
  $$LocalTransactionRevisionsTableTableManager(
    _$AppDatabase db,
    $LocalTransactionRevisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTransactionRevisionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalTransactionRevisionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalTransactionRevisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<int> revisionNumber = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String?> beforeDataJson = const Value.absent(),
                Value<String?> afterDataJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionRevisionsCompanion(
                id: id,
                transactionId: transactionId,
                userId: userId,
                revisionNumber: revisionNumber,
                action: action,
                beforeDataJson: beforeDataJson,
                afterDataJson: afterDataJson,
                reason: reason,
                deviceId: deviceId,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String userId,
                required int revisionNumber,
                required String action,
                Value<String?> beforeDataJson = const Value.absent(),
                Value<String?> afterDataJson = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> deviceId = const Value.absent(),
                required int createdAtMs,
                Value<int> rowid = const Value.absent(),
              }) => LocalTransactionRevisionsCompanion.insert(
                id: id,
                transactionId: transactionId,
                userId: userId,
                revisionNumber: revisionNumber,
                action: action,
                beforeDataJson: beforeDataJson,
                afterDataJson: afterDataJson,
                reason: reason,
                deviceId: deviceId,
                createdAtMs: createdAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTransactionRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalTransactionRevisionsTable,
      LocalTransactionRevision,
      $$LocalTransactionRevisionsTableFilterComposer,
      $$LocalTransactionRevisionsTableOrderingComposer,
      $$LocalTransactionRevisionsTableAnnotationComposer,
      $$LocalTransactionRevisionsTableCreateCompanionBuilder,
      $$LocalTransactionRevisionsTableUpdateCompanionBuilder,
      (
        LocalTransactionRevision,
        BaseReferences<
          _$AppDatabase,
          $LocalTransactionRevisionsTable,
          LocalTransactionRevision
        >,
      ),
      LocalTransactionRevision,
      PrefetchHooks Function()
    >;
typedef $$LocalReceiptsTableCreateCompanionBuilder =
    LocalReceiptsCompanion Function({
      required String id,
      required String transactionId,
      required String userId,
      required String filePath,
      Value<String?> localFilePath,
      Value<String?> fileName,
      required String mimeType,
      required int fileSize,
      Value<String?> checksum,
      Value<String?> ocrText,
      Value<String?> extractedDataJson,
      Value<bool> isUploaded,
      Value<int> version,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalReceiptsTableUpdateCompanionBuilder =
    LocalReceiptsCompanion Function({
      Value<String> id,
      Value<String> transactionId,
      Value<String> userId,
      Value<String> filePath,
      Value<String?> localFilePath,
      Value<String?> fileName,
      Value<String> mimeType,
      Value<int> fileSize,
      Value<String?> checksum,
      Value<String?> ocrText,
      Value<String?> extractedDataJson,
      Value<bool> isUploaded,
      Value<int> version,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalReceiptsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalReceiptsTable> {
  $$LocalReceiptsTableFilterComposer({
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

  ColumnFilters<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedDataJson => $composableBuilder(
    column: $table.extractedDataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUploaded => $composableBuilder(
    column: $table.isUploaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalReceiptsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalReceiptsTable> {
  $$LocalReceiptsTableOrderingComposer({
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

  ColumnOrderings<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ocrText => $composableBuilder(
    column: $table.ocrText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedDataJson => $composableBuilder(
    column: $table.extractedDataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUploaded => $composableBuilder(
    column: $table.isUploaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalReceiptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalReceiptsTable> {
  $$LocalReceiptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get transactionId => $composableBuilder(
    column: $table.transactionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get localFilePath => $composableBuilder(
    column: $table.localFilePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get ocrText =>
      $composableBuilder(column: $table.ocrText, builder: (column) => column);

  GeneratedColumn<String> get extractedDataJson => $composableBuilder(
    column: $table.extractedDataJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUploaded => $composableBuilder(
    column: $table.isUploaded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalReceiptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalReceiptsTable,
          LocalReceipt,
          $$LocalReceiptsTableFilterComposer,
          $$LocalReceiptsTableOrderingComposer,
          $$LocalReceiptsTableAnnotationComposer,
          $$LocalReceiptsTableCreateCompanionBuilder,
          $$LocalReceiptsTableUpdateCompanionBuilder,
          (
            LocalReceipt,
            BaseReferences<_$AppDatabase, $LocalReceiptsTable, LocalReceipt>,
          ),
          LocalReceipt,
          PrefetchHooks Function()
        > {
  $$LocalReceiptsTableTableManager(_$AppDatabase db, $LocalReceiptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalReceiptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalReceiptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalReceiptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> transactionId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<String?> checksum = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<String?> extractedDataJson = const Value.absent(),
                Value<bool> isUploaded = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalReceiptsCompanion(
                id: id,
                transactionId: transactionId,
                userId: userId,
                filePath: filePath,
                localFilePath: localFilePath,
                fileName: fileName,
                mimeType: mimeType,
                fileSize: fileSize,
                checksum: checksum,
                ocrText: ocrText,
                extractedDataJson: extractedDataJson,
                isUploaded: isUploaded,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String transactionId,
                required String userId,
                required String filePath,
                Value<String?> localFilePath = const Value.absent(),
                Value<String?> fileName = const Value.absent(),
                required String mimeType,
                required int fileSize,
                Value<String?> checksum = const Value.absent(),
                Value<String?> ocrText = const Value.absent(),
                Value<String?> extractedDataJson = const Value.absent(),
                Value<bool> isUploaded = const Value.absent(),
                Value<int> version = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalReceiptsCompanion.insert(
                id: id,
                transactionId: transactionId,
                userId: userId,
                filePath: filePath,
                localFilePath: localFilePath,
                fileName: fileName,
                mimeType: mimeType,
                fileSize: fileSize,
                checksum: checksum,
                ocrText: ocrText,
                extractedDataJson: extractedDataJson,
                isUploaded: isUploaded,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalReceiptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalReceiptsTable,
      LocalReceipt,
      $$LocalReceiptsTableFilterComposer,
      $$LocalReceiptsTableOrderingComposer,
      $$LocalReceiptsTableAnnotationComposer,
      $$LocalReceiptsTableCreateCompanionBuilder,
      $$LocalReceiptsTableUpdateCompanionBuilder,
      (
        LocalReceipt,
        BaseReferences<_$AppDatabase, $LocalReceiptsTable, LocalReceipt>,
      ),
      LocalReceipt,
      PrefetchHooks Function()
    >;
typedef $$LocalBudgetsTableCreateCompanionBuilder =
    LocalBudgetsCompanion Function({
      required String id,
      required String userId,
      required String name,
      Value<String> periodType,
      required String startDate,
      required String endDate,
      Value<int?> totalLimit,
      Value<int> warningPercent,
      Value<bool> isActive,
      Value<int> version,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalBudgetsTableUpdateCompanionBuilder =
    LocalBudgetsCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> name,
      Value<String> periodType,
      Value<String> startDate,
      Value<String> endDate,
      Value<int?> totalLimit,
      Value<int> warningPercent,
      Value<bool> isActive,
      Value<int> version,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalBudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warningPercent => $composableBuilder(
    column: $table.warningPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endDate => $composableBuilder(
    column: $table.endDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warningPercent => $composableBuilder(
    column: $table.warningPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBudgetsTable> {
  $$LocalBudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get periodType => $composableBuilder(
    column: $table.periodType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get totalLimit => $composableBuilder(
    column: $table.totalLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warningPercent => $composableBuilder(
    column: $table.warningPercent,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalBudgetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBudgetsTable,
          LocalBudget,
          $$LocalBudgetsTableFilterComposer,
          $$LocalBudgetsTableOrderingComposer,
          $$LocalBudgetsTableAnnotationComposer,
          $$LocalBudgetsTableCreateCompanionBuilder,
          $$LocalBudgetsTableUpdateCompanionBuilder,
          (
            LocalBudget,
            BaseReferences<_$AppDatabase, $LocalBudgetsTable, LocalBudget>,
          ),
          LocalBudget,
          PrefetchHooks Function()
        > {
  $$LocalBudgetsTableTableManager(_$AppDatabase db, $LocalBudgetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalBudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalBudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> periodType = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> endDate = const Value.absent(),
                Value<int?> totalLimit = const Value.absent(),
                Value<int> warningPercent = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetsCompanion(
                id: id,
                userId: userId,
                name: name,
                periodType: periodType,
                startDate: startDate,
                endDate: endDate,
                totalLimit: totalLimit,
                warningPercent: warningPercent,
                isActive: isActive,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String name,
                Value<String> periodType = const Value.absent(),
                required String startDate,
                required String endDate,
                Value<int?> totalLimit = const Value.absent(),
                Value<int> warningPercent = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> version = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetsCompanion.insert(
                id: id,
                userId: userId,
                name: name,
                periodType: periodType,
                startDate: startDate,
                endDate: endDate,
                totalLimit: totalLimit,
                warningPercent: warningPercent,
                isActive: isActive,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBudgetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBudgetsTable,
      LocalBudget,
      $$LocalBudgetsTableFilterComposer,
      $$LocalBudgetsTableOrderingComposer,
      $$LocalBudgetsTableAnnotationComposer,
      $$LocalBudgetsTableCreateCompanionBuilder,
      $$LocalBudgetsTableUpdateCompanionBuilder,
      (
        LocalBudget,
        BaseReferences<_$AppDatabase, $LocalBudgetsTable, LocalBudget>,
      ),
      LocalBudget,
      PrefetchHooks Function()
    >;
typedef $$LocalBudgetCategoriesTableCreateCompanionBuilder =
    LocalBudgetCategoriesCompanion Function({
      required String id,
      required String userId,
      required String budgetId,
      required String categoryId,
      Value<String> categoryType,
      required int amountLimit,
      Value<int> version,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });
typedef $$LocalBudgetCategoriesTableUpdateCompanionBuilder =
    LocalBudgetCategoriesCompanion Function({
      Value<String> id,
      Value<String> userId,
      Value<String> budgetId,
      Value<String> categoryId,
      Value<String> categoryType,
      Value<int> amountLimit,
      Value<int> version,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int?> deletedAtMs,
      Value<int> rowid,
    });

class $$LocalBudgetCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $LocalBudgetCategoriesTable> {
  $$LocalBudgetCategoriesTableFilterComposer({
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

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get amountLimit => $composableBuilder(
    column: $table.amountLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalBudgetCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalBudgetCategoriesTable> {
  $$LocalBudgetCategoriesTableOrderingComposer({
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

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get budgetId => $composableBuilder(
    column: $table.budgetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get amountLimit => $composableBuilder(
    column: $table.amountLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalBudgetCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalBudgetCategoriesTable> {
  $$LocalBudgetCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get budgetId =>
      $composableBuilder(column: $table.budgetId, builder: (column) => column);

  GeneratedColumn<String> get categoryId => $composableBuilder(
    column: $table.categoryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoryType => $composableBuilder(
    column: $table.categoryType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get amountLimit => $composableBuilder(
    column: $table.amountLimit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get deletedAtMs => $composableBuilder(
    column: $table.deletedAtMs,
    builder: (column) => column,
  );
}

class $$LocalBudgetCategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalBudgetCategoriesTable,
          LocalBudgetCategory,
          $$LocalBudgetCategoriesTableFilterComposer,
          $$LocalBudgetCategoriesTableOrderingComposer,
          $$LocalBudgetCategoriesTableAnnotationComposer,
          $$LocalBudgetCategoriesTableCreateCompanionBuilder,
          $$LocalBudgetCategoriesTableUpdateCompanionBuilder,
          (
            LocalBudgetCategory,
            BaseReferences<
              _$AppDatabase,
              $LocalBudgetCategoriesTable,
              LocalBudgetCategory
            >,
          ),
          LocalBudgetCategory,
          PrefetchHooks Function()
        > {
  $$LocalBudgetCategoriesTableTableManager(
    _$AppDatabase db,
    $LocalBudgetCategoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalBudgetCategoriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$LocalBudgetCategoriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$LocalBudgetCategoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> budgetId = const Value.absent(),
                Value<String> categoryId = const Value.absent(),
                Value<String> categoryType = const Value.absent(),
                Value<int> amountLimit = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetCategoriesCompanion(
                id: id,
                userId: userId,
                budgetId: budgetId,
                categoryId: categoryId,
                categoryType: categoryType,
                amountLimit: amountLimit,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String userId,
                required String budgetId,
                required String categoryId,
                Value<String> categoryType = const Value.absent(),
                required int amountLimit,
                Value<int> version = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int?> deletedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalBudgetCategoriesCompanion.insert(
                id: id,
                userId: userId,
                budgetId: budgetId,
                categoryId: categoryId,
                categoryType: categoryType,
                amountLimit: amountLimit,
                version: version,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                deletedAtMs: deletedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalBudgetCategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalBudgetCategoriesTable,
      LocalBudgetCategory,
      $$LocalBudgetCategoriesTableFilterComposer,
      $$LocalBudgetCategoriesTableOrderingComposer,
      $$LocalBudgetCategoriesTableAnnotationComposer,
      $$LocalBudgetCategoriesTableCreateCompanionBuilder,
      $$LocalBudgetCategoriesTableUpdateCompanionBuilder,
      (
        LocalBudgetCategory,
        BaseReferences<
          _$AppDatabase,
          $LocalBudgetCategoriesTable,
          LocalBudgetCategory
        >,
      ),
      LocalBudgetCategory,
      PrefetchHooks Function()
    >;
typedef $$SyncOutboxTableCreateCompanionBuilder =
    SyncOutboxCompanion Function({
      required String id,
      required String operationId,
      required String userId,
      required String deviceId,
      required String entityType,
      required String entityId,
      required String operationType,
      Value<int> baseVersion,
      required String payloadJson,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      required int createdAtMs,
      required int updatedAtMs,
      Value<int> rowid,
    });
typedef $$SyncOutboxTableUpdateCompanionBuilder =
    SyncOutboxCompanion Function({
      Value<String> id,
      Value<String> operationId,
      Value<String> userId,
      Value<String> deviceId,
      Value<String> entityType,
      Value<String> entityId,
      Value<String> operationType,
      Value<int> baseVersion,
      Value<String> payloadJson,
      Value<String> status,
      Value<int> retryCount,
      Value<String?> lastError,
      Value<int> createdAtMs,
      Value<int> updatedAtMs,
      Value<int> rowid,
    });

class $$SyncOutboxTableFilterComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableFilterComposer({
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

  ColumnFilters<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
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

  ColumnFilters<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncOutboxTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableOrderingComposer({
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

  ColumnOrderings<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
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

  ColumnOrderings<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncOutboxTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncOutboxTable> {
  $$SyncOutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get operationId => $composableBuilder(
    column: $table.operationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operationType => $composableBuilder(
    column: $table.operationType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get baseVersion => $composableBuilder(
    column: $table.baseVersion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<int> get createdAtMs => $composableBuilder(
    column: $table.createdAtMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAtMs => $composableBuilder(
    column: $table.updatedAtMs,
    builder: (column) => column,
  );
}

class $$SyncOutboxTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncOutboxTable,
          SyncOutboxData,
          $$SyncOutboxTableFilterComposer,
          $$SyncOutboxTableOrderingComposer,
          $$SyncOutboxTableAnnotationComposer,
          $$SyncOutboxTableCreateCompanionBuilder,
          $$SyncOutboxTableUpdateCompanionBuilder,
          (
            SyncOutboxData,
            BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
          ),
          SyncOutboxData,
          PrefetchHooks Function()
        > {
  $$SyncOutboxTableTableManager(_$AppDatabase db, $SyncOutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncOutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncOutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncOutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> operationId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operationType = const Value.absent(),
                Value<int> baseVersion = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> createdAtMs = const Value.absent(),
                Value<int> updatedAtMs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion(
                id: id,
                operationId: operationId,
                userId: userId,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                baseVersion: baseVersion,
                payloadJson: payloadJson,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String operationId,
                required String userId,
                required String deviceId,
                required String entityType,
                required String entityId,
                required String operationType,
                Value<int> baseVersion = const Value.absent(),
                required String payloadJson,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                required int createdAtMs,
                required int updatedAtMs,
                Value<int> rowid = const Value.absent(),
              }) => SyncOutboxCompanion.insert(
                id: id,
                operationId: operationId,
                userId: userId,
                deviceId: deviceId,
                entityType: entityType,
                entityId: entityId,
                operationType: operationType,
                baseVersion: baseVersion,
                payloadJson: payloadJson,
                status: status,
                retryCount: retryCount,
                lastError: lastError,
                createdAtMs: createdAtMs,
                updatedAtMs: updatedAtMs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncOutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncOutboxTable,
      SyncOutboxData,
      $$SyncOutboxTableFilterComposer,
      $$SyncOutboxTableOrderingComposer,
      $$SyncOutboxTableAnnotationComposer,
      $$SyncOutboxTableCreateCompanionBuilder,
      $$SyncOutboxTableUpdateCompanionBuilder,
      (
        SyncOutboxData,
        BaseReferences<_$AppDatabase, $SyncOutboxTable, SyncOutboxData>,
      ),
      SyncOutboxData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSyncStateTableTableManager get localSyncState =>
      $$LocalSyncStateTableTableManager(_db, _db.localSyncState);
  $$LocalUsersTableTableManager get localUsers =>
      $$LocalUsersTableTableManager(_db, _db.localUsers);
  $$LocalUserSettingsTableTableManager get localUserSettings =>
      $$LocalUserSettingsTableTableManager(_db, _db.localUserSettings);
  $$LocalDevicesTableTableManager get localDevices =>
      $$LocalDevicesTableTableManager(_db, _db.localDevices);
  $$LocalAccountsTableTableManager get localAccounts =>
      $$LocalAccountsTableTableManager(_db, _db.localAccounts);
  $$LocalCategoriesTableTableManager get localCategories =>
      $$LocalCategoriesTableTableManager(_db, _db.localCategories);
  $$LocalTransactionsTableTableManager get localTransactions =>
      $$LocalTransactionsTableTableManager(_db, _db.localTransactions);
  $$LocalAccountMovementsTableTableManager get localAccountMovements =>
      $$LocalAccountMovementsTableTableManager(_db, _db.localAccountMovements);
  $$LocalAccountAdjustmentsTableTableManager get localAccountAdjustments =>
      $$LocalAccountAdjustmentsTableTableManager(
        _db,
        _db.localAccountAdjustments,
      );
  $$LocalTransactionRevisionsTableTableManager get localTransactionRevisions =>
      $$LocalTransactionRevisionsTableTableManager(
        _db,
        _db.localTransactionRevisions,
      );
  $$LocalReceiptsTableTableManager get localReceipts =>
      $$LocalReceiptsTableTableManager(_db, _db.localReceipts);
  $$LocalBudgetsTableTableManager get localBudgets =>
      $$LocalBudgetsTableTableManager(_db, _db.localBudgets);
  $$LocalBudgetCategoriesTableTableManager get localBudgetCategories =>
      $$LocalBudgetCategoriesTableTableManager(_db, _db.localBudgetCategories);
  $$SyncOutboxTableTableManager get syncOutbox =>
      $$SyncOutboxTableTableManager(_db, _db.syncOutbox);
}
