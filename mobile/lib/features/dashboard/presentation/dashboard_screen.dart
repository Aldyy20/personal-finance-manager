import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../../accounts/presentation/account_detail_sheet.dart';
import '../../accounts/presentation/account_form_sheet.dart';
import '../../receipt_scanner/presentation/receipt_scanner_sheet.dart';
import '../../transactions/presentation/transaction_detail_sheet.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final financialColors = theme.extension<FinancialColors>()!;

    final sessionAsync = ref.watch(activeSessionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final syncInfo = ref.watch(syncStatusProvider);
    final pendingCount = ref.watch(pendingOutboxCountProvider).valueOrNull ?? syncInfo.pendingCount;
    final overviewAsync = ref.watch(dashboardOverviewProvider);
    final accountsAsync = ref.watch(activeAccountsStreamProvider);
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final budgetSummariesAsync = ref.watch(budgetSummariesProvider);

    final categoryMap = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance Manager'),
        actions: [
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
        ],
      ),
      body: sessionAsync.when(
        loading: () => const LoadingStateView(message: 'Menyiapkan buku kas lokal...'),
        error: (err, _) => ErrorStateView(
          message: 'Gagal memuat sesi workspace: $err',
          onRetry: () => ref.invalidate(activeSessionProvider),
        ),
        data: (session) {
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
                96,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Signature Moment: Hero Net-Worth & Cash-Flow Stage
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: overviewAsync.when(
                              loading: () => const SizedBox(
                                height: 120,
                                child: Center(child: CircularProgressIndicator()),
                              ),
                              error: (err, _) => ErrorStateView(message: err.toString()),
                              data: (overview) {
                                final totalBalance = (overview['total_balance'] as num?)?.toInt() ?? 0;
                                final totalIncome = (overview['total_income'] as num?)?.toInt() ?? 0;
                                final totalExpense = (overview['total_expense'] as num?)?.toInt() ?? 0;
                                final netCashFlow = (overview['net_cash_flow'] as num?)?.toInt() ?? 0;
                                final activeAccCount = (overview['active_accounts_count'] as num?)?.toInt() ?? 0;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          size: 18,
                                          color: colorScheme.primary,
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Text(
                                          'TOTAL SALDO AKTIF ($activeAccCount REKENING)',
                                          style: textTheme.labelMedium?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    AnimatedSwitcher(
                                      duration: AppMotion.resolve(context, AppMotion.normal),
                                      child: Text(
                                        CurrencyFormatter.formatIdr(totalBalance),
                                        key: ValueKey(totalBalance),
                                        style: FinancialTypography.heroBalance(context).copyWith(
                                          color: totalBalance < 0
                                              ? financialColors.expense
                                              : financialColors.balance,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'Halo, ${session.name} • Bulan Berjalan',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    const Divider(),
                                    const SizedBox(height: AppSpacing.lg),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _CashFlowStat(
                                            label: 'Pemasukan',
                                            icon: Icons.south_west,
                                            color: financialColors.income,
                                            amountText: '+${CurrencyFormatter.formatIdr(totalIncome)}',
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: _CashFlowStat(
                                            label: 'Pengeluaran',
                                            icon: Icons.north_east,
                                            color: financialColors.expense,
                                            amountText: '-${CurrencyFormatter.formatIdr(totalExpense)}',
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.md),
                                        Expanded(
                                          child: _CashFlowStat(
                                            label: 'Arus Bersih',
                                            icon: netCashFlow >= 0
                                                ? Icons.trending_up
                                                : Icons.trending_down,
                                            color: netCashFlow >= 0
                                                ? financialColors.income
                                                : financialColors.expense,
                                            amountText:
                                                '${netCashFlow > 0 ? '+' : ''}${CurrencyFormatter.formatIdr(netCashFlow)}',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SyncStatusBanner(
                          syncInfo: syncInfo,
                          pendingCount: pendingCount,
                          isCloudAuthenticated: session.isCloudAuthenticated,
                          onActionPressed: () async {
                            if (!session.isCloudAuthenticated) {
                              context.push('/auth');
                              return;
                            }
                            final result = await ref.read(syncStatusProvider.notifier).triggerSync();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  result.lastError ??
                                      'Sinkronisasi selesai (${result.pendingCount} tersisa).',
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const SectionHeader(title: 'Aksi Cepat'),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            _QuickActionButton(
                              icon: Icons.north_east,
                              label: 'Pengeluaran',
                              color: financialColors.expense,
                              onPressed: () => TransactionFormSheet.show(
                                context,
                                initialType: 'expense',
                              ),
                            ),
                            _QuickActionButton(
                              icon: Icons.south_west,
                              label: 'Pemasukan',
                              color: financialColors.income,
                              onPressed: () => TransactionFormSheet.show(
                                context,
                                initialType: 'income',
                              ),
                            ),
                            _QuickActionButton(
                              icon: Icons.swap_horiz,
                              label: 'Transfer',
                              color: financialColors.transfer,
                              onPressed: () => TransactionFormSheet.show(
                                context,
                                initialType: 'transfer',
                              ),
                            ),
                            _QuickActionButton(
                              icon: Icons.document_scanner_outlined,
                              label: 'Scan Struk',
                              color: colorScheme.primary,
                              onPressed: () => ReceiptScannerSheet.showSaveOrAttach(context),
                            ),
                            _QuickActionButton(
                              icon: Icons.pie_chart_outline,
                              label: 'Anggaran',
                              color: colorScheme.primary,
                              onPressed: () => context.push('/budgets'),
                            ),
                            _QuickActionButton(
                              icon: Icons.category_outlined,
                              label: 'Kategori',
                              color: colorScheme.primary,
                              onPressed: () => context.push('/categories'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SectionHeader(
                          title: 'Rekening Aktif',
                          actionLabel: 'Kelola',
                          onActionPressed: () => context.go('/accounts'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        accountsAsync.when(
                          loading: () => const LoadingStateView(),
                          error: (e, _) => ErrorStateView(message: e.toString()),
                          data: (accounts) {
                            if (accounts.isEmpty) {
                              return EmptyStateView(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'Belum Ada Rekening Aktif',
                                message: 'Tambahkan rekening tunai, bank, atau e-wallet.',
                                actionLabel: 'Tambah Rekening',
                                onAction: () => AccountFormSheet.show(context),
                              );
                            }
                            return SizedBox(
                              height: 112,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: accounts.length,
                                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                                itemBuilder: (context, index) {
                                  final acc = accounts[index];
                                  return SizedBox(
                                    width: 184,
                                    child: Card(
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                        onTap: () => AccountDetailSheet.show(context, acc),
                                        child: Padding(
                                          padding: const EdgeInsets.all(AppSpacing.md),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    accountTypeIcon(acc.accountType),
                                                    size: 18,
                                                    color: colorScheme.primary,
                                                  ),
                                                  const SizedBox(width: AppSpacing.xs),
                                                  Expanded(
                                                    child: Text(
                                                      acc.name,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: textTheme.titleSmall?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    accountTypeLabel(acc.accountType),
                                                    style: textTheme.labelSmall?.copyWith(
                                                      color: colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                  const SizedBox(height: AppSpacing.xxs),
                                                  Text(
                                                    CurrencyFormatter.formatIdr(acc.balanceCache),
                                                    style: FinancialTypography.amountList(
                                                      context,
                                                      color: acc.balanceCache < 0
                                                          ? financialColors.expense
                                                          : colorScheme.onSurface,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SectionHeader(
                          title: 'Ringkasan Anggaran',
                          actionLabel: 'Atur Anggaran',
                          onActionPressed: () => context.push('/budgets'),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        budgetSummariesAsync.when(
                          loading: () => const LinearProgressIndicator(),
                          error: (e, _) => ErrorStateView(message: e.toString()),
                          data: (summaries) {
                            if (summaries.isEmpty) {
                              return Card(
                                child: ListTile(
                                  leading: Icon(Icons.pie_chart_outline, color: colorScheme.primary),
                                  title: const Text('Belum ada anggaran aktif'),
                                  subtitle: const Text('Tetapkan batas belanja bulanan agar arus kas terkendali.'),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => context.push('/budgets'),
                                ),
                              );
                            }

                            final top = summaries.take(2).toList();
                            return Card(
                              child: Column(
                                children: [
                                  for (var i = 0; i < top.length; i++) ...[
                                    if (i > 0) const Divider(),
                                    Builder(
                                      builder: (context) {
                                        final item = top[i];
                                        final budget = item['budget'] as LocalBudget;
                                        final used = (item['total_used'] as num).toInt();
                                        final limit = (item['total_limit'] as num).toInt();
                                        final pct = (item['percentage'] as num).toDouble();
                                        final status = item['status'] as String;
                                        final statusColor = switch (status) {
                                          'exceeded' => financialColors.expense,
                                          'warning' => financialColors.warning,
                                          _ => colorScheme.primary,
                                        };
                                        return InkWell(
                                          onTap: () => context.push('/budgets'),
                                          child: Padding(
                                            padding: const EdgeInsets.all(AppSpacing.lg),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        budget.name,
                                                        style: textTheme.titleSmall?.copyWith(
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    if (status != 'normal')
                                                      Icon(
                                                        status == 'exceeded'
                                                            ? Icons.error_outline
                                                            : Icons.warning_amber_rounded,
                                                        size: 18,
                                                        color: statusColor,
                                                      ),
                                                    const SizedBox(width: AppSpacing.xs),
                                                    Text(
                                                      '${pct.toStringAsFixed(0)}%',
                                                      style: FinancialTypography.tabular(
                                                        textTheme.labelLarge!,
                                                      ).copyWith(
                                                        color: statusColor,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: AppSpacing.sm),
                                                LinearProgressIndicator(
                                                  value: (pct / 100).clamp(0.0, 1.0),
                                                  color: statusColor,
                                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                                  minHeight: 8,
                                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                                ),
                                                const SizedBox(height: AppSpacing.xs),
                                                Text(
                                                  'Terpakai ${CurrencyFormatter.formatIdr(used)} dari ${CurrencyFormatter.formatIdr(limit)}',
                                                  style: FinancialTypography.tabular(
                                                    textTheme.bodySmall!,
                                                  ).copyWith(color: colorScheme.onSurfaceVariant),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        SectionHeader(
                          title: 'Transaksi Terbaru',
                          actionLabel: 'Semua',
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

class _CashFlowStat extends StatelessWidget {
  const _CashFlowStat({
    required this.label,
    required this.icon,
    required this.color,
    required this.amountText,
  });

  final String label;
  final IconData icon;
  final Color color;
  final String amountText;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                label,
                style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          amountText,
          style: FinancialTypography.amountList(context, color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
      icon: Icon(icon, size: 18, color: color),
      label: Text(label),
    );
  }
}

