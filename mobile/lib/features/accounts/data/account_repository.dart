import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/local_ledger_service.dart';

class AccountRepository {
  AccountRepository({
    required this.db,
    required this.ledgerService,
  });

  final AppDatabase db;
  final LocalLedgerService ledgerService;

  Stream<List<LocalAccount>> watchAccounts(String userId, {bool activeOnly = false}) {
    final query = db.select(db.localAccounts)
      ..where((t) {
        var predicate = t.userId.equals(userId) & t.deletedAtMs.isNull();
        if (activeOnly) {
          predicate = predicate & t.isActive.equals(true);
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.isActive),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.watch();
  }

  Future<List<LocalAccount>> getAccounts(String userId, {bool activeOnly = false}) {
    final query = db.select(db.localAccounts)
      ..where((t) {
        var predicate = t.userId.equals(userId) & t.deletedAtMs.isNull();
        if (activeOnly) {
          predicate = predicate & t.isActive.equals(true);
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.desc(t.isActive),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.get();
  }

  Future<List<LocalAccountMovement>> getAccountMovements(String accountId) {
    return (db.select(db.localAccountMovements)
          ..where((t) => t.accountId.equals(accountId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();
  }

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
  }) {
    return ledgerService.createAccount(
      userId: userId,
      deviceId: deviceId,
      name: name,
      accountType: accountType,
      institutionName: institutionName,
      accountNumber: accountNumber,
      openingBalance: openingBalance,
      openingBalanceDate: openingBalanceDate,
      icon: icon,
      color: color,
    );
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
  }) {
    return ledgerService.updateAccount(
      userId: userId,
      deviceId: deviceId,
      accountId: accountId,
      name: name,
      accountType: accountType,
      institutionName: institutionName,
      accountNumber: accountNumber,
      openingBalance: openingBalance,
      icon: icon,
      color: color,
    );
  }

  Future<LocalAccount> archiveAccount(String userId, String deviceId, String accountId) {
    return ledgerService.setAccountActiveState(
      userId: userId,
      deviceId: deviceId,
      accountId: accountId,
      isActive: false,
    );
  }

  Future<LocalAccount> restoreAccount(String userId, String deviceId, String accountId) {
    return ledgerService.setAccountActiveState(
      userId: userId,
      deviceId: deviceId,
      accountId: accountId,
      isActive: true,
    );
  }

  Future<LocalAccountAdjustment> createAdjustment({
    required String userId,
    required String deviceId,
    required String accountId,
    required int amountSigned,
    required String reason,
  }) {
    return ledgerService.createAdjustment(
      userId: userId,
      deviceId: deviceId,
      accountId: accountId,
      amountSigned: amountSigned,
      reason: reason,
    );
  }
}

