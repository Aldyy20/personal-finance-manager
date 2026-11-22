import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/sync/sync_status.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../../accounts/presentation/account_detail_sheet.dart';
import '../../accounts/presentation/account_form_sheet.dart';
import '../../receipt_scanner/presentation/receipt_scanner_sheet.dart';
import '../../transactions/presentation/transaction_detail_sheet.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  bool _hideBalance = false;
  bool _dismissInsight = false;

  String _greetingPrefix() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final sessionAsync = ref.watch(activeSessionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final syncInfo = ref.watch(syncStatusProvider);
    final pendingCount =
        ref.watch(pendingOutboxCountProvider).valueOrNull ?? syncInfo.pendingCount;
    final overviewAsync = ref.watch(dashboardOverviewProvider);
    final accountsAsync = ref.watch(activeAccountsStreamProvider);
    final categories =
        ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final budgetSummariesAsync = ref.watch(budgetSummariesProvider);

    final categoryMap = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: AppBar(
        title: const StitchAppBarTitle(title: 'Personal Finance Manager'),
        actions: [
          IconButton(
            tooltip: _hideBalance ? 'Tampilkan Saldo' : 'Sembunyikan Saldo',
            onPressed: () => setState(() => _hideBalance = !_hideBalance),
            icon: Icon(
              _hideBalance
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Ganti Tema',
            onPressed: () {
              final next = switch (themeMode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
              ref.read(themeModeProvider.notifier).state = next;
            },
            icon: Icon(
              switch (themeMode) {
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.system => Icons.brightness_auto,
              },
            ),
          ),
          IconButton(
            tooltip: 'Pengaturan & Profil',
            onPressed: () => context.go('/settings'),
            icon: CircleAvatar(
              radius: 14,
              backgroundColor: financialColors.brandGold,
              child: Icon(
                Icons.person_rounded,
                size: 16,
                color: financialColors.onBrandGold,
              ),
            ),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const LoadingStateView(message: 'Menyiapkan buku kas lokal...'),
        error: (err, _) => ErrorStateView(
          message: 'Gagal memuat sesi workspace: $err',
          onRetry: () => ref.invalidate(activeSessionProvider),
        ),
        data: (session) {
          final isSyncedOnline = session.isCloudAuthenticated &&
              pendingCount == 0 &&
              syncInfo.status != SyncStateStatus.error;
          final syncLabel = isSyncedOnline
              ? 'TERSINKRON (CLOUD & LOKAL)'
              : (!session.isCloudAuthenticated
                  ? 'DATA TERSIMPAN AMAN DI PERANGKAT'
                  : 'MENUNGGU SINKRON: $pendingCount DATA');
          final syncDotColor = isSyncedOnline
              ? financialColors.income
              : (pendingCount > 0
                  ? financialColors.brandGold
                  : financialColors.brandBlueLight);

          return RefreshIndicator(
            onRefresh: () async {
              if (session.isCloudAuthenticated) {
                await ref.read(syncStatusProvider.notifier).triggerSync();
              } else {
                ref.invalidate(dashboardOverviewProvider);
                ref.invalidate(budgetSummariesProvider);
              }
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                104,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // 1. Greeting & Realtime Sync Bar (Stitch Top Section)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: syncDotColor,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          syncLabel,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.labelSmall?.copyWith(
                                            color: isDark
                                                ? const Color(0xFF38BDF8)
                                                : financialColors.brandBlueLight,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text.rich(
                                    TextSpan(
                                      text: '${_greetingPrefix()}, ',
                                      style: textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: -0.3,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: session.name,
                                          style: TextStyle(
                                            color: isDark
                                                ? const Color(0xFF38BDF8)
                                                : financialColors.brandBlueLight,
                                          ),
                                        ),
                                        const TextSpan(text: ' 👋'),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF17233D)
                                    : colorScheme.surfaceContainer,
                                border: isDark
                                    ? Border.all(color: const Color(0xFF1E335A))
                                    : null,
                              ),
                              child: IconButton(
                                tooltip: session.isCloudAuthenticated
                                    ? 'Sinkronkan Cloud Sekarang'
                                    : 'Masuk Akun Cloud',
                                onPressed: () async {
                                  if (!session.isCloudAuthenticated) {
                                    context.push('/auth');
                                    return;
                                  }
                                  final res = await ref
                                      .read(syncStatusProvider.notifier)
                                      .triggerSync();
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        res.lastError ??
                                            'Sinkronisasi selesai (${res.pendingCount} tersisa).',
                                      ),
                                    ),
                                  );
                                },
                                icon: Icon(
                                  session.isCloudAuthenticated
                                      ? Icons.sync_rounded
                                      : Icons.cloud_queue_rounded,
                                  size: 20,
                                  color: isDark
                                      ? const Color(0xFF38BDF8)
                                      : financialColors.brandBlueLight,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 2. Hero Card: Total Aset Finansial (Stitch Sapphire Mesh)
                        LivinHeroBanner(
                          child: overviewAsync.when(
                            loading: () => const SizedBox(
                              height: 150,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            error: (err, _) => Text(
                              err.toString(),
                              style: const TextStyle(color: Color(0xFFFFFFFF)),
                            ),
                            data: (overview) {
                              final totalBalance =
                                  (overview['total_balance'] as num?)?.toInt() ?? 0;
                              final totalIncome =
                                  (overview['total_income'] as num?)?.toInt() ?? 0;
                              final totalExpense =
                                  (overview['total_expense'] as num?)?.toInt() ?? 0;
                              final netCashFlow =
                                  (overview['net_cash_flow'] as num?)?.toInt() ?? 0;
                              final activeAccCount =
                                  (overview['active_accounts_count'] as num?)?.toInt() ?? 0;

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance,
                                        size: 18,
                                        color: financialColors.brandGold,
                                      ),
                                      const SizedBox(width: AppSpacing.xs),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Total Aset Finansial',
                                              style: textTheme.labelMedium?.copyWith(
                                                color: const Color(0xFF93C5FD),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              'TOTAL SALDO AKTIF ($activeAccCount REKENING)',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: textTheme.labelSmall?.copyWith(
                                                fontSize: 10,
                                                color: const Color(0xFFFFFFFF)
                                                    .withValues(alpha: 0.72),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: _hideBalance
                                            ? 'Intip Saldo'
                                            : 'Tutup Saldo',
                                        onPressed: () => setState(
                                          () => _hideBalance = !_hideBalance,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: const Color(0xFFFFFFFF)
                                              .withValues(alpha: 0.14),
                                          foregroundColor: const Color(0xFFFFFFFF),
                                        ),
                                        icon: Icon(
                                          _hideBalance
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  AnimatedSwitcher(
                                    duration: AppMotion.resolve(
                                      context,
                                      AppMotion.normal,
                                    ),
                                    layoutBuilder: (currentChild, previousChildren) =>
                                        Stack(
                                      alignment: Alignment.centerLeft,
                                      children: <Widget>[
                                        ...previousChildren,
                                        ?currentChild,
                                      ],
                                    ),
                                    child: Text(
                                      _hideBalance
                                          ? 'Rp ••••••••'
                                          : CurrencyFormatter.formatIdr(totalBalance),
                                      key: ValueKey('$_hideBalance-$totalBalance'),
                                      style: FinancialTypography.heroBalance(context)
                                          .copyWith(
                                        color: totalBalance < 0 && !_hideBalance
                                            ? financialColors.brandGold
                                            : const Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Container(
                                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: const Color(0xFFFFFFFF)
                                              .withValues(alpha: 0.12),
                                        ),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFFFF)
                                                  .withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  netCashFlow >= 0
                                                      ? Icons.trending_up_rounded
                                                      : Icons.trending_down_rounded,
                                                  size: 15,
                                                  color: financialColors.brandGold,
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    _hideBalance
                                                        ? 'Rp ••••• bln ini'
                                                        : '${netCashFlow >= 0 ? '+' : ''}${CurrencyFormatter.formatIdr(netCashFlow)} bln ini',
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: textTheme.labelSmall?.copyWith(
                                                      color: const Color(0xFFFFFFFF),
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              netCashFlow >= 0
                                                  ? 'Kondisi Sehat'
                                                  : 'Pantau Kas',
                                              style: textTheme.labelSmall?.copyWith(
                                                color: const Color(0xFFFFDDB8),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.verified,
                                              size: 15,
                                              color: financialColors.brandGold,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _HeroFlowTile(
                                          label: 'Pemasukan',
                                          icon: Icons.south_west_rounded,
                                          accentColor: const Color(0xFF6EE7B7),
                                          amountText: _hideBalance
                                              ? 'Rp •••••'
                                              : '+${CurrencyFormatter.formatIdr(totalIncome)}',
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: _HeroFlowTile(
                                          label: 'Pengeluaran',
                                          icon: Icons.north_east_rounded,
                                          accentColor: financialColors.brandGold,
                                          amountText: _hideBalance
                                              ? 'Rp •••••'
                                              : '-${CurrencyFormatter.formatIdr(totalExpense)}',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // 3. Quick Action Tactile Circles (Stitch Circular Buttons + AI Badge)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _StitchCircleAction(
                                icon: Icons.arrow_downward_rounded,
                                label: 'Pengeluaran',
                                iconColor: financialColors.expense,
                                onTap: () => TransactionFormSheet.show(
                                  context,
                                  initialType: 'expense',
                                ),
                              ),
                            ),
                            Expanded(
                              child: _StitchCircleAction(
                                icon: Icons.arrow_upward_rounded,
                                label: 'Pemasukan',
                                iconColor: financialColors.income,
                                onTap: () => TransactionFormSheet.show(
                                  context,
                                  initialType: 'income',
                                ),
                              ),
                            ),
                            Expanded(
                              child: _StitchCircleAction(
                                icon: Icons.swap_horiz_rounded,
                                label: 'Transfer',
                                iconColor: isDark
                                    ? const Color(0xFF38BDF8)
                                    : financialColors.transfer,
                                onTap: () => TransactionFormSheet.show(
                                  context,
                                  initialType: 'transfer',
                                ),
                              ),
                            ),
                            Expanded(
                              child: _StitchCircleAction(
                                icon: Icons.document_scanner_outlined,
                                label: 'Scan Struk',
                                iconColor: const Color(0xFFFFFFFF),
                                isHighlightedGradient: true,
                                badgeLabel: 'AI',
                                onTap: () =>
                                    ReceiptScannerSheet.showSaveOrAttach(context),
                              ),
                            ),
                            Expanded(
                              child: _StitchCircleAction(
                                icon: Icons.pie_chart_outline_rounded,
                                label: 'Anggaran',
                                iconColor: isDark
                                    ? const Color(0xFF93C5FD)
                                    : financialColors.brandBlue,
                                onTap: () => context.push('/budgets'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // 4. Budgeting & Anggaran Bulanan Widget (Stitch Track + Warning Marker)
                        budgetSummariesAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => ErrorStateView(message: e.toString()),
                          data: (summaries) {
                            if (summaries.isEmpty) {
                              return Card(
                                child: ListTile(
                                  leading: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? const Color(0xFF172748)
                                          : colorScheme.surfaceContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.pie_chart_outline_rounded,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : financialColors.brandBlueLight,
                                    ),
                                  ),
                                  title: const Text(
                                    'Anggaran Bulan Ini',
                                    style: TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: const Text(
                                    'Tetapkan batas belanja agar arus kas terkendali.',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push('/budgets'),
                                ),
                              );
                            }

                            final primaryItem = summaries.first;
                            final budget = primaryItem['budget'] as LocalBudget;
                            final used = (primaryItem['total_used'] as num).toInt();
                            final limit = (primaryItem['total_limit'] as num).toInt();
                            final pct = (primaryItem['percentage'] as num).toDouble();
                            final status = primaryItem['status'] as String;
                            final warningRatio =
                                (budget.warningPercent / 100).clamp(0.05, 0.98);
                            final warningAmount =
                                (limit * budget.warningPercent / 100).round();

                            final statusBadgeText = switch (status) {
                              'exceeded' => 'Melebihi (${pct.toStringAsFixed(0)}%)',
                              'warning' => 'Waspada (${pct.toStringAsFixed(0)}%)',
                              _ => 'Aman (${pct.toStringAsFixed(0)}%)',
                            };
                            final statusBadgeColor = switch (status) {
                              'exceeded' => financialColors.expense,
                              'warning' => financialColors.warning,
                              _ => financialColors.brandBlueLight,
                            };

                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 34,
                                          height: 34,
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF172748)
                                                : colorScheme.surfaceContainer,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Icon(
                                            Icons.pie_chart_rounded,
                                            size: 19,
                                            color: isDark
                                                ? const Color(0xFF38BDF8)
                                                : financialColors.brandBlueLight,
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.sm),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Anggaran Bulan Ini',
                                                style: textTheme.titleSmall?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                budget.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
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
                                            color: statusBadgeColor.withValues(alpha: 0.14),
                                            borderRadius: BorderRadius.circular(999),
                                          ),
                                          child: Text(
                                            statusBadgeText,
                                            style: textTheme.labelSmall?.copyWith(
                                              color: isDark && status == 'normal'
                                                  ? const Color(0xFF38BDF8)
                                                  : statusBadgeColor,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: [
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              text: CurrencyFormatter.formatIdr(used),
                                              style: FinancialTypography.amountList(
                                                context,
                                              ).copyWith(fontWeight: FontWeight.w800),
                                              children: [
                                                TextSpan(
                                                  text:
                                                      ' / ${CurrencyFormatter.formatIdr(limit)}',
                                                  style: textTheme.bodySmall?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Text(
                                          'Batas Aman ${budget.warningPercent}%',
                                          style: textTheme.labelSmall?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    // Stitch visual track with 80% warning marker
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final w = constraints.maxWidth;
                                        final fillW =
                                            w * (pct / 100).clamp(0.0, 1.0);
                                        final markerX =
                                            (w * warningRatio).clamp(4.0, w - 4.0);
                                        return SizedBox(
                                          height: 12,
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: w,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  color: colorScheme.surfaceContainerHigh,
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                              ),
                                              Container(
                                                width: fillW,
                                                height: 12,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: status == 'exceeded'
                                                        ? [
                                                            financialColors.expense,
                                                            financialColors.warning,
                                                          ]
                                                        : [
                                                            financialColors.brandBlueLight,
                                                            isDark
                                                                ? const Color(0xFF38BDF8)
                                                                : financialColors.transfer,
                                                          ],
                                                  ),
                                                  borderRadius: BorderRadius.circular(999),
                                                ),
                                              ),
                                              Positioned(
                                                left: markerX,
                                                top: 0,
                                                bottom: 0,
                                                child: Container(
                                                  width: 2,
                                                  color: financialColors.expense,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 7,
                                              height: 7,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: financialColors.expense,
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Batas Waspada ${CurrencyFormatter.formatIdr(warningAmount)}',
                                              style: textTheme.labelSmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        InkWell(
                                          onTap: () => context.push('/budgets'),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Atur Limit',
                                                style: textTheme.labelSmall?.copyWith(
                                                  color: isDark
                                                      ? const Color(0xFF38BDF8)
                                                      : financialColors.brandBlueLight,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Icon(
                                                Icons.chevron_right_rounded,
                                                size: 16,
                                                color: isDark
                                                    ? const Color(0xFF38BDF8)
                                                    : financialColors.brandBlueLight,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),

                        // 5. Rekening & Kas (Horizontal Slider Cards)
                        accountsAsync.when(
                          loading: () => const LoadingStateView(),
                          error: (e, _) => ErrorStateView(message: e.toString()),
                          data: (accounts) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: SectionHeader(
                                        title: 'Rekening & Kas',
                                        actionLabel: 'Kelola',
                                        onActionPressed: () =>
                                            context.go('/accounts'),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: colorScheme.surfaceContainerHigh,
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${accounts.length}',
                                          style: textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                if (accounts.isEmpty)
                                  Card(
                                    child: EmptyStateView(
                                      icon: Icons.account_balance_wallet_outlined,
                                      title: 'Belum Ada Rekening Aktif',
                                      message:
                                          'Tambahkan rekening tunai, bank, atau e-wallet.',
                                      actionLabel: 'Tambah Rekening',
                                      onAction: () => AccountFormSheet.show(context),
                                    ),
                                  )
                                else
                                  SizedBox(
                                    height: 152,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: accounts.length,
                                      separatorBuilder: (_, _) =>
                                          const SizedBox(width: AppSpacing.sm),
                                      itemBuilder: (context, index) {
                                        final acc = accounts[index];
                                        return SizedBox(
                                          width: 212,
                                          child: LivinAccountCard(
                                            account: acc,
                                            hideBalance: _hideBalance,
                                            compact: true,
                                            featured: acc.accountType == 'bank' ||
                                                index == 1,
                                            onTap: () =>
                                                AccountDetailSheet.show(context, acc),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // 6. Insight Finansial Mini Delight Banner
                        if (!_dismissInsight) ...[
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: isDark
                                  ? const Color(0xFF102347)
                                  : colorScheme.surfaceContainerHigh,
                              border: isDark
                                  ? Border.all(color: const Color(0xFF1E3A70))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: financialColors.brandBlueLight,
                                  ),
                                  child: const Icon(
                                    Icons.psychology_outlined,
                                    color: Color(0xFFFFFFFF),
                                    size: 21,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Insight Finansial',
                                        style: textTheme.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        overviewAsync.valueOrNull == null
                                            ? 'Catat setiap pemasukan & pengeluaran untuk analisis arus kas otomatis.'
                                            : ((overviewAsync.valueOrNull!['net_cash_flow']
                                                            as num?)
                                                        ?.toInt() ??
                                                    0) >=
                                                0
                                            ? 'Arus kas bulan ini surplus! Alokasikan kelebihan kas ke rekening tabungan atau dana darurat.'
                                            : 'Pengeluaran bulan ini melebihi pemasukan. Periksa kategori belanja terbesar Anda di menu Laporan.',
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Tutup Saran',
                                  onPressed: () =>
                                      setState(() => _dismissInsight = true),
                                  icon: Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                        ],

                        // 7. Transaksi Terbaru Section
                        SectionHeader(
                          title: 'Transaksi Terbaru',
                          actionLabel: 'Lihat Semua',
                          onActionPressed: () => context.go('/transactions'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        transactionsAsync.when(
                          loading: () => const LoadingStateView(),
                          error: (e, _) => ErrorStateView(message: e.toString()),
                          data: (transactions) {
                            if (transactions.isEmpty) {
                              return Card(
                                child: EmptyStateView(
                                  icon: Icons.receipt_long_outlined,
                                  title: 'Belum Ada Transaksi',
                                  message:
                                      'Mulai catat pemasukan, pengeluaran, atau transfer pertama Anda.',
                                  actionLabel: 'Catat Transaksi',
                                  onAction: () => TransactionFormSheet.show(context),
                                ),
                              );
                            }

                            final recent = transactions.take(5).toList();
                            return Card(
                              child: Column(
                                children: [
                                  for (var i = 0; i < recent.length; i++) ...[
                                    if (i > 0) const Divider(),
                                    TransactionLedgerRow(
                                      transaction: recent[i],
                                      categoryName: recent[i].categoryId != null
                                          ? categoryMap[recent[i].categoryId!]
                                          : null,
                                      onTap: () => TransactionDetailSheet.show(
                                        context,
                                        recent[i].id,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // 8. Stitch Floating Fast Action QRIS / Scan Struk Pill Dock
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: FilledButton.icon(
                              onPressed: () =>
                                  ReceiptScannerSheet.showSaveOrAttach(context),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: financialColors.brandBlueLight,
                                foregroundColor: const Color(0xFFFFFFFF),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.qr_code_scanner_rounded),
                              label: const Text(
                                'Bayar Cepat QRIS / Scan Struk',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroFlowTile extends StatelessWidget {
  const _HeroFlowTile({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.amountText,
  });

  final String label;
  final IconData icon;
  final Color accentColor;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
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
          Row(
            children: [
              Icon(icon, size: 14, color: accentColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            amountText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FinancialTypography.amountList(
              context,
              color: const Color(0xFFFFFFFF),
            ).copyWith(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StitchCircleAction extends StatelessWidget {
  const _StitchCircleAction({
    required this.icon,
    required this.label,
    required this.iconColor,
    required this.onTap,
    this.isHighlightedGradient = false,
    this.badgeLabel,
  });

  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isHighlightedGradient;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isHighlightedGradient
                        ? LinearGradient(
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                            colors: [
                              financialColors.brandBlueLight,
                              isDark
                                  ? const Color(0xFF00DAF3)
                                  : const Color(0xFF60A5FA),
                            ],
                          )
                        : null,
                    color: isHighlightedGradient
                        ? null
                        : (isDark
                            ? const Color(0xFF132240)
                            : const Color(0xFFFFFFFF)),
                    border: isHighlightedGradient
                        ? null
                        : Border.all(
                            color: isDark
                                ? const Color(0xFF1E335A)
                                : const Color(0xFFEAEDFF),
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isHighlightedGradient
                            ? financialColors.brandBlueLight.withValues(alpha: 0.35)
                            : financialColors.brandBlueDark.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                if (badgeLabel != null)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: financialColors.brandGold,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Text(
                        badgeLabel!,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: financialColors.onBrandGold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
