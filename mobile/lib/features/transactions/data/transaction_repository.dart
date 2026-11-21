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

  Stream<List<LocalTransaction>> watchFilteredTransactions(
    String userId, {
    String? type,
    String? accountId,
    String? categoryId,
    String? status,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 100,
  }) {
    final query = db.select(db.localTransactions)
      ..where((t) {
        var predicate = t.userId.equals(userId) & t.deletedAtMs.isNull();
        if (type != null && type.isNotEmpty) {
          predicate = predicate & t.type.equals(type);
        }
        if (categoryId != null && categoryId.isNotEmpty) {
          predicate = predicate & t.categoryId.equals(categoryId);
        }
        if (status != null && status.isNotEmpty) {
          predicate = predicate & t.status.equals(status);
        }
        if (startDate != null && endDate != null) {
          predicate = predicate &
              t.transactionDateMs.isBetweenValues(
                startDate.toUtc().millisecondsSinceEpoch,
                endDate.toUtc().millisecondsSinceEpoch,
              );
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.transactionDateMs),
        (t) => OrderingTerm.desc(t.createdAtMs),
      ]);

    return query.watch().asyncMap((rows) async {
      var filtered = rows;

      if (accountId != null && accountId.isNotEmpty) {
        final movements = await (db.select(db.localAccountMovements)
              ..where((m) => m.accountId.equals(accountId) & m.transactionId.isNotNull()))
            .get();
        final txIds = movements.map((m) => m.transactionId!).toSet();
        filtered = filtered.where((tx) => txIds.contains(tx.id)).toList();
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final q = searchQuery.trim().toLowerCase();
        filtered = filtered.where((tx) {
          final desc = (tx.description ?? '').toLowerCase();
          final notes = (tx.notes ?? '').toLowerCase();
          return desc.contains(q) || notes.contains(q);
        }).toList();
      }

      return filtered.take(limit).toList();
    });
  }

  Future<LocalTransaction?> getTransactionById(String userId, String transactionId) {
    return (db.select(db.localTransactions)
          ..where((t) => t.id.equals(transactionId) & t.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<List<LocalAccountMovement>> getActiveMovements(String transactionId) {
    return ledgerService.getActiveMovementsForTransaction(transactionId);
  }

  Future<List<LocalAccountMovement>> getAllMovements(String transactionId) {
    return (db.select(db.localAccountMovements)
          ..where((t) => t.transactionId.equals(transactionId))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
        .get();
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

