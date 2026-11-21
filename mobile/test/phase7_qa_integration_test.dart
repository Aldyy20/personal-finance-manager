import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_finance_manager/core/config/env_config.dart';
import 'package:personal_finance_manager/core/database/app_database.dart';
import 'package:personal_finance_manager/core/database/local_ledger_service.dart';
import 'package:personal_finance_manager/core/network/api_client.dart';
import 'package:personal_finance_manager/core/security/secure_storage_service.dart';
import 'package:personal_finance_manager/core/sync/sync_manager.dart';
import 'package:personal_finance_manager/core/sync/sync_status.dart';
import 'package:personal_finance_manager/features/accounts/data/account_repository.dart';
import 'package:personal_finance_manager/features/authentication/data/auth_repository.dart';
import 'package:personal_finance_manager/features/categories/data/category_repository.dart';
import 'package:personal_finance_manager/features/receipt_scanner/data/receipt_repository.dart';
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

typedef _AdapterHandler = Future<ResponseBody> Function(RequestOptions options);

class _MockHttpClientAdapter implements HttpClientAdapter {
  _MockHttpClientAdapter(this.handler);

  _AdapterHandler handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonResponse(Map<String, dynamic> body, {int statusCode = 200}) {
  return ResponseBody.fromString(
    jsonEncode(body),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
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
          name: 'QA Offline User',
          email: 'qa_offline@example.com',
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
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('Phase 7 Quality Assurance & Integration Scenarios', () {
    test('Scenarios 1-4, 9-10: Offline push failure preserves local ledger/receipt & recovers on retry', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      var serverOnline = false;
      final adapter = _MockHttpClientAdapter((options) async {
        if (!serverOnline) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'Simulated offline network outage',
          );
        }

        if (options.path.endsWith('/sync/push')) {
          final body = Map<String, dynamic>.from(options.data as Map);
          final ops = (body['operations'] as List<dynamic>).cast<Map<String, dynamic>>();
          return _jsonResponse({
            'success': true,
            'message': 'Sync push processed',
            'data': {
              'device_id': body['device_id'],
              'last_sequence': ops.length,
              'results': ops
                  .map((op) => {
                        'operation_id': op['operation_id'],
                        'entity_id': op['entity_id'],
                        'status': 'applied',
                        'entity_version': 1,
                        'idempotent_replay': false,
                      })
                  .toList(),
            },
          });
        }

        if (options.path.endsWith('/sync/pull')) {
          return _jsonResponse({
            'success': true,
            'message': 'Changes retrieved',
            'data': {
              'changes': [],
              'next_cursor': 4,
              'has_more': false,
            },
          });
        }

        return _jsonResponse({'success': true, 'data': {}});
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://mock.local/api/v1'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(
        envConfig: const EnvConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'http://mock.local/api/v1',
        ),
        secureStorage: _InMemorySecureStorage(),
        dio: dio,
      );

      final ledger = LocalLedgerService(db: db);
      final syncManager = SyncManager(db: db, apiClient: apiClient, ledgerService: ledger);
      final accountRepo = AccountRepository(db: db, ledgerService: ledger);
      final txRepo = TransactionRepository(db: db, ledgerService: ledger);
      final receiptRepo = ReceiptRepository(db: db, ledgerService: ledger);
      final ctx = await _seedOfflineUser(db);

      final cash = await accountRepo.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'Cash',
        accountType: 'cash',
        openingBalance: 1000000,
      );
      final exp = await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: ctx.expenseCatId,
        amount: 75000,
        transactionDate: DateTime.now().toUtc(),
        description: 'Kopi QA',
      );
      await receiptRepo.saveReceiptWithOcr(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        transactionId: exp.id,
        filePath: 'local_receipts/kopi.jpg',
        fileName: 'kopi.jpg',
        ocrText: 'KAFE QA\nTOTAL 75.000',
      );

      // Attempt sync while server is unavailable
      final offlineRes = await syncManager.synchronize(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
      );
      expect(offlineRes.status, SyncStateStatus.offline);
      expect(offlineRes.pendingCount, 3);
      expect(await ledger.calculateAccountBalance(cash.id), 925000);

      final failedRows = await db.select(db.syncOutbox).get();
      expect(failedRows.every((r) => r.status == 'failed' && r.retryCount == 1), isTrue);

      // Server returns online -> sync retry succeeds without duplicating local mutations
      serverOnline = true;
      final recoveredRes = await syncManager.synchronize(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
      );
      expect(recoveredRes.status, SyncStateStatus.synced);
      expect(recoveredRes.pendingCount, 0);
      expect(await ledger.calculateAccountBalance(cash.id), 925000);

      final syncedRows = await db.select(db.syncOutbox).get();
      expect(syncedRows.every((r) => r.status == 'synced'), isTrue);
    });

    test('Scenarios 5-7 & PRD 18.7: Conflict response preserves unresolved local edits during pull', () async {
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
        openingBalance: 1000000,
      );
      final tx = await txRepo.createIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: ctx.expenseCatId,
        amount: 200000,
        transactionDate: DateTime.now().toUtc(),
        description: 'Initial Local',
      );
      // Mark account & initial create as synced so only edit conflicts
      await (db.update(db.syncOutbox)).write(const SyncOutboxCompanion(status: Value('synced')));

      // Offline edit changes amount to 350.000
      await txRepo.updateIncomeOrExpense(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        transactionId: tx.id,
        amount: 350000,
        description: 'Local Pending Edit',
      );

      final adapter = _MockHttpClientAdapter((options) async {
        if (options.path.endsWith('/sync/push')) {
          final ops = (options.data['operations'] as List<dynamic>).cast<Map<String, dynamic>>();
          return _jsonResponse({
            'success': true,
            'message': 'Sync push processed',
            'data': {
              'results': ops
                  .map((op) => {
                        'operation_id': op['operation_id'],
                        'entity_id': op['entity_id'],
                        'status': 'conflict',
                        'code': 'CONFLICT',
                        'message': 'Version mismatch on server',
                      })
                  .toList(),
            },
          });
        }

        if (options.path.endsWith('/sync/pull')) {
          // Server tries to send an older/conflicting snapshot with amount 999.000
          return _jsonResponse({
            'success': true,
            'message': 'Changes retrieved',
            'data': {
              'changes': [
                {
                  'sequence': 10,
                  'entity_type': 'transactions',
                  'entity_id': tx.id,
                  'operation': 'update',
                  'entity_version': 3,
                  'data': {
                    'id': tx.id,
                    'user_id': ctx.userId,
                    'type': 'expense',
                    'category_id': ctx.expenseCatId,
                    'category_type': 'expense',
                    'amount': 999000,
                    'transaction_date': DateTime.now().toUtc().toIso8601String(),
                    'description': 'Conflicting Server Snapshot',
                    'status': 'posted',
                    'version': 3,
                  },
                },
              ],
              'next_cursor': 10,
              'has_more': false,
            },
          });
        }

        return _jsonResponse({'success': true, 'data': {}});
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://mock.local/api/v1'));
      dio.httpClientAdapter = adapter;
      final apiClient = ApiClient(
        envConfig: const EnvConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'http://mock.local/api/v1',
        ),
        secureStorage: _InMemorySecureStorage(),
        dio: dio,
      );
      final syncManager = SyncManager(db: db, apiClient: apiClient, ledgerService: ledger);

      final syncRes = await syncManager.synchronize(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
      );
      expect(syncRes.status, SyncStateStatus.conflict);
      expect(syncRes.pendingCount, 1);

      // Local edit (350.000) MUST NOT be blindly overwritten by server snapshot (999.000)
      final localTx = await txRepo.getTransactionById(ctx.userId, tx.id);
      expect(localTx!.amount, 350000);
      expect(localTx.description, 'Local Pending Edit');
      expect(await ledger.calculateAccountBalance(cash.id), 650000);
    });

    test('Scenario 12 & PRD 12 Rule 14: Switching user login purges previous user SQLite data', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      const userAId = '11111111-1111-4111-8111-111111111111';
      const userBId = '22222222-2222-4222-8222-222222222222';
      var activeEmail = 'user_a@example.com';

      final adapter = _MockHttpClientAdapter((options) async {
        if (options.path.endsWith('/auth/login')) {
          final isUserA = activeEmail == 'user_a@example.com';
          return _jsonResponse({
            'success': true,
            'data': {
              'user': {
                'id': isUserA ? userAId : userBId,
                'name': isUserA ? 'User A' : 'User B',
                'email': activeEmail,
              },
              'access_token': isUserA ? 'token-a' : 'token-b',
            },
          });
        }
        return _jsonResponse({'success': true, 'data': {'changes': [], 'next_cursor': 0, 'has_more': false}});
      });

      final dio = Dio(BaseOptions(baseUrl: 'http://mock.local/api/v1'));
      dio.httpClientAdapter = adapter;
      final storage = _InMemorySecureStorage();
      final apiClient = ApiClient(
        envConfig: const EnvConfig(
          environment: AppEnvironment.dev,
          apiBaseUrl: 'http://mock.local/api/v1',
        ),
        secureStorage: storage,
        dio: dio,
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

      final sessionA = await authRepo.login(
        email: 'user_a@example.com',
        password: 'PasswordA123!',
        pullInitialData: false,
      );
      await accountRepo.createAccount(
        userId: sessionA.userId,
        deviceId: sessionA.deviceId,
        name: 'User A Private Account',
        accountType: 'bank',
        openingBalance: 9000000,
      );
      expect((await accountRepo.getAccounts(userAId)).length, 1);

      // Login User B on the exact same device -> User A rows must be purged cleanly
      activeEmail = 'user_b@example.com';
      final sessionB = await authRepo.login(
        email: 'user_b@example.com',
        password: 'PasswordB123!',
        pullInitialData: false,
      );
      expect(sessionB.userId, userBId);
      expect(await db.select(db.localAccounts).get(), isEmpty);
      expect(await accountRepo.getAccounts(userAId), isEmpty);
    });

    test('Scenario 11 & Drive D: Persistent disk SQLite survives restart with 50-tx batch performance', () async {
      final dbFile = File(r'D:\kerja\Sistem\personal-finance-manager\temp\qa_restart_test.sqlite');
      dbFile.parent.createSync(recursive: true);

      final db1 = AppDatabase(NativeDatabase(dbFile));
      final ledger1 = LocalLedgerService(db: db1);
      final accountRepo1 = AccountRepository(db: db1, ledgerService: ledger1);
      final txRepo1 = TransactionRepository(db: db1, ledgerService: ledger1);
      final ctx = await _seedOfflineUser(db1);

      final acc = await accountRepo1.createAccount(
        userId: ctx.userId,
        deviceId: ctx.deviceId,
        name: 'Disk Persistence Bank',
        accountType: 'bank',
        openingBalance: 10000000,
      );

      final sw = Stopwatch()..start();
      for (var i = 0; i < 50; i++) {
        await txRepo1.createIncomeOrExpense(
          userId: ctx.userId,
          deviceId: ctx.deviceId,
          type: 'expense',
          accountId: acc.id,
          categoryId: ctx.expenseCatId,
          amount: 10000,
          transactionDate: DateTime.now().toUtc(),
          description: 'Disk Batch $i',
        );
      }
      sw.stop();

      expect(sw.elapsedMilliseconds, lessThan(5000));
      await db1.close();

      // Re-open AppDatabase from the exact same SQLite file on Drive D: (simulated app restart)
      final db2 = AppDatabase(NativeDatabase(dbFile));
      addTearDown(db2.close);
      final ledger2 = LocalLedgerService(db: db2);

      // Balance: 10.000.000 - (50 * 10.000) = 9.500.000
      expect(await ledger2.calculateAccountBalance(acc.id), 9500000);
      final persistedOutbox = await (db2.select(db2.syncOutbox)
            ..where((t) => t.userId.equals(ctx.userId) & t.status.equals('pending')))
          .get();
      expect(persistedOutbox.length, 51);
    });

    test('Live Multi-Device E2E Sync (Device 1 SQLite <-> Laravel MySQL <-> Device 2 SQLite)', () async {
      const runLiveTest = bool.fromEnvironment('RUN_LIVE_API_TEST', defaultValue: false);
      if (!runLiveTest) {
        return;
      }

      HttpOverrides.global = null;

      final db1 = AppDatabase(NativeDatabase.memory());
      final db2 = AppDatabase(NativeDatabase.memory());
      addTearDown(() async {
        await db1.close();
        await db2.close();
      });

      final storage1 = _InMemorySecureStorage();
      final storage2 = _InMemorySecureStorage();
      const env = EnvConfig(
        environment: AppEnvironment.dev,
        apiBaseUrl: 'http://127.0.0.1:8000/api/v1',
      );
      final api1 = ApiClient(envConfig: env, secureStorage: storage1);
      final api2 = ApiClient(envConfig: env, secureStorage: storage2);

      final ledger1 = LocalLedgerService(db: db1);
      final ledger2 = LocalLedgerService(db: db2);
      final sync1 = SyncManager(db: db1, apiClient: api1, ledgerService: ledger1);
      final sync2 = SyncManager(db: db2, apiClient: api2, ledgerService: ledger2);

      final auth1 = AuthRepository(db: db1, apiClient: api1, secureStorage: storage1, syncManager: sync1);
      final auth2 = AuthRepository(db: db2, apiClient: api2, secureStorage: storage2, syncManager: sync2);

      final email = 'qa_multidevice_${DateTime.now().millisecondsSinceEpoch}@example.com';
      const password = 'QaMultiPassword123!';

      // Device 1 registers and pulls initial bootstrap data
      final s1 = await auth1.register(
        name: 'QA User',
        email: email,
        password: password,
        passwordConfirmation: password,
        deviceName: 'Device 1 Pixel',
      );

      // Device 2 logs in on the same user account and pulls bootstrap data
      final s2 = await auth2.login(
        email: email,
        password: password,
        deviceName: 'Device 2 Galaxy',
      );

      final accRepo1 = AccountRepository(db: db1, ledgerService: ledger1);
      final catRepo1 = CategoryRepository(db: db1, ledgerService: ledger1);
      final txRepo1 = TransactionRepository(db: db1, ledgerService: ledger1);

      final accRepo2 = AccountRepository(db: db2, ledgerService: ledger2);
      final catRepo2 = CategoryRepository(db: db2, ledgerService: ledger2);
      final txRepo2 = TransactionRepository(db: db2, ledgerService: ledger2);

      final cash = (await accRepo1.getAccounts(s1.userId)).first;
      final cats1 = await catRepo1.getCategories(s1.userId);
      final cats2 = await catRepo2.getCategories(s2.userId);
      final salaryCat1 = cats1.firstWhere((c) => c.type == 'income' && c.name == 'Gaji');
      final foodCat1 = cats1.firstWhere((c) => c.type == 'expense' && c.name == 'Makanan');
      final foodCat2 = cats2.firstWhere((c) => c.type == 'expense' && c.name == 'Makanan');

      final now = DateTime.now().toUtc();

      // Device 1 offline ops: Create BCA (5M), Income +2M -> BCA, Expense -400k -> Cash, Edit Expense 400k->250k, Transfer 1M BCA->Cash
      final bca1 = await accRepo1.createAccount(
        userId: s1.userId,
        deviceId: s1.deviceId,
        name: 'BCA Device 1',
        accountType: 'bank',
        openingBalance: 5000000,
      );
      await txRepo1.createIncomeOrExpense(
        userId: s1.userId,
        deviceId: s1.deviceId,
        type: 'income',
        accountId: bca1.id,
        categoryId: salaryCat1.id,
        amount: 2000000,
        transactionDate: now,
        description: 'Gaji D1',
      );
      final exp1 = await txRepo1.createIncomeOrExpense(
        userId: s1.userId,
        deviceId: s1.deviceId,
        type: 'expense',
        accountId: cash.id,
        categoryId: foodCat1.id,
        amount: 400000,
        transactionDate: now,
        description: 'Makan D1',
      );
      await txRepo1.updateIncomeOrExpense(
        userId: s1.userId,
        deviceId: s1.deviceId,
        transactionId: exp1.id,
        amount: 250000,
        reason: 'Koreksi D1',
      );
      await txRepo1.createTransfer(
        userId: s1.userId,
        deviceId: s1.deviceId,
        sourceAccountId: bca1.id,
        destinationAccountId: cash.id,
        amount: 1000000,
        transactionDate: now,
        description: 'Transfer D1',
      );

      // Device 2 offline ops simultaneously: Create GoPay (1M), Expense -150k -> GoPay
      final gopay2 = await accRepo2.createAccount(
        userId: s2.userId,
        deviceId: s2.deviceId,
        name: 'GoPay Device 2',
        accountType: 'e_wallet',
        openingBalance: 1000000,
      );
      final exp2 = await txRepo2.createIncomeOrExpense(
        userId: s2.userId,
        deviceId: s2.deviceId,
        type: 'expense',
        accountId: gopay2.id,
        categoryId: foodCat2.id,
        amount: 150000,
        transactionDate: now,
        description: 'Snack D2',
      );

      // Bidirectional convergence: D1 syncs -> D2 syncs -> D1 syncs again to pull D2 changes
      final resD1First = await sync1.synchronize(userId: s1.userId, deviceId: s1.deviceId);
      final resD2First = await sync2.synchronize(userId: s2.userId, deviceId: s2.deviceId);
      final resD1Second = await sync1.synchronize(userId: s1.userId, deviceId: s1.deviceId);

      expect(resD1First.status, SyncStateStatus.synced);
      expect(resD2First.status, SyncStateStatus.synced);
      expect(resD1Second.status, SyncStateStatus.synced);

      // Expected balances across ALL 3 databases (DB1, DB2, Laravel MySQL):
      // BCA = 5M + 2M - 1M = 6.000.000
      // Cash = 0 - 250k + 1M = 750.000
      // GoPay = 1M - 150k = 850.000
      expect(await ledger1.calculateAccountBalance(bca1.id), 6000000);
      expect(await ledger1.calculateAccountBalance(cash.id), 750000);
      expect(await ledger1.calculateAccountBalance(gopay2.id), 850000);

      expect(await ledger2.calculateAccountBalance(bca1.id), 6000000);
      expect(await ledger2.calculateAccountBalance(cash.id), 750000);
      expect(await ledger2.calculateAccountBalance(gopay2.id), 850000);

      // Real multi-device conflict test: D2 edits exp2 (v1->v2) and syncs; D1 still thinks exp2 is v1 and tries to edit -> Conflict detected!
      await txRepo2.updateIncomeOrExpense(
        userId: s2.userId,
        deviceId: s2.deviceId,
        transactionId: exp2.id,
        amount: 200000,
        reason: 'Device 2 authoritative update',
      );
      expect((await sync2.synchronize(userId: s2.userId, deviceId: s2.deviceId)).status, SyncStateStatus.synced);

      await txRepo1.updateIncomeOrExpense(
        userId: s1.userId,
        deviceId: s1.deviceId,
        transactionId: exp2.id,
        amount: 999999,
        reason: 'Stale Device 1 offline edit',
      );
      final conflictRes = await sync1.synchronize(userId: s1.userId, deviceId: s1.deviceId);
      expect(conflictRes.status, SyncStateStatus.conflict);
      expect(conflictRes.pendingCount, 1);
    });
  });
}

