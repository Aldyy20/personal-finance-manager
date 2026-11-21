import 'dart:convert';

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
import 'transaction_form_sheet.dart';

class TransactionDetailSheet extends ConsumerStatefulWidget {
  const TransactionDetailSheet({
    super.key,
    required this.transactionId,
  });

  final String transactionId;

  static Future<void> show(BuildContext context, String transactionId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => TransactionDetailSheet(transactionId: transactionId),
    );
  }

  @override
  ConsumerState<TransactionDetailSheet> createState() => _TransactionDetailSheetState();
}

class _TransactionDetailSheetState extends ConsumerState<TransactionDetailSheet> {
  Future<({
    LocalTransaction? transaction,
    List<LocalAccountMovement> movements,
    List<LocalTransactionRevision> revisions,
    List<LocalReceipt> receipts,
    Map<String, LocalAccount> accountMap,
    Map<String, LocalCategory> categoryMap,
  })> _loadDetail() async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) {
      return (
        transaction: null,
        movements: const <LocalAccountMovement>[],
        revisions: const <LocalTransactionRevision>[],
        receipts: const <LocalReceipt>[],
        accountMap: const <String, LocalAccount>{},
        categoryMap: const <String, LocalCategory>{},
      );
    }

    final txRepo = ref.read(transactionRepositoryProvider);
    final accRepo = ref.read(accountRepositoryProvider);
    final catRepo = ref.read(categoryRepositoryProvider);
    final receiptRepo = ref.read(receiptRepositoryProvider);

    final tx = await txRepo.getTransactionById(session.userId, widget.transactionId);
    final movements = await txRepo.getAllMovements(widget.transactionId);
    final revisions = await txRepo.getRevisions(widget.transactionId);
    final receipts = await receiptRepo.getReceiptsForTransaction(widget.transactionId);
    final accounts = await accRepo.getAccounts(session.userId);
    final categories = await catRepo.getCategories(session.userId, activeOnly: false);

    return (
      transaction: tx,
      movements: movements,
      revisions: revisions,
      receipts: receipts,
      accountMap: {for (final a in accounts) a.id: a},
      categoryMap: {for (final c in categories) c.id: c},
    );
  }

  Future<void> _editTransaction(
    LocalTransaction tx,
    List<LocalAccountMovement> movements,
  ) async {
    final reversedIds = movements.map((m) => m.reversalOfId).whereType<String>().toSet();
    final active = movements
        .where((m) => m.movementType == 'transaction' && !reversedIds.contains(m.id))
        .toList();

    String? initialAccountId;
    String? initialDestinationId;
    if (tx.type == 'transfer') {
      initialAccountId = active.where((m) => m.amountSigned < 0).firstOrNull?.accountId;
      initialDestinationId = active.where((m) => m.amountSigned > 0).firstOrNull?.accountId;
    } else {
      initialAccountId = active.firstOrNull?.accountId;
    }

    final changed = await TransactionFormSheet.show(
      context,
      existingTransaction: tx,
      initialAccountId: initialAccountId,
      initialDestinationAccountId: initialDestinationId,
    );
    if (changed == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _voidTransaction(LocalTransaction tx) async {
    var reasonText = '';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('Batalkan (Void) Transaksi?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ledger akan mencatat mutasi pembalik (reversal) agar jejak audit dan saldo rekening tetap akurat.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: reasonText,
              onChanged: (v) => reasonText = v,
              decoration: const InputDecoration(
                labelText: 'Alasan Pembatalan (Opsional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Void Transaksi'),
          ),
        ],
      ),
    );
    final reason = reasonText.trim();

    if (confirmed != true) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    try {
      await ref.read(transactionRepositoryProvider).voidTransaction(
            userId: session.userId,
            deviceId: session.deviceId,
            transactionId: tx.id,
            reason: reason.isEmpty ? null : reason,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi dibatalkan dan saldo direkonsiliasi.')),
      );
      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membatalkan transaksi: $e')),
      );
    }
  }

  Future<void> _attachReceipt(LocalTransaction tx) async {
    final attached = await ReceiptScannerSheet.showSaveOrAttach(
      context,
      attachToTransactionId: tx.id,
    );
    if (attached == true && mounted) {
      setState(() {});
    }
  }

  Future<void> _deleteReceipt(LocalReceipt receipt) async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;
    await ref.read(receiptRepositoryProvider).deleteReceipt(
          userId: session.userId,
          deviceId: session.deviceId,
          receiptId: receipt.id,
        );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return FutureBuilder(
      future: _loadDetail(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 300,
            child: LoadingStateView(message: 'Memuat detail transaksi & riwayat revisi...'),
          );
        }

        final data = snapshot.data!;
        final tx = data.transaction;
        if (tx == null) {
          return const SizedBox(
            height: 240,
            child: ErrorStateView(message: 'Transaksi tidak ditemukan.'),
          );
        }

        final isVoided = tx.status == 'voided';
        final semanticColor = switch (tx.type) {
          'income' => financialColors.income,
          'expense' => financialColors.expense,
          _ => financialColors.transfer,
        };
        final prefix = switch (tx.type) {
          'income' => '+',
          'expense' => '-',
          _ => '',
        };
        final categoryName = tx.categoryId != null
            ? data.categoryMap[tx.categoryId!]?.name
            : null;
        final txDate = DateTime.fromMillisecondsSinceEpoch(
          tx.transactionDateMs,
          isUtc: true,
        ).toLocal();

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.96,
          expand: false,
          builder: (context, scrollController) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detail Transaksi',
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: semanticColor.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              tx.type.toUpperCase(),
                              style: textTheme.labelMedium?.copyWith(
                                color: semanticColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isVoided
                                  ? colorScheme.errorContainer
                                  : colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              isVoided ? 'VOIDED (DIBATALKAN)' : 'POSTED • v${tx.version}',
                              style: textTheme.labelMedium?.copyWith(
                                color: isVoided
                                    ? colorScheme.onErrorContainer
                                    : colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        '$prefix${CurrencyFormatter.formatIdr(tx.amount)}',
                        style: FinancialTypography.heroBalance(context).copyWith(
                          color: isVoided ? colorScheme.onSurfaceVariant : semanticColor,
                          decoration: isVoided ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        tx.description?.trim().isNotEmpty == true
                            ? tx.description!
                            : (categoryName ?? 'Transfer Antar Rekening'),
                        style: textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${DateFormat('dd MMMM yyyy, HH:mm').format(txDate)}'
                        '${categoryName != null ? ' • $categoryName' : ''}',
                        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      if (tx.notes != null && tx.notes!.trim().isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(tx.notes!, style: textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isVoided) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editTransaction(tx, data.movements),
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _voidTransaction(tx),
                        icon: Icon(Icons.block_outlined, color: colorScheme.error),
                        label: Text(
                          'Void',
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Mutasi Ledger (${data.movements.length})',
                subtitle: 'Catatan mutasi bersifat permanen (immutable)',
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < data.movements.length; i++) ...[
                      if (i > 0) const Divider(),
                      Builder(
                        builder: (context) {
                          final m = data.movements[i];
                          final acc = data.accountMap[m.accountId];
                          final isPositive = m.amountSigned >= 0;
                          final color = m.movementType == 'reversal'
                              ? financialColors.warning
                              : (isPositive ? financialColors.income : financialColors.expense);
                          return ListTile(
                            leading: Icon(
                              m.movementType == 'reversal'
                                  ? Icons.undo
                                  : (isPositive ? Icons.add_circle_outline : Icons.remove_circle_outline),
                              color: color,
                            ),
                            title: Text(acc?.name ?? 'Rekening'),
                            subtitle: Text('Tipe: ${m.movementType.toUpperCase()}'),
                            trailing: Text(
                              '${isPositive ? '+' : ''}${CurrencyFormatter.formatIdr(m.amountSigned)}',
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
              SectionHeader(
                title: 'Lampiran Struk (${data.receipts.length})',
                actionLabel: 'Tambah Struk',
                onActionPressed: () => _attachReceipt(tx),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (data.receipts.isEmpty)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Belum ada lampiran struk'),
                    subtitle: const Text('Ketuk Tambah Struk untuk memindai/melampirkan struk OCR.'),
                  ),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < data.receipts.length; i++) ...[
                        if (i > 0) const Divider(),
                        ListTile(
                          leading: const Icon(Icons.description_outlined),
                          title: Text(data.receipts[i].fileName ?? 'Struk Transaksi'),
                          subtitle: Text(
                            data.receipts[i].ocrText?.replaceAll('\n', ' • ') ?? 'Tersimpan lokal',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            tooltip: 'Hapus Struk',
                            onPressed: () => _deleteReceipt(data.receipts[i]),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Riwayat Revisi Audit (${data.revisions.length})',
              ),
              const SizedBox(height: AppSpacing.sm),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < data.revisions.length; i++) ...[
                      if (i > 0) const Divider(),
                      Builder(
                        builder: (context) {
                          final rev = data.revisions[i];
                          final revDate = DateTime.fromMillisecondsSinceEpoch(
                            rev.createdAtMs,
                            isUtc: true,
                          ).toLocal();
                          int? beforeAmount;
                          int? afterAmount;
                          if (rev.beforeDataJson != null) {
                            final b = jsonDecode(rev.beforeDataJson!) as Map<String, dynamic>;
                            beforeAmount = (b['amount'] as num?)?.toInt();
                          }
                          if (rev.afterDataJson != null) {
                            final a = jsonDecode(rev.afterDataJson!) as Map<String, dynamic>;
                            afterAmount = (a['amount'] as num?)?.toInt();
                          }
                          final amountDiff = beforeAmount != null && afterAmount != null
                              ? '${CurrencyFormatter.formatIdr(beforeAmount)} → ${CurrencyFormatter.formatIdr(afterAmount)}'
                              : (afterAmount != null ? CurrencyFormatter.formatIdr(afterAmount) : '');

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: colorScheme.surfaceContainerHigh,
                              child: Text('v${rev.revisionNumber}'),
                            ),
                            title: Text('Aksi: ${rev.action.toUpperCase()}'),
                            subtitle: Text(
                              '${DateFormat('dd MMM yyyy, HH:mm').format(revDate)}'
                              '${rev.reason != null ? '\nAlasan: ${rev.reason}' : ''}',
                            ),
                            trailing: amountDiff.isNotEmpty
                                ? Text(
                                    amountDiff,
                                    style: FinancialTypography.tabular(textTheme.labelMedium!),
                                  )
                                : null,
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        );
      },
    );
  }
}

