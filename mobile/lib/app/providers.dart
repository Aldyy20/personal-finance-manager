import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../core/config/env_config.dart';
import '../core/database/app_database.dart';
import '../core/database/local_ledger_service.dart';
import '../core/network/api_client.dart';
import '../core/security/secure_storage_service.dart';
import '../core/sync/sync_manager.dart';
import '../features/accounts/data/account_repository.dart';
import '../features/authentication/data/auth_repository.dart';
import '../features/budgets/data/budget_repository.dart';
import '../features/categories/data/category_repository.dart';
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

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
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
