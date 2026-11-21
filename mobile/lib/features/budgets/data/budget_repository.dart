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
    int? totalLimit,
    int warningPercent = 80,
    List<({String categoryId, int amountLimit})> categories = const [],
  }) {
    return ledgerService.createBudget(
      userId: userId,
      deviceId: deviceId,
      name: name,
      startDate: startDate,
      endDate: endDate,
      totalLimit: totalLimit,
      warningPercent: warningPercent,
      categories: categories,
    );
  }

  Future<Map<String, dynamic>> getBudgetSummary(String userId, String budgetId) {
    return ledgerService.getLocalBudgetSummary(userId, budgetId);
  }
}

