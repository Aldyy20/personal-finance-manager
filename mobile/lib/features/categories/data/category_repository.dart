import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/local_ledger_service.dart';

class CategoryRepository {
  CategoryRepository({
    required this.db,
    required this.ledgerService,
  });

  final AppDatabase db;
  final LocalLedgerService ledgerService;

  Stream<List<LocalCategory>> watchCategories(
    String userId, {
    String? type,
    bool activeOnly = true,
  }) {
    final query = db.select(db.localCategories)
      ..where((t) {
        var predicate = t.userId.equals(userId) & t.deletedAtMs.isNull();
        if (type != null) {
          predicate = predicate & t.type.equals(type);
        }
        if (activeOnly) {
          predicate = predicate & t.isActive.equals(true);
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.asc(t.type),
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.watch();
  }

  Future<List<LocalCategory>> getCategories(
    String userId, {
    String? type,
    bool activeOnly = true,
  }) {
    final query = db.select(db.localCategories)
      ..where((t) {
        var predicate = t.userId.equals(userId) & t.deletedAtMs.isNull();
        if (type != null) {
          predicate = predicate & t.type.equals(type);
        }
        if (activeOnly) {
          predicate = predicate & t.isActive.equals(true);
        }
        return predicate;
      })
      ..orderBy([
        (t) => OrderingTerm.asc(t.type),
        (t) => OrderingTerm.asc(t.sortOrder),
        (t) => OrderingTerm.asc(t.name),
      ]);
    return query.get();
  }

  Future<LocalCategory> createCategory({
    required String userId,
    required String deviceId,
    required String name,
    required String type,
    String? icon,
    String? color,
    int sortOrder = 0,
  }) {
    return ledgerService.createCategory(
      userId: userId,
      deviceId: deviceId,
      name: name,
      type: type,
      icon: icon,
      color: color,
      sortOrder: sortOrder,
    );
  }

  Future<LocalCategory> updateCategory({
    required String userId,
    required String deviceId,
    required String categoryId,
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
  }) {
    return ledgerService.updateCategory(
      userId: userId,
      deviceId: deviceId,
      categoryId: categoryId,
      name: name,
      icon: icon,
      color: color,
      sortOrder: sortOrder,
    );
  }

  Future<LocalCategory> archiveCategory(String userId, String deviceId, String categoryId) {
    return ledgerService.setCategoryActiveState(
      userId: userId,
      deviceId: deviceId,
      categoryId: categoryId,
      isActive: false,
    );
  }

  Future<LocalCategory> restoreCategory(String userId, String deviceId, String categoryId) {
    return ledgerService.setCategoryActiveState(
      userId: userId,
      deviceId: deviceId,
      categoryId: categoryId,
      isActive: true,
    );
  }
}

