import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';

class BudgetsScreen extends ConsumerStatefulWidget {
  const BudgetsScreen({super.key});

  @override
  ConsumerState<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends ConsumerState<BudgetsScreen> {
  int _selectedBudgetIndex = 0;
  String _categoryFilter = 'all'; // 'all', 'warning', 'safe'

  void _showNotificationsModal(
    BuildContext context, {
    required LocalBudget budget,
    required List<Map<String, dynamic>> warningItems,
    required String budgetStatus,
    required double budgetPct,
  }) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        final financialColors = Theme.of(ctx).extension<FinancialColors>()!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: financialColors.warning,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Notifikasi Pagu Anggaran',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (budgetStatus == 'normal' && warningItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: financialColors.income.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      'Seluruh pos anggaran "${budget.name}" masih aman di bawah ambang peringatan ${budget.warningPercent}%.',
                      style: textTheme.bodyMedium,
                    ),
                  )
                else ...[
                  if (budgetStatus != 'normal')
                    ListTile(
                      leading: Icon(
                        Icons.warning_amber_rounded,
                        color: budgetStatus == 'exceeded'
                            ? financialColors.expense
                            : financialColors.warning,
                      ),
                      title: Text(budget.name),
                      subtitle: Text(
                        'Pemakaian keseluruhan mencapai ${budgetPct.toStringAsFixed(1)}% (batas peringatan ${budget.warningPercent}%).',
                      ),
                    ),
                  for (final cat in warningItems)
                    ListTile(
                      leading: Icon(
                        Icons.priority_high_rounded,
                        color: cat['status'] == 'exceeded'
                            ? financialColors.expense
                            : financialColors.warning,
                      ),
                      title: Text(
                        'Pos ${(cat['percentage'] as num).toStringAsFixed(1)}% Terpakai',
                      ),
                      subtitle: Text(
                        'Sisa: ${CurrencyFormatter.formatIdr((cat['remaining'] as num).toInt())} dari ${CurrencyFormatter.formatIdr((cat['amount_limit'] as num).toInt())}',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showBudgetHistorySheet(
    BuildContext context, {
    required List<LocalBudget> allBudgets,
    required List<Map<String, dynamic>> activeSummaries,
  }) async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        final colorScheme = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        final financialColors = Theme.of(ctx).extension<FinancialColors>()!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      color: financialColors.brandBlueLight,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Riwayat & Draf Anggaran (${allBudgets.length})',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                if (allBudgets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Text('Belum ada riwayat anggaran tersimpan.'),
                  )
                else
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 400),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: allBudgets.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final b = allBudgets[i];
                        final activeIdx = activeSummaries.indexWhere(
                          (s) => (s['budget'] as LocalBudget).id == b.id,
                        );
                        final isSelected =
                            activeIdx >= 0 && activeIdx == _selectedBudgetIndex;

                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? financialColors.brandBlueLight
                                    .withValues(alpha: 0.1)
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? financialColors.brandBlueLight
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: activeIdx >= 0
                                      ? () {
                                          setState(() {
                                            _selectedBudgetIndex = activeIdx;
                                          });
                                          Navigator.of(ctx).pop();
                                        }
                                      : null,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Wrap(
                                        spacing: 6,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        children: [
                                          Text(
                                            b.name,
                                            style: textTheme.titleSmall
                                                ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 7,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: b.isActive
                                                  ? financialColors.income
                                                      .withValues(alpha: 0.14)
                                                  : financialColors.warning
                                                      .withValues(alpha: 0.16),
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              b.isActive ? 'Aktif' : 'Draf / Arsip',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: b.isActive
                                                    ? financialColors.income
                                                    : financialColors.warning,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${b.startDate} s/d ${b.endDate} • ${b.periodType == 'monthly' ? 'Bulanan' : 'Kustom'}',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!b.isActive)
                                TextButton(
                                  onPressed: () async {
                                    await ref
                                        .read(budgetRepositoryProvider)
                                        .restoreBudget(
                                          session.userId,
                                          session.deviceId,
                                          b.id,
                                        );
                                    ref.invalidate(budgetSummariesProvider);
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                  },
                                  child: const Text('Aktifkan'),
                                )
                              else
                                IconButton(
                                  tooltip: 'Arsipkan',
                                  onPressed: () async {
                                    await ref
                                        .read(budgetRepositoryProvider)
                                        .archiveBudget(
                                          session.userId,
                                          session.deviceId,
                                          b.id,
                                        );
                                    ref.invalidate(budgetSummariesProvider);
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                  },
                                  icon: Icon(
                                    Icons.archive_outlined,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
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

    final summariesAsync = ref.watch(budgetSummariesProvider);
    final allBudgets =
        ref.watch(budgetsStreamProvider).valueOrNull ?? const <LocalBudget>[];
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ??
            const <LocalCategory>[];
    final pendingOutboxCount =
        ref.watch(pendingOutboxCountProvider).valueOrNull ?? 0;
    final categoryMap = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran Bulanan'),
        actions: [
          summariesAsync.whenOrNull(
                data: (summaries) {
                  if (summaries.isEmpty) return const SizedBox.shrink();
                  final safeIdx =
                      _selectedBudgetIndex.clamp(0, summaries.length - 1);
                  final active = summaries[safeIdx];
                  final budget = active['budget'] as LocalBudget;
                  final status = active['status'] as String;
                  final pct = (active['percentage'] as num).toDouble();
                  final cats = (active['categories'] as List<dynamic>)
                      .cast<Map<String, dynamic>>();
                  final warningCats = cats
                      .where(
                        (c) =>
                            c['status'] == 'warning' ||
                            c['status'] == 'exceeded',
                      )
                      .toList();
                  final hasAlert =
                      status != 'normal' || warningCats.isNotEmpty;

                  return IconButton(
                    tooltip: 'Notifikasi Anggaran',
                    onPressed: () => _showNotificationsModal(
                      context,
                      budget: budget,
                      warningItems: warningCats,
                      budgetStatus: status,
                      budgetPct: pct,
                    ),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.notifications_outlined),
                        if (hasAlert)
                          Positioned(
                            right: -1,
                            top: -1,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: financialColors.brandGold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ) ??
              const SizedBox.shrink(),
          TextButton.icon(
            onPressed: () => BudgetFormSheet.show(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppSpacing.minTouchTarget,
                AppSpacing.minTouchTarget,
              ),
              foregroundColor: financialColors.brandGold,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Buat',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                border: Border.all(
                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.28),
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
      body: summariesAsync.when(
        loading: () =>
            const LoadingStateView(message: 'Menghitung realisasi anggaran...'),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (summaries) {
          if (summaries.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: EmptyStateView(
                    icon: Icons.pie_chart_outline_rounded,
                    title: 'Belum Ada Anggaran',
                    message:
                        'Buat anggaran bulanan dan alokasikan batas kategori pengeluaran agar arus kas terkontrol.',
                    actionLabel: 'Buat Anggaran',
                    onAction: () => BudgetFormSheet.show(context),
                  ),
                ),
                if (allBudgets.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: OutlinedButton.icon(
                      onPressed: () => _showBudgetHistorySheet(
                        context,
                        allBudgets: allBudgets,
                        activeSummaries: summaries,
                      ),
                      icon: const Icon(Icons.history_rounded),
                      label: Text('Lihat Draf / Arsip (${allBudgets.length})'),
                    ),
                  ),
                ],
              ],
            );
          }

          final activeIndex =
              _selectedBudgetIndex.clamp(0, summaries.length - 1);
          final item = summaries[activeIndex];
          final budget = item['budget'] as LocalBudget;
          final limit = (item['total_limit'] as num).toInt();
          final used = (item['total_used'] as num).toInt();
          final remaining = (item['total_remaining'] as num).toInt();
          final pct = (item['percentage'] as num).toDouble();
          final status = item['status'] as String;
          final daysRemaining = (item['days_remaining'] as num?)?.toInt() ?? 0;
          final dailyAvg =
              (item['daily_average_spent'] as num?)?.toInt() ?? 0;
          final dailySafe =
              (item['daily_safe_remaining'] as num?)?.toInt() ?? 0;
          final projectedSurplus =
              (item['projected_surplus'] as num?)?.toInt() ?? 0;
          final catItems = (item['categories'] as List<dynamic>)
              .cast<Map<String, dynamic>>();

          final warningItems = catItems
              .where(
                (c) => c['status'] == 'warning' || c['status'] == 'exceeded',
              )
              .toList();
          final safeItems =
              catItems.where((c) => c['status'] == 'normal').toList();

          final filteredCatItems = switch (_categoryFilter) {
            'warning' => warningItems,
            'safe' => safeItems,
            _ => catItems,
          };

          final topAlertCategory = warningItems.isNotEmpty
              ? (List<Map<String, dynamic>>.from(warningItems)
                    ..sort(
                      (a, b) => (b['percentage'] as num)
                          .compareTo(a['percentage'] as num),
                    ))
                  .first
              : null;

          final periodLabel = _formatBudgetPeriodLabel(budget);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            children: [
              // 1. Month Selector & Sub-action Bar
              Row(
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF161F34)
                            : colorScheme.surface,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF1E335A)
                              : colorScheme.outlineVariant
                                  .withValues(alpha: 0.7),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          InkWell(
                            onTap: activeIndex > 0
                                ? () => setState(
                                      () => _selectedBudgetIndex =
                                          activeIndex - 1,
                                    )
                                : null,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.chevron_left_rounded,
                                size: 18,
                                color: activeIndex > 0
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : financialColors.brandBlueLight,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              periodLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: activeIndex < summaries.length - 1
                                ? () => setState(
                                      () => _selectedBudgetIndex =
                                          activeIndex + 1,
                                    )
                                : null,
                            borderRadius: BorderRadius.circular(999),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                Icons.chevron_right_rounded,
                                size: 18,
                                color: activeIndex < summaries.length - 1
                                    ? colorScheme.onSurface
                                    : colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.35),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Material(
                    color: isDark
                        ? const Color(0xFF161F34)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    child: InkWell(
                      onTap: () => _showBudgetHistorySheet(
                        context,
                        allBudgets: allBudgets,
                        activeSummaries: summaries,
                      ),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E335A)
                                : colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 15,
                              color: isDark
                                  ? const Color(0xFF93C5FD)
                                  : financialColors.brandBlueLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Riwayat',
                              style: textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Material(
                    color: isDark
                        ? const Color(0xFF161F34)
                        : colorScheme.surface,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => BudgetFormSheet.show(
                        context,
                        existingBudget: budget,
                        existingCategories: catItems,
                      ),
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF1E335A)
                                : colorScheme.outlineVariant
                                    .withValues(alpha: 0.7),
                          ),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          size: 17,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // 2. Hero Budget Card
              _HeroBudgetSummaryCard(
                budget: budget,
                limit: limit,
                used: used,
                remaining: remaining,
                pct: pct,
                status: status,
                daysRemaining: daysRemaining,
                dailyAverageSpent: dailyAvg,
                dailySafeRemaining: dailySafe,
              ),

              // 3. Warning Threshold Alert Banner
              if (warningItems.isNotEmpty || status != 'normal') ...[
                const SizedBox(height: AppSpacing.md),
                _WarningThresholdBanner(
                  warningPercent: budget.warningPercent,
                  warningCount: warningItems.length,
                  topAlertCategoryName: topAlertCategory != null
                      ? (categoryMap[topAlertCategory['category_id'] as String] ??
                          'Kategori')
                      : budget.name,
                  topAlertPct: topAlertCategory != null
                      ? (topAlertCategory['percentage'] as num).toDouble()
                      : pct,
                  topAlertRemaining: topAlertCategory != null
                      ? (topAlertCategory['remaining'] as num).toInt()
                      : remaining,
                ),
              ],
              const SizedBox(height: AppSpacing.lg),

              // 4. Category Filter Header & Pills
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Alokasi Beban Biaya',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${catItems.length} Pos Aktif',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _BudgetFilterChip(
                      label: 'Semua Kategori',
                      count: catItems.length,
                      selected: _categoryFilter == 'all',
                      onTap: () => setState(() => _categoryFilter = 'all'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _BudgetFilterChip(
                      label: 'Mendekati Batas',
                      count: warningItems.length,
                      dotColor: financialColors.warning,
                      selected: _categoryFilter == 'warning',
                      onTap: () => setState(() => _categoryFilter = 'warning'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    _BudgetFilterChip(
                      label: 'Aman',
                      count: safeItems.length,
                      dotColor: financialColors.income,
                      selected: _categoryFilter == 'safe',
                      onTap: () => setState(() => _categoryFilter = 'safe'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 5. Category Budget Cards
              if (catItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161F34)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E335A)
                          : colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.pie_chart_outline_rounded,
                        color: financialColors.brandBlueLight,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(
                          'Menggunakan batas total keseluruhan (${CurrencyFormatter.formatIdr(limit)}). Ketuk Kelola Alokasi untuk memecah kuota per kategori.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (filteredCatItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF161F34)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E335A)
                          : colorScheme.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    'Tidak ada kategori pada filter ini.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Column(
                  children: [
                    for (var i = 0; i < filteredCatItems.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      _StitchBudgetCategoryCard(
                        categoryName: categoryMap[
                                filteredCatItems[i]['category_id'] as String] ??
                            'Kategori',
                        limit: (filteredCatItems[i]['amount_limit'] as num)
                            .toInt(),
                        used: (filteredCatItems[i]['used'] as num).toInt(),
                        remaining:
                            (filteredCatItems[i]['remaining'] as num).toInt(),
                        pct: (filteredCatItems[i]['percentage'] as num)
                            .toDouble(),
                        status: filteredCatItems[i]['status'] as String,
                      ),
                    ],
                  ],
                ),

              const SizedBox(height: AppSpacing.md),

              // 6. Smart Insights Card (Estimasi Surplus Akhir Bulan)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF121B2F)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF1E335A)
                        : colorScheme.outlineVariant.withValues(alpha: 0.7),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: financialColors.brandBlueLight
                            .withValues(alpha: 0.14),
                      ),
                      child: Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 19,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : financialColors.brandBlueLight,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estimasi Surplus Akhir Bulan',
                            style: textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            projectedSurplus > 0
                                ? 'Potensi tabungan sisa sekitar ${CurrencyFormatter.formatIdr(projectedSurplus)}'
                                : 'Perlu pengendalian belanja agar tidak melewati pagu.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 7. SQLite Sync Status Pill
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF040E21)
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E335A)
                          : colorScheme.outlineVariant.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: pendingOutboxCount > 0
                              ? financialColors.warning
                              : (isDark
                                  ? const Color(0xFF38BDF8)
                                  : financialColors.income),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          'Tersinkronisasi otomatis dengan SQLite lokal',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        Icons.done_all_rounded,
                        size: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // 8. Primary Bottom CTA Row (Kelola Alokasi + Anggaran Baru)
              Row(
                children: [
                  Expanded(
                    flex: 7,
                    child: FilledButton.icon(
                      onPressed: () => BudgetFormSheet.show(
                        context,
                        existingBudget: budget,
                        existingCategories: catItems,
                      ),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: isDark
                            ? const Color(0xFF1E60FF)
                            : financialColors.brandBlueLight,
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          size: 19),
                      label: const Text(
                        'Kelola Alokasi',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 5,
                    child: OutlinedButton.icon(
                      onPressed: () => BudgetFormSheet.show(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text(
                        'Buat Baru',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeroBudgetSummaryCard extends StatelessWidget {
  const _HeroBudgetSummaryCard({
    required this.budget,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.pct,
    required this.status,
    required this.daysRemaining,
    required this.dailyAverageSpent,
    required this.dailySafeRemaining,
  });

  final LocalBudget budget;
  final int limit;
  final int used;
  final int remaining;
  final double pct;
  final String status;
  final int daysRemaining;
  final int dailyAverageSpent;
  final int dailySafeRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final statusColor = switch (status) {
      'exceeded' => financialColors.expense,
      'warning' => financialColors.warning,
      _ => isDark ? const Color(0xFF38BDF8) : financialColors.income,
    };

    final statusHeadline = switch (status) {
      'exceeded' => 'MELEBIHI PLAFON ANGGARAN',
      'warning' => 'MENDEKATI BATAS ${budget.warningPercent}%',
      _ => 'PENGELUARAN TERKENDALI',
    };

    final remainingFormatted = NumberFormat('#,##0', 'id_ID').format(remaining);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? null : const Color(0xFFFFFFFF),
        gradient: isDark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF202A3F),
                  Color(0xFF161F34),
                  Color(0xFF121B2F),
                ],
              )
            : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2B3D63)
              : colorScheme.outlineVariant.withValues(alpha: 0.75),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark
                    ? const Color(0xFF040E21)
                    : financialColors.brandBlue)
                .withValues(alpha: isDark ? 0.55 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  statusHeadline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelMedium?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF040E21).withValues(alpha: 0.8)
                      : colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: financialColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Sisa $daysRemaining hari lagi',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Balances Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sisa Anggaran',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            'Rp',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFFB6C4FF)
                                  : financialColors.brandBlueLight,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            remainingFormatted,
                            style: FinancialTypography.heroBalance(context)
                                .copyWith(
                              fontSize: 27,
                              color: remaining < 0
                                  ? financialColors.expense
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total Plafon',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        CurrencyFormatter.formatIdr(limit),
                        style: FinancialTypography.tabular(
                          textTheme.titleMedium!,
                        ).copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Progress Bar + Percentage (retaining exact e.g. '3.5%' format for tests)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Terpakai: ${CurrencyFormatter.formatIdr(used)}',
                style: FinancialTypography.tabular(textTheme.bodySmall!)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${pct.toStringAsFixed(1)}%',
                style: FinancialTypography.tabular(textTheme.labelLarge!)
                    .copyWith(
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 10,
              color: statusColor,
              backgroundColor: isDark
                  ? const Color(0xFF040E21)
                  : colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Pacing Insights Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF040E21).withValues(alpha: 0.7)
                        : colorScheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF1E335A)
                          : colorScheme.outlineVariant.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: financialColors.brandBlueLight
                              .withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : financialColors.brandBlueLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rata-rata/Hari',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10.5,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.formatIdr(dailyAverageSpent),
                                style: FinancialTypography.tabular(
                                  textTheme.labelMedium!,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF00E3FD).withValues(alpha: 0.08)
                        : financialColors.income.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isDark
                              ? const Color(0xFF00E3FD)
                              : financialColors.income)
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (isDark
                                  ? const Color(0xFF00E3FD)
                                  : financialColors.income)
                              .withValues(alpha: 0.18),
                        ),
                        child: Icon(
                          Icons.savings_outlined,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : financialColors.income,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plafon Sisa/Hari',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelSmall?.copyWith(
                                color: isDark
                                    ? const Color(0xFF38BDF8)
                                    : financialColors.income,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.5,
                              ),
                            ),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.formatIdr(dailySafeRemaining),
                                style: FinancialTypography.tabular(
                                  textTheme.labelMedium!,
                                ).copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
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
    );
  }
}

class _WarningThresholdBanner extends StatelessWidget {
  const _WarningThresholdBanner({
    required this.warningPercent,
    required this.warningCount,
    required this.topAlertCategoryName,
    required this.topAlertPct,
    required this.topAlertRemaining,
  });

  final int warningPercent;
  final int warningCount;
  final String topAlertCategoryName;
  final double topAlertPct;
  final int topAlertRemaining;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF9C6200).withValues(alpha: 0.25)
            : const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? const Color(0xFFFFB95F).withValues(alpha: 0.45)
              : const Color(0xFFFDE68A),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: financialColors.warning.withValues(alpha: 0.18),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 20,
              color: financialColors.warning,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'PERHATIAN BATAS $warningPercent%',
                        style: textTheme.labelMedium?.copyWith(
                          color: isDark
                              ? const Color(0xFFFFB95F)
                              : const Color(0xFF78350F),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: financialColors.warning.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        warningCount > 0
                            ? '$warningCount Kategori'
                            : 'Pagu Utama',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFFFDDB8)
                              : const Color(0xFF78350F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Pos $topAlertCategoryName sudah mencapai ${topAlertPct.toStringAsFixed(1)}% dari alokasi periode. Sisa pagu tinggal ${CurrencyFormatter.formatIdr(topAlertRemaining)}.',
                  style: textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? const Color(0xFFE2E8F0)
                        : const Color(0xFF78350F),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetFilterChip extends StatelessWidget {
  const _BudgetFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final bgColor = selected
        ? (isDark ? const Color(0xFF1E60FF) : financialColors.brandBlue)
        : (isDark ? const Color(0xFF161F34) : colorScheme.surface);
    final borderColor = selected
        ? (isDark ? const Color(0xFF1E60FF) : financialColors.brandBlue)
        : (isDark
            ? const Color(0xFF1E335A)
            : colorScheme.outlineVariant.withValues(alpha: 0.7));

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null && !selected) ...[
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0xFFFFFFFF).withValues(alpha: 0.22)
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: selected
                        ? const Color(0xFFFFFFFF)
                        : colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StitchBudgetCategoryCard extends StatelessWidget {
  const _StitchBudgetCategoryCard({
    required this.categoryName,
    required this.limit,
    required this.used,
    required this.remaining,
    required this.pct,
    required this.status,
  });

  final String categoryName;
  final int limit;
  final int used;
  final int remaining;
  final double pct;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final isExceeded = status == 'exceeded';
    final isWarning = status == 'warning';
    final accentColor = isExceeded
        ? financialColors.expense
        : (isWarning
            ? financialColors.warning
            : (isDark
                ? const Color(0xFF38BDF8)
                : financialColors.brandBlueLight));

    final statusCaption = isExceeded
        ? 'Melebihi Batas'
        : (isWarning
            ? 'Mendekati Batas'
            : (pct < 45 ? 'Sangat Hemat' : (pct < 70 ? 'Stabil' : 'Aman')));

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F34) : colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isExceeded || isWarning)
              ? accentColor.withValues(alpha: 0.55)
              : (isDark
                  ? const Color(0xFF1E335A)
                  : colorScheme.outlineVariant.withValues(alpha: 0.75)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _budgetCategoryIcon(categoryName),
                  size: 20,
                  color: accentColor,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            categoryName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isExceeded || isWarning) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.priority_high_rounded,
                            size: 16,
                            color: accentColor,
                          ),
                        ],
                      ],
                    ),
                    Text(
                      'Pagu: ${CurrencyFormatter.formatIdr(limit)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${pct.toStringAsFixed(1)}%',
                      style: FinancialTypography.tabular(textTheme.labelSmall!)
                          .copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Sisa ${CurrencyFormatter.formatIdr(remaining)}',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: (pct / 100).clamp(0.0, 1.0),
              minHeight: 7,
              color: accentColor,
              backgroundColor: isDark
                  ? const Color(0xFF040E21)
                  : colorScheme.surfaceContainerHighest,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                CurrencyFormatter.formatIdr(used),
                style: FinancialTypography.tabular(textTheme.labelMedium!)
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                statusCaption,
                style: textTheme.labelSmall?.copyWith(
                  color: accentColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BudgetFormSheet extends ConsumerStatefulWidget {
  const BudgetFormSheet({
    super.key,
    this.existingBudget,
    this.existingCategories = const [],
  });

  final LocalBudget? existingBudget;
  final List<Map<String, dynamic>> existingCategories;

  static Future<bool?> show(
    BuildContext context, {
    LocalBudget? existingBudget,
    List<Map<String, dynamic>> existingCategories = const [],
  }) {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: BudgetFormSheet(
          existingBudget: existingBudget,
          existingCategories: existingCategories,
        ),
      ),
    );
  }

  @override
  ConsumerState<BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends ConsumerState<BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _totalLimitController;
  late final TextEditingController _warningPercentController;
  late String _periodType;
  late String _startDate;
  late String _endDate;
  bool _smartNotifEnabled = true;
  bool _showCategorySelector = false;
  final Map<String, TextEditingController> _categoryLimitControllers = {};
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0);

    final b = widget.existingBudget;
    _periodType = b?.periodType ?? 'monthly';
    _nameController = TextEditingController(
      text: b?.name ?? 'Anggaran ${_monthLabel(now)} ${now.year}',
    );
    _totalLimitController = TextEditingController(
      text: b?.totalLimit != null ? b!.totalLimit.toString() : '',
    );
    _warningPercentController = TextEditingController(
      text: (b?.warningPercent ?? 80).toString(),
    );
    _startDate = b?.startDate ?? monthStart.toIso8601String().substring(0, 10);
    _endDate = b?.endDate ?? monthEnd.toIso8601String().substring(0, 10);

    for (final cat in widget.existingCategories) {
      final catId = cat['category_id'] as String;
      final limit = (cat['amount_limit'] as num).toInt();
      _categoryLimitControllers[catId] =
          TextEditingController(text: limit.toString());
    }
  }

  static String _monthLabel(DateTime dt) {
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
    return months[dt.month - 1];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _totalLimitController.dispose();
    _warningPercentController.dispose();
    for (final c in _categoryLimitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  int get _parsedTotalLimit {
    return int.tryParse(
          _totalLimitController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        ) ??
        0;
  }

  int get _parsedWarningPercent {
    return (int.tryParse(_warningPercentController.text.trim()) ?? 80)
        .clamp(1, 100);
  }

  int get _allocatedTotal {
    var sum = 0;
    for (final c in _categoryLimitControllers.values) {
      sum += int.tryParse(c.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }
    return sum;
  }

  void _addTotalLimitDelta(int delta) {
    final next = _parsedTotalLimit + delta;
    setState(() {
      _totalLimitController.text = next.toString();
    });
  }

  void _copyFromPreviousBudget(List<Map<String, dynamic>> summaries) {
    final previous = summaries.firstWhere(
      (s) => (s['budget'] as LocalBudget).id != widget.existingBudget?.id,
      orElse: () => const {},
    );
    if (previous.isEmpty) {
      setState(() {
        _totalLimitController.text = '10000000';
      });
      return;
    }

    final prevBudget = previous['budget'] as LocalBudget;
    final prevCats = (previous['categories'] as List<dynamic>)
        .cast<Map<String, dynamic>>();
    setState(() {
      _totalLimitController.text =
          (prevBudget.totalLimit ?? (previous['total_limit'] as num).toInt())
              .toString();
      _warningPercentController.text = prevBudget.warningPercent.toString();
      for (final c in _categoryLimitControllers.values) {
        c.dispose();
      }
      _categoryLimitControllers.clear();
      for (final item in prevCats) {
        final catId = item['category_id'] as String;
        final amt = (item['amount_limit'] as num).toInt();
        _categoryLimitControllers[catId] =
            TextEditingController(text: amt.toString());
      }
    });
  }

  Future<void> _submit({required bool saveAsActive}) async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final allocations = <({String categoryId, int amountLimit})>[];
    for (final entry in _categoryLimitControllers.entries) {
      final parsed = int.tryParse(
        entry.value.text.replaceAll(RegExp(r'[^0-9]'), ''),
      );
      if (parsed == null || parsed <= 0) {
        setState(
          () => _errorMessage = 'Semua nominal alokasi kategori harus > 0.',
        );
        return;
      }
      allocations.add((categoryId: entry.key, amountLimit: parsed));
    }

    final totalLimitText =
        _totalLimitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final totalLimit =
        totalLimitText.isEmpty ? null : int.tryParse(totalLimitText);
    if (totalLimit == null && allocations.isEmpty) {
      setState(
        () => _errorMessage =
            'Isi Batas Total Anggaran atau pilih minimal satu alokasi kategori.',
      );
      return;
    }

    final warningPercent = _parsedWarningPercent;

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(budgetRepositoryProvider);
      if (widget.existingBudget == null) {
        await repo.createBudget(
          userId: session.userId,
          deviceId: session.deviceId,
          name: _nameController.text.trim(),
          periodType: _periodType,
          startDate: _startDate,
          endDate: _endDate,
          totalLimit: totalLimit,
          warningPercent: warningPercent,
          isActive: saveAsActive,
          categories: allocations,
        );
      } else {
        await repo.updateBudget(
          userId: session.userId,
          deviceId: session.deviceId,
          budgetId: widget.existingBudget!.id,
          name: _nameController.text.trim(),
          periodType: _periodType,
          startDate: _startDate,
          endDate: _endDate,
          totalLimit: totalLimit,
          clearTotalLimit: totalLimit == null,
          warningPercent: warningPercent,
          isActive: saveAsActive,
          categories: allocations,
        );
      }

      ref.invalidate(budgetSummariesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !saveAsActive
                ? 'Anggaran disimpan sebagai draf.'
                : (widget.existingBudget == null
                    ? 'Anggaran berhasil dibuat & diaktifkan.'
                    : 'Anggaran berhasil diperbarui.'),
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ??
            const <LocalCategory>[];
    final existingSummaries =
        ref.watch(budgetSummariesProvider).valueOrNull ?? const [];
    final expenseCategories = categories
        .where((c) => c.type == 'expense' && c.isActive)
        .toList();

    final startDt = DateTime.tryParse(_startDate) ?? DateTime.now();
    final endDt = DateTime.tryParse(_endDate) ?? DateTime.now();
    final dayCount = math.max(1, endDt.difference(startDt).inDays + 1);

    final hasCap = _parsedTotalLimit > 0;
    final hasAlloc = _categoryLimitControllers.isNotEmpty;
    final stepTwoReady = hasCap || hasAlloc;

    final allocated = _allocatedTotal;
    final capDenominator = hasCap ? _parsedTotalLimit : allocated;
    final unallocated = capDenominator - allocated;
    final unallocatedPct = capDenominator > 0
        ? ((unallocated / capDenominator) * 100).round()
        : 0;

    final cardBg =
        isDark ? const Color(0xFF121B2F) : colorScheme.surface;
    final innerBg =
        isDark ? const Color(0xFF161F34) : colorScheme.surfaceContainerLow;
    final borderColor = isDark
        ? const Color(0xFF2B3D63)
        : colorScheme.outlineVariant.withValues(alpha: 0.7);

    const tierColors = [
      Color(0xFF2563EB),
      Color(0xFF06B6D4),
      Color(0xFFF59E0B),
      Color(0xFF6366F1),
      Color(0xFF10B981),
    ];

    final maxHeight = math.max(
      280.0,
      MediaQuery.sizeOf(context).height -
          MediaQuery.viewInsetsOf(context).bottom -
          24,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),

            // Top App Modal Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existingBudget == null
                        ? 'Buat Anggaran Baru'
                        : 'Edit Anggaran Bulanan',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Progress Stepper Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isDark
                                  ? const Color(0xFF00E3FD)
                                  : financialColors.brandBlueLight,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stepTwoReady
                                ? 'LANGKAH 2 DARI 2'
                                : 'LANGKAH 1 DARI 2',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? const Color(0xFF38BDF8)
                                  : financialColors.brandBlueLight,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        stepTwoReady ? '100% Siap' : '50% Selesai',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Pengaturan Periode & Pagu Total',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: stepTwoReady ? 1.0 : 0.5,
                      minHeight: 7,
                      color: financialColors.brandBlueLight,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 15,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : financialColors.brandBlueLight,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Data tersimpan otomatis secara privat di perangkat Anda.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Seksi 1: Identitas & Periode Anggaran
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 19,
                            color: financialColors.brandBlueLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Identitas & Periode Anggaran',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: financialColors.warning.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Wajib',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: financialColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Anggaran',
                      prefixIcon: Icon(Icons.edit_note_rounded),
                    ),
                    validator: (val) => (val == null || val.trim().isEmpty)
                        ? 'Nama anggaran wajib diisi.'
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Tipe Siklus Anggaran',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: innerBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CycleTabButton(
                            title: 'Bulanan',
                            subtitle: 'Rekomendasi',
                            selected: _periodType == 'monthly',
                            onTap: () {
                              final now = DateTime.now();
                              setState(() {
                                _periodType = 'monthly';
                                if (widget.existingBudget == null) {
                                  _startDate = DateTime(now.year, now.month, 1)
                                      .toIso8601String()
                                      .substring(0, 10);
                                  _endDate =
                                      DateTime(now.year, now.month + 1, 0)
                                          .toIso8601String()
                                          .substring(0, 10);
                                }
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: _CycleTabButton(
                            title: 'Kustom / Mingguan',
                            subtitle: 'Fleksibel',
                            selected: _periodType != 'monthly',
                            onTap: () => setState(() => _periodType = 'custom'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: innerBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: financialColors.brandBlueLight
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.date_range_rounded,
                            size: 20,
                            color: financialColors.brandBlueLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rentang Kalender Aktif',
                                style: textTheme.labelSmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                '${_formatShortDateId(startDt)} - ${_formatShortDateId(endDt)}',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: financialColors.warning.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13,
                                color: financialColors.warning,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$dayCount Hari',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: financialColors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final initial =
                                DateTime.tryParse(_startDate) ?? DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && mounted) {
                              setState(
                                () => _startDate =
                                    picked.toIso8601String().substring(0, 10),
                              );
                            }
                          },
                          icon: const Icon(Icons.calendar_today_outlined,
                              size: 16),
                          label: Text(
                            'Mulai: $_startDate',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final initial =
                                DateTime.tryParse(_endDate) ?? DateTime.now();
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: initial,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null && mounted) {
                              setState(
                                () => _endDate =
                                    picked.toIso8601String().substring(0, 10),
                              );
                            }
                          },
                          icon: const Icon(Icons.event_outlined, size: 16),
                          label: Text(
                            'Selesai: $_endDate',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Seksi 2: Batas Keseluruhan (Total Pagu)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 19,
                            color: financialColors.brandBlueLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Batas Keseluruhan (Total Pagu)',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: financialColors.brandBlueLight
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'IDR',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF00E3FD)
                                : financialColors.brandBlueLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: innerBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'MAKSIMAL PENGELUARAN GABUNGAN',
                          style: textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _totalLimitController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          style: FinancialTypography.heroBalance(context)
                              .copyWith(fontSize: 22),
                          decoration: const InputDecoration(
                            labelText: 'Batas Total (Rp, Opsional)',
                            prefixText: 'Rp ',
                            hintText: 'Contoh: 5000000',
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Kosongkan jika batas total mengikuti jumlah pagu kategori.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Penyesuaian Cepat',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        label: const Text('+1 Jt'),
                        onPressed: () => _addTotalLimitDelta(1000000),
                      ),
                      ActionChip(
                        label: const Text('+2.5 Jt'),
                        onPressed: () => _addTotalLimitDelta(2500000),
                      ),
                      ActionChip(
                        label: const Text('+5 Jt'),
                        onPressed: () => _addTotalLimitDelta(5000000),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.history_rounded, size: 16),
                        label: const Text('Salin Bulan Lalu'),
                        onPressed: () =>
                            _copyFromPreviousBudget(existingSummaries),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Seksi 3: Alokasi Pagu Kategori (PRD 5.9)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_rounded,
                            size: 19,
                            color: financialColors.brandBlueLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Alokasi Pagu Kategori',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: innerBg,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          'PRD 5.9 Rule',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Multi-tier Allocation Tracker
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: innerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Dialokasikan:',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                '${CurrencyFormatter.formatIdr(allocated)} / ${CurrencyFormatter.formatIdr(capDenominator)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: FinancialTypography.tabular(
                                  textTheme.labelLarge!,
                                ).copyWith(fontWeight: FontWeight.w800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 10,
                            color: isDark
                                ? const Color(0xFF040E21)
                                : colorScheme.surfaceContainerHighest,
                            child: capDenominator > 0 &&
                                    _categoryLimitControllers.isNotEmpty
                                ? Row(
                                    children: [
                                      for (var idx = 0;
                                          idx <
                                              _categoryLimitControllers.length;
                                          idx++)
                                        Builder(
                                          builder: (_) {
                                            final ctrl =
                                                _categoryLimitControllers.values
                                                    .elementAt(idx);
                                            final val = int.tryParse(
                                                  ctrl.text.replaceAll(
                                                    RegExp(r'[^0-9]'),
                                                    '',
                                                  ),
                                                ) ??
                                                0;
                                            if (val <= 0) {
                                              return const SizedBox.shrink();
                                            }
                                            final flex =
                                                math.max(1, val ~/ 1000);
                                            return Expanded(
                                              flex: flex,
                                              child: Container(
                                                color: tierColors[
                                                    idx % tierColors.length],
                                              ),
                                            );
                                          },
                                        ),
                                      if (unallocated > 0)
                                        Expanded(
                                          flex: math.max(1, unallocated ~/ 1000),
                                          child: const SizedBox.shrink(),
                                        ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: unallocated < 0
                                        ? financialColors.expense
                                        : financialColors.brandBlueLight,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Sisa Belum Dialokasikan:',
                                  style: textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              unallocated >= 0
                                  ? '${CurrencyFormatter.formatIdr(unallocated)} ($unallocatedPct%)'
                                  : 'Defisit ${CurrencyFormatter.formatIdr(unallocated.abs())}',
                              style: FinancialTypography.tabular(
                                textTheme.labelSmall!,
                              ).copyWith(
                                fontWeight: FontWeight.w800,
                                color: unallocated < 0
                                    ? financialColors.expense
                                    : financialColors.brandBlueLight,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Active Category Sliders
                  for (var idx = 0;
                      idx < _categoryLimitControllers.length;
                      idx++) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Builder(
                      builder: (context) {
                        final entry = _categoryLimitControllers.entries
                            .elementAt(idx);
                        final catName = expenseCategories
                                .where((c) => c.id == entry.key)
                                .firstOrNull
                                ?.name ??
                            'Kategori';
                        final currentVal = int.tryParse(
                              entry.value.text
                                  .replaceAll(RegExp(r'[^0-9]'), ''),
                            ) ??
                            0;
                        final sliderMax = math.max(
                          hasCap ? _parsedTotalLimit : 10000000,
                          math.max(currentVal, 1000000),
                        );
                        final sharePct = capDenominator > 0
                            ? (currentVal / capDenominator) * 100.0
                            : 0.0;
                        final tierColor = tierColors[idx % tierColors.length];

                        return Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: innerBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      color: tierColor.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _budgetCategoryIcon(catName),
                                      size: 18,
                                      color: tierColor,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          catName,
                                          style: textTheme.labelLarge?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          '${sharePct.toStringAsFixed(0)}% Pagu',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: tierColor,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Hapus kategori',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () {
                                      setState(() {
                                        _categoryLimitControllers
                                            .remove(entry.key)
                                            ?.dispose();
                                      });
                                    },
                                    icon: const Icon(Icons.close_rounded,
                                        size: 18),
                                  ),
                                ],
                              ),
                              Slider(
                                value: currentVal
                                    .toDouble()
                                    .clamp(0.0, sliderMax.toDouble()),
                                min: 0,
                                max: sliderMax.toDouble(),
                                divisions: math.max(1, sliderMax ~/ 100000),
                                activeColor: tierColor,
                                onChanged: (val) {
                                  final rounded = (val / 100000).round() * 100000;
                                  setState(() {
                                    entry.value.text =
                                        math.max(100000, rounded).toString();
                                  });
                                },
                              ),
                              TextFormField(
                                controller: entry.value,
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                style: FinancialTypography.tabular(
                                  textTheme.bodyLarge!,
                                ),
                                decoration: InputDecoration(
                                  labelText: 'Batas Kategori: $catName',
                                  prefixText: 'Rp ',
                                ),
                                validator: (val) {
                                  final v = int.tryParse(
                                    (val ?? '')
                                        .replaceAll(RegExp(r'[^0-9]'), ''),
                                  );
                                  if (v == null || v <= 0) return 'Harus > 0';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: AppSpacing.sm),

                  OutlinedButton.icon(
                    onPressed: () => setState(
                      () => _showCategorySelector = !_showCategorySelector,
                    ),
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 18),
                    label: Text(
                      _showCategorySelector
                          ? 'Sembunyikan Pilihan Kategori'
                          : 'Tambah Kategori Pengeluaran Lainnya',
                    ),
                  ),
                  if (_showCategorySelector ||
                      _categoryLimitControllers.isEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        for (final cat in expenseCategories)
                          FilterChip(
                            label: Text(cat.name),
                            selected:
                                _categoryLimitControllers.containsKey(cat.id),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _categoryLimitControllers[cat.id] =
                                      TextEditingController(text: '500000');
                                } else {
                                  _categoryLimitControllers
                                      .remove(cat.id)
                                      ?.dispose();
                                }
                              });
                            },
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Seksi 4: Parameter Peringatan Ambang Batas (PRD 5.9)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.crisis_alert_rounded,
                            size: 19,
                            color: financialColors.warning,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Parameter Peringatan Ambang Batas',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'PRD 5.9',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: innerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Peringatan Mendekati Batas',
                                    style: textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    'Batas aman konsumsi dompet',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: financialColors.brandBlueLight
                                    .withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '$_parsedWarningPercent%',
                                style: FinancialTypography.tabular(
                                  textTheme.labelLarge!,
                                ).copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: financialColors.brandBlueLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value:
                              _parsedWarningPercent.toDouble().clamp(50.0, 95.0),
                          min: 50,
                          max: 95,
                          divisions: 9,
                          activeColor: financialColors.brandBlueLight,
                          onChanged: (v) {
                            setState(() {
                              _warningPercentController.text =
                                  v.round().toString();
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '50% (Ketat)',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '80% (Standar PRD)',
                              style: textTheme.labelSmall?.copyWith(
                                color: financialColors.brandBlueLight,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '95% (Longgar)',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _warningPercentController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Alert (%)',
                            suffixText: '%',
                          ),
                          validator: (val) {
                            final p = int.tryParse(val ?? '');
                            if (p == null || p < 1 || p > 100) return '1-100';
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: innerBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: financialColors.brandBlueLight
                                .withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.notifications_active_outlined,
                            size: 18,
                            color: financialColors.brandBlueLight,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kirim notifikasi pintar saat $_parsedWarningPercent%',
                                style: textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Termasuk alarm 100% saat pagu terlampaui',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _smartNotifEnabled,
                          onChanged: (v) =>
                              setState(() => _smartNotifEnabled = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Text(
                  _errorMessage!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),

            // Fixed Bottom Action Bar (1:1 Google Stitch Footer)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: cardBg,
                border: Border(top: BorderSide(color: borderColor)),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: OutlinedButton.icon(
                            onPressed: _saving
                                ? null
                                : () => _submit(saveAsActive: false),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: const Icon(Icons.drafts_outlined, size: 18),
                            label: const Text(
                              'Draf',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          flex: 8,
                          child: FilledButton.icon(
                            onPressed: _saving
                                ? null
                                : () => _submit(saveAsActive: true),
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              backgroundColor: financialColors.brandBlueLight,
                              foregroundColor: const Color(0xFFFFFFFF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            icon: _saving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFFFFFFFF),
                                    ),
                                  )
                                : const Icon(Icons.check_circle_outline_rounded),
                            label: const Text(
                              'Simpan Anggaran',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 14,
                          color: financialColors.brandBlueLight,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'Pencatatan transaksi otomatis terhubung ke kuota ini via SQLite lokal.',
                            textAlign: TextAlign.center,
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CycleTabButton extends StatelessWidget {
  const _CycleTabButton({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final financialColors = theme.extension<FinancialColors>()!;

    return Material(
      color: selected ? financialColors.brandBlueLight : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          child: Column(
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.5,
                  color: selected
                      ? const Color(0xFFDBEAFE)
                      : colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _budgetCategoryIcon(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('makan') ||
      lower.contains('minum') ||
      lower.contains('kopi') ||
      lower.contains('food')) {
    return Icons.restaurant_rounded;
  }
  if (lower.contains('transport') ||
      lower.contains('bensin') ||
      lower.contains('ojek') ||
      lower.contains('parkir')) {
    return Icons.directions_car_rounded;
  }
  if (lower.contains('belanja') ||
      lower.contains('kebutuhan') ||
      lower.contains('mart') ||
      lower.contains('shop')) {
    return Icons.shopping_bag_rounded;
  }
  if (lower.contains('tagihan') ||
      lower.contains('utilitas') ||
      lower.contains('listrik') ||
      lower.contains('air') ||
      lower.contains('wifi')) {
    return Icons.bolt_rounded;
  }
  if (lower.contains('hiburan') ||
      lower.contains('rekreasi') ||
      lower.contains('game') ||
      lower.contains('film')) {
    return Icons.sports_esports_rounded;
  }
  if (lower.contains('kesehatan') || lower.contains('obat')) {
    return Icons.medical_services_rounded;
  }
  return Icons.category_rounded;
}

String _formatBudgetPeriodLabel(LocalBudget budget) {
  final start = DateTime.tryParse(budget.startDate);
  if (start == null) return budget.name;
  const fullMonths = [
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
  if (budget.periodType == 'monthly') {
    return '${fullMonths[start.month - 1]} ${start.year}';
  }
  return budget.name;
}

String _formatShortDateId(DateTime dt) {
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
  return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
}
