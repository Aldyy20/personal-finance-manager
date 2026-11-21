import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../database/local_ledger_service.dart';
import '../errors/app_exception.dart';
import '../network/api_client.dart';
import 'sync_status.dart';

class SyncManager {
  SyncManager({
    required this.db,
    required this.apiClient,
    required this.ledgerService,
    Uuid? uuid,
  }) : _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final ApiClient apiClient;
  final LocalLedgerService ledgerService;
  final Uuid _uuid;

  Future<int> getPendingOutboxCount(String userId) async {
    final rows = await (db.select(db.syncOutbox)
          ..where((t) => t.userId.equals(userId) & t.status.isIn(['pending', 'failed'])))
        .get();
    return rows.length;
  }

  Future<int> getLastCursor(String userId, String deviceId) async {
    final state = await (db.select(db.localSyncState)
          ..where((t) => t.userId.equals(userId) & t.deviceId.equals(deviceId)))
        .getSingleOrNull();
    return state?.lastCursor ?? 0;
  }

  /// Pushes pending outbox operations in batches up to 50 items per request.
  Future<({int appliedCount, int conflictCount, int failedCount})> pushPendingOperations({
    required String userId,
    required String deviceId,
  }) async {
    final allPending = await (db.select(db.syncOutbox)
          ..where((t) => t.userId.equals(userId) & t.status.isIn(['pending', 'failed']))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAtMs)]))
        .get();

    // Filter out non-retryable conflicts/validation rejections
    final batch = allPending
        .where(
          (row) =>
              row.status == 'pending' ||
              (row.lastError != null &&
                  !row.lastError!.startsWith('CONFLICT') &&
                  !row.lastError!.startsWith('VALIDATION_ERROR') &&
                  !row.lastError!.startsWith('FORBIDDEN')),
        )
        .take(50)
        .toList();

    if (batch.isEmpty) {
      return (appliedCount: 0, conflictCount: 0, failedCount: 0);
    }

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
    final batchIds = batch.map((e) => e.id).toList();

    await (db.update(db.syncOutbox)..where((t) => t.id.isIn(batchIds))).write(
      SyncOutboxCompanion(status: const Value('syncing'), updatedAtMs: Value(nowMs)),
    );

    try {
      final response = await apiClient.post<Map<String, dynamic>>(
        '/sync/push',
        data: {
          'device_id': deviceId,
          'operations': batch
              .map((op) => {
                    'operation_id': op.operationId,
                    'entity_type': op.entityType,
                    'entity_id': op.entityId,
                    'operation_type': op.operationType,
                    'base_version': op.baseVersion,
                    'payload': jsonDecode(op.payloadJson) as Map<String, dynamic>,
                  })
              .toList(),
        },
        parseData: (raw) => Map<String, dynamic>.from(raw as Map),
      );

      final results = (response.data?['results'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final byOpId = {
        for (final r in results) r['operation_id'] as String: r,
      };

      var applied = 0;
      var conflicts = 0;
      var rejected = 0;

      for (final op in batch) {
        final res = byOpId[op.operationId];
        if (res == null) {
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
            SyncOutboxCompanion(
              status: const Value('failed'),
              retryCount: Value(op.retryCount + 1),
              lastError: const Value('Missing operation result from server'),
              updatedAtMs: Value(nowMs),
            ),
          );
          rejected++;
          continue;
        }

        final status = res['status'] as String? ?? 'rejected';
        if (status == 'applied') {
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
            SyncOutboxCompanion(
              status: const Value('synced'),
              lastError: const Value(null),
              updatedAtMs: Value(nowMs),
            ),
          );
          applied++;
        } else if (status == 'conflict') {
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
            SyncOutboxCompanion(
              status: const Value('failed'),
              lastError: Value('CONFLICT: ${res['message'] ?? 'Version mismatch'}'),
              updatedAtMs: Value(nowMs),
            ),
          );
          conflicts++;
        } else {
          await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
            SyncOutboxCompanion(
              status: const Value('failed'),
              lastError: Value('${res['code'] ?? 'VALIDATION_ERROR'}: ${res['message'] ?? 'Rejected'}'),
              updatedAtMs: Value(nowMs),
            ),
          );
          rejected++;
        }
      }

      return (appliedCount: applied, conflictCount: conflicts, failedCount: rejected);
    } on AppException catch (e) {
      for (final op in batch) {
        await (db.update(db.syncOutbox)..where((t) => t.id.equals(op.id))).write(
          SyncOutboxCompanion(
            status: const Value('failed'),
            retryCount: Value(op.retryCount + 1),
            lastError: Value(e.message),
            updatedAtMs: Value(nowMs),
          ),
        );
      }
      rethrow;
    }
  }

  /// Pulls server changes past local cursor and commits them atomically before advancing cursor.
  Future<int> pullServerChanges({
    required String userId,
    required String deviceId,
    int limit = 100,
  }) async {
    var cursor = await getLastCursor(userId, deviceId);
    var totalApplied = 0;
    var hasMore = true;

    while (hasMore) {
      final response = await apiClient.get<Map<String, dynamic>>(
        '/sync/pull',
        queryParameters: {
          'device_id': deviceId,
          'cursor': cursor,
          'limit': limit,
        },
        parseData: (raw) => Map<String, dynamic>.from(raw as Map),
      );

      final data = response.data ?? const {};
      final changes = (data['changes'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final nextCursor = (data['next_cursor'] as num?)?.toInt() ?? cursor;
      hasMore = data['has_more'] == true;

      if (changes.isEmpty && nextCursor <= cursor) {
        break;
      }

      await db.transaction(() async {
        final touchedAccounts = <String>{};

        for (final change in changes) {
          final entityType = change['entity_type'] as String;
          final entityData = change['data'] as Map<String, dynamic>?;
          if (entityData == null) continue;

          final accountIds = await _applyHydratedEntity(userId, entityType, entityData);
          touchedAccounts.addAll(accountIds);
          totalApplied++;
        }

        for (final accountId in touchedAccounts) {
          await ledgerService.reconcileAccountBalance(accountId);
        }

        // Advance cursor only inside the atomic commit after all changes succeed
        final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;
        final stateId = '${userId}_$deviceId';
        await db.into(db.localSyncState).insert(
              LocalSyncStateCompanion.insert(
                id: stateId,
                userId: userId,
                deviceId: deviceId,
                lastCursor: Value(nextCursor),
                lastSyncAtMs: Value(nowMs),
                updatedAtMs: nowMs,
              ),
              mode: InsertMode.insertOrReplace,
            );
      });

      cursor = nextCursor;
    }

    return totalApplied;
  }

  Future<SyncStatusInfo> synchronize({
    required String userId,
    required String deviceId,
  }) async {
    try {
      final pushRes = await pushPendingOperations(userId: userId, deviceId: deviceId);
      await pullServerChanges(userId: userId, deviceId: deviceId);

      final pending = await getPendingOutboxCount(userId);
      final cursor = await getLastCursor(userId, deviceId);

      return SyncStatusInfo(
        status: pushRes.conflictCount > 0
            ? SyncStateStatus.conflict
            : (pushRes.failedCount > 0 ? SyncStateStatus.error : SyncStateStatus.synced),
        pendingCount: pending,
        lastCursor: cursor,
        lastSyncAt: DateTime.now().toUtc(),
      );
    } on NetworkException catch (e) {
      final pending = await getPendingOutboxCount(userId);
      final cursor = await getLastCursor(userId, deviceId);
      return SyncStatusInfo(
        status: SyncStateStatus.offline,
        pendingCount: pending,
        lastCursor: cursor,
        lastError: e.message,
      );
    } catch (e) {
      final pending = await getPendingOutboxCount(userId);
      final cursor = await getLastCursor(userId, deviceId);
      return SyncStatusInfo(
        status: SyncStateStatus.error,
        pendingCount: pending,
        lastCursor: cursor,
        lastError: e.toString(),
      );
    }
  }

  Future<Set<String>> _applyHydratedEntity(
    String userId,
    String entityType,
    Map<String, dynamic> data,
  ) async {
    final touchedAccounts = <String>{};
    final entityId = data['id'] as String?;
    if (entityId != null) {
      final unresolvedOutbox = await (db.select(db.syncOutbox)
            ..where(
              (t) =>
                  t.userId.equals(userId) &
                  t.entityId.equals(entityId) &
                  t.status.isIn(['pending', 'syncing', 'failed']),
            ))
          .get();
      if (unresolvedOutbox.isNotEmpty) {
        // Preserve pending or conflicted local mutations until resolved/synced (PRD 18.7).
        return touchedAccounts;
      }
    }

    final nowMs = DateTime.now().toUtc().millisecondsSinceEpoch;

    switch (entityType) {
      case 'user_settings':
        await db.into(db.localUserSettings).insert(
              LocalUserSettingsCompanion.insert(
                id: data['id'] as String,
                userId: (data['user_id'] as String?) ?? userId,
                themeMode: Value((data['theme_mode'] as String?) ?? 'system'),
                currency: Value((data['currency'] as String?) ?? 'IDR'),
                timezone: Value((data['timezone'] as String?) ?? 'Asia/Jakarta'),
                budgetWarningPercent: Value((data['budget_warning_percent'] as num?)?.toInt() ?? 80),
                notificationsEnabled: Value(data['notifications_enabled'] != false),
                version: Value((data['version'] as num?)?.toInt() ?? 1),
                updatedAtMs: _parseMs(data['updated_at']) ?? nowMs,
              ),
              mode: InsertMode.insertOrReplace,
            );

      case 'accounts':
        final accountId = data['id'] as String;
        final openingBalance = (data['opening_balance'] as num?)?.toInt() ?? 0;
        await db.into(db.localAccounts).insert(
              LocalAccountsCompanion.insert(
                id: accountId,
                userId: (data['user_id'] as String?) ?? userId,
                name: data['name'] as String,
                accountType: data['account_type'] as String,
                institutionName: Value(data['institution_name'] as String?),
                accountNumber: Value(data['account_number'] as String?),
                openingBalance: Value(openingBalance),
                openingBalanceDate: (data['opening_balance_date'] as String?) ?? '2026-01-01',
                balanceCache: Value((data['balance_cache'] as num?)?.toInt() ?? openingBalance),
                icon: Value(data['icon'] as String?),
                color: Value(data['color'] as String?),
                isActive: Value(data['is_active'] != false),
                version: Value((data['version'] as num?)?.toInt() ?? 1),
                createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                updatedAtMs: _parseMs(data['updated_at']) ?? nowMs,
                deletedAtMs: Value(_parseMs(data['deleted_at'])),
              ),
              mode: InsertMode.insertOrReplace,
            );

        // Ensure opening movement exists locally so SUM(amount_signed) reconciles with server
        final existingOpening = await (db.select(db.localAccountMovements)
              ..where((t) => t.accountId.equals(accountId) & t.movementType.equals('opening')))
            .getSingleOrNull();
        if (existingOpening == null) {
          await db.into(db.localAccountMovements).insert(
                LocalAccountMovementsCompanion.insert(
                  id: _uuid.v4(),
                  userId: (data['user_id'] as String?) ?? userId,
                  accountId: accountId,
                  postingGroupId: _uuid.v4(),
                  movementType: 'opening',
                  amountSigned: openingBalance,
                  createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                ),
              );
        }
        touchedAccounts.add(accountId);

      case 'categories':
        await db.into(db.localCategories).insert(
              LocalCategoriesCompanion.insert(
                id: data['id'] as String,
                userId: (data['user_id'] as String?) ?? userId,
                name: data['name'] as String,
                type: data['type'] as String,
                icon: Value(data['icon'] as String?),
                color: Value(data['color'] as String?),
                isDefault: Value(data['is_default'] == true),
                isActive: Value(data['is_active'] != false),
                sortOrder: Value((data['sort_order'] as num?)?.toInt() ?? 0),
                version: Value((data['version'] as num?)?.toInt() ?? 1),
                createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                updatedAtMs: _parseMs(data['updated_at']) ?? nowMs,
                deletedAtMs: Value(_parseMs(data['deleted_at'])),
              ),
              mode: InsertMode.insertOrReplace,
            );

      case 'transactions':
        final txId = data['id'] as String;
        await db.into(db.localTransactions).insert(
              LocalTransactionsCompanion.insert(
                id: txId,
                userId: (data['user_id'] as String?) ?? userId,
                type: data['type'] as String,
                categoryId: Value(data['category_id'] as String?),
                categoryType: Value(data['category_type'] as String?),
                amount: (data['amount'] as num).toInt(),
                transactionDateMs: _parseMs(data['transaction_date']) ?? nowMs,
                description: Value(data['description'] as String?),
                notes: Value(data['notes'] as String?),
                status: Value((data['status'] as String?) ?? 'posted'),
                createdByDeviceId: Value(data['created_by_device_id'] as String?),
                version: Value((data['version'] as num?)?.toInt() ?? 1),
                createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                updatedAtMs: _parseMs(data['updated_at']) ?? nowMs,
                deletedAtMs: Value(_parseMs(data['deleted_at'])),
              ),
              mode: InsertMode.insertOrReplace,
            );

        final movements = (data['movements'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        if (movements.isNotEmpty) {
          final existingMovements = await (db.select(db.localAccountMovements)
                ..where((t) => t.transactionId.equals(txId)))
              .get();
          for (final oldM in existingMovements) {
            touchedAccounts.add(oldM.accountId);
          }

          // Replace client-generated local movements with authoritative server movements
          // so pulling back synced transactions never duplicates ledger rows.
          await (db.delete(db.localAccountMovements)
                ..where((t) => t.transactionId.equals(txId)))
              .go();

          final ordered = [...movements]..sort((a, b) {
              final aIsRev = a['reversal_of_id'] != null ? 1 : 0;
              final bIsRev = b['reversal_of_id'] != null ? 1 : 0;
              return aIsRev.compareTo(bIsRev);
            });

          for (final m in ordered) {
            final accId = m['account_id'] as String;
            await db.into(db.localAccountMovements).insert(
                  LocalAccountMovementsCompanion.insert(
                    id: m['id'] as String,
                    userId: (data['user_id'] as String?) ?? userId,
                    accountId: accId,
                    transactionId: Value(txId),
                    adjustmentId: Value(m['adjustment_id'] as String?),
                    postingGroupId: m['posting_group_id'] as String,
                    movementType: m['movement_type'] as String,
                    amountSigned: (m['amount_signed'] as num).toInt(),
                    reversalOfId: Value(m['reversal_of_id'] as String?),
                    createdAtMs: _parseMs(m['created_at']) ?? nowMs,
                  ),
                  mode: InsertMode.insertOrReplace,
                );
            touchedAccounts.add(accId);
          }
        }

      case 'account_adjustments':
        final adjId = data['id'] as String;
        final accId = data['account_id'] as String;
        final amountSigned = (data['amount_signed'] as num).toInt();
        await db.into(db.localAccountAdjustments).insert(
              LocalAccountAdjustmentsCompanion.insert(
                id: adjId,
                userId: (data['user_id'] as String?) ?? userId,
                accountId: accId,
                amountSigned: amountSigned,
                reason: data['reason'] as String,
                createdByDeviceId: Value(data['created_by_device_id'] as String?),
                createdAtMs: _parseMs(data['created_at']) ?? nowMs,
              ),
              mode: InsertMode.insertOrReplace,
            );
        final existingAdjMov = await (db.select(db.localAccountMovements)
              ..where((t) => t.adjustmentId.equals(adjId)))
            .getSingleOrNull();
        if (existingAdjMov == null) {
          await db.into(db.localAccountMovements).insert(
                LocalAccountMovementsCompanion.insert(
                  id: _uuid.v4(),
                  userId: (data['user_id'] as String?) ?? userId,
                  accountId: accId,
                  adjustmentId: Value(adjId),
                  postingGroupId: _uuid.v4(),
                  movementType: 'adjustment',
                  amountSigned: amountSigned,
                  createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                ),
              );
        }
        touchedAccounts.add(accId);

      case 'budgets':
        final budgetId = data['id'] as String;
        await db.into(db.localBudgets).insert(
              LocalBudgetsCompanion.insert(
                id: budgetId,
                userId: (data['user_id'] as String?) ?? userId,
                name: data['name'] as String,
                periodType: Value((data['period_type'] as String?) ?? 'monthly'),
                startDate: data['start_date'] as String,
                endDate: data['end_date'] as String,
                totalLimit: Value((data['total_limit'] as num?)?.toInt()),
                warningPercent: Value((data['warning_percent'] as num?)?.toInt() ?? 80),
                isActive: Value(data['is_active'] != false),
                version: Value((data['version'] as num?)?.toInt() ?? 1),
                createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                updatedAtMs: _parseMs(data['updated_at']) ?? nowMs,
                deletedAtMs: Value(_parseMs(data['deleted_at'])),
              ),
              mode: InsertMode.insertOrReplace,
            );
        final cats = (data['categories'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        for (final bc in cats) {
          await db.into(db.localBudgetCategories).insert(
                LocalBudgetCategoriesCompanion.insert(
                  id: bc['id'] as String,
                  userId: (data['user_id'] as String?) ?? userId,
                  budgetId: budgetId,
                  categoryId: bc['category_id'] as String,
                  categoryType: Value((bc['category_type'] as String?) ?? 'expense'),
                  amountLimit: (bc['amount_limit'] as num).toInt(),
                  version: Value((bc['version'] as num?)?.toInt() ?? 1),
                  createdAtMs: nowMs,
                  updatedAtMs: nowMs,
                ),
                mode: InsertMode.insertOrReplace,
              );
        }

      case 'receipts':
        await db.into(db.localReceipts).insert(
              LocalReceiptsCompanion.insert(
                id: data['id'] as String,
                transactionId: data['transaction_id'] as String,
                userId: (data['user_id'] as String?) ?? userId,
                filePath: (data['file_path'] as String?) ?? (data['download_url'] as String? ?? ''),
                fileName: Value(data['file_name'] as String?),
                mimeType: (data['mime_type'] as String?) ?? 'image/jpeg',
                fileSize: (data['file_size'] as num?)?.toInt() ?? 0,
                checksum: Value(data['checksum'] as String?),
                ocrText: Value(data['ocr_text'] as String?),
                extractedDataJson: Value(
                  data['extracted_data'] != null ? jsonEncode(data['extracted_data']) : null,
                ),
                isUploaded: const Value(true),
                version: Value((data['version'] as num?)?.toInt() ?? 1),
                createdAtMs: _parseMs(data['created_at']) ?? nowMs,
                updatedAtMs: _parseMs(data['updated_at']) ?? nowMs,
                deletedAtMs: Value(_parseMs(data['deleted_at'])),
              ),
              mode: InsertMode.insertOrReplace,
            );
    }

    return touchedAccounts;
  }

  int? _parseMs(dynamic iso) {
    if (iso is! String || iso.isEmpty) return null;
    return DateTime.tryParse(iso)?.toUtc().millisecondsSinceEpoch;
  }
}

