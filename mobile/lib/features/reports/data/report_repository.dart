import '../../../core/database/local_ledger_service.dart';
import '../../../core/utils/currency_formatter.dart';

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

  Future<List<Map<String, dynamic>>> getCategoryBreakdown(
    String userId, {
    required String type,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return ledgerService.getLocalCategoryBreakdown(
      userId,
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Future<List<Map<String, dynamic>>> getMonthlyComparison(
    String userId, {
    int months = 6,
  }) {
    return ledgerService.getLocalMonthlyComparison(userId, months: months);
  }

  Future<List<Map<String, dynamic>>> getAccountReport(String userId) {
    return ledgerService.getLocalAccountReport(userId);
  }

  Future<String> generateCsvReport(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final overview = await getOverview(userId, startDate: startDate, endDate: endDate);
    final expenseBreakdown = await getCategoryBreakdown(
      userId,
      type: 'expense',
      startDate: startDate,
      endDate: endDate,
    );
    final incomeBreakdown = await getCategoryBreakdown(
      userId,
      type: 'income',
      startDate: startDate,
      endDate: endDate,
    );
    final accounts = await getAccountReport(userId);

    final buf = StringBuffer()
      ..writeln('Bagian,Nama,Tipe,Jumlah_Transaksi,Nominal_IDR,Persentase')
      ..writeln('Ringkasan,Total Saldo Aktif,balance,-,${overview['total_balance']},100')
      ..writeln('Ringkasan,Total Pemasukan,income,-,${overview['total_income']},-')
      ..writeln('Ringkasan,Total Pengeluaran,expense,-,${overview['total_expense']},-')
      ..writeln('Ringkasan,Arus Kas Bersih,net,-,${overview['net_cash_flow']},-');

    for (final acc in accounts) {
      final escapedName = _csvCell(acc['name'] as String);
      buf.writeln(
        'Rekening,$escapedName,${acc['account_type']},${acc['movement_count']},${acc['balance_cache']},-',
      );
    }

    for (final cat in incomeBreakdown) {
      final escapedName = _csvCell(cat['category_name'] as String);
      buf.writeln(
        'Kategori_Pemasukan,$escapedName,income,${cat['transaction_count']},${cat['total_amount']},${cat['percentage']}',
      );
    }

    for (final cat in expenseBreakdown) {
      final escapedName = _csvCell(cat['category_name'] as String);
      buf.writeln(
        'Kategori_Pengeluaran,$escapedName,expense,${cat['transaction_count']},${cat['total_amount']},${cat['percentage']}',
      );
    }

    return buf.toString();
  }

  Future<String> generatePrintableSummary(
    String userId, {
    required String periodLabel,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final overview = await getOverview(userId, startDate: startDate, endDate: endDate);
    final expenseBreakdown = await getCategoryBreakdown(
      userId,
      type: 'expense',
      startDate: startDate,
      endDate: endDate,
    );
    final accounts = await getAccountReport(userId);

    final buf = StringBuffer()
      ..writeln('=== LAPORAN KEUANGAN PERSONAL FINANCE MANAGER ===')
      ..writeln('Periode: $periodLabel')
      ..writeln('')
      ..writeln('1. RINGKASAN ARUS KAS')
      ..writeln('Total Saldo Aktif : ${CurrencyFormatter.formatIdr(overview['total_balance'] as int)}')
      ..writeln('Total Pemasukan   : ${CurrencyFormatter.formatIdr(overview['total_income'] as int)}')
      ..writeln('Total Pengeluaran : ${CurrencyFormatter.formatIdr(overview['total_expense'] as int)}')
      ..writeln('Arus Kas Bersih   : ${CurrencyFormatter.formatIdr(overview['net_cash_flow'] as int)}')
      ..writeln('')
      ..writeln('2. SALDO REKENING TERKONSOLIDASI');

    for (final acc in accounts) {
      final status = (acc['is_active'] as bool) ? 'Aktif' : 'Arsip';
      buf.writeln(
        '- ${acc['name']} (${acc['account_type']}, $status): ${CurrencyFormatter.formatIdr(acc['balance_cache'] as int)}',
      );
    }

    buf
      ..writeln('')
      ..writeln('3. RINCIAN PENGELUARAN PER KATEGORI');
    if (expenseBreakdown.isEmpty) {
      buf.writeln('- Belum ada pengeluaran pada periode ini.');
    } else {
      for (final cat in expenseBreakdown) {
        buf.writeln(
          '- ${cat['category_name']}: ${CurrencyFormatter.formatIdr(cat['total_amount'] as int)} (${cat['percentage']}%)',
        );
      }
    }

    return buf.toString();
  }

  String _csvCell(String raw) {
    if (raw.contains(',') || raw.contains('"') || raw.contains('\n')) {
      return '"${raw.replaceAll('"', '""')}"';
    }
    return raw;
  }
}

