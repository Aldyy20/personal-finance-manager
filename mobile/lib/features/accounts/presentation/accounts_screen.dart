import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import 'account_detail_sheet.dart';
import 'account_form_sheet.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rekening & Dompet'),
        actions: [
          TextButton.icon(
            onPressed: () => AccountFormSheet.show(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const LoadingStateView(message: 'Memuat daftar rekening...'),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (allAccounts) {
          final activeAccounts = allAccounts.where((a) => a.isActive).toList();
          final visibleAccounts = _showArchived ? allAccounts : activeAccounts;
          final totalActiveBalance = activeAccounts.fold<int>(
            0,
            (sum, acc) => sum + acc.balanceCache,
          );

          if (allAccounts.isEmpty) {
            return EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Belum Ada Rekening',
              message: 'Buat rekening pertama Anda seperti Cash, Bank BCA, atau E-Wallet.',
              actionLabel: 'Tambah Rekening',
              onAction: () => AccountFormSheet.show(context),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL SALDO REKENING AKTIF (${activeAccounts.length})',
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        CurrencyFormatter.formatIdr(totalActiveBalance),
                        style: FinancialTypography.heroBalance(context).copyWith(
                          color: totalActiveBalance < 0
                              ? financialColors.expense
                              : financialColors.balance,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          FilterChip(
                            label: Text('Tampilkan Arsip (${allAccounts.length - activeAccounts.length})'),
                            selected: _showArchived,
                            onSelected: (val) => setState(() => _showArchived = val),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SectionHeader(
                title: 'Daftar Rekening',
                subtitle: 'Ketuk rekening untuk melihat mutasi atau koreksi saldo',
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < visibleAccounts.length; i++) ...[
                      if (i > 0) const Divider(),
                      Builder(
                        builder: (context) {
                          final acc = visibleAccounts[i];
                          return ListTile(
                            onTap: () => AccountDetailSheet.show(context, acc),
                            leading: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHigh,
                                borderRadius: BorderRadius.circular(AppRadius.md),
                              ),
                              child: Icon(
                                accountTypeIcon(acc.accountType),
                                color: acc.isActive
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    acc.name,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (!acc.isActive)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xxs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                    child: Text('ARSIP', style: textTheme.labelSmall),
                                  ),
                              ],
                            ),
                            subtitle: Text(
                              '${accountTypeLabel(acc.accountType)}'
                              '${acc.institutionName != null ? ' • ${acc.institutionName}' : ''}'
                              ' • Awal ${CurrencyFormatter.formatIdr(acc.openingBalance)}',
                              style: FinancialTypography.tabular(textTheme.bodySmall!).copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            trailing: Text(
                              CurrencyFormatter.formatIdr(acc.balanceCache),
                              style: FinancialTypography.amountList(
                                context,
                                color: acc.balanceCache < 0
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

