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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocalSyncStateTable localSyncState = $LocalSyncStateTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [localSyncState];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocalSyncStateTableTableManager get localSyncState =>
      $$LocalSyncStateTableTableManager(_db, _db.localSyncState);
}
