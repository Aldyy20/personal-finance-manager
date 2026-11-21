import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../../transactions/presentation/transaction_form_sheet.dart';
import 'account_detail_sheet.dart';
import 'account_form_sheet.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  String _selectedType = 'all'; // all, bank, e_wallet, cash
  bool _showArchived = false;
  bool _hideBalance = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;
    final accountsAsync = ref.watch(accountsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const StitchAppBarTitle(title: 'Rekening & Dompet'),
        actions: [
          TextButton.icon(
            onPressed: () => AccountFormSheet.show(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppSpacing.minTouchTarget,
                AppSpacing.minTouchTarget,
              ),
              foregroundColor: financialColors.brandGold,
            ),
            icon: const Icon(Icons.add),
            label: const Text(
              'Tambah',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: accountsAsync.when(
        loading: () => const LoadingStateView(message: 'Memuat daftar rekening...'),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (allAccounts) {
          final activeAccounts = allAccounts.where((a) => a.isActive).toList();
          final baseList = _showArchived ? allAccounts : activeAccounts;
          final visibleAccounts = _selectedType == 'all'
              ? baseList
              : baseList.where((a) => a.accountType == _selectedType).toList();
          final totalActiveBalance = activeAccounts.fold<int>(
            0,
            (sum, acc) => sum + acc.balanceCache,
          );

          final bankCount = baseList.where((a) => a.accountType == 'bank').length;
          final ewalletCount =
              baseList.where((a) => a.accountType == 'e_wallet').length;
          final cashCount = baseList.where((a) => a.accountType == 'cash').length;

          if (allAccounts.isEmpty) {
            return EmptyStateView(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Belum Ada Rekening',
              message:
                  'Buat rekening pertama Anda seperti Cash, Bank BCA, atau E-Wallet.',
              actionLabel: 'Tambah Rekening',
              onAction: () => AccountFormSheet.show(context),
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              96,
            ),
            children: [
              // 1. Consolidated Balance Hero Banner
              LivinHeroBanner(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance,
                              size: 16,
                              color: Color(0xFFAAC7FD),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              'TOTAL SALDO TERKONSOLIDASI',
                              style: textTheme.labelSmall?.copyWith(
                                color: const Color(0xFF93C5FD),
                                letterSpacing: 0.7,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF34D399),
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                '${activeAccounts.length} Akun Aktif',
                                style: textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFFFFFFFF),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _hideBalance
                                ? 'Rp ••••••••'
                                : CurrencyFormatter.formatIdr(totalActiveBalance),
                            style: FinancialTypography.heroBalance(context).copyWith(
                              fontSize: 26,
                              color: totalActiveBalance < 0 && !_hideBalance
                                  ? financialColors.brandGold
                                  : const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip:
                              _hideBalance ? 'Tampilkan Saldo' : 'Sembunyikan Saldo',
                          onPressed: () =>
                              setState(() => _hideBalance = !_hideBalance),
                          visualDensity: VisualDensity.compact,
                          style: IconButton.styleFrom(
                            backgroundColor:
                                const Color(0xFFFFFFFF).withValues(alpha: 0.14),
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
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => AccountFormSheet.show(context),
                        style: FilledButton.styleFrom(
                          backgroundColor: financialColors.brandBlueLight,
                          foregroundColor: const Color(0xFFFFFFFF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.add_circle_outline_rounded, size: 19),
                        label: const Text('Tambah Rekening Sumber Dana'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 2. Pill Type Filter Navigation
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('Semua (${baseList.length})'),
                      selected: _selectedType == 'all',
                      onSelected: (_) => setState(() => _selectedType = 'all'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      label: Text('Bank ($bankCount)'),
                      selected: _selectedType == 'bank',
                      onSelected: (_) => setState(() => _selectedType = 'bank'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      label: Text('E-Wallet ($ewalletCount)'),
                      selected: _selectedType == 'e_wallet',
                      onSelected: (_) => setState(() => _selectedType = 'e_wallet'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ChoiceChip(
                      label: Text('Tunai ($cashCount)'),
                      selected: _selectedType == 'cash',
                      onSelected: (_) => setState(() => _selectedType = 'cash'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    FilterChip(
                      label: Text(
                        'Arsip (${allAccounts.length - activeAccounts.length})',
                      ),
                      selected: _showArchived,
                      onSelected: (val) => setState(() => _showArchived = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // 3. Virtual ISO Debit Cards List
              const SectionHeader(
                title: 'Kartu & Rekening Anda',
              ),
              const SizedBox(height: AppSpacing.xs),
              if (visibleAccounts.isEmpty)
                const Card(
                  child: EmptyStateView(
                    icon: Icons.credit_card_off_outlined,
                    title: 'Tidak Ada Rekening Pada Kategori Ini',
                    message: 'Pilih tab "Semua" atau tambahkan rekening baru.',
                  ),
                )
              else
                for (var i = 0; i < visibleAccounts.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  LivinAccountCard(
                    account: visibleAccounts[i],
                    hideBalance: _hideBalance,
                    compact: false,
                    onTap: () => AccountDetailSheet.show(context, visibleAccounts[i]),
                    onCopyNumber: () async {
                      final acc = visibleAccounts[i];
                      final text = acc.accountNumber?.trim().isNotEmpty == true
                          ? acc.accountNumber!
                          : acc.name;
                      await Clipboard.setData(ClipboardData(text: text));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Disalin: $text')),
                      );
                    },
                  ),
                ],

              // 4. Stitch 3-Column Quick Ledger Actions
              if (activeAccounts.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Aksi Cepat Rekening',
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _QuickLedgerActionCard(
                        icon: Icons.send_rounded,
                        label: 'Transfer Keluar',
                        iconBg: financialColors.brandBlueLight,
                        iconColor: const Color(0xFFFFFFFF),
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onTap: () => TransactionFormSheet.show(
                          context,
                          initialType: 'transfer',
                          initialAccountId: activeAccounts.first.id,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _QuickLedgerActionCard(
                        icon: Icons.history_edu_rounded,
                        label: 'Mutasi Rekening',
                        iconBg: colorScheme.surfaceContainerHighest,
                        iconColor: isDark
                            ? const Color(0xFF38BDF8)
                            : financialColors.brandBlue,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onTap: () => AccountDetailSheet.show(
                          context,
                          activeAccounts.first,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _QuickLedgerActionCard(
                        icon: Icons.category_outlined,
                        label: 'Kategori',
                        iconBg: colorScheme.surfaceContainerHighest,
                        iconColor: colorScheme.onSurfaceVariant,
                        isDark: isDark,
                        colorScheme: colorScheme,
                        onTap: () => context.push('/categories'),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _QuickLedgerActionCard extends StatelessWidget {
  const _QuickLedgerActionCard({
    required this.icon,
    required this.label,
    required this.iconBg,
    required this.iconColor,
    required this.isDark,
    required this.colorScheme,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color iconBg;
  final Color iconColor;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark ? const Color(0xFF11203D) : colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconBg,
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
