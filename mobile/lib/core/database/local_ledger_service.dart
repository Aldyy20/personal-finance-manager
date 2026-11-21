import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../errors/app_exception.dart';
import 'app_database.dart';

class LocalLedgerService {
  LocalLedgerService({
    required this.db,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final Uuid _uuid;

  // =========================================================================
  // ACCOUNTS & ADJUSTMENTS
  // =========================================================================

  Future<LocalAccount> createAccount({
    required String userId,
    required String deviceId,
    required String name,
    required String accountType,
    String? institutionName,
    String? accountNumber,
    int openingBalance = 0,
    String? openingBalanceDate,
    String? icon,
    String? color,
  }) async {
    const validTypes = ['cash', 'bank', 'e_wallet', 'other'];
    if (!validTypes.contains(accountType)) {
      throw const ValidationException(message: 'Tipe rekening tidak valid.');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException(message: 'Nama rekening wajib diisi.');
    }

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final dateStr = openingBalanceDate ?? DateTime.now().toUtc().toIso8601String().substring(0, 10);
    final accountId = _uuid.v4();

    return db.transaction(() async {
      await db.into(db.localAccounts).insert(
            LocalAccountsCompanion.insert(
              id: accountId,
              userId: userId,
              name: trimmedName,
              accountType: accountType,
              institutionName: Value(institutionName),
              accountNumber: Value(accountNumber),
              openingBalance: Value(openingBalance),
              openingBalanceDate: dateStr,
              balanceCache: Value(openingBalance),
              icon: Value(icon),
              color: Value(color),
              isActive: const Value(true),
              version: const Value(1),
              createdAtMs: nowMs,
              updatedAtMs: nowMs,
            ),
          );

      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: accountId,
              postingGroupId: _uuid.v4(),
              movementType: 'opening',
              amountSigned: openingBalance,
              createdAtMs: nowMs,
            ),
          );

      await reconcileAccountBalance(accountId);

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'accounts',
        entityId: accountId,
        operationType: 'create',
        baseVersion: 0,
        payload: {
          'name': trimmedName,
          'account_type': accountType,
          'institution_name': institutionName,
          'account_number': accountNumber,
          'opening_balance': openingBalance,
          'opening_balance_date': dateStr,
          'icon': icon,
          'color': color,
        },
        nowMs: nowMs,
      );

      return (db.select(db.localAccounts)..where((t) => t.id.equals(accountId))).getSingle();
    });
  }

  Future<LocalAccount> updateAccount({
    required String userId,
    required String deviceId,
    required String accountId,
    String? name,
    String? accountType,
    String? institutionName,
    String? accountNumber,
    int? openingBalance,
    String? icon,
    String? color,
  }) async {
    return db.transaction(() async {
      final account = await _requireOwnedAccount(userId, accountId);

      if (openingBalance != null && openingBalance != account.openingBalance) {
        throw const ValidationException(
          message: 'Saldo awal tidak dapat diubah langsung. Gunakan koreksi saldo (adjustment).',
        );
      }

      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final newName = name != null ? name.trim() : account.name;
      if (newName.isEmpty) {
        throw const ValidationException(message: 'Nama rekening tidak boleh kosong.');
      }

      final newType = accountType ?? account.accountType;
      final newVersion = account.version + 1;

      await (db.update(db.localAccounts)..where((t) => t.id.equals(accountId))).write(
        LocalAccountsCompanion(
          name: Value(newName),
          accountType: Value(newType),
          institutionName: Value(institutionName ?? account.institutionName),
          accountNumber: Value(accountNumber ?? account.accountNumber),
          icon: Value(icon ?? account.icon),
          color: Value(color ?? account.color),
          version: Value(newVersion),
          updatedAtMs: Value(nowMs),
        ),
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'accounts',
        entityId: accountId,
        operationType: 'update',
        baseVersion: account.version,
        payload: {
          'name': newName,
          'account_type': newType,
          'institution_name': institutionName ?? account.institutionName,
          'account_number': accountNumber ?? account.accountNumber,
          'icon': icon ?? account.icon,
          'color': color ?? account.color,
        },
        nowMs: nowMs,
      );

      return (db.select(db.localAccounts)..where((t) => t.id.equals(accountId))).getSingle();
    });
  }

  Future<LocalAccount> setAccountActiveState({
    required String userId,
    required String deviceId,
    required String accountId,
    required bool isActive,
  }) async {
    return db.transaction(() async {
      final account = await _requireOwnedAccount(userId, accountId);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final newVersion = account.version + 1;

      await (db.update(db.localAccounts)..where((t) => t.id.equals(accountId))).write(
        LocalAccountsCompanion(
          isActive: Value(isActive),
          version: Value(newVersion),
          updatedAtMs: Value(nowMs),
        ),
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'accounts',
        entityId: accountId,
        operationType: isActive ? 'restore' : 'archive',
        baseVersion: account.version,
        payload: const {},
        nowMs: nowMs,
      );

      return (db.select(db.localAccounts)..where((t) => t.id.equals(accountId))).getSingle();
    });
  }

  Future<LocalAccountAdjustment> createAdjustment({
    required String userId,
    required String deviceId,
    required String accountId,
    required int amountSigned,
    required String reason,
  }) async {
    if (amountSigned == 0) {
      throw const ValidationException(message: 'Nominal adjustment tidak boleh nol.');
    }
    final trimmedReason = reason.trim();
    if (trimmedReason.isEmpty) {
      throw const ValidationException(message: 'Alasan adjustment wajib diisi.');
    }

    return db.transaction(() async {
      final account = await _requireOwnedAccount(userId, accountId);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final adjustmentId = _uuid.v4();

      await db.into(db.localAccountAdjustments).insert(
            LocalAccountAdjustmentsCompanion.insert(
              id: adjustmentId,
              userId: userId,
              accountId: accountId,
              amountSigned: amountSigned,
              reason: trimmedReason,
              createdByDeviceId: Value(deviceId),
              createdAtMs: nowMs,
            ),
          );

      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: accountId,
              adjustmentId: Value(adjustmentId),
              postingGroupId: _uuid.v4(),
              movementType: 'adjustment',
              amountSigned: amountSigned,
              createdAtMs: nowMs,
            ),
          );

      await reconcileAccountBalance(accountId);

      await (db.update(db.localAccounts)..where((t) => t.id.equals(accountId))).write(
        LocalAccountsCompanion(
          version: Value(account.version + 1),
          updatedAtMs: Value(nowMs),
        ),
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'account_adjustments',
        entityId: adjustmentId,
        operationType: 'create',
        baseVersion: 0,
        payload: {
          'account_id': accountId,
          'amount_signed': amountSigned,
          'reason': trimmedReason,
        },
        nowMs: nowMs,
      );

      return (db.select(db.localAccountAdjustments)..where((t) => t.id.equals(adjustmentId))).getSingle();
    });
  }

  Future<int> calculateAccountBalance(String accountId) async {
    final row = await db.customSelect(
      'SELECT COALESCE(SUM(amount_signed), 0) AS total FROM local_account_movements WHERE account_id = ?',
      variables: [Variable.withString(accountId)],
      readsFrom: {db.localAccountMovements},
    ).getSingle();
    return row.read<int>('total');
  }

  Future<int> reconcileAccountBalance(String accountId) async {
    final balance = await calculateAccountBalance(accountId);
    await (db.update(db.localAccounts)..where((t) => t.id.equals(accountId))).write(
      LocalAccountsCompanion(balanceCache: Value(balance)),
    );
    return balance;
  }

  // =========================================================================
  // CATEGORIES
  // =========================================================================

  Future<LocalCategory> createCategory({
    required String userId,
    required String deviceId,
    required String name,
    required String type,
    String? icon,
    String? color,
    int sortOrder = 0,
  }) async {
    if (type != 'income' && type != 'expense') {
      throw const ValidationException(message: 'Tipe kategori harus income atau expense.');
    }
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException(message: 'Nama kategori wajib diisi.');
    }

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final categoryId = _uuid.v4();

    return db.transaction(() async {
      await db.into(db.localCategories).insert(
            LocalCategoriesCompanion.insert(
              id: categoryId,
              userId: userId,
              name: trimmedName,
              type: type,
              icon: Value(icon),
              color: Value(color),
              isDefault: const Value(false),
              isActive: const Value(true),
              sortOrder: Value(sortOrder),
              version: const Value(1),
              createdAtMs: nowMs,
              updatedAtMs: nowMs,
            ),
          );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'categories',
        entityId: categoryId,
        operationType: 'create',
        baseVersion: 0,
        payload: {
          'name': trimmedName,
          'type': type,
          'icon': icon,
          'color': color,
          'sort_order': sortOrder,
        },
        nowMs: nowMs,
      );

      return (db.select(db.localCategories)..where((t) => t.id.equals(categoryId))).getSingle();
    });
  }

  Future<LocalCategory> updateCategory({
    required String userId,
    required String deviceId,
    required String categoryId,
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
  }) async {
    return db.transaction(() async {
      final category = await _requireOwnedCategory(userId, categoryId);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final newName = name != null ? name.trim() : category.name;
      if (newName.isEmpty) {
        throw const ValidationException(message: 'Nama kategori tidak boleh kosong.');
      }
      final newVersion = category.version + 1;

      await (db.update(db.localCategories)..where((t) => t.id.equals(categoryId))).write(
        LocalCategoriesCompanion(
          name: Value(newName),
          icon: Value(icon ?? category.icon),
          color: Value(color ?? category.color),
          sortOrder: Value(sortOrder ?? category.sortOrder),
          version: Value(newVersion),
          updatedAtMs: Value(nowMs),
        ),
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'categories',
        entityId: categoryId,
        operationType: 'update',
        baseVersion: category.version,
        payload: {
          'name': newName,
          'icon': icon ?? category.icon,
          'color': color ?? category.color,
          'sort_order': sortOrder ?? category.sortOrder,
        },
        nowMs: nowMs,
      );

      return (db.select(db.localCategories)..where((t) => t.id.equals(categoryId))).getSingle();
    });
  }

  Future<LocalCategory> setCategoryActiveState({
    required String userId,
    required String deviceId,
    required String categoryId,
    required bool isActive,
  }) async {
    return db.transaction(() async {
      final category = await _requireOwnedCategory(userId, categoryId);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

      await (db.update(db.localCategories)..where((t) => t.id.equals(categoryId))).write(
        LocalCategoriesCompanion(
          isActive: Value(isActive),
          version: Value(category.version + 1),
          updatedAtMs: Value(nowMs),
        ),
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'categories',
        entityId: categoryId,
        operationType: isActive ? 'restore' : 'archive',
        baseVersion: category.version,
        payload: const {},
        nowMs: nowMs,
      );

      return (db.select(db.localCategories)..where((t) => t.id.equals(categoryId))).getSingle();
    });
  }

  // =========================================================================
  // TRANSACTIONS & TRANSFERS
  // =========================================================================

  Future<LocalTransaction> createIncomeOrExpense({
    required String userId,
    required String deviceId,
    required String type,
    required String accountId,
    required String categoryId,
    required int amount,
    required DateTime transactionDate,
    String? description,
    String? notes,
  }) async {
    if (type != 'income' && type != 'expense') {
      throw const ValidationException(message: 'Tipe transaksi harus income atau expense.');
    }
    if (amount <= 0) {
      throw const ValidationException(message: 'Nominal transaksi harus lebih dari nol.');
    }

    return db.transaction(() async {
      final account = await _requireOwnedAccount(userId, accountId);
      if (!account.isActive) {
        throw const ValidationException(message: 'Rekening terarsip tidak dapat digunakan.');
      }

      final category = await _requireOwnedCategory(userId, categoryId);
      if (!category.isActive) {
        throw const ValidationException(message: 'Kategori nonaktif tidak dapat digunakan.');
      }
      if (category.type != type) {
        throw ValidationException(message: 'Kategori harus bertipe $type.');
      }

      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final txDateUtc = transactionDate.toUtc();
      final txId = _uuid.v4();
      final postingGroupId = _uuid.v4();

      await db.into(db.localTransactions).insert(
            LocalTransactionsCompanion.insert(
              id: txId,
              userId: userId,
              type: type,
              categoryId: Value(category.id),
              categoryType: Value(category.type),
              amount: amount,
              transactionDateMs: txDateUtc.millisecondsSinceEpoch,
              description: Value(description),
              notes: Value(notes),
              status: const Value('posted'),
              createdByDeviceId: Value(deviceId),
              version: const Value(1),
              createdAtMs: nowMs,
              updatedAtMs: nowMs,
            ),
          );

      final signedAmount = type == 'income' ? amount : -amount;
      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: accountId,
              transactionId: Value(txId),
              postingGroupId: postingGroupId,
              movementType: 'transaction',
              amountSigned: signedAmount,
              createdAtMs: nowMs,
            ),
          );

      await reconcileAccountBalance(accountId);
      await _bumpAccountVersion(account, nowMs);

      final txRow = await (db.select(db.localTransactions)..where((t) => t.id.equals(txId))).getSingle();
      await _appendRevision(
        transaction: txRow,
        action: 'create',
        beforeData: null,
        deviceId: deviceId,
        reason: null,
        nowMs: nowMs,
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'transactions',
        entityId: txId,
        operationType: 'create',
        baseVersion: 0,
        payload: {
          'type': type,
          'account_id': accountId,
          'category_id': categoryId,
          'amount': amount,
          'transaction_date': txDateUtc.toIso8601String(),
          'description': description,
          'notes': notes,
        },
        nowMs: nowMs,
      );

      return txRow;
    });
  }

  Future<LocalTransaction> createTransfer({
    required String userId,
    required String deviceId,
    required String sourceAccountId,
    required String destinationAccountId,
    required int amount,
    required DateTime transactionDate,
    String? description,
    String? notes,
  }) async {
    if (amount <= 0) {
      throw const ValidationException(message: 'Nominal transfer harus lebih dari nol.');
    }
    if (sourceAccountId == destinationAccountId) {
      throw const ValidationException(message: 'Rekening asal dan tujuan harus berbeda.');
    }

    return db.transaction(() async {
      final sourceAccount = await _requireOwnedAccount(userId, sourceAccountId);
      final destAccount = await _requireOwnedAccount(userId, destinationAccountId);
      if (!sourceAccount.isActive || !destAccount.isActive) {
        throw const ValidationException(message: 'Kedua rekening transfer harus aktif.');
      }

      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final txDateUtc = transactionDate.toUtc();
      final txId = _uuid.v4();
      final postingGroupId = _uuid.v4();

      await db.into(db.localTransactions).insert(
            LocalTransactionsCompanion.insert(
              id: txId,
              userId: userId,
              type: 'transfer',
              categoryId: const Value(null),
              categoryType: const Value(null),
              amount: amount,
              transactionDateMs: txDateUtc.millisecondsSinceEpoch,
              description: Value(description),
              notes: Value(notes),
              status: const Value('posted'),
              createdByDeviceId: Value(deviceId),
              version: const Value(1),
              createdAtMs: nowMs,
              updatedAtMs: nowMs,
            ),
          );

      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: sourceAccountId,
              transactionId: Value(txId),
              postingGroupId: postingGroupId,
              movementType: 'transaction',
              amountSigned: -amount,
              createdAtMs: nowMs,
            ),
          );

      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: destinationAccountId,
              transactionId: Value(txId),
              postingGroupId: postingGroupId,
              movementType: 'transaction',
              amountSigned: amount,
              createdAtMs: nowMs,
            ),
          );

      await reconcileAccountBalance(sourceAccountId);
      await reconcileAccountBalance(destinationAccountId);
      await _bumpAccountVersion(sourceAccount, nowMs);
      await _bumpAccountVersion(destAccount, nowMs);

      final txRow = await (db.select(db.localTransactions)..where((t) => t.id.equals(txId))).getSingle();
      await _appendRevision(
        transaction: txRow,
        action: 'create',
        beforeData: null,
        deviceId: deviceId,
        reason: null,
        nowMs: nowMs,
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'transfers',
        entityId: txId,
        operationType: 'create',
        baseVersion: 0,
        payload: {
          'source_account_id': sourceAccountId,
          'destination_account_id': destinationAccountId,
          'amount': amount,
          'transaction_date': txDateUtc.toIso8601String(),
          'description': description,
          'notes': notes,
        },
        nowMs: nowMs,
      );

      return txRow;
    });
  }

  Future<LocalTransaction> updateIncomeOrExpense({
    required String userId,
    required String deviceId,
    required String transactionId,
    String? type,
    String? accountId,
    String? categoryId,
    int? amount,
    DateTime? transactionDate,
    String? description,
    String? notes,
    String? reason,
  }) async {
    return db.transaction(() async {
      final tx = await _requireOwnedTransaction(userId, transactionId);
      if (tx.type != 'income' && tx.type != 'expense') {
        throw const ValidationException(message: 'Gunakan updateTransfer untuk mengubah transfer.');
      }
      if (tx.status != 'posted') {
        throw const ConflictException(message: 'Transaksi yang sudah di-void tidak dapat diedit.');
      }

      final activeMovements = await getActiveMovementsForTransaction(tx.id);
      if (activeMovements.isEmpty) {
        throw const ConflictException(message: 'Mutasi aktif transaksi tidak ditemukan.');
      }

      final oldAccountId = activeMovements.first.accountId;
      final newAccountId = accountId ?? oldAccountId;
      final newType = type ?? tx.type;
      final newAmount = amount ?? tx.amount;
      final newCategoryId = categoryId ?? tx.categoryId!;
      if (newAmount <= 0) {
        throw const ValidationException(message: 'Nominal harus lebih dari nol.');
      }

      final newAccount = await _requireOwnedAccount(userId, newAccountId);
      if (!newAccount.isActive) {
        throw const ValidationException(message: 'Rekening tujuan tidak aktif.');
      }
      final category = await _requireOwnedCategory(userId, newCategoryId);
      if (newCategoryId != tx.categoryId && !category.isActive) {
        throw const ValidationException(message: 'Kategori baru tidak aktif.');
      }
      if (category.type != newType) {
        throw ValidationException(message: 'Kategori harus bertipe $newType.');
      }

      final beforeSnapshot = await _buildSnapshot(tx);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final postingGroupId = _uuid.v4();

      // Reverse all active movements
      await _reverseMovements(activeMovements, tx, postingGroupId, nowMs);

      final newTxDateMs = transactionDate?.toUtc().millisecondsSinceEpoch ?? tx.transactionDateMs;
      final newVersion = tx.version + 1;

      await (db.update(db.localTransactions)..where((t) => t.id.equals(tx.id))).write(
        LocalTransactionsCompanion(
          type: Value(newType),
          categoryId: Value(category.id),
          categoryType: Value(category.type),
          amount: Value(newAmount),
          transactionDateMs: Value(newTxDateMs),
          description: Value(description ?? tx.description),
          notes: Value(notes ?? tx.notes),
          version: Value(newVersion),
          updatedAtMs: Value(nowMs),
        ),
      );

      final signedAmount = newType == 'income' ? newAmount : -newAmount;
      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: newAccountId,
              transactionId: Value(tx.id),
              postingGroupId: postingGroupId,
              movementType: 'transaction',
              amountSigned: signedAmount,
              createdAtMs: nowMs,
            ),
          );

      for (final accId in {oldAccountId, newAccountId}) {
        await reconcileAccountBalance(accId);
      }

      final updatedTx = await (db.select(db.localTransactions)..where((t) => t.id.equals(tx.id))).getSingle();
      await _appendRevision(
        transaction: updatedTx,
        action: 'edit',
        beforeData: beforeSnapshot,
        deviceId: deviceId,
        reason: reason,
        nowMs: nowMs,
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'transactions',
        entityId: tx.id,
        operationType: 'update',
        baseVersion: tx.version,
        payload: {
          'type': newType,
          'account_id': newAccountId,
          'category_id': category.id,
          'amount': newAmount,
          'transaction_date': DateTime.fromMillisecondsSinceEpoch(newTxDateMs, isUtc: true).toIso8601String(),
          'description': updatedTx.description,
          'notes': updatedTx.notes,
          'reason': reason,
        },
        nowMs: nowMs,
      );

      return updatedTx;
    });
  }

  Future<LocalTransaction> updateTransfer({
    required String userId,
    required String deviceId,
    required String transactionId,
    String? sourceAccountId,
    String? destinationAccountId,
    int? amount,
    DateTime? transactionDate,
    String? description,
    String? notes,
    String? reason,
  }) async {
    return db.transaction(() async {
      final tx = await _requireOwnedTransaction(userId, transactionId);
      if (tx.type != 'transfer') {
        throw const ValidationException(message: 'Transaksi bukan bertipe transfer.');
      }
      if (tx.status != 'posted') {
        throw const ConflictException(message: 'Transfer yang sudah di-void tidak dapat diedit.');
      }

      final activeMovements = await getActiveMovementsForTransaction(tx.id);
      final oldDebit = activeMovements.where((m) => m.amountSigned < 0).firstOrNull;
      final oldCredit = activeMovements.where((m) => m.amountSigned > 0).firstOrNull;
      if (oldDebit == null || oldCredit == null) {
        throw const ConflictException(message: 'Mutasi transfer tidak seimbang.');
      }

      final newSourceId = sourceAccountId ?? oldDebit.accountId;
      final newDestId = destinationAccountId ?? oldCredit.accountId;
      final newAmount = amount ?? tx.amount;

      if (newAmount <= 0) {
        throw const ValidationException(message: 'Nominal transfer harus lebih dari nol.');
      }
      if (newSourceId == newDestId) {
        throw const ValidationException(message: 'Rekening asal dan tujuan harus berbeda.');
      }

      final newSource = await _requireOwnedAccount(userId, newSourceId);
      final newDest = await _requireOwnedAccount(userId, newDestId);
      if (!newSource.isActive || !newDest.isActive) {
        throw const ValidationException(message: 'Kedua rekening transfer harus aktif.');
      }

      final beforeSnapshot = await _buildSnapshot(tx);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final postingGroupId = _uuid.v4();

      await _reverseMovements(activeMovements, tx, postingGroupId, nowMs);

      final newTxDateMs = transactionDate?.toUtc().millisecondsSinceEpoch ?? tx.transactionDateMs;
      final newVersion = tx.version + 1;

      await (db.update(db.localTransactions)..where((t) => t.id.equals(tx.id))).write(
        LocalTransactionsCompanion(
          amount: Value(newAmount),
          transactionDateMs: Value(newTxDateMs),
          description: Value(description ?? tx.description),
          notes: Value(notes ?? tx.notes),
          version: Value(newVersion),
          updatedAtMs: Value(nowMs),
        ),
      );

      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: newSourceId,
              transactionId: Value(tx.id),
              postingGroupId: postingGroupId,
              movementType: 'transaction',
              amountSigned: -newAmount,
              createdAtMs: nowMs,
            ),
          );

      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: userId,
              accountId: newDestId,
              transactionId: Value(tx.id),
              postingGroupId: postingGroupId,
              movementType: 'transaction',
              amountSigned: newAmount,
              createdAtMs: nowMs,
            ),
          );

      for (final accId in {oldDebit.accountId, oldCredit.accountId, newSourceId, newDestId}) {
        await reconcileAccountBalance(accId);
      }

      final updatedTx = await (db.select(db.localTransactions)..where((t) => t.id.equals(tx.id))).getSingle();
      await _appendRevision(
        transaction: updatedTx,
        action: 'edit',
        beforeData: beforeSnapshot,
        deviceId: deviceId,
        reason: reason,
        nowMs: nowMs,
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'transfers',
        entityId: tx.id,
        operationType: 'update',
        baseVersion: tx.version,
        payload: {
          'source_account_id': newSourceId,
          'destination_account_id': newDestId,
          'amount': newAmount,
          'transaction_date': DateTime.fromMillisecondsSinceEpoch(newTxDateMs, isUtc: true).toIso8601String(),
          'description': updatedTx.description,
          'notes': updatedTx.notes,
          'reason': reason,
        },
        nowMs: nowMs,
      );

      return updatedTx;
    });
  }

  Future<LocalTransaction> voidTransaction({
    required String userId,
    required String deviceId,
    required String transactionId,
    String? reason,
  }) async {
    return db.transaction(() async {
      final tx = await _requireOwnedTransaction(userId, transactionId);
      if (tx.status == 'voided') {
        throw const ConflictException(message: 'Transaksi sudah dibatalkan (voided).');
      }

      final activeMovements = await getActiveMovementsForTransaction(tx.id);
      if (activeMovements.isEmpty) {
        throw const ConflictException(message: 'Tidak ada mutasi aktif untuk di-void.');
      }

      final beforeSnapshot = await _buildSnapshot(tx);
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final postingGroupId = _uuid.v4();

      await _reverseMovements(activeMovements, tx, postingGroupId, nowMs);

      await (db.update(db.localTransactions)..where((t) => t.id.equals(tx.id))).write(
        LocalTransactionsCompanion(
          status: const Value('voided'),
          version: Value(tx.version + 1),
          updatedAtMs: Value(nowMs),
        ),
      );

      for (final accId in activeMovements.map((m) => m.accountId).toSet()) {
        await reconcileAccountBalance(accId);
      }

      final voidedTx = await (db.select(db.localTransactions)..where((t) => t.id.equals(tx.id))).getSingle();
      await _appendRevision(
        transaction: voidedTx,
        action: 'void',
        beforeData: beforeSnapshot,
        deviceId: deviceId,
        reason: reason,
        nowMs: nowMs,
      );

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: tx.type == 'transfer' ? 'transfers' : 'transactions',
        entityId: tx.id,
        operationType: 'void',
        baseVersion: tx.version,
        payload: {'reason': reason},
        nowMs: nowMs,
      );

      return voidedTx;
    });
  }

  Future<List<LocalAccountMovement>> getActiveMovementsForTransaction(String transactionId) async {
    final all = await (db.select(db.localAccountMovements)
          ..where((t) => t.transactionId.equals(transactionId)))
        .get();

    final reversedIds = all.map((m) => m.reversalOfId).whereType<String>().toSet();
    return all
        .where((m) => m.movementType == 'transaction' && !reversedIds.contains(m.id))
        .toList();
  }

  // =========================================================================
  // BUDGETS & LOCAL REPORTS
  // =========================================================================

  Future<LocalBudget> createBudget({
    required String userId,
    required String deviceId,
    required String name,
    required String startDate,
    required String endDate,
    int? totalLimit,
    int warningPercent = 80,
    List<({String categoryId, int amountLimit})> categories = const [],
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const ValidationException(message: 'Nama anggaran wajib diisi.');
    }
    if (endDate.compareTo(startDate) < 0) {
      throw const ValidationException(message: 'Tanggal selesai harus >= tanggal mulai.');
    }
    if (warningPercent < 1 || warningPercent > 100) {
      throw const ValidationException(message: 'Batas peringatan harus antara 1 dan 100%.');
    }

    return db.transaction(() async {
      final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
      final budgetId = _uuid.v4();

      await db.into(db.localBudgets).insert(
            LocalBudgetsCompanion.insert(
              id: budgetId,
              userId: userId,
              name: trimmedName,
              periodType: const Value('monthly'),
              startDate: startDate,
              endDate: endDate,
              totalLimit: Value(totalLimit),
              warningPercent: Value(warningPercent),
              isActive: const Value(true),
              version: const Value(1),
              createdAtMs: nowMs,
              updatedAtMs: nowMs,
            ),
          );

      final outboxCategories = <Map<String, dynamic>>[];

      for (final item in categories) {
        if (item.amountLimit <= 0) {
          throw const ValidationException(message: 'Batas anggaran kategori harus > 0.');
        }
        final cat = await _requireOwnedCategory(userId, item.categoryId);
        if (cat.type != 'expense') {
          throw const ValidationException(
            message: 'Anggaran hanya dapat menerima kategori pengeluaran (expense).',
          );
        }

        final bcId = _uuid.v4();
        await db.into(db.localBudgetCategories).insert(
              LocalBudgetCategoriesCompanion.insert(
                id: bcId,
                userId: userId,
                budgetId: budgetId,
                categoryId: cat.id,
                categoryType: const Value('expense'),
                amountLimit: item.amountLimit,
                version: const Value(1),
                createdAtMs: nowMs,
                updatedAtMs: nowMs,
              ),
            );

        outboxCategories.add({
          'id': bcId,
          'category_id': cat.id,
          'amount_limit': item.amountLimit,
        });
      }

      await _enqueueOutbox(
        userId: userId,
        deviceId: deviceId,
        entityType: 'budgets',
        entityId: budgetId,
        operationType: 'create',
        baseVersion: 0,
        payload: {
          'name': trimmedName,
          'period_type': 'monthly',
          'start_date': startDate,
          'end_date': endDate,
          'total_limit': totalLimit,
          'warning_percent': warningPercent,
          'categories': outboxCategories,
        },
        nowMs: nowMs,
      );

      return (db.select(db.localBudgets)..where((t) => t.id.equals(budgetId))).getSingle();
    });
  }

  Future<Map<String, dynamic>> getLocalBudgetSummary(String userId, String budgetId) async {
    final budget = await (db.select(db.localBudgets)
          ..where((t) => t.id.equals(budgetId) & t.userId.equals(userId)))
        .getSingleOrNull();
    if (budget == null) {
      throw const DatabaseException(message: 'Anggaran tidak ditemukan.');
    }

    final startMs = DateTime.parse('${budget.startDate}T00:00:00.000Z').millisecondsSinceEpoch;
    final endMs = DateTime.parse('${budget.endDate}T23:59:59.999Z').millisecondsSinceEpoch;

    final expenses = await (db.select(db.localTransactions)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.type.equals('expense') &
                t.status.equals('posted') &
                t.transactionDateMs.isBetweenValues(startMs, endMs),
          ))
        .get();

    final spentByCat = <String, int>{};
    var totalExpense = 0;
    for (final tx in expenses) {
      totalExpense += tx.amount;
      if (tx.categoryId != null) {
        spentByCat[tx.categoryId!] = (spentByCat[tx.categoryId!] ?? 0) + tx.amount;
      }
    }

    final allocations = await (db.select(db.localBudgetCategories)
          ..where((t) => t.budgetId.equals(budget.id) & t.deletedAtMs.isNull()))
        .get();

    var allocatedUsed = 0;
    var allocatedLimit = 0;
    final categoryItems = <Map<String, dynamic>>[];

    for (final bc in allocations) {
      final used = spentByCat[bc.categoryId] ?? 0;
      allocatedUsed += used;
      allocatedLimit += bc.amountLimit;
      final pct = bc.amountLimit > 0 ? (used / bc.amountLimit) * 100.0 : 0.0;
      categoryItems.add({
        'category_id': bc.categoryId,
        'amount_limit': bc.amountLimit,
        'used': used,
        'remaining': bc.amountLimit - used,
        'percentage': double.parse(pct.toStringAsFixed(2)),
        'status': pct >= 100 ? 'exceeded' : (pct >= budget.warningPercent ? 'warning' : 'normal'),
      });
    }

    final effectiveLimit = budget.totalLimit ?? allocatedLimit;
    final effectiveUsed = budget.totalLimit != null ? totalExpense : allocatedUsed;
    final totalPct = effectiveLimit > 0 ? (effectiveUsed / effectiveLimit) * 100.0 : 0.0;

    return {
      'budget': budget,
      'total_limit': effectiveLimit,
      'total_used': effectiveUsed,
      'total_remaining': effectiveLimit - effectiveUsed,
      'percentage': double.parse(totalPct.toStringAsFixed(2)),
      'status': totalPct >= 100 ? 'exceeded' : (totalPct >= budget.warningPercent ? 'warning' : 'normal'),
      'categories': categoryItems,
    };
  }

  Future<Map<String, dynamic>> getLocalOverview(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final activeAccounts = await (db.select(db.localAccounts)
          ..where((t) => t.userId.equals(userId) & t.isActive.equals(true) & t.deletedAtMs.isNull()))
        .get();

    final totalBalance = activeAccounts.fold<int>(0, (sum, a) => sum + a.balanceCache);

    final now = DateTime.now().toUtc();
    final startMs = (startDate ?? DateTime.utc(now.year, now.month, 1)).millisecondsSinceEpoch;
    final endMs = (endDate ?? DateTime.utc(now.year, now.month + 1, 0, 23, 59, 59, 999))
        .millisecondsSinceEpoch;

    final postedTx = await (db.select(db.localTransactions)
          ..where(
            (t) =>
                t.userId.equals(userId) &
                t.status.equals('posted') &
                t.type.isIn(['income', 'expense']) &
                t.transactionDateMs.isBetweenValues(startMs, endMs),
          ))
        .get();

    var totalIncome = 0;
    var totalExpense = 0;
    for (final tx in postedTx) {
      if (tx.type == 'income') {
        totalIncome += tx.amount;
      } else if (tx.type == 'expense') {
        totalExpense += tx.amount;
      }
    }

    return {
      'total_balance': totalBalance,
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_cash_flow': totalIncome - totalExpense,
      'active_accounts_count': activeAccounts.length,
    };
  }

  // =========================================================================
  // PRIVATE HELPERS
  // =========================================================================

  Future<LocalAccount> _requireOwnedAccount(String userId, String accountId) async {
    final account = await (db.select(db.localAccounts)
          ..where((t) => t.id.equals(accountId) & t.userId.equals(userId)))
        .getSingleOrNull();
    if (account == null) {
      throw const ForbiddenException(message: 'Rekening tidak ditemukan atau bukan milik pengguna.');
    }
    return account;
  }

  Future<LocalCategory> _requireOwnedCategory(String userId, String categoryId) async {
    final category = await (db.select(db.localCategories)
          ..where((t) => t.id.equals(categoryId) & t.userId.equals(userId)))
        .getSingleOrNull();
    if (category == null) {
      throw const ForbiddenException(message: 'Kategori tidak ditemukan atau bukan milik pengguna.');
    }
    return category;
  }

  Future<LocalTransaction> _requireOwnedTransaction(String userId, String txId) async {
    final tx = await (db.select(db.localTransactions)
          ..where((t) => t.id.equals(txId) & t.userId.equals(userId)))
        .getSingleOrNull();
    if (tx == null) {
      throw const ForbiddenException(message: 'Transaksi tidak ditemukan atau bukan milik pengguna.');
    }
    return tx;
  }

  Future<void> _bumpAccountVersion(LocalAccount account, int nowMs) async {
    await (db.update(db.localAccounts)..where((t) => t.id.equals(account.id))).write(
      LocalAccountsCompanion(
        version: Value(account.version + 1),
        updatedAtMs: Value(nowMs),
      ),
    );
  }

  Future<void> _reverseMovements(
    List<LocalAccountMovement> activeMovements,
    LocalTransaction tx,
    String postingGroupId,
    int nowMs,
  ) async {
    for (final movement in activeMovements) {
      await db.into(db.localAccountMovements).insert(
            LocalAccountMovementsCompanion.insert(
              id: _uuid.v4(),
              userId: tx.userId,
              accountId: movement.accountId,
              transactionId: Value(tx.id),
              postingGroupId: postingGroupId,
              movementType: 'reversal',
              amountSigned: -movement.amountSigned,
              reversalOfId: Value(movement.id),
              createdAtMs: nowMs,
            ),
          );
    }
  }

  Future<Map<String, dynamic>> _buildSnapshot(LocalTransaction tx) async {
    final activeMovements = await getActiveMovementsForTransaction(tx.id);
    return {
      'id': tx.id,
      'type': tx.type,
      'category_id': tx.categoryId,
      'category_type': tx.categoryType,
      'amount': tx.amount,
      'transaction_date_ms': tx.transactionDateMs,
      'description': tx.description,
      'notes': tx.notes,
      'status': tx.status,
      'version': tx.version,
      'active_movements': activeMovements
          .map((m) => {'id': m.id, 'account_id': m.accountId, 'amount_signed': m.amountSigned})
          .toList(),
    };
  }

  Future<void> _appendRevision({
    required LocalTransaction transaction,
    required String action,
    required Map<String, dynamic>? beforeData,
    required String deviceId,
    required String? reason,
    required int nowMs,
  }) async {
    final existing = await (db.select(db.localTransactionRevisions)
          ..where((t) => t.transactionId.equals(transaction.id)))
        .get();
    final nextRev = existing.isEmpty
        ? 1
        : existing.map((e) => e.revisionNumber).reduce((a, b) => a > b ? a : b) + 1;

    final afterData = await _buildSnapshot(transaction);

    await db.into(db.localTransactionRevisions).insert(
          LocalTransactionRevisionsCompanion.insert(
            id: _uuid.v4(),
            transactionId: transaction.id,
            userId: transaction.userId,
            revisionNumber: nextRev,
            action: action,
            beforeDataJson: Value(beforeData != null ? jsonEncode(beforeData) : null),
            afterDataJson: Value(jsonEncode(afterData)),
            reason: Value(reason),
            deviceId: Value(deviceId),
            createdAtMs: nowMs,
          ),
        );
  }

  Future<void> _enqueueOutbox({
    required String userId,
    required String deviceId,
    required String entityType,
    required String entityId,
    required String operationType,
    required int baseVersion,
    required Map<String, dynamic> payload,
    required int nowMs,
  }) async {
    await db.into(db.syncOutbox).insert(
          SyncOutboxCompanion.insert(
            id: _uuid.v4(),
            operationId: _uuid.v4(),
            userId: userId,
            deviceId: deviceId,
            entityType: entityType,
            entityId: entityId,
            operationType: operationType,
            baseVersion: Value(baseVersion),
            payloadJson: jsonEncode(payload),
            status: const Value('pending'),
            retryCount: const Value(0),
            createdAtMs: nowMs,
            updatedAtMs: nowMs,
          ),
        );
  }
}

