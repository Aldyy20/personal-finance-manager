import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/config/env_config.dart';
import 'package:personal_finance_manager/core/database/app_database.dart';
import 'package:personal_finance_manager/core/database/local_ledger_service.dart';
import 'package:personal_finance_manager/core/errors/app_exception.dart';
import 'package:personal_finance_manager/core/network/api_client.dart';
import 'package:personal_finance_manager/core/security/secure_storage_service.dart';
import 'package:personal_finance_manager/core/sync/sync_manager.dart';
import 'package:personal_finance_manager/core/sync/sync_status.dart';
import 'package:personal_finance_manager/features/accounts/data/account_repository.dart';
import 'package:personal_finance_manager/features/authentication/data/auth_repository.dart';
import 'package:personal_finance_manager/features/budgets/data/budget_repository.dart';
import 'package:personal_finance_manager/features/categories/data/category_repository.dart';
import 'package:personal_finance_manager/features/reports/data/report_repository.dart';
import 'package:personal_finance_manager/features/transactions/data/transaction_repository.dart';
import 'package:uuid/uuid.dart';

class _InMemorySecureStorage extends SecureStorageService {
  final Map<String, String> _store = {};

  @override
  Future<void> saveAccessToken(String token) async =>
      _store['access_token'] = token;

  @override
  Future<String?> getAccessToken() async => _store['access_token'];

  @override
  Future<void> saveSessionMetadata({
    required String userId,
    required String deviceId,
    required String email,
  }) async {
    _store['user_id'] = userId;
    _store['device_id'] = deviceId;
    _store['last_authenticated_email'] = email;
  }

  @override
  Future<String?> getUserId() async => _store['user_id'];

  @override
  Future<String?> getDeviceId() async => _store['device_id'];

  @override
  Future<String?> getLastEmail() async => _store['last_authenticated_email'];

  @override
  Future<void> clearSession() async {
    _store.remove('access_token');
    _store.remove('user_id');
  }
}

Future<({String userId, String deviceId, String incomeCatId, String expenseCatId})>
    _seedOfflineUser(AppDatabase db) async {
  const uuid = Uuid();
  final userId = uuid.v4();
  final deviceId = uuid.v4();
  final incomeCatId = uuid.v4();
  final expenseCatId = uuid.v4();
  final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

  await db.into(db.localUsers).insert(
        LocalUsersCompanion.insert(
          id: userId,
          name: 'Offline Tester',
          email: 'offline@example.com',
          createdAtMs: nowMs,
          updatedAtMs: nowMs,
        ),
      );

  await db.into(db.localCategories).insert(
        LocalCategoriesCompanion.insert(
          id: incomeCatId,
          userId: userId,
          name: 'Gaji',
          type: 'income',
          isDefault: const Value(true),
          createdAtMs: nowMs,
          updatedAtMs: nowMs,
        ),
      );

  await db.into(db.localCategories).insert(
        LocalCategoriesCompanion.insert(
          id: expenseCatId,
          userId: userId,
          name: 'Makanan',
          type: 'expense',
          isDefault: const Value(true),
          createdAtMs: nowMs,
          updatedAtMs: nowMs,
        ),
      );

  return (
    userId: userId,
    deviceId: deviceId,
    incomeCatId: incomeCatId,
    expenseCatId: expenseCatId,
  );
}

void main() {
  group('Phase 5 Offline Persistence & Ledger Engine', () {
    test('Offline account creation, opening balance, adjustment, and outbox atomicity', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final ledger = LocalLedgerService(db: db);
      final accountRepo = AccountRepository(db: db, ledgerService: ledger);
      final ctx = await _seedOfflineUser(db);

      final bca = await accountRepo.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'BCA',
        accountType: 'bank',
        openingBalance: 2000000,
      );

      expect(bca.balanceCache, 2000000);
      expect(await ledger.calculateAccountBalance(bca.id), 2000000);

      // Direct opening_balance edit must fail
      expect(
        () => accountRepo.updateAccount(
          userId: ctx.userId,
          deviceId: ctx.deviceId,
          accountId: bca.id,
          openingBalance: 9999999,
        ),
        throwsA(isA<ValidationException>()),
      );

      // Manual adjustment updates ledger and outbox
      await accountRepo.createAdjustment(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        accountId: bca.id,
        amountSigned: -150000,
        reason: 'Koreksi saldo awal',
      );

      final updated = (await accountRepo.getAccounts(ctx.userId)).first;
      expect(updated.balanceCache, 1850000);
      expect(await ledger.calculateAccountBalance(bca.id), 1850000);

      final outbox = await db.select(db.syncOutbox).get();
      expect(outbox.length, 2);
      expect(outbox.map((o) => o.entityType).toList(), ['accounts', 'account_adjustments']);
      expect(outbox.every((o) => o.status == 'pending'), isTrue);
    });

    test('Offline income, expense (negative balance), transfer, edit reversal, and void', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final ledger = LocalLedgerService(db: db);
      final accountRepo = AccountRepository(db: db, ledgerService: ledger);
      final txRepo = TransactionRepository(db: db, ledgerService: ledger);
      final ctx = await _seedOfflineUser(db);

      final cash = await accountRepo.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'Cash',
        accountType: 'cash',
        openingBalance: 0,
      );
      final bca = await accountRepo.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'BCA',
        accountType: 'bank',
        openingBalance: 1000000,
      );

      final now = DateTime.now().toUtc();

      // Income +500k into Cash
      final inc = await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'income',
        accountId: cash.id,
        categoryId: ctx.incomeCatId,
        amount: 500000,
        transactionDate: now,
        description: 'Bonus',
      );
      expect(await ledger.calculateAccountBalance(cash.id), 500000);

      // Expense -700k from Cash -> negative balance -200k allowed
      final exp = await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: ctx.expenseCatId,
        amount: 700000,
        transactionDate: now,
        description: 'Makan besar',
      );
      expect(await ledger.calculateAccountBalance(cash.id), -200000);

      // Edit expense 700k -> 300k via reversal + replacement
      final editedExp = await txRepo.updateIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        transactionId: exp.id,
        amount: 300000,
        reason: 'Koreksi bon',
      );
      expect(editedExp.version, 2);
      expect(await ledger.calculateAccountBalance(cash.id), 200000);

      final revisions = await txRepo.getRevisions(exp.id);
      expect(revisions.length, 2);
      expect(revisions[1].action, 'edit');
      final beforeData = jsonDecode(revisions[1].beforeDataJson!) as Map<String, dynamic>;
      expect(beforeData['amount'], 700000);

      // Transfer 400k from BCA to Cash
      final trf = await txRepo.createTransfer(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        sourceAccountId: bca.id,
        destinationAccountId: cash.id,
        amount: 400000,
        transactionDate: now,
        description: 'Tarik tunai',
      );
      expect(await ledger.calculateAccountBalance(bca.id), 600000);
      expect(await ledger.calculateAccountBalance(cash.id), 600000);

      // Void transfer -> restores both accounts
      await txRepo.voidTransaction(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        transactionId: trf.id,
        reason: 'Batal',
      );
      expect(await ledger.calculateAccountBalance(bca.id), 1000000);
      expect(await ledger.calculateAccountBalance(cash.id), 200000);

      // Void income -> Cash becomes -300k
      await txRepo.voidTransaction(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        transactionId: inc.id,
      );
      expect(await ledger.calculateAccountBalance(cash.id), -300000);
    });

    test('Offline budgets and local overview report exclude transfers and voided transactions', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      final ledger = LocalLedgerService(db: db);
      final accountRepo = AccountRepository(db: db, ledgerService: ledger);
      final txRepo = TransactionRepository(db: db, ledgerService: ledger);
      final budgetRepo = BudgetRepository(db: db, ledgerService: ledger);
      final reportRepo = ReportRepository(ledgerService: ledger);
      final ctx = await _seedOfflineUser(db);

      final cash = await accountRepo.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'Cash',
        accountType: 'cash',
        openingBalance: 1000000,
      );
      final bca = await accountRepo.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'BCA',
        accountType: 'bank',
        openingBalance: 2000000,
      );

      final now = DateTime.now().toUtc();
      final monthStart = DateTime.utc(now.year, now.month, 1);
      final monthEnd = DateTime.utc(now.year, now.month + 1, 0);
      final startStr = monthStart.toIso8601String().substring(0, 10);
      final endStr = monthEnd.toIso8601String().substring(0, 10);

      // Reject income category in budget
      expect(
        () => budgetRepo.createBudget(
          userId: ctx.userId,
          deviceId: ctx.deviceId,
          name: 'Invalid',
          startDate: startStr,
          endDate: endStr,
          categories: [(categoryId: ctx.incomeCatId, amountLimit: 500000)],
        ),
        throwsA(isA<ValidationException>()),
      );

      final budget = await budgetRepo.createBudget(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'Budget Bulanan',
        startDate: startStr,
        endDate: endStr,
        totalLimit: 1000000,
        warningPercent: 80,
        categories: [(categoryId: ctx.expenseCatId, amountLimit: 500000)],
      );

      await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'income',
        accountId: bca.id,
        categoryId: ctx.incomeCatId,
        amount: 3000000,
        transactionDate: now,
      );
      await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: ctx.expenseCatId,
        amount: 450000,
        transactionDate: now,
      );
      final voidedExp = await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: ctx.expenseCatId,
        amount: 999000,
        transactionDate: now,
      );
      await txRepo.voidTransaction(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        transactionId: voidedExp.id,
      );
      await txRepo.createTransfer(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        sourceAccountId: bca.id,
        destinationAccountId: cash.id,
        amount: 500000,
        transactionDate: now,
      );

      final summary = await budgetRepo.getBudgetSummary(ctx.userId, budget.id);
      expect(summary['total_used'], 450000);
      expect((summary['categories'] as List).first['status'], 'warning');

      final overview = await reportRepo.getOverview(ctx.userId);
      // Total balance: Cash (1M - 450k + 500k = 1.050M) + BCA (2M + 3M - 500k = 4.5M) = 5.550M
      expect(overview['total_balance'], 5550000);
      expect(overview['total_income'], 3000000);
      expect(overview['total_expense'], 450000);
      expect(overview['net_cash_flow'], 2550000);
    });

    test('End-to-End Live Sync: Register, Pull defaults, Offline edits, Push & Pull verify', () async {
      const runLiveTest = bool.fromEnvironment('RUN_LIVE_API_TEST', defaultValue: false);
      if (!runLiveTest) {
        return;
      }

      HttpOverrides.global = null;

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      final storage = _InMemorySecureStorage();
      final apiClient = ApiClient(
        envConfig: const EnvConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
        ),
        secureStorage: storage,
      );
      final ledger = LocalLedgerService(db: db);
      final syncManager = SyncManager(db: db, apiClient: apiClient, ledgerService: ledger);
      final authRepo = AuthRepository(
        db: db,
        apiClient: apiClient,
        secureStorage: storage,
        syncManager: syncManager,
      );
      final accountRepo = AccountRepository(db: db, ledgerService: ledger);
      final categoryRepo = CategoryRepository(db: db, ledgerService: ledger);
      final txRepo = TransactionRepository(db: db, ledgerService: ledger);

      final uniqueEmail = 'flutter_sync_${DateTime.now().millisecondsSinceEpoch}@example.com';
      final session = await authRepo.register(
        name: 'Flutter Sync User',
        email: uniqueEmail,
        password: 'SyncPassword123!',
        passwordConfirmation: 'SyncPassword123!',
        deviceName: 'Physical Android Test',
      );

      // Verify initial server bootstrap data was pulled into local Drift SQLite
      final localAccounts = await accountRepo.getAccounts(session.userId);
      final localCategories = await categoryRepo.getCategories(session.userId);
      expect(localAccounts.length, 1);
      expect(localAccounts.first.name, 'Cash');
      expect(localCategories.length, 17);

      final cash = localAccounts.first;
      final salaryCat = localCategories.firstWhere((c) => c.type == 'income' && c.name == 'Gaji');
      final foodCat = localCategories.firstWhere((c) => c.type == 'expense' && c.name == 'Makanan');
      final now = DateTime.now().toUtc();

      // Offline operations queued in SQLite + sync_outbox
      final bca = await accountRepo.createAccount(
        userId: session.userId,
        deviceId: session.deviceId,
        name: 'BCA Mobile',
        accountType: 'bank',
        openingBalance: 5000000,
      );
      await txRepo.createIncomeOrExpense(
        userId: session.userId,
        deviceId: session.deviceId,
        type: 'income',
        accountId: bca.id,
        categoryId: salaryCat.id,
        amount: 1000000,
        transactionDate: now,
        description: 'Gaji Offline',
      );
      final exp = await txRepo.createIncomeOrExpense(
        userId: session.userId,
        deviceId: session.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: foodCat.id,
        amount: 250000,
        transactionDate: now,
        description: 'Belanja Offline',
      );
      await txRepo.createTransfer(
        userId: session.userId,
        deviceId: session.deviceId,
        sourceAccountId: bca.id,
        destinationAccountId: cash.id,
        amount: 500000,
        transactionDate: now,
        description: 'Topup Cash',
      );
      await txRepo.updateIncomeOrExpense(
        userId: session.userId,
        deviceId: session.deviceId,
        transactionId: exp.id,
        amount: 400000,
        reason: 'Update offline',
      );

      expect(await syncManager.getPendingOutboxCount(session.userId), 5);

      // Synchronize local outbox to Laravel + pull back
      final syncStatus = await syncManager.synchronize(
        userId: session.userId,
        deviceId: session.deviceId,
      );

      expect(syncStatus.status, SyncStateStatus.synced);
      expect(syncStatus.pendingCount, 0);

      // Local balances: BCA = 5M + 1M - 500k = 5.500.000; Cash = 0 + 500k - 400k = 100.000
      final localBcaBalance = await ledger.calculateAccountBalance(bca.id);
      final localCashBalance = await ledger.calculateAccountBalance(cash.id);
      expect(localBcaBalance, 5500000);
      expect(localCashBalance, 100000);

      // Verify server MySQL balances match local SQLite balances 100%
      final serverAccountsRes = await apiClient.get<List<dynamic>>(
        '/accounts',
        parseData: (raw) => List<dynamic>.from(raw as List),
      );
      final serverAccounts = serverAccountsRes.data!.cast<Map<String, dynamic>>();
      final serverBca = serverAccounts.firstWhere((a) => a['id'] == bca.id);
      final serverCash = serverAccounts.firstWhere((a) => a['id'] == cash.id);

      expect(serverBca['balance_cache'], 5500000);
      expect(serverCash['balance_cache'], 100000);
    });
  });
}

