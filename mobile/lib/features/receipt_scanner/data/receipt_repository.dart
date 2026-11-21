import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/local_ledger_service.dart';

class ReceiptRepository {
  ReceiptRepository({
    required this.db,
    required this.ledgerService,
  });

  final AppDatabase db;
  final LocalLedgerService ledgerService;

  Stream<List<LocalReceipt>> watchReceiptsForTransaction(String transactionId) {
    return (db.select(db.localReceipts)
          ..where((t) => t.transactionId.equals(transactionId) & t.deletedAtMs.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .watch();
  }

  Future<List<LocalReceipt>> getReceiptsForTransaction(String transactionId) {
    return (db.select(db.localReceipts)
          ..where((t) => t.transactionId.equals(transactionId) & t.deletedAtMs.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.createdAtMs)]))
        .get();
  }

  Future<LocalReceipt> saveReceiptWithOcr({
    required String userId,
    required String deviceId,
    required String transactionId,
    required String filePath,
    String? localFilePath,
    String? fileName,
    String mimeType = 'image/jpeg',
    int fileSize = 0,
    String? checksum,
    String? ocrText,
    Map<String, dynamic>? extractedData,
  }) {
    return ledgerService.attachReceipt(
      userId: userId,
      deviceId: deviceId,
      transactionId: transactionId,
      filePath: filePath,
      localFilePath: localFilePath,
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      checksum: checksum,
      ocrText: ocrText,
      extractedData: extractedData,
    );
  }

  Future<void> deleteReceipt({
    required String userId,
    required String deviceId,
    required String receiptId,
  }) {
    return ledgerService.deleteReceipt(
      userId: userId,
      deviceId: deviceId,
      receiptId: receiptId,
    );
  }
}

