import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/widgets/finance_widgets.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _selectedType = 'expense';
  bool _showArchived = false;

  Future<void> _showCategoryDialog({LocalCategory? existing}) async {
    final formKey = GlobalKey<FormState>();
    var nameText = existing?.name ?? '';
    var type = existing?.type ?? _selectedType;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          scrollable: true,
          title: Text(existing == null ? 'Tambah Kategori' : 'Edit Kategori'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (existing == null) ...[
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'expense', label: Text('Pengeluaran')),
                      ButtonSegment(value: 'income', label: Text('Pemasukan')),
                    ],
                    selected: {type},
                    onSelectionChanged: (sel) => setDialogState(() => type = sel.first),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                TextFormField(
                  initialValue: nameText,
                  onChanged: (v) => nameText = v,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kategori',
                    hintText: 'Contoh: Belanja Dapur / Bonus Proyek',
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty)
                      ? 'Nama kategori wajib diisi.'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(ctx).pop(true);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );

    final name = nameText.trim();

    if (confirmed != true) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final repo = ref.read(categoryRepositoryProvider);
    if (existing == null) {
      await repo.createCategory(
        userId: session.userId,
        deviceId: session.deviceId,
        name: name,
        type: type,
      );
    } else {
      await repo.updateCategory(
        userId: session.userId,
        deviceId: session.deviceId,
        categoryId: existing.id,
        name: name,
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          existing == null ? 'Kategori "$name" ditambahkan.' : 'Kategori diperbarui.',
        ),
      ),
    );
  }

  Future<void> _toggleArchive(LocalCategory cat) async {
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;
    final repo = ref.read(categoryRepositoryProvider);
    if (cat.isActive) {
      await repo.archiveCategory(session.userId, session.deviceId, cat.id);
    } else {
      await repo.restoreCategory(session.userId, session.deviceId, cat.id);
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(cat.isActive ? 'Kategori dinonaktifkan.' : 'Kategori dipulihkan.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori'),
        actions: [
          TextButton.icon(
            onPressed: () => _showCategoryDialog(),
            style: TextButton.styleFrom(
              minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
            ),
            icon: const Icon(Icons.add),
            label: const Text('Tambah'),
          ),
        ],
      ),
      body: categoriesAsync.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (allCategories) {
          final filtered = allCategories.where((c) {
            if (c.type != _selectedType) return false;
            if (!_showArchived && !c.isActive) return false;
            return true;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              96,
            ),
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'expense',
                    label: Text('Pengeluaran'),
                    icon: Icon(Icons.north_east),
                  ),
                  ButtonSegment(
                    value: 'income',
                    label: Text('Pemasukan'),
                    icon: Icon(Icons.south_west),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (sel) => setState(() => _selectedType = sel.first),
              ),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerLeft,
                child: FilterChip(
                  label: const Text('Tampilkan Nonaktif'),
                  selected: _showArchived,
                  onSelected: (val) => setState(() => _showArchived = val),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (filtered.isEmpty)
                EmptyStateView(
                  icon: Icons.category_outlined,
                  title: 'Belum Ada Kategori',
                  message: 'Tambahkan kategori kustom sesuai kebutuhan Anda.',
                  actionLabel: 'Tambah Kategori',
                  onAction: () => _showCategoryDialog(),
                )
              else
                Card(
                  child: Column(
                    children: [
                      for (var i = 0; i < filtered.length; i++) ...[
                        if (i > 0) const Divider(),
                        Builder(
                          builder: (context) {
                            final cat = filtered[i];
                            final color = cat.type == 'income'
                                ? financialColors.income
                                : financialColors.expense;
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: color.withValues(alpha: 0.12),
                                child: Icon(
                                  cat.type == 'income' ? Icons.south_west : Icons.north_east,
                                  color: cat.isActive ? color : colorScheme.onSurfaceVariant,
                                  size: 20,
                                ),
                              ),
                              title: Text(cat.name),
                              subtitle: Text(
                                '${cat.isDefault ? 'Default' : 'Kustom'}'
                                '${cat.isActive ? '' : ' • Nonaktif'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Edit Kategori',
                                    onPressed: () => _showCategoryDialog(existing: cat),
                                    icon: const Icon(Icons.edit_outlined),
                                  ),
                                  IconButton(
                                    tooltip: cat.isActive ? 'Nonaktifkan' : 'Pulihkan',
                                    onPressed: () => _toggleArchive(cat),
                                    icon: Icon(
                                      cat.isActive
                                          ? Icons.archive_outlined
                                          : Icons.unarchive_outlined,
                                    ),
                                  ),
                                ],
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

