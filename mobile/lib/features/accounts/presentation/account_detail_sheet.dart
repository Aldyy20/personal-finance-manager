import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';
import 'account_form_sheet.dart';

class AccountDetailSheet extends ConsumerStatefulWidget {
  const AccountDetailSheet({
    super.key,
    required this.account,
  });

  final LocalAccount account;

  static Future<void> show(BuildContext context, LocalAccount account) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AccountDetailSheet(account: account),
    );
  }

  @override
  ConsumerState<AccountDetailSheet> createState() => _AccountDetailSheetState();
}

class _AccountDetailSheetState extends ConsumerState<AccountDetailSheet> {
  Future<void> _showAdjustmentDialog(LocalAccount acc) async {
    final formKey = GlobalKey<FormState>();
    var amountText = '';
    var reasonText = '';
    var isAddition = true;

    final result = await showDialog<({int signedAmount, String reason})>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text('Koreksi Saldo • ${acc.name}'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Tambah (+)')),
                    ButtonSegment(value: false, label: Text('Kurang (-)')),
                  ],
                  selected: {isAddition},
                  onSelectionChanged: (sel) => setDialogState(() => isAddition = sel.first),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  initialValue: amountText,
                  onChanged: (v) => amountText = v,
                  keyboardType: TextInputType.number,
                  style: FinancialTypography.tabular(Theme.of(ctx).textTheme.titleMedium!),
                  decoration: const InputDecoration(
                    labelText: 'Nominal Koreksi (Rp)',
                    prefixText: 'Rp ',
                  ),
                  validator: (val) {
                    final parsed = int.tryParse((val ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                    if (parsed == null || parsed <= 0) {
                      return 'Nominal harus lebih dari nol.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  initialValue: reasonText,
                  onChanged: (v) => reasonText = v,
                  decoration: const InputDecoration(
                    labelText: 'Alasan Penyesuaian',
                    hintText: 'Contoh: Selisih kas / biaya admin bank',
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Alasan koreksi wajib diisi.'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                final rawAmount = int.parse(
                  amountText.replaceAll(RegExp(r'[^0-9]'), ''),
                );
                Navigator.of(ctx).pop((
                  signedAmount: isAddition ? rawAmount : -rawAmount,
                  reason: reasonText.trim(),
                ));
              },
              child: const Text('Simpan Koreksi'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    await ref.read(accountRepositoryProvider).createAdjustment(
          userId: session.userId,
          deviceId: session.deviceId,
          accountId: acc.id,
          amountSigned: result.signedAmount,
          reason: result.reason,
        );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Penyesuaian saldo (adjustment) berhasil dicatat.')),
    );
    setState(() {});
  }

  Future<void> _toggleArchive(LocalAccount acc) async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;
    final repo = ref.read(accountRepositoryProvider);
    if (acc.isActive) {
      await repo.archiveAccount(session.userId, session.deviceId, acc.id);
    } else {
      await repo.restoreAccount(session.userId, session.deviceId, acc.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          acc.isActive ? 'Rekening diarsipkan.' : 'Rekening dipulihkan.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? const <LocalAccount>[];
    final current = accounts.where((a) => a.id == widget.account.id).firstOrNull ?? widget.account;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => FutureBuilder<List<LocalAccountMovement>>(
        future: ref.read(accountRepositoryProvider).getAccountMovements(current.id),
        builder: (context, snapshot) {
          final movements = snapshot.data ?? const <LocalAccountMovement>[];

          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  Icon(accountTypeIcon(current.accountType), color: colorScheme.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      current.name,
                      style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${accountTypeLabel(current.accountType)}'
                        '${current.institutionName != null ? ' • ${current.institutionName}' : ''}'
                        '${current.isActive ? '' : ' • DIARSIPKAN'}',
                        style: textTheme.labelLarge?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        CurrencyFormatter.formatIdr(current.balanceCache),
                        style: FinancialTypography.heroBalance(context).copyWith(
                          color: current.balanceCache < 0
                              ? financialColors.expense
                              : financialColors.balance,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Saldo Awal: ${CurrencyFormatter.formatIdr(current.openingBalance)} (${current.openingBalanceDate})',
                        style: FinancialTypography.tabular(textTheme.bodySmall!).copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: () => _showAdjustmentDialog(current),
                    icon: const Icon(Icons.tune),
                    label: const Text('Koreksi Saldo'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final edited = await AccountFormSheet.show(
                        context,
                        existingAccount: current,
                      );
                      if (edited == true && mounted) {
                        setState(() {});
                      }
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _toggleArchive(current),
                    icon: Icon(current.isActive ? Icons.archive_outlined : Icons.unarchive_outlined),
                    label: Text(current.isActive ? 'Arsipkan' : 'Pulihkan'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Riwayat Mutasi Rekening (${movements.length})',
                subtitle: 'SUM(amount_signed) = saldo rekening saat ini',
              ),
              const SizedBox(height: AppSpacing.sm),
              if (!snapshot.hasData)
                const LoadingStateView(message: 'Memuat mutasi rekening...')
              else if (movements.isEmpty)
                const EmptyStateView(
                  icon: Icons.history,
                  title: 'Belum Ada Mutasi',
                  message: 'Belum ada pergerakan saldo tercatat untuk rekening ini.',
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < movements.length; i++) ...[
                        if (i > 0) const Divider(),
                        Builder(
                          builder: (context) {
                            final m = movements[i];
                            final dt = DateTime.fromMillisecondsSinceEpoch(
                              m.createdAtMs,
                              isUtc: true,
                            ).toLocal();
                            final isPos = m.amountSigned >= 0;
                            final color = m.movementType == 'reversal'
                                ? financialColors.warning
                                : (isPos ? financialColors.income : financialColors.expense);
                            return ListTile(
                              leading: Icon(
                                switch (m.movementType) {
                                  'opening' => Icons.flag_outlined,
                                  'adjustment' => Icons.tune,
                                  'reversal' => Icons.undo,
                                  _ => isPos ? Icons.south_west : Icons.north_east,
                                },
                                color: color,
                              ),
                              title: Text(m.movementType.toUpperCase()),
                              subtitle: Text(DateFormat('dd MMM yyyy, HH:mm').format(dt)),
                              trailing: Text(
                                '${isPos ? '+' : ''}${CurrencyFormatter.formatIdr(m.amountSigned)}',
                                style: FinancialTypography.amountList(context, color: color),
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }
}

