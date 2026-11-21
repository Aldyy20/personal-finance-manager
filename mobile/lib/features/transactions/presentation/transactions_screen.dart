import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../../receipt_scanner/presentation/receipt_scanner_sheet.dart';
import 'transaction_detail_sheet.dart';
import 'transaction_form_sheet.dart';

class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _selectedType; // null = semua
  bool _showVoided = true;
  bool _onlyWithOcr = false;
  String? _selectedAccountId;
  DateTime? _selectedMonth; // null = semua periode

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _selectedType = null;
      _showVoided = true;
      _onlyWithOcr = false;
      _selectedAccountId = null;
      _selectedMonth = null;
    });
  }

  Future<void> _showMonthPickerSheet() async {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    final monthOptions = [
      for (var i = 0; i < 6; i++)
        DateTime(currentMonth.year, currentMonth.month - i),
    ];

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        final financialColors = Theme.of(ctx).extension<FinancialColors>()!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pilih Periode Bulan',
                  style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Tampilkan seluruh mutasi atau saring berdasarkan bulan tertentu.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  leading: Icon(
                    Icons.all_inclusive_rounded,
                    color: _selectedMonth == null
                        ? financialColors.brandBlueLight
                        : colorScheme.onSurfaceVariant,
                  ),
                  title: const Text('Semua Periode'),
                  trailing: _selectedMonth == null
                      ? Icon(Icons.check_circle_rounded,
                          color: financialColors.brandBlueLight)
                      : null,
                  onTap: () {
                    setState(() => _selectedMonth = null);
                    Navigator.of(ctx).pop();
                  },
                ),
                const Divider(),
                for (final month in monthOptions)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    leading: Icon(
                      Icons.calendar_month_outlined,
                      color: _isSameMonth(_selectedMonth, month)
                          ? financialColors.brandBlueLight
                          : colorScheme.onSurfaceVariant,
                    ),
                    title: Text(_formatFullMonthYearId(month)),
                    trailing: _isSameMonth(_selectedMonth, month)
                        ? Icon(Icons.check_circle_rounded,
                            color: financialColors.brandBlueLight)
                        : null,
                    onTap: () {
                      setState(() => _selectedMonth = month);
                      Navigator.of(ctx).pop();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAdvancedFilterSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        final financialColors = Theme.of(ctx).extension<FinancialColors>()!;

        return StatefulBuilder(
          builder: (ctx, setModalState) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pengaturan Filter Riwayat',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          _resetFilters();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Reset Semua'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  SwitchListTile(
                    value: _showVoided,
                    title: const Text('Sertakan Transaksi Void / Dibatalkan'),
                    subtitle: const Text(
                      'Tampilkan transaksi berstatus voided beserta penanda reversal.',
                    ),
                    onChanged: (val) {
                      setState(() => _showVoided = val);
                      setModalState(() {});
                    },
                  ),
                  SwitchListTile(
                    value: _onlyWithOcr,
                    title: const Text('Hanya Transaksi dengan Nota / OCR'),
                    subtitle: const Text(
                      'Saring mutasi yang memiliki lampiran bukti struk.',
                    ),
                    onChanged: (val) {
                      setState(() => _onlyWithOcr = val);
                      setModalState(() {});
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _showMonthPickerSheet();
                    },
                    icon: Icon(
                      Icons.calendar_month_rounded,
                      color: financialColors.brandBlueLight,
                    ),
                    label: Text(
                      _selectedMonth == null
                          ? 'Periode: Semua Bulan'
                          : 'Periode: ${_formatFullMonthYearId(_selectedMonth!)}',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    style: FilledButton.styleFrom(
                      backgroundColor: financialColors.brandBlueLight,
                      foregroundColor: const Color(0xFFFFFFFF),
                    ),
                    child: Text(
                      'Terapkan Filter',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
    final accounts =
        ref.watch(accountsStreamProvider).valueOrNull ?? const <LocalAccount>[];
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ??
            const <LocalCategory>[];
    final movements =
        ref.watch(transactionMovementsStreamProvider).valueOrNull ??
            const <LocalAccountMovement>[];
    final receipts =
        ref.watch(receiptsStreamProvider).valueOrNull ?? const <LocalReceipt>[];
    final outboxEntries =
        ref.watch(outboxEntriesProvider).valueOrNull ??
            const <SyncOutboxData>[];

    final accountMap = {for (final a in accounts) a.id: a};
    final categoryMap = {for (final c in categories) c.id: c.name};

    final movementsByTxId = <String, List<LocalAccountMovement>>{};
    for (final m in movements) {
      final txId = m.transactionId;
      if (txId == null) continue;
      (movementsByTxId[txId] ??= []).add(m);
    }

    final receiptsByTxId = <String, List<LocalReceipt>>{};
    for (final r in receipts) {
      (receiptsByTxId[r.transactionId] ??= []).add(r);
    }

    final pendingTxIds = outboxEntries
        .where(
          (e) =>
              e.status == 'pending' ||
              e.status == 'failed' ||
              e.status == 'syncing',
        )
        .map((e) => e.entityId)
        .toSet();

    DateTime? startDate;
    DateTime? endDate;
    if (_selectedMonth != null) {
      startDate = DateTime(_selectedMonth!.year, _selectedMonth!.month, 1);
      endDate = DateTime(
        _selectedMonth!.year,
        _selectedMonth!.month + 1,
        0,
        23,
        59,
        59,
        999,
      );
    }

    final activeMonthChipLabel = _formatShortMonthYearId(
      _selectedMonth ?? DateTime.now(),
    );
    final summaryPeriodTitle = _selectedMonth != null
        ? _formatFullMonthYearId(_selectedMonth!).toUpperCase()
        : 'SEMUA PERIODE (${_formatFullMonthYearId(DateTime.now()).toUpperCase()})';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Pencarian Transaksi',
            onPressed: () => _searchFocusNode.requestFocus(),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'Filter Transaksi',
            onPressed: _showAdvancedFilterSheet,
            icon: const Icon(Icons.tune_rounded),
          ),
          IconButton(
            tooltip: 'Scan Struk OCR',
            onPressed: () => ReceiptScannerSheet.showSaveOrAttach(context),
            icon: const Icon(Icons.document_scanner_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF12213A)
                    : const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF1E2F4D)
                      : const Color(0xFFFFFFFF).withValues(alpha: 0.28),
                ),
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: Color(0xFFFFFFFF),
              ),
            ),
          ),
        ],
      ),
      body: session == null
          ? const LoadingStateView()
          : StreamBuilder<List<LocalTransaction>>(
              stream: ref.watch(transactionRepositoryProvider).watchFilteredTransactions(
                    session.userId,
                    type: _selectedType,
                    accountId: _selectedAccountId,
                    status: _showVoided ? null : 'posted',
                    startDate: startDate,
                    endDate: endDate,
                    limit: 200,
                  ),
              builder: (context, snapshot) {
                final rawItems = snapshot.data ?? const <LocalTransaction>[];
                final query = _searchController.text.trim().toLowerCase();

                final items = rawItems.where((tx) {
                  if (_onlyWithOcr &&
                      (receiptsByTxId[tx.id] ?? const []).isEmpty) {
                    return false;
                  }
                  if (query.isEmpty) return true;

                  final desc = (tx.description ?? '').toLowerCase();
                  final notes = (tx.notes ?? '').toLowerCase();
                  final cat = (tx.categoryId != null
                          ? (categoryMap[tx.categoryId!] ?? '')
                          : '')
                      .toLowerCase();
                  final amountRaw = tx.amount.toString();
                  final amountFormatted =
                      CurrencyFormatter.formatIdr(tx.amount).toLowerCase();

                  final txMovements = movementsByTxId[tx.id] ?? const [];
                  final accountNames = txMovements
                      .map((m) => (accountMap[m.accountId]?.name ?? '').toLowerCase())
                      .join(' ');

                  return desc.contains(query) ||
                      notes.contains(query) ||
                      cat.contains(query) ||
                      amountRaw.contains(query) ||
                      amountFormatted.contains(query) ||
                      accountNames.contains(query);
                }).toList();

                return Column(
                  children: [
                    // Top Filter & Search Controls
                    Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.xs,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  focusNode: _searchFocusNode,
                                  onChanged: (_) => setState(() {}),
                                  style: textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: isDark
                                        ? const Color(0xFF0D192E)
                                        : colorScheme.surface,
                                    hintText: 'Cari transaksi, toko, nominal...',
                                    hintStyle: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurfaceVariant
                                          .withValues(alpha: 0.72),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: 10,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      size: 20,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    suffixIcon: _searchController.text.isNotEmpty
                                        ? IconButton(
                                            tooltip: 'Hapus Pencarian',
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.close_rounded,
                                                size: 18),
                                          )
                                        : null,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? const Color(0xFF1E2F4D)
                                            : colorScheme.outlineVariant
                                                .withValues(alpha: 0.45),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                      borderSide: BorderSide(
                                        color: financialColors.brandBlueLight,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Material(
                                color: isDark
                                    ? const Color(0xFF0D192E)
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                child: InkWell(
                                  onTap: _showMonthPickerSheet,
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 42,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _selectedMonth != null
                                            ? financialColors.brandBlueLight
                                            : (isDark
                                                ? const Color(0xFF1E2F4D)
                                                : colorScheme.outlineVariant
                                                    .withValues(alpha: 0.45)),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.calendar_month_rounded,
                                          size: 17,
                                          color: isDark
                                              ? const Color(0xFF38BDF8)
                                              : financialColors.brandBlueLight,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          activeMonthChipLabel,
                                          style: textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: isDark
                                                ? const Color(0xFFFFFFFF)
                                                : financialColors.brandBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(
                                          Icons.expand_more_rounded,
                                          size: 16,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Quick Filter Chips Scrollable
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _StitchFilterPill(
                                  label: 'Semua (${items.length})',
                                  selected: _selectedType == null &&
                                      !_onlyWithOcr &&
                                      _selectedAccountId == null,
                                  onTap: () => setState(() {
                                    _selectedType = null;
                                    _onlyWithOcr = false;
                                    _selectedAccountId = null;
                                  }),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _StitchFilterPill(
                                  label: 'Pengeluaran',
                                  selected: _selectedType == 'expense',
                                  onTap: () => setState(() {
                                    _selectedType =
                                        _selectedType == 'expense'
                                            ? null
                                            : 'expense';
                                  }),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _StitchFilterPill(
                                  label: 'Pemasukan',
                                  selected: _selectedType == 'income',
                                  onTap: () => setState(() {
                                    _selectedType =
                                        _selectedType == 'income'
                                            ? null
                                            : 'income';
                                  }),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _StitchFilterPill(
                                  label: 'Transfer',
                                  selected: _selectedType == 'transfer',
                                  onTap: () => setState(() {
                                    _selectedType =
                                        _selectedType == 'transfer'
                                            ? null
                                            : 'transfer';
                                  }),
                                ),
                                const SizedBox(width: AppSpacing.xs),
                                _StitchFilterPill(
                                  label: 'Ada Nota OCR',
                                  leadingIcon: Icons.document_scanner_outlined,
                                  leadingColor: financialColors.brandGold,
                                  selected: _onlyWithOcr,
                                  onTap: () => setState(
                                    () => _onlyWithOcr = !_onlyWithOcr,
                                  ),
                                ),
                                for (final acc in accounts) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  _StitchFilterPill(
                                    label: acc.name,
                                    selected: _selectedAccountId == acc.id,
                                    onTap: () => setState(() {
                                      _selectedAccountId =
                                          _selectedAccountId == acc.id
                                              ? null
                                              : acc.id;
                                    }),
                                  ),
                                ],
                                const SizedBox(width: AppSpacing.xs),
                                _StitchFilterPill(
                                  label: 'Sertakan Void',
                                  selected: _showVoided,
                                  onTap: () => setState(
                                    () => _showVoided = !_showVoided,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Builder(
                        builder: (context) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting &&
                              !snapshot.hasData) {
                            return const LoadingStateView();
                          }
                          if (snapshot.hasError) {
                            return ErrorStateView(
                              message: snapshot.error.toString(),
                            );
                          }
                          if (items.isEmpty) {
                            final hasActiveFilter = _searchController.text
                                    .trim()
                                    .isNotEmpty ||
                                _selectedType != null ||
                                _selectedAccountId != null ||
                                _onlyWithOcr ||
                                _selectedMonth != null ||
                                !_showVoided;
                            return EmptyStateView(
                              icon: Icons.receipt_long_outlined,
                              title: 'Belum Ada Transaksi Cocok',
                              message: hasActiveFilter
                                  ? 'Tidak ada transaksi yang sesuai filter aktif. Ubah kata kunci atau reset filter.'
                                  : 'Mulai catat pengeluaran, pemasukan, atau transfer antar-rekening Anda.',
                              actionLabel: hasActiveFilter
                                  ? 'Reset Filter'
                                  : 'Tambah Transaksi',
                              onAction: hasActiveFilter
                                  ? _resetFilters
                                  : () => TransactionFormSheet.show(context),
                            );
                          }

                          // Compute summary totals excluding transfers and voided items
                          var filteredIncome = 0;
                          var filteredExpense = 0;
                          for (final tx in items) {
                            if (tx.status != 'posted') continue;
                            if (tx.type == 'income') {
                              filteredIncome += tx.amount;
                            } else if (tx.type == 'expense') {
                              filteredExpense += tx.amount;
                            }
                          }
                          final netCash = filteredIncome - filteredExpense;

                          // Group transactions by local day preserving order
                          final groups = <_TransactionDayGroup>[];
                          for (final tx in items) {
                            final localDate =
                                DateTime.fromMillisecondsSinceEpoch(
                              tx.transactionDateMs,
                              isUtc: true,
                            ).toLocal();
                            final dayKey = DateTime(
                              localDate.year,
                              localDate.month,
                              localDate.day,
                            );
                            if (groups.isEmpty ||
                                groups.last.day != dayKey) {
                              groups.add(
                                _TransactionDayGroup(day: dayKey, items: [tx]),
                              );
                            } else {
                              groups.last.items.add(tx);
                            }
                          }

                          return ListView(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.lg,
                              AppSpacing.xs,
                              AppSpacing.lg,
                              96,
                            ),
                            children: [
                              _MonthlySummaryCard(
                                periodTitle: summaryPeriodTitle,
                                transactionCount: items.length,
                                totalIncome: filteredIncome,
                                totalExpense: filteredExpense,
                                netCash: netCash,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              for (var g = 0; g < groups.length; g++) ...[
                                if (g > 0)
                                  const SizedBox(height: AppSpacing.lg),
                                _DateGroupSection(
                                  group: groups[g],
                                  accountMap: accountMap,
                                  categoryMap: categoryMap,
                                  movementsByTxId: movementsByTxId,
                                  receiptsByTxId: receiptsByTxId,
                                  pendingTxIds: pendingTxIds,
                                  onTapTransaction: (tx) =>
                                      TransactionDetailSheet.show(
                                    context,
                                    tx.id,
                                  ),
                                ),
                              ],

                              const SizedBox(height: AppSpacing.lg),
                              _OfflineSqliteBanner(
                                count: items.length,
                                pendingCount: pendingTxIds.length,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

class _StitchFilterPill extends StatelessWidget {
  const _StitchFilterPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.leadingIcon,
    this.leadingColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final Color? leadingColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final bgColor = selected
        ? financialColors.brandBlueLight
        : (isDark ? const Color(0xFF12213A) : colorScheme.surface);
    final borderColor = selected
        ? financialColors.brandBlueLight
        : (isDark
            ? const Color(0xFF1E2F4D)
            : colorScheme.outlineVariant.withValues(alpha: 0.45));
    final textColor =
        selected ? const Color(0xFFFFFFFF) : colorScheme.onSurfaceVariant;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingIcon != null) ...[
                Icon(
                  leadingIcon,
                  size: 15,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : (leadingColor ?? colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthlySummaryCard extends StatelessWidget {
  const _MonthlySummaryCard({
    required this.periodTitle,
    required this.transactionCount,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCash,
  });

  final String periodTitle;
  final int transactionCount;
  final int totalIncome;
  final int totalExpense;
  final int netCash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final netPrefix = netCash > 0 ? '+' : '';
    final netText = '$netPrefix${CurrencyFormatter.formatIdr(netCash)}';
    final netColor = isDark
        ? (netCash < 0 ? const Color(0xFFF87171) : const Color(0xFF38BDF8))
        : (netCash < 0 ? const Color(0xFFFFDDB5) : const Color(0xFFFFFFFF));

    final cardContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_rounded,
                    size: 16,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : const Color(0xFFDAE2FF),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'RINGKASAN KAS • $periodTitle',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFFDAE2FF),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF19345E)
                          : const Color(0xFFFFFFFF).withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                      border: isDark
                          ? Border.all(color: const Color(0xFF234579))
                          : null,
                    ),
                    child: Text(
                      '$transactionCount Transaksi',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFB6C4FF)
                            : const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF09152B).withValues(alpha: 0.72)
                            : const Color(0xFFFFFFFF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFF1E3256)
                                    .withValues(alpha: 0.75),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_downward_rounded,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFAAC7FD),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Total Masuk',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFFE2E7FF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '+${CurrencyFormatter.formatIdr(totalIncome)}',
                              style: FinancialTypography.amountList(
                                context,
                                color: isDark
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFD6E3FF),
                              ).copyWith(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF09152B).withValues(alpha: 0.72)
                            : const Color(0xFFFFFFFF).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: isDark
                            ? Border.all(
                                color: const Color(0xFF1E3256)
                                    .withValues(alpha: 0.75),
                              )
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 14,
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFFFB956),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Total Keluar',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? const Color(0xFF94A3B8)
                                      : const Color(0xFFE2E7FF),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              '-${CurrencyFormatter.formatIdr(totalExpense)}',
                              style: FinancialTypography.amountList(
                                context,
                                color: isDark
                                    ? const Color(0xFFF87171)
                                    : const Color(0xFFFFDDB5),
                              ).copyWith(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF071326).withValues(alpha: 0.85)
                : const Color(0xFFFFFFFF).withValues(alpha: 0.12),
            border: isDark
                ? const Border(
                    top: BorderSide(color: Color(0xFF1E3A66)),
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Selisih Kas Bersih',
                style: textTheme.labelLarge?.copyWith(
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFFE2E7FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    netText,
                    style: FinancialTypography.tabular(textTheme.titleMedium!)
                        .copyWith(
                      fontWeight: FontWeight.w800,
                      color: netColor,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    netCash >= 0
                        ? Icons.trending_up_rounded
                        : Icons.trending_down_rounded,
                    size: 18,
                    color: netColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    if (isDark) {
      return Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFF0D2040),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF1E3A66)),
          boxShadow: [
            BoxShadow(
              color: financialColors.brandBlueDark.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: cardContent,
      );
    }

    return LivinHeroBanner(
      padding: EdgeInsets.zero,
      borderRadius: 18,
      child: cardContent,
    );
  }
}

class _TransactionDayGroup {
  _TransactionDayGroup({required this.day, required this.items});

  final DateTime day;
  final List<LocalTransaction> items;
}

class _DateGroupSection extends StatelessWidget {
  const _DateGroupSection({
    required this.group,
    required this.accountMap,
    required this.categoryMap,
    required this.movementsByTxId,
    required this.receiptsByTxId,
    required this.pendingTxIds,
    required this.onTapTransaction,
  });

  final _TransactionDayGroup group;
  final Map<String, LocalAccount> accountMap;
  final Map<String, String> categoryMap;
  final Map<String, List<LocalAccountMovement>> movementsByTxId;
  final Map<String, List<LocalReceipt>> receiptsByTxId;
  final Set<String> pendingTxIds;
  final ValueChanged<LocalTransaction> onTapTransaction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final isRecent = group.day == today || group.day == yesterday;

    var dailyNet = 0;
    for (final tx in group.items) {
      if (tx.status != 'posted') continue;
      if (tx.type == 'income') {
        dailyNet += tx.amount;
      } else if (tx.type == 'expense') {
        dailyNet -= tx.amount;
      }
    }

    final dailyNetLabel = dailyNet > 0
        ? 'Total: +${CurrencyFormatter.formatIdr(dailyNet)}'
        : dailyNet < 0
            ? 'Total: ${CurrencyFormatter.formatIdr(dailyNet)}'
            : 'Total: Rp 0';

    final dailyNetColor = dailyNet > 0
        ? financialColors.income
        : dailyNet < 0
            ? financialColors.expense
            : colorScheme.onSurfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecent
                      ? financialColors.brandBlueLight
                      : colorScheme.outlineVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _formatDateGroupHeader(group.day, today, yesterday),
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFFFFFFFF)
                        : financialColors.brandBlue,
                  ),
                ),
              ),
              Text(
                dailyNetLabel,
                style: FinancialTypography.tabular(textTheme.labelMedium!)
                    .copyWith(
                  fontWeight: FontWeight.w700,
                  color: dailyNetColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        for (var i = 0; i < group.items.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.sm),
          _StitchTransactionHistoryCard(
            transaction: group.items[i],
            accountMap: accountMap,
            categoryName: group.items[i].categoryId != null
                ? categoryMap[group.items[i].categoryId!]
                : null,
            movements: movementsByTxId[group.items[i].id] ?? const [],
            receipts: receiptsByTxId[group.items[i].id] ?? const [],
            isPendingSync: pendingTxIds.contains(group.items[i].id),
            onTap: () => onTapTransaction(group.items[i]),
          ),
        ],
      ],
    );
  }
}

class _StitchTransactionHistoryCard extends StatelessWidget {
  const _StitchTransactionHistoryCard({
    required this.transaction,
    required this.accountMap,
    required this.categoryName,
    required this.movements,
    required this.receipts,
    required this.isPendingSync,
    required this.onTap,
  });

  final LocalTransaction transaction;
  final Map<String, LocalAccount> accountMap;
  final String? categoryName;
  final List<LocalAccountMovement> movements;
  final List<LocalReceipt> receipts;
  final bool isPendingSync;
  final VoidCallback onTap;

  String _formatAccountDisplay(LocalAccount? acc) {
    if (acc == null) return 'Rekening';
    final num = acc.accountNumber?.trim();
    if (num != null && num.length >= 4) {
      return '${acc.name} •••• ${num.substring(num.length - 4)}';
    }
    return acc.name;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;
    final isVoided = transaction.status == 'voided';
    final isTransfer = transaction.type == 'transfer';

    // Resolve active movements or fall back to historic movements (for voided)
    final reversedIds =
        movements.map((m) => m.reversalOfId).whereType<String>().toSet();
    final activeMovements = movements
        .where(
          (m) => m.movementType == 'transaction' && !reversedIds.contains(m.id),
        )
        .toList();
    final effectiveMovements =
        activeMovements.isNotEmpty ? activeMovements : movements;

    LocalAccount? sourceAccount;
    LocalAccount? destAccount;
    LocalAccount? singleAccount;
    if (isTransfer) {
      final srcId = effectiveMovements
          .where((m) => m.amountSigned < 0)
          .firstOrNull
          ?.accountId;
      final dstId = effectiveMovements
          .where((m) => m.amountSigned > 0)
          .firstOrNull
          ?.accountId;
      sourceAccount = srcId != null ? accountMap[srcId] : null;
      destAccount = dstId != null ? accountMap[dstId] : null;
    } else {
      final accId = effectiveMovements.firstOrNull?.accountId;
      singleAccount = accId != null ? accountMap[accId] : null;
    }

    final titleText = (transaction.description != null &&
            transaction.description!.trim().isNotEmpty)
        ? transaction.description!.trim()
        : (isTransfer
            ? 'Transfer Antar Rekening'
            : (categoryName ??
                (transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran')));

    final signPrefix = isVoided
        ? ''
        : switch (transaction.type) {
            'income' => '+',
            'expense' => '-',
            _ => '',
          };

    final amountColor = isVoided
        ? colorScheme.onSurfaceVariant
        : switch (transaction.type) {
            'income' => financialColors.income,
            'expense' => isDark ? const Color(0xFFF87171) : colorScheme.onSurface,
            _ => isDark ? const Color(0xFFFFFFFF) : financialColors.brandBlueLight,
          };

    final txDate = DateTime.fromMillisecondsSinceEpoch(
      transaction.transactionDateMs,
      isUtc: true,
    ).toLocal();
    final timeLabel = '${DateFormat('HH:mm').format(txDate)} WIB';

    final (iconData, iconBg, iconFg) = _resolveIconStyle(
      categoryName: categoryName,
      type: transaction.type,
      isVoided: isVoided,
      isDark: isDark,
      colorScheme: colorScheme,
      financialColors: financialColors,
    );

    final hasOcr = receipts.any(
      (r) =>
          (r.ocrText ?? '').trim().isNotEmpty ||
          (r.extractedDataJson ?? '').trim().isNotEmpty,
    );

    final cardContent = Material(
      color: isDark ? const Color(0xFF0D192E) : colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF1E2F4D)
                  : colorScheme.outlineVariant.withValues(alpha: 0.42),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                  border: isDark
                      ? Border.all(color: iconFg.withValues(alpha: 0.28))
                      : null,
                ),
                child: Icon(iconData, color: iconFg, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            titleText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isVoided
                                  ? colorScheme.onSurfaceVariant
                                  : colorScheme.onSurface,
                              decoration:
                                  isVoided ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '$signPrefix${CurrencyFormatter.formatIdr(transaction.amount)}',
                          style: FinancialTypography.amountList(
                            context,
                            color: amountColor,
                          ).copyWith(
                            fontWeight: FontWeight.w800,
                            decoration:
                                isVoided ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    if (isTransfer)
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              sourceAccount?.name ?? 'Rekening Asal',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 13,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              destAccount?.name ?? 'Rekening Tujuan',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${categoryName ?? (transaction.type == 'income' ? 'Pemasukan' : 'Pengeluaran')} • ${_formatAccountDisplay(singleAccount)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (isVoided) ...[
                                _StatusBadgePill(
                                  icon: Icons.block_rounded,
                                  label: 'Voided / Dibatalkan',
                                  bgColor: isDark
                                      ? const Color(0xFF12213A)
                                      : colorScheme.surfaceContainerHigh,
                                  textColor: colorScheme.onSurfaceVariant,
                                  borderColor: isDark
                                      ? const Color(0xFF1E2F4D)
                                      : null,
                                ),
                                _StatusBadgePill(
                                  label: 'Reversal Otomatis Diposting',
                                  bgColor: isDark
                                      ? const Color(0xFF0D192E)
                                      : colorScheme.surfaceContainer,
                                  textColor: colorScheme.onSurfaceVariant,
                                  borderColor: isDark
                                      ? const Color(0xFF1E2F4D)
                                      : null,
                                ),
                              ] else ...[
                                if (isTransfer)
                                  _StatusBadgePill(
                                    icon: Icons.sync_alt_rounded,
                                    label: 'Transfer Antar-Rekening (Net 0)',
                                    bgColor: isDark
                                        ? const Color(0xFF12213A)
                                        : colorScheme.surfaceContainer,
                                    textColor: isDark
                                        ? const Color(0xFFB6C4FF)
                                        : financialColors.brandBlue,
                                    borderColor: isDark
                                        ? const Color(0xFF1E2F4D)
                                        : null,
                                  ),
                                if (receipts.isNotEmpty)
                                  _StatusBadgePill(
                                    icon: hasOcr
                                        ? Icons.document_scanner_outlined
                                        : Icons.image_outlined,
                                    label: hasOcr
                                        ? 'Nota OCR Terverifikasi'
                                        : (receipts.first.fileName ??
                                            'Lampiran Struk'),
                                    bgColor: isDark
                                        ? const Color(0xFF00E3FD)
                                            .withValues(alpha: 0.12)
                                        : colorScheme.surfaceContainer,
                                    textColor: isDark
                                        ? const Color(0xFF00DAF3)
                                        : financialColors.brandBlueLight,
                                    borderColor: isDark
                                        ? const Color(0xFF00E3FD)
                                            .withValues(alpha: 0.25)
                                        : null,
                                  ),
                                _StatusBadgePill(
                                  icon: isPendingSync
                                      ? Icons.cloud_upload_outlined
                                      : Icons.cloud_done_outlined,
                                  label: isPendingSync
                                      ? 'Antrean Sync'
                                      : 'Tersinkron',
                                  bgColor: (isPendingSync
                                          ? financialColors.warning
                                          : financialColors.income)
                                      .withValues(alpha: 0.12),
                                  textColor: isPendingSync
                                      ? financialColors.warning
                                      : financialColors.income,
                                  borderColor: isDark
                                      ? (isPendingSync
                                              ? financialColors.warning
                                              : financialColors.income)
                                          .withValues(alpha: 0.28)
                                      : null,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          timeLabel,
                          style: FinancialTypography.tabular(
                            textTheme.labelSmall!,
                          ).copyWith(
                            fontSize: 11.5,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.78),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (isVoided) {
      return Opacity(opacity: 0.78, child: cardContent);
    }
    return cardContent;
  }

  (IconData, Color, Color) _resolveIconStyle({
    required String? categoryName,
    required String type,
    required bool isVoided,
    required bool isDark,
    required ColorScheme colorScheme,
    required FinancialColors financialColors,
  }) {
    if (isVoided) {
      return (
        Icons.cancel_outlined,
        isDark ? const Color(0xFF12213A) : colorScheme.surfaceContainerHigh,
        colorScheme.onSurfaceVariant,
      );
    }
    if (type == 'transfer') {
      return (
        Icons.swap_horiz_rounded,
        financialColors.transfer.withValues(alpha: isDark ? 0.16 : 0.12),
        isDark ? const Color(0xFFB6C4FF) : financialColors.transfer,
      );
    }
    if (type == 'income') {
      return (
        Icons.payments_rounded,
        financialColors.income.withValues(alpha: isDark ? 0.16 : 0.12),
        financialColors.income,
      );
    }

    final lower = (categoryName ?? '').toLowerCase();
    if (lower.contains('makan') ||
        lower.contains('minum') ||
        lower.contains('kopi') ||
        lower.contains('food')) {
      return (
        Icons.restaurant_rounded,
        const Color(0xFFF59E0B).withValues(alpha: 0.14),
        isDark ? const Color(0xFFFFB95F) : const Color(0xFFC68100),
      );
    }
    if (lower.contains('transport') ||
        lower.contains('bensin') ||
        lower.contains('ojek') ||
        lower.contains('grab') ||
        lower.contains('taxi')) {
      return (
        Icons.directions_car_rounded,
        financialColors.brandBlueLight.withValues(alpha: 0.14),
        isDark ? const Color(0xFF38BDF8) : financialColors.brandBlueLight,
      );
    }
    if (lower.contains('belanja') ||
        lower.contains('mart') ||
        lower.contains('shop')) {
      return (
        Icons.shopping_cart_rounded,
        const Color(0xFFA855F7).withValues(alpha: 0.14),
        isDark ? const Color(0xFFC084FC) : const Color(0xFF7E22CE),
      );
    }
    if (lower.contains('tagihan') ||
        lower.contains('listrik') ||
        lower.contains('internet') ||
        lower.contains('air')) {
      return (
        Icons.receipt_long_rounded,
        financialColors.brandBlueLight.withValues(alpha: 0.14),
        isDark ? const Color(0xFF93C5FD) : financialColors.brandBlue,
      );
    }
    if (lower.contains('kesehatan') ||
        lower.contains('obat') ||
        lower.contains('dokter')) {
      return (
        Icons.medical_services_rounded,
        const Color(0xFF14B8A6).withValues(alpha: 0.14),
        isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0F766E),
      );
    }

    return (
      Icons.shopping_bag_outlined,
      financialColors.expense.withValues(alpha: 0.12),
      financialColors.expense,
    );
  }
}

class _StatusBadgePill extends StatelessWidget {
  const _StatusBadgePill({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.icon,
    this.borderColor,
  });

  final IconData? icon;
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineSqliteBanner extends StatelessWidget {
  const _OfflineSqliteBanner({
    required this.count,
    required this.pendingCount,
  });

  final int count;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D192E) : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: isDark
            ? Border.all(color: const Color(0xFF1E2F4D))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pendingCount > 0
                  ? financialColors.warning
                  : financialColors.income,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                children: [
                  TextSpan(
                    text: 'Database Lokal SQLite Aktif',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  TextSpan(
                    text:
                        ' • $count transaksi tersimpan aman & siap sinkron cloud.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.verified_rounded,
            size: 18,
            color: isDark
                ? const Color(0xFF38BDF8)
                : financialColors.brandBlueLight,
          ),
        ],
      ),
    );
  }
}

bool _isSameMonth(DateTime? a, DateTime b) {
  if (a == null) return false;
  return a.year == b.year && a.month == b.month;
}

String _shortMonthId(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _fullMonthId(int month) {
  const months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  return months[(month - 1).clamp(0, 11)];
}

String _formatShortMonthYearId(DateTime dt) =>
    '${_shortMonthId(dt.month)} ${dt.year}';

String _formatFullMonthYearId(DateTime dt) =>
    '${_fullMonthId(dt.month)} ${dt.year}';

String _formatDateGroupHeader(
  DateTime day,
  DateTime today,
  DateTime yesterday,
) {
  final base = '${day.day} ${_shortMonthId(day.month)} ${day.year}';
  if (day == today) return 'Hari Ini, $base';
  if (day == yesterday) return 'Kemarin, $base';
  return base;
}
