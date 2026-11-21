import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/widgets/finance_widgets.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final summariesAsync = ref.watch(budgetSummariesProvider);
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];
    final categoryMap = {for (final c in categories) c.id: c.name};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Anggaran Bulanan'),
        actions: [
          TextButton.icon(
            onPressed: () => BudgetFormSheet.show(context),
            style: TextButton.styleFrom(
              minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Buat'),
          ),
        ],
      ),
      body: summariesAsync.when(
        loading: () => const LoadingStateView(message: 'Menghitung realisasi anggaran...'),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (summaries) {
          if (summaries.isEmpty) {
            return EmptyStateView(
              icon: Icons.pie_chart_outline,
              title: 'Belum Ada Anggaran',
              message:
                  'Buat anggaran bulanan dan alokasikan batas kategori pengeluaran agar arus kas terkontrol.',
              actionLabel: 'Buat Anggaran',
              onAction: () => BudgetFormSheet.show(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            itemCount: summaries.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              final item = summaries[index];
              final budget = item['budget'] as LocalBudget;
              final limit = (item['total_limit'] as num).toInt();
              final used = (item['total_used'] as num).toInt();
              final remaining = (item['total_remaining'] as num).toInt();
              final pct = (item['percentage'] as num).toDouble();
              final status = item['status'] as String;
              final catItems = (item['categories'] as List<dynamic>).cast<Map<String, dynamic>>();

              final statusColor = switch (status) {
                'exceeded' => financialColors.expense,
                'warning' => financialColors.warning,
                _ => financialColors.income,
              };
              final statusLabel = switch (status) {
                'exceeded' => 'Melebihi Batas',
                'warning' => 'Peringatan (>= ${budget.warningPercent}%)',
                _ => 'Terkendali',
              };
              final statusIcon = switch (status) {
                'exceeded' => Icons.error_outline,
                'warning' => Icons.warning_amber_rounded,
                _ => Icons.check_circle_outline,
              };

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  budget.name,
                                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: AppSpacing.xxs),
                                Text(
                                  '${budget.startDate} s/d ${budget.endDate}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Edit Anggaran',
                            onPressed: () => BudgetFormSheet.show(
                              context,
                              existingBudget: budget,
                              existingCategories: catItems,
                            ),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Icon(statusIcon, size: 18, color: statusColor),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            statusLabel,
                            style: textTheme.labelMedium?.copyWith(
                              color: statusColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${pct.toStringAsFixed(1)}%',
                            style: FinancialTypography.amountList(context, color: statusColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: (pct / 100).clamp(0.0, 1.0),
                        color: statusColor,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Terpakai: ${CurrencyFormatter.formatIdr(used)}',
                            style: FinancialTypography.tabular(textTheme.bodySmall!),
                          ),
                          Text(
                            'Sisa: ${CurrencyFormatter.formatIdr(remaining)} / ${CurrencyFormatter.formatIdr(limit)}',
                            style: FinancialTypography.tabular(textTheme.bodySmall!).copyWith(
                              color: remaining < 0
                                  ? financialColors.expense
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (catItems.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        const Divider(),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Alokasi per Kategori Pengeluaran',
                          style: textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final cat in catItems) ...[
                          Builder(
                            builder: (context) {
                              final catId = cat['category_id'] as String;
                              final catName = categoryMap[catId] ?? 'Kategori';
                              final catUsed = (cat['used'] as num).toInt();
                              final catLimit = (cat['amount_limit'] as num).toInt();
                              final catPct = (cat['percentage'] as num).toDouble();
                              final catStatus = cat['status'] as String;
                              final catColor = switch (catStatus) {
                                'exceeded' => financialColors.expense,
                                'warning' => financialColors.warning,
                                _ => colorScheme.primary,
                              };
                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(catName, style: textTheme.bodyMedium),
                                        Text(
                                          '${CurrencyFormatter.formatIdr(catUsed)} / ${CurrencyFormatter.formatIdr(catLimit)} (${catPct.toStringAsFixed(0)}%)',
                                          style: FinancialTypography.tabular(textTheme.bodySmall!)
                                              .copyWith(color: catColor),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    LinearProgressIndicator(
                                      value: (catPct / 100).clamp(0.0, 1.0),
                                      color: catColor,
                                      backgroundColor: colorScheme.surfaceContainerHighest,
                                      minHeight: 6,
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
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
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
  late String _startDate;
  late String _endDate;
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
      _categoryLimitControllers[catId] = TextEditingController(text: limit.toString());
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final allocations = <({String categoryId, int amountLimit})>[];
    for (final entry in _categoryLimitControllers.entries) {
      final parsed = int.tryParse(entry.value.text.replaceAll(RegExp(r'[^0-9]'), ''));
      if (parsed == null || parsed <= 0) {
        setState(() => _errorMessage = 'Semua nominal alokasi kategori harus > 0.');
        return;
      }
      allocations.add((categoryId: entry.key, amountLimit: parsed));
    }

    final totalLimitText = _totalLimitController.text.replaceAll(RegExp(r'[^0-9]'), '');
    final totalLimit = totalLimitText.isEmpty ? null : int.tryParse(totalLimitText);
    if (totalLimit == null && allocations.isEmpty) {
      setState(
        () => _errorMessage =
            'Isi Batas Total Anggaran atau pilih minimal satu alokasi kategori.',
      );
      return;
    }

    final warningPercent = int.tryParse(_warningPercentController.text.trim()) ?? 80;

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
          startDate: _startDate,
          endDate: _endDate,
          totalLimit: totalLimit,
          warningPercent: warningPercent,
          categories: allocations,
        );
      } else {
        await repo.updateBudget(
          userId: session.userId,
          deviceId: session.deviceId,
          budgetId: widget.existingBudget!.id,
          name: _nameController.text.trim(),
          startDate: _startDate,
          endDate: _endDate,
          totalLimit: totalLimit,
          clearTotalLimit: totalLimit == null,
          warningPercent: warningPercent,
          categories: allocations,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingBudget == null
                ? 'Anggaran berhasil dibuat.'
                : 'Anggaran berhasil diperbarui.',
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
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final categories = ref.watch(categoriesStreamProvider).valueOrNull ?? const <LocalCategory>[];
    final expenseCategories = categories
        .where((c) => c.type == 'expense' && c.isActive)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.existingBudget == null ? 'Buat Anggaran Bulanan' : 'Edit Anggaran',
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
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Anggaran',
              ),
              validator: (val) => (val == null || val.trim().isEmpty)
                  ? 'Nama anggaran wajib diisi.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final initial = DateTime.tryParse(_startDate) ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() => _startDate = picked.toIso8601String().substring(0, 10));
                      }
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                    label: Text('Mulai: $_startDate'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final initial = DateTime.tryParse(_endDate) ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null && mounted) {
                        setState(() => _endDate = picked.toIso8601String().substring(0, 10));
                      }
                    },
                    icon: const Icon(Icons.event_outlined),
                    label: Text('Selesai: $_endDate'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _totalLimitController,
                    keyboardType: TextInputType.number,
                    style: FinancialTypography.tabular(textTheme.titleMedium!),
                    decoration: const InputDecoration(
                      labelText: 'Batas Total (Rp, Opsional)',
                      prefixText: 'Rp ',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextFormField(
                    controller: _warningPercentController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Alert (%)',
                    ),
                    validator: (val) {
                      final p = int.tryParse(val ?? '');
                      if (p == null || p < 1 || p > 100) return '1-100';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Alokasi Kategori Pengeluaran',
              style: textTheme.labelLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final cat in expenseCategories)
                  FilterChip(
                    label: Text(cat.name),
                    selected: _categoryLimitControllers.containsKey(cat.id),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _categoryLimitControllers[cat.id] =
                              TextEditingController(text: '500000');
                        } else {
                          _categoryLimitControllers.remove(cat.id)?.dispose();
                        }
                      });
                    },
                  ),
              ],
            ),
            for (final entry in _categoryLimitControllers.entries) ...[
              const SizedBox(height: AppSpacing.md),
              Builder(
                builder: (context) {
                  final catName = expenseCategories
                          .where((c) => c.id == entry.key)
                          .firstOrNull
                          ?.name ??
                      'Kategori';
                  return TextFormField(
                    controller: entry.value,
                    keyboardType: TextInputType.number,
                    style: FinancialTypography.tabular(textTheme.bodyLarge!),
                    decoration: InputDecoration(
                      labelText: 'Batas Kategori: $catName',
                      prefixText: 'Rp ',
                    ),
                    validator: (val) {
                      final v = int.tryParse((val ?? '').replaceAll(RegExp(r'[^0-9]'), ''));
                      if (v == null || v <= 0) return 'Harus > 0';
                      return null;
                    },
                  );
                },
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: const Text('Simpan Anggaran'),
            ),
          ],
        ),
      ),
    );
  }
}

