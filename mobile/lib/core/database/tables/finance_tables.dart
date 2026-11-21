import 'package:drift/drift.dart';

class LocalUsers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  IntColumn get emailVerifiedAtMs => integer().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalUserSettings extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().unique()();
  TextColumn get themeMode => text().withDefault(const Constant('system'))();
  TextColumn get currency => text().withDefault(const Constant('IDR'))();
  TextColumn get timezone => text().withDefault(const Constant('Asia/Jakarta'))();
  IntColumn get budgetWarningPercent => integer().withDefault(const Constant(80))();
  BoolColumn get notificationsEnabled => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalDevices extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get deviceName => text()();
  TextColumn get platform => text().withDefault(const Constant('android'))();
  TextColumn get appVersion => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get lastSyncAtMs => integer().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAccounts extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get accountType => text()();
  TextColumn get institutionName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  IntColumn get openingBalance => integer().withDefault(const Constant(0))();
  TextColumn get openingBalanceDate => text()();
  IntColumn get balanceCache => integer().withDefault(const Constant(0))();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalCategories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTransactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get type => text()();
  TextColumn get categoryId => text().nullable()();
  TextColumn get categoryType => text().nullable()();
  IntColumn get amount => integer()();
  IntColumn get transactionDateMs => integer()();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('posted'))();
  TextColumn get createdByDeviceId => text().nullable()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAccountMovements extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get accountId => text()();
  TextColumn get transactionId => text().nullable()();
  TextColumn get adjustmentId => text().nullable()();
  TextColumn get postingGroupId => text()();
  TextColumn get movementType => text()();
  IntColumn get amountSigned => integer()();
  TextColumn get reversalOfId => text().nullable().unique()();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalAccountAdjustments extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get accountId => text()();
  IntColumn get amountSigned => integer()();
  TextColumn get reason => text()();
  TextColumn get createdByDeviceId => text().nullable()();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTransactionRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get userId => text()();
  IntColumn get revisionNumber => integer()();
  TextColumn get action => text()();
  TextColumn get beforeDataJson => text().nullable()();
  TextColumn get afterDataJson => text().nullable()();
  TextColumn get reason => text().nullable()();
  TextColumn get deviceId => text().nullable()();
  IntColumn get createdAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalReceipts extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text()();
  TextColumn get userId => text()();
  TextColumn get filePath => text()();
  TextColumn get localFilePath => text().nullable()();
  TextColumn get fileName => text().nullable()();
  TextColumn get mimeType => text()();
  IntColumn get fileSize => integer()();
  TextColumn get checksum => text().nullable()();
  TextColumn get ocrText => text().nullable()();
  TextColumn get extractedDataJson => text().nullable()();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalBudgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get periodType => text().withDefault(const Constant('monthly'))();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  IntColumn get totalLimit => integer().nullable()();
  IntColumn get warningPercent => integer().withDefault(const Constant(80))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalBudgetCategories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get budgetId => text()();
  TextColumn get categoryId => text()();
  TextColumn get categoryType => text().withDefault(const Constant('expense'))();
  IntColumn get amountLimit => integer()();
  IntColumn get version => integer().withDefault(const Constant(1))();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();
  IntColumn get deletedAtMs => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class SyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get operationId => text().unique()();
  TextColumn get userId => text()();
  TextColumn get deviceId => text()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operationType => text()();
  IntColumn get baseVersion => integer().withDefault(const Constant(0))();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

