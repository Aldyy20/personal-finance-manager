import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                      content: Text('Gunakan tombol Salin pada perangkat/lingkungan pengujian.'),
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final session = ref.watch(activeSessionProvider).valueOrNull;
    // Rebuild reports automatically when transactions or accounts change locally or synced
    ref.watch(transactionsStreamProvider);
    ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Keuangan'),
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
                if (!snapshot.hasData && snapshot.connectionState == ConnectionState.waiting) {
                  return const LoadingStateView(message: 'Menyusun laporan analitik lokal...');
                }
                if (snapshot.hasError) {
                  return ErrorStateView(message: snapshot.error.toString());
                }

                final data = snapshot.data!;
                final overview = data.overview;
                final totalIncome = (overview['total_income'] as num?)?.toInt() ?? 0;
                final totalExpense = (overview['total_expense'] as num?)?.toInt() ?? 0;
                final netFlow = (overview['net_cash_flow'] as num?)?.toInt() ?? 0;
                final totalBalance = (overview['total_balance'] as num?)?.toInt() ?? 0;

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    96,
                  ),
                  children: [
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
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ringkasan Arus Kas • ${_period.label}',
                              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Transfer antar rekening & transaksi voided dikecualikan dari total.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Pemasukan',
                                    amount: totalIncome,
                                    prefix: '+',
                                    color: financialColors.income,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Pengeluaran',
                                    amount: totalExpense,
                                    prefix: '-',
                                    color: financialColors.expense,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Arus Kas Bersih',
                                    amount: netFlow,
                                    prefix: netFlow > 0 ? '+' : '',
                                    color: netFlow >= 0
                                        ? financialColors.income
                                        : financialColors.expense,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Saldo Aktif Saat Ini',
                                    amount: totalBalance,
                                    prefix: '',
                                    color: financialColors.balance,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _exportReport(isCsv: true),
                                    icon: const Icon(Icons.table_view_outlined),
                                    label: const Text('Ekspor CSV'),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _exportReport(isCsv: false),
                                    icon: const Icon(Icons.picture_as_pdf_outlined),
                                    label: const Text('Cetak / PDF'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const SectionHeader(
                      title: 'Perbandingan Bulanan (6 Bulan)',
                      subtitle: 'Grafik Pemasukan vs Pengeluaran',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: _MonthlyComparisonChart(
                          months: data.monthly,
                          incomeColor: financialColors.income,
                          expenseColor: financialColors.expense,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
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
                      onSelectionChanged: (sel) => setState(() => _breakdownType = sel.first),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (data.breakdown.isEmpty)
                      const Card(
                        child: EmptyStateView(
                          icon: Icons.bar_chart_outlined,
                          title: 'Belum Ada Data Kategori',
                          message: 'Belum ada transaksi posted pada periode dan jenis ini.',
                        ),
                      )
                    else
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            children: [
                              for (var i = 0; i < data.breakdown.length; i++) ...[
                                if (i > 0) const SizedBox(height: AppSpacing.md),
                                Builder(
                                  builder: (context) {
                                    final item = data.breakdown[i];
                                    final pct = (item['percentage'] as num).toDouble();
                                    final amt = (item['total_amount'] as num).toInt();
                                    final count = (item['transaction_count'] as num).toInt();
                                    final color = _breakdownType == 'income'
                                        ? financialColors.income
                                        : financialColors.expense;
                                    return Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item['category_name']} ($count transaksi)',
                                                style: textTheme.bodyMedium?.copyWith(
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${CurrencyFormatter.formatIdr(amt)} (${pct.toStringAsFixed(1)}%)',
                                              style: FinancialTypography.tabular(
                                                textTheme.bodySmall!,
                                              ).copyWith(
                                                color: color,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        LinearProgressIndicator(
                                          value: (pct / 100).clamp(0.0, 1.0),
                                          color: color,
                                          backgroundColor: colorScheme.surfaceContainerHighest,
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(AppRadius.sm),
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
                                    style: FinancialTypography.tabular(textTheme.bodySmall!),
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.amount,
    required this.prefix,
    required this.color,
  });

  final String label;
  final int amount;
  final String prefix;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '$prefix${CurrencyFormatter.formatIdr(amount)}',
            style: FinancialTypography.amountList(context, color: color),
          ),
        ],
      ),
    );
  }
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
            Icon(Icons.square_rounded, size: 12, color: incomeColor),
            const SizedBox(width: AppSpacing.xs),
            Text('Pemasukan', style: textTheme.labelMedium),
            const SizedBox(width: AppSpacing.lg),
            Icon(Icons.square_rounded, size: 12, color: expenseColor),
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ),
    );
  }
}

