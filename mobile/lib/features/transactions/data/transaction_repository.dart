import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/local_ledger_service.dart';

class TransactionRepository {
  TransactionRepository({
    required this.db,
    required this.ledgerService,
  });

  final AppDatabase db;
  final LocalLedgerService ledgerService;

  Stream<List<LocalTransaction>> watchTransactions(String userId, {int limit = 50}) {
    final query = db.select(db.localTransactions)
      ..where((t) => t.userId.equals(userId) & t.deletedAtMs.isNull())
      ..orderBy([(t) => OrderingTerm.desc(t.transactionDateMs)])
      ..limit(limit);
    return query.watch();
  }

  Future<List<LocalTransactionRevision>> getRevisions(String transactionId) {
    return (db.select(db.localTransactionRevisions)
          ..where((t) => t.transactionId.equals(transactionId))
          ..orderBy([(t) => OrderingTerm.asc(t.revisionNumber)]))
        .get();
  }

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
  }) {
    return ledgerService.createIncomeOrExpense(
      userId: userId,
      deviceId: deviceId,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      transactionDate: transactionDate,
      description: description,
      notes: notes,
    );
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
  }) {
    return ledgerService.createTransfer(
      userId: userId,
      deviceId: deviceId,
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      transactionDate: transactionDate,
      description: description,
      notes: notes,
    );
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
  }) {
    return ledgerService.updateIncomeOrExpense(
      userId: userId,
      deviceId: deviceId,
      transactionId: transactionId,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      amount: amount,
      transactionDate: transactionDate,
      description: description,
      notes: notes,
      reason: reason,
    );
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
  }) {
    return ledgerService.updateTransfer(
      userId: userId,
      deviceId: deviceId,
      transactionId: transactionId,
      sourceAccountId: sourceAccountId,
      destinationAccountId: destinationAccountId,
      amount: amount,
      transactionDate: transactionDate,
      description: description,
      notes: notes,
      reason: reason,
    );
  }

  Future<LocalTransaction> voidTransaction({
    required String userId,
    required String deviceId,
    required String transactionId,
    String? reason,
  }) {
    return ledgerService.voidTransaction(
      userId: userId,
      deviceId: deviceId,
      transactionId: transactionId,
      reason: reason,
    );
  }
}

