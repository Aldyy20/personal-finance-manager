import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  String? _selectedType; // null = semua
  bool _showVoided = true;
  String? _selectedAccountId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final session = ref.watch(activeSessionProvider).valueOrNull;
    final accounts = ref.watch(accountsStreamProvider).valueOrNull ?? const <LocalAccount>[];
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];
    final categoryMap = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Scan Struk OCR',
            onPressed: () => ReceiptScannerSheet.showSaveOrAttach(context),
            icon: const Icon(Icons.document_scanner_outlined),
          ),
        ],
      ),
      body: session == null
          ? const LoadingStateView()
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Cari deskripsi atau catatan transaksi...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  tooltip: 'Hapus Pencarian',
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                  icon: const Icon(Icons.close),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Semua'),
                              selected: _selectedType == null,
                              onSelected: (_) => setState(() => _selectedType = null),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            ChoiceChip(
                              label: const Text('Pengeluaran'),
                              selected: _selectedType == 'expense',
                              onSelected: (_) => setState(() => _selectedType = 'expense'),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            ChoiceChip(
                              label: const Text('Pemasukan'),
                              selected: _selectedType == 'income',
                              onSelected: (_) => setState(() => _selectedType = 'income'),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            ChoiceChip(
                              label: const Text('Transfer'),
                              selected: _selectedType == 'transfer',
                              onSelected: (_) => setState(() => _selectedType = 'transfer'),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            FilterChip(
                              label: const Text('Sertakan Void'),
                              selected: _showVoided,
                              onSelected: (val) => setState(() => _showVoided = val),
                            ),
                          ],
                        ),
                      ),
                      if (accounts.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              FilterChip(
                                label: const Text('Semua Rekening'),
                                selected: _selectedAccountId == null,
                                onSelected: (_) => setState(() => _selectedAccountId = null),
                              ),
                              for (final acc in accounts) ...[
                                const SizedBox(width: AppSpacing.xs),
                                FilterChip(
                                  label: Text(acc.name),
                                  selected: _selectedAccountId == acc.id,
                                  onSelected: (_) => setState(() {
                                    _selectedAccountId =
                                        _selectedAccountId == acc.id ? null : acc.id;
                                  }),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<LocalTransaction>>(
                    stream: ref.watch(transactionRepositoryProvider).watchFilteredTransactions(
                          session.userId,
                          type: _selectedType,
                          accountId: _selectedAccountId,
                          status: _showVoided ? null : 'posted',
                          searchQuery: _searchController.text,
                          limit: 200,
                        ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          !snapshot.hasData) {
                        return const LoadingStateView();
                      }
                      if (snapshot.hasError) {
                        return ErrorStateView(message: snapshot.error.toString());
                      }

                      final items = snapshot.data ?? const <LocalTransaction>[];
                      if (items.isEmpty) {
                        return EmptyStateView(
                          icon: Icons.receipt_long_outlined,
                          title: 'Belum Ada Transaksi Cocok',
                          message:
                              'Coba ubah kata kunci pencarian/filter atau catat transaksi baru.',
                          actionLabel: 'Tambah Transaksi',
                          onAction: () => TransactionFormSheet.show(context),
                        );
                      }

                      // Compute totals strictly excluding transfer and voided items
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

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.xs,
                          AppSpacing.lg,
                          96,
                        ),
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                              vertical: AppSpacing.md,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pemasukan (${items.length} item)',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '+${CurrencyFormatter.formatIdr(filteredIncome)}',
                                        style: FinancialTypography.amountList(
                                          context,
                                          color: financialColors.income,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Pengeluaran (Non-Transfer)',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      Text(
                                        '-${CurrencyFormatter.formatIdr(filteredExpense)}',
                                        style: FinancialTypography.amountList(
                                          context,
                                          color: financialColors.expense,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Card(
                            child: Column(
                              children: [
                                for (var i = 0; i < items.length; i++) ...[
                                  if (i > 0) const Divider(),
                                  TransactionLedgerRow(
                                    transaction: items[i],
                                    categoryName: items[i].categoryId != null
                                        ? categoryMap[items[i].categoryId!]
                                        : null,
                                    onTap: () => TransactionDetailSheet.show(
                                      context,
                                      items[i].id,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

