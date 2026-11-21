import '../../../core/database/local_ledger_service.dart';

class ReportRepository {
  ReportRepository({
    required this.ledgerService,
  });

  final LocalLedgerService ledgerService;

  Future<Map<String, dynamic>> getOverview(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ledgerService.getLocalOverview(
      userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}

