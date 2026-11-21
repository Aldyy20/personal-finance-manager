import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/local_ledger_service.dart';

class BudgetRepository {
  BudgetRepository({
    required this.db,
    required this.ledgerService,
  });

  final AppDatabase db;
  final LocalLedgerService ledgerService;

  Stream<List<LocalBudget>> watchBudgets(String userId) {
    return (db.select(db.localBudgets)
          ..where((t) => t.userId.equals(userId) & t.deletedAtMs.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .watch();
  }

  Future<LocalBudget> createBudget({
    required String userId,
    required String deviceId,
    required String name,
    required String startDate,
    required String endDate,
    String periodType = 'monthly',
    int? totalLimit,
    int warningPercent = 80,
    bool isActive = true,
    List<({String categoryId, int amountLimit})> categories = const [],
  }) {
    return ledgerService.createBudget(
      userId: userId,
      deviceId: deviceId,
      name: name,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      totalLimit: totalLimit,
      warningPercent: warningPercent,
      isActive: isActive,
      categories: categories,
    );
  }

  Future<LocalBudget> updateBudget({
    required String userId,
    required String deviceId,
    required String budgetId,
    String? name,
    String? periodType,
    String? startDate,
    String? endDate,
    int? totalLimit,
    bool clearTotalLimit = false,
    int? warningPercent,
    bool? isActive,
    List<({String categoryId, int amountLimit})>? categories,
  }) {
    return ledgerService.updateBudget(
      userId: userId,
      deviceId: deviceId,
      budgetId: budgetId,
      name: name,
      periodType: periodType,
      startDate: startDate,
      endDate: endDate,
      totalLimit: totalLimit,
      clearTotalLimit: clearTotalLimit,
      warningPercent: warningPercent,
      isActive: isActive,
      categories: categories,
    );
  }

  Future<LocalBudget> archiveBudget(String userId, String deviceId, String budgetId) {
    return ledgerService.setBudgetActiveState(
      userId: userId,
      deviceId: deviceId,
      budgetId: budgetId,
      isActive: false,
    );
  }

  Future<LocalBudget> restoreBudget(String userId, String deviceId, String budgetId) {
    return ledgerService.setBudgetActiveState(
      userId: userId,
      deviceId: deviceId,
      budgetId: budgetId,
      isActive: true,
    );
  }

  Future<Map<String, dynamic>> getBudgetSummary(String userId, String budgetId) {
    return ledgerService.getLocalBudgetSummary(userId, budgetId);
  }

  Future<List<Map<String, dynamic>>> getAllBudgetSummaries(
    String userId, {
    bool activeOnly = true,
  }) async {
    final budgets = await (db.select(db.localBudgets)
          ..where((t) {
            var p = t.userId.equals(userId) & t.deletedAtMs.isNull();
            if (activeOnly) {
              p = p & t.isActive.equals(true);
            }
            return p;
          })
          ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
        .get();

    final summaries = <Map<String, dynamic>>[];
    for (final b in budgets) {
      summaries.add(await getBudgetSummary(userId, b.id));
    }
    return summaries;
  }
}

