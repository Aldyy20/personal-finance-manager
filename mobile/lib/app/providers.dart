import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/config/env_config.dart';
import '../core/database/app_database.dart';
import '../core/database/local_ledger_service.dart';
import '../core/network/api_client.dart';
import '../core/security/secure_storage_service.dart';
import '../core/sync/sync_manager.dart';
import '../core/sync/sync_status.dart';
import '../features/accounts/data/account_repository.dart';
import '../features/authentication/application/session_controller.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/budgets/data/budget_repository.dart';
import '../features/categories/data/category_repository.dart';
import '../features/receipt_scanner/application/ocr_parser_service.dart';
import '../features/receipt_scanner/data/receipt_repository.dart';
import '../features/reports/data/report_repository.dart';
import '../features/transactions/data/transaction_repository.dart';

final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment();
});

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    envConfig: ref.watch(envConfigProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
  );
});

final localLedgerServiceProvider = Provider<LocalLedgerService>((ref) {
  return LocalLedgerService(db: ref.watch(appDatabaseProvider));
});

final syncManagerProvider = Provider<SyncManager>((ref) {
  return SyncManager(
    db: ref.watch(appDatabaseProvider),
    apiClient: ref.watch(apiClientProvider),
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    db: ref.watch(appDatabaseProvider),
    apiClient: ref.watch(apiClientProvider),
    secureStorage: ref.watch(secureStorageServiceProvider),
    syncManager: ref.watch(syncManagerProvider),
  );
});

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  return AccountRepository(
    db: ref.watch(appDatabaseProvider),
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  return CategoryRepository(
    db: ref.watch(appDatabaseProvider),
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
    db: ref.watch(appDatabaseProvider),
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  return BudgetRepository(
    db: ref.watch(appDatabaseProvider),
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final ocrParserServiceProvider = Provider<OcrParserService>((ref) {
  return const OcrParserService();
});

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepository(
    db: ref.watch(appDatabaseProvider),
    ledgerService: ref.watch(localLedgerServiceProvider),
  );
});

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

final activeSessionProvider =
    AsyncNotifierProvider<SessionController, ActiveWorkspaceSession>(
  SessionController.new,
);

class SyncController extends StateNotifier<SyncStatusInfo> {
  SyncController({
    required this.ref,
    required this.syncManager,
  }) : super(const SyncStatusInfo(status: SyncStateStatus.idle));

  final Ref ref;
  final SyncManager syncManager;

  Future<void> refreshLocalState() async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final pending = await syncManager.getPendingOutboxCount(session.userId);
    final cursor = await syncManager.getLastCursor(session.userId, session.deviceId);
    state = SyncStatusInfo(
      status: session.isCloudAuthenticated
          ? (pending > 0 ? SyncStateStatus.idle : SyncStateStatus.synced)
          : SyncStateStatus.offline,
      pendingCount: pending,
      lastCursor: cursor,
      lastSyncAt: state.lastSyncAt,
      lastError: state.lastError,
    );
  }

  Future<SyncStatusInfo> triggerSync() async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) {
      return state;
    }

    if (!session.isCloudAuthenticated) {
      final pending = await syncManager.getPendingOutboxCount(session.userId);
      final info = SyncStatusInfo(
        status: SyncStateStatus.offline,
        pendingCount: pending,
        lastError: 'Masuk ke akun cloud di Pengaturan untuk sinkronisasi multi-perangkat.',
      );
      state = info;
      return info;
    }

    state = SyncStatusInfo(
      status: SyncStateStatus.syncing,
      pendingCount: state.pendingCount,
      lastCursor: state.lastCursor,
      lastSyncAt: state.lastSyncAt,
    );

    final result = await syncManager.synchronize(
      userId: session.userId,
      deviceId: session.deviceId,
    );
    state = result;
    return result;
  }
}

final syncStatusProvider = StateNotifierProvider<SyncController, SyncStatusInfo>((ref) {
  final controller = SyncController(
    ref: ref,
    syncManager: ref.watch(syncManagerProvider),
  );
  ref.listen<AsyncValue<ActiveWorkspaceSession>>(activeSessionProvider, (_, _) {
    controller.refreshLocalState();
  });
  return controller;
});

final pendingOutboxCountProvider = StreamProvider<int>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return Stream.value(0);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncOutbox)
        ..where((t) => t.userId.equals(session.userId) & t.status.isIn(['pending', 'failed', 'syncing'])))
      .watch()
      .map((rows) => rows.length);
});

final outboxEntriesProvider = StreamProvider<List<SyncOutboxData>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return Stream.value(const []);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.syncOutbox)
        ..where((t) => t.userId.equals(session.userId))
        ..orderBy([(t) => OrderingTerm.desc(t.updatedAtMs)])
        ..limit(50))
      .watch();
});

final accountsStreamProvider = StreamProvider<List<LocalAccount>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return const Stream.empty();
  return ref.watch(accountRepositoryProvider).watchAccounts(session.userId, activeOnly: false);
});

final activeAccountsStreamProvider = StreamProvider<List<LocalAccount>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return const Stream.empty();
  return ref.watch(accountRepositoryProvider).watchAccounts(session.userId, activeOnly: true);
});

final categoriesStreamProvider = StreamProvider<List<LocalCategory>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return const Stream.empty();
  return ref.watch(categoryRepositoryProvider).watchCategories(session.userId, activeOnly: false);
});

final transactionsStreamProvider = StreamProvider<List<LocalTransaction>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return const Stream.empty();
  return ref.watch(transactionRepositoryProvider).watchTransactions(session.userId, limit: 200);
});

final transactionMovementsStreamProvider =
    StreamProvider<List<LocalAccountMovement>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return Stream.value(const []);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.localAccountMovements)
        ..where(
          (m) =>
              m.userId.equals(session.userId) & m.transactionId.isNotNull(),
        ))
      .watch();
});

final receiptsStreamProvider = StreamProvider<List<LocalReceipt>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return Stream.value(const []);
  final db = ref.watch(appDatabaseProvider);
  return (db.select(db.localReceipts)
        ..where(
          (r) => r.userId.equals(session.userId) & r.deletedAtMs.isNull(),
        ))
      .watch();
});

final budgetsStreamProvider = StreamProvider<List<LocalBudget>>((ref) {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return const Stream.empty();
  return ref.watch(budgetRepositoryProvider).watchBudgets(session.userId);
});

final dashboardOverviewProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) {
    return {
      'total_balance': 0,
      'total_income': 0,
      'total_expense': 0,
      'net_cash_flow': 0,
      'active_accounts_count': 0,
    };
  }
  // React automatically whenever accounts or transactions change locally or after sync
  ref.watch(accountsStreamProvider);
  ref.watch(transactionsStreamProvider);
  return ref.watch(reportRepositoryProvider).getOverview(session.userId);
});

final budgetSummariesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final session = ref.watch(activeSessionProvider).valueOrNull;
  if (session == null) return const [];
  ref.watch(budgetsStreamProvider);
  ref.watch(transactionsStreamProvider);
  return ref.watch(budgetRepositoryProvider).getAllBudgetSummaries(session.userId);
});

final localDbHealthProvider = FutureProvider<bool>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  return db.checkDatabaseHealth();
});

final backendHealthProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  final response = await client.checkHealth();
  return response.data ?? const {};
});
