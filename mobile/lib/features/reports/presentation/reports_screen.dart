import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../app/providers.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';

enum ReportPeriod {
  thisMonth('Bulan Ini'),
  threeMonths('3 Bulan'),
  thisYear('Tahun Ini'),
  allTime('Semua');

  const ReportPeriod(this.label);
  final String label;
}

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.thisMonth;
  String _breakdownType = 'expense';

  static const _donutPalette = [
    Color(0xFF0054CC),
    Color(0xFF00C087),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFFF43F5E),
    Color(0xFF06B6D4),
  ];

  ({DateTime start, DateTime end}) _resolveRange() {
    final now = DateTime.now().toUtc();
    final endOfThisMonth = DateTime.utc(now.year, now.month + 1, 0, 23, 59, 59, 999);
    return switch (_period) {
      ReportPeriod.thisMonth => (
          start: DateTime.utc(now.year, now.month, 1),
          end: endOfThisMonth,
        ),
      ReportPeriod.threeMonths => (
          start: DateTime.utc(now.year, now.month - 2, 1),
          end: endOfThisMonth,
        ),
      ReportPeriod.thisYear => (
          start: DateTime.utc(now.year, 1, 1),
          end: DateTime.utc(now.year, 12, 31, 23, 59, 59, 999),
        ),
      ReportPeriod.allTime => (
          start: DateTime.utc(2000, 1, 1),
          end: DateTime.utc(2100, 12, 31, 23, 59, 59, 999),
        ),
    };
  }

  Future<({
    Map<String, dynamic> overview,
    List<Map<String, dynamic>> breakdown,
    List<Map<String, dynamic>> monthly,
    List<Map<String, dynamic>> accounts,
  })> _loadReportData(String userId) async {
    final repo = ref.read(reportRepositoryProvider);
    final range = _resolveRange();

    final overview = await repo.getOverview(
      userId,
      startDate: range.start,
      endDate: range.end,
    );
    final breakdown = await repo.getCategoryBreakdown(
      userId,
      type: _breakdownType,
      startDate: range.start,
      endDate: range.end,
    );
    final monthly = await repo.getMonthlyComparison(userId, months: 6);
    final accounts = await repo.getAccountReport(userId);

    return (
      overview: overview,
      breakdown: breakdown,
      monthly: monthly,
      accounts: accounts,
    );
  }

  Future<void> _exportReport({required bool isCsv}) async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final repo = ref.read(reportRepositoryProvider);
    final range = _resolveRange();
    final content = isCsv
        ? await repo.generateCsvReport(
            session.userId,
            startDate: range.start,
            endDate: range.end,
          )
        : await repo.generatePrintableSummary(
            session.userId,
            periodLabel: _period.label,
            startDate: range.start,
            endDate: range.end,
          );

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isCsv ? 'Ekspor CSV (Excel)' : 'Ringkasan Laporan (Cetak / PDF)'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(
              content,
              style: FinancialTypography.tabular(Theme.of(ctx).textTheme.bodySmall!),
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: content));
              if (ctx.mounted) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('Isi laporan disalin ke clipboard.')),
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Salin'),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              try {
                final dir = await getApplicationDocumentsDirectory();
                final ext = isCsv ? 'csv' : 'txt';
                final fileName =
                    'laporan_keuangan_${DateTime.now().millisecondsSinceEpoch}.$ext';
                final file = File(p.join(dir.path, fileName));
                await file.writeAsString(content);
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Tersimpan ke ${file.path}')),
                  );
                }
              } catch (_) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Gunakan tombol Salin pada perangkat/lingkungan pengujian.',
                      ),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.save_alt),
            label: Text(isCsv ? 'Simpan CSV' : 'Simpan Dokumen'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final session = ref.watch(activeSessionProvider).valueOrNull;
    ref.watch(transactionsStreamProvider);
    ref.watch(accountsStreamProvider);

    final now = DateTime.now();
    final selectedPeriodLabel = _period == ReportPeriod.allTime
        ? 'Semua Periode'
        : (_period == ReportPeriod.thisYear
            ? 'Tahun ${now.year}'
            : DateFormat('MMMM yyyy').format(now));

    return Scaffold(
      appBar: AppBar(
        title: const StitchAppBarTitle(title: 'Laporan Keuangan'),
        actions: [
          IconButton(
            tooltip: 'Ekspor CSV (Excel)',
            onPressed: () => _exportReport(isCsv: true),
            icon: const Icon(Icons.table_view_outlined),
          ),
          IconButton(
            tooltip: 'Ringkasan Cetak / PDF',
            onPressed: () => _exportReport(isCsv: false),
            icon: const Icon(Icons.picture_as_pdf_outlined),
          ),
        ],
      ),
      body: session == null
          ? const LoadingStateView()
          : FutureBuilder(
              future: _loadReportData(session.userId),
              builder: (context, snapshot) {
                if (!snapshot.hasData &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingStateView(
                    message: 'Menyusun laporan analitik lokal...',
                  );
                }
                if (snapshot.hasError) {
                  return ErrorStateView(message: snapshot.error.toString());
                }

                final data = snapshot.data!;
                final overview = data.overview;
                final totalIncome = (overview['total_income'] as num?)?.toInt() ?? 0;
                final totalExpense = (overview['total_expense'] as num?)?.toInt() ?? 0;
                final netFlow = (overview['net_cash_flow'] as num?)?.toInt() ?? 0;

                Map<String, dynamic>? peakMonth;
                for (final m in data.monthly) {
                  final mIncome = (m['income'] as num).toInt();
                  if (peakMonth == null || mIncome > (peakMonth['income'] as num).toInt()) {
                    peakMonth = m;
                  }
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    96,
                  ),
                  children: [
                    // 1. Periode Terpilih Pill Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.event_rounded,
                                size: 20,
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : financialColors.transfer,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Periode Terpilih',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  Text(
                                    '$selectedPeriodLabel • ${_period.label}',
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final pItem in ReportPeriod.values) ...[
                            ChoiceChip(
                              label: Text(pItem.label),
                              selected: _period == pItem,
                              onSelected: (_) => setState(() => _period = pItem),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. Hero Card: Arus Kas Bersih (Net)
                    LivinHeroBanner(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 18,
                                    color: Color(0xFF93C5FD),
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Arus Kas Bersih (Net)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF93C5FD),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: netFlow >= 0
                                      ? const Color(0xFF10B981).withValues(alpha: 0.22)
                                      : const Color(0xFFEF4444).withValues(alpha: 0.24),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  netFlow >= 0 ? 'Surplus Sehat' : 'Defisit Kas',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: netFlow >= 0
                                        ? const Color(0xFF6EE7B7)
                                        : const Color(0xFFFCA5A5),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '${netFlow > 0 ? '+' : ''}${CurrencyFormatter.formatIdr(netFlow)}',
                            style: FinancialTypography.heroBalance(context).copyWith(
                              color: const Color(0xFFFFFFFF),
                              fontSize: 27,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            netFlow >= 0
                                ? 'Saldo akumulatif lebih tinggi dari pengeluaran periode ini'
                                : 'Pengeluaran lebih besar dari pemasukan periode ini',
                            style: textTheme.bodySmall?.copyWith(
                              color: const Color(0xFFAAC7FD),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              Expanded(
                                child: _HeroMetricTile(
                                  label: 'Pemasukan',
                                  amount: totalIncome,
                                  prefix: '+',
                                  accentColor: const Color(0xFF6EE7B7),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: _HeroMetricTile(
                                  label: 'Pengeluaran',
                                  amount: totalExpense,
                                  prefix: '-',
                                  accentColor: financialColors.brandGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                size: 14,
                                color: Color(0xFF7490C3),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Transfer antar rekening sendiri tidak dihitung sebagai pemasukan atau pengeluaran.',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF93C5FD),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 3. Perbandingan Bulanan (6 Bulan) Chart + Summary Box
                    const SectionHeader(
                      title: 'Perbandingan Bulanan (6 Bulan)',
                      subtitle: 'Komparasi Pemasukan vs Pengeluaran',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            _MonthlyComparisonChart(
                              months: data.monthly,
                              incomeColor: isDark
                                  ? const Color(0xFF38BDF8)
                                  : const Color(0xFF0054CC),
                              expenseColor: const Color(0xFFF97316),
                            ),
                            if (peakMonth != null &&
                                (peakMonth['income'] as num).toInt() > 0) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.trending_up_rounded,
                                      size: 18,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : financialColors.transfer,
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Expanded(
                                      child: Text(
                                        'Pemasukan tertinggi pada ${peakMonth['month_label']}',
                                        style: textTheme.bodySmall,
                                      ),
                                    ),
                                    Text(
                                      CurrencyFormatter.formatIdr(
                                        (peakMonth['income'] as num).toInt(),
                                      ),
                                      style: FinancialTypography.tabular(
                                        textTheme.labelMedium!,
                                      ).copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? const Color(0xFF38BDF8)
                                            : financialColors.transfer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 4. Insight Mandiri Pintar Box
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [const Color(0xFF102347), const Color(0xFF0E1B33)]
                              : [
                                  colorScheme.surfaceContainer,
                                  colorScheme.surfaceContainerLow,
                                ],
                        ),
                        border: isDark
                            ? Border.all(color: const Color(0xFF1E3A70))
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : financialColors.transfer,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 17,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INSIGHT MANDIRI PINTAR',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isDark
                                        ? const Color(0xFF38BDF8)
                                        : financialColors.transfer,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  totalIncome > 0
                                      ? 'Rasio tabungan bersih periode ini sebesar ${((netFlow / totalIncome) * 100).toStringAsFixed(1)}% dari total pemasukan Anda.'
                                      : 'Catat pemasukan dan pengeluaran rutin untuk melihat rasio penghematan otomatis.',
                                  style: textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 5. Analisis Kategori + Stitch Donut Chart
                    SectionHeader(
                      title: 'Analisis Kategori',
                      subtitle: _breakdownType == 'expense'
                          ? 'Distribusi Pengeluaran'
                          : 'Distribusi Pemasukan',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                        ButtonSegment(value: 'income', label: Text('Pemasukan')),
                      ],
                      selected: {_breakdownType},
                      onSelectionChanged: (sel) =>
                          setState(() => _breakdownType = sel.first),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (data.breakdown.isEmpty)
                      const Card(
                        child: EmptyStateView(
                          icon: Icons.bar_chart_outlined,
                          title: 'Belum Ada Data Kategori',
                          message:
                              'Belum ada transaksi posted pada periode dan jenis ini.',
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              // Stitch Interactive Donut Chart + Top Legend
                              _CategoryDonutSection(
                                items: data.breakdown,
                                palette: _donutPalette,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              const Divider(),
                              const SizedBox(height: AppSpacing.md),
                              for (var i = 0; i < data.breakdown.length; i++) ...[
                                if (i > 0) const SizedBox(height: AppSpacing.md),
                                Builder(
                                  builder: (context) {
                                    final item = data.breakdown[i];
                                    final pct = (item['percentage'] as num).toDouble();
                                    final amt = (item['total_amount'] as num).toInt();
                                    final count =
                                        (item['transaction_count'] as num).toInt();
                                    final sliceColor =
                                        _donutPalette[i % _donutPalette.length];
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['category_name']} ($count transaksi)',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${CurrencyFormatter.formatIdr(amt)} (${pct.toStringAsFixed(1)}%)',
                                              style: FinancialTypography.tabular(
                                                textTheme.bodySmall!,
                                              ).copyWith(
                                                color: sliceColor,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        LinearProgressIndicator(
                                          value: (pct / 100).clamp(0.0, 1.0),
                                          color: sliceColor,
                                          backgroundColor:
                                              colorScheme.surfaceContainerHigh,
                                          minHeight: 7,
                                          borderRadius:
                                              BorderRadius.circular(AppRadius.sm),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // 6. Unduh & Ekspor Laporan Card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Unduh & Ekspor Laporan',
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Dapatkan rekap mutasi resmi format standar perbankan',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed: () => _exportReport(isCsv: false),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF93000A)
                                              .withValues(alpha: 0.45)
                                          : const Color(0xFFFFDAD6),
                                      foregroundColor: isDark
                                          ? const Color(0xFFFCA5A5)
                                          : financialColors.expense,
                                    ),
                                    icon: const Icon(Icons.picture_as_pdf_outlined),
                                    label: const Text('Unduh PDF'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: FilledButton.tonalIcon(
                                    onPressed: () => _exportReport(isCsv: true),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF064E3B)
                                              .withValues(alpha: 0.55)
                                          : const Color(0xFFECFDF5),
                                      foregroundColor: isDark
                                          ? const Color(0xFF6EE7B7)
                                          : const Color(0xFF065F46),
                                    ),
                                    icon: const Icon(Icons.table_view_outlined),
                                    label: const Text('Ekspor CSV (.xlsx)'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // 7. Laporan Saldo Rekening
                    const SectionHeader(
                      title: 'Laporan Saldo Rekening',
                      subtitle: 'Rekonsiliasi Opening Balance & Saldo Terkini',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < data.accounts.length; i++) ...[
                            if (i > 0) const Divider(),
                            Builder(
                              builder: (context) {
                                final acc = data.accounts[i];
                                final balance = (acc['balance_cache'] as num).toInt();
                                final opening = (acc['opening_balance'] as num).toInt();
                                return ListTile(
                                  leading: Icon(
                                    accountTypeIcon(acc['account_type'] as String),
                                    color: colorScheme.primary,
                                  ),
                                  title: Text(acc['name'] as String),
                                  subtitle: Text(
                                    'Awal ${CurrencyFormatter.formatIdr(opening)} • ${acc['movement_count']} mutasi',
                                    style: FinancialTypography.tabular(
                                      textTheme.bodySmall!,
                                    ),
                                  ),
                                  trailing: Text(
                                    CurrencyFormatter.formatIdr(balance),
                                    style: FinancialTypography.amountList(
                                      context,
                                      color: balance < 0
                                          ? financialColors.expense
                                          : colorScheme.onSurface,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _HeroMetricTile extends StatelessWidget {
  const _HeroMetricTile({
    required this.label,
    required this.amount,
    required this.prefix,
    required this.accentColor,
  });

  final String label;
  final int amount;
  final String prefix;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              color: const Color(0xFFDBEAFE),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$prefix${CurrencyFormatter.formatIdr(amount)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FinancialTypography.amountList(context, color: accentColor)
                .copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CategoryDonutSection extends StatelessWidget {
  const _CategoryDonutSection({
    required this.items,
    required this.palette,
  });

  final List<Map<String, dynamic>> items;
  final List<Color> palette;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final top = items.first;
    final topPct = (top['percentage'] as num).toDouble();
    final topName = top['category_name'] as String;

    return Row(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(132, 132),
                painter: _DonutChartPainter(
                  slices: [
                    for (var i = 0; i < items.length; i++)
                      (
                        pct: (items[i]['percentage'] as num).toDouble(),
                        color: palette[i % palette.length],
                      ),
                  ],
                  trackColor: colorScheme.surfaceContainer,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Terbesar',
                    style: textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${topPct.toStringAsFixed(0)}%',
                    style: FinancialTypography.tabular(
                      textTheme.titleMedium!,
                    ).copyWith(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(
                    width: 66,
                    child: Text(
                      topName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: palette.first,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < math.min(4, items.length); i++) ...[
                if (i > 0) const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: palette[i % palette.length],
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        items[i]['category_name'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${(items[i]['percentage'] as num).toDouble().toStringAsFixed(0)}%',
                      style: FinancialTypography.tabular(
                        textTheme.labelSmall!,
                      ).copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({
    required this.slices,
    required this.trackColor,
  });

  final List<({double pct, Color color})> slices;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 10;
    const strokeWidth = 15.0;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    var startAngle = -math.pi / 2;
    for (final slice in slices) {
      if (slice.pct <= 0) continue;
      final sweep = (slice.pct / 100.0) * 2 * math.pi;
      final paint = Paint()
        ..color = slice.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(rect, startAngle, sweep, false, paint);
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) => true;
}

class _MonthlyComparisonChart extends StatelessWidget {
  const _MonthlyComparisonChart({
    required this.months,
    required this.incomeColor,
    required this.expenseColor,
  });

  final List<Map<String, dynamic>> months;
  final Color incomeColor;
  final Color expenseColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    var maxValue = 1;
    for (final m in months) {
      maxValue = math.max(maxValue, (m['income'] as num).toInt());
      maxValue = math.max(maxValue, (m['expense'] as num).toInt());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: incomeColor),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('Pemasukan', style: textTheme.labelMedium),
            const SizedBox(width: AppSpacing.lg),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(shape: BoxShape.circle, color: expenseColor),
            ),
            const SizedBox(width: AppSpacing.xs),
            Text('Pengeluaran', style: textTheme.labelMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 168,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final m in months) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _ChartBar(
                                  ratio: (m['income'] as num).toDouble() / maxValue,
                                  color: incomeColor,
                                  tooltip:
                                      '${m['month_label']} Masuk: ${CurrencyFormatter.formatIdr((m['income'] as num).toInt())}',
                                ),
                                const SizedBox(width: 4),
                                _ChartBar(
                                  ratio: (m['expense'] as num).toDouble() / maxValue,
                                  color: expenseColor,
                                  tooltip:
                                      '${m['month_label']} Keluar: ${CurrencyFormatter.formatIdr((m['expense'] as num).toInt())}',
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          m['short_label'] as String,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ChartBar extends StatelessWidget {
  const _ChartBar({
    required this.ratio,
    required this.color,
    required this.tooltip,
  });

  final double ratio;
  final Color color;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final safeRatio = ratio.clamp(0.0, 1.0);
    final barHeight = safeRatio == 0 ? 4.0 : math.max(8.0, 128.0 * safeRatio);

    return Tooltip(
      message: tooltip,
      child: Container(
        width: 12,
        height: barHeight,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
        ),
      ),
    );
  }
}
