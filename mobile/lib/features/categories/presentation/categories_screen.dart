import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/widgets/finance_widgets.dart';

class CategoryColorOption {
  const CategoryColorOption({
    required this.hex,
    required this.name,
    required this.color,
  });

  final String hex;
  final String name;
  final Color color;
}

class CategoryIconOption {
  const CategoryIconOption({
    required this.key,
    required this.label,
    required this.icon,
    required this.group,
    required this.keywords,
  });

  final String key;
  final String label;
  final IconData icon;
  final String group;
  final String keywords;
}

class CategoryVisualCatalog {
  const CategoryVisualCatalog._();

  static const List<CategoryColorOption> colors = [
    CategoryColorOption(
      hex: '#D97706',
      name: 'Amber Toast',
      color: Color(0xFFD97706),
    ),
    CategoryColorOption(
      hex: '#059669',
      name: 'Emerald Green',
      color: Color(0xFF059669),
    ),
    CategoryColorOption(
      hex: '#1E60FF',
      name: 'Sapphire Blue',
      color: Color(0xFF1E60FF),
    ),
    CategoryColorOption(
      hex: '#7C3AED',
      name: 'Royal Violet',
      color: Color(0xFF7C3AED),
    ),
    CategoryColorOption(
      hex: '#E11D48',
      name: 'Berry Rose',
      color: Color(0xFFE11D48),
    ),
    CategoryColorOption(
      hex: '#0891B2',
      name: 'Deep Cyan',
      color: Color(0xFF0891B2),
    ),
    CategoryColorOption(
      hex: '#EA580C',
      name: 'Solar Orange',
      color: Color(0xFFEA580C),
    ),
    CategoryColorOption(
      hex: '#475569',
      name: 'Slate Modern',
      color: Color(0xFF475569),
    ),
  ];

  static const List<CategoryIconOption> icons = [
    CategoryIconOption(
      key: 'local_cafe',
      label: 'Kopi',
      icon: Icons.local_cafe_rounded,
      group: 'fnb',
      keywords: 'kopi cafe coffee nongkrong cangkir drink',
    ),
    CategoryIconOption(
      key: 'fastfood',
      label: 'Burger',
      icon: Icons.lunch_dining_rounded,
      group: 'fnb',
      keywords: 'burger fastfood makan junkfood lunch',
    ),
    CategoryIconOption(
      key: 'restaurant',
      label: 'Resto',
      icon: Icons.restaurant_rounded,
      group: 'fnb',
      keywords: 'restoran sendok garpu makan malam dinner makanan food',
    ),
    CategoryIconOption(
      key: 'local_pizza',
      label: 'Pizza',
      icon: Icons.local_pizza_rounded,
      group: 'fnb',
      keywords: 'pizza snack cemilan makanan',
    ),
    CategoryIconOption(
      key: 'local_bar',
      label: 'Minum',
      icon: Icons.local_bar_rounded,
      group: 'fnb',
      keywords: 'minuman botol jus drink bar',
    ),
    CategoryIconOption(
      key: 'shopping_cart',
      label: 'Troli',
      icon: Icons.shopping_cart_rounded,
      group: 'shopping',
      keywords: 'keranjang supermarket mart belanja bulanan troli cart',
    ),
    CategoryIconOption(
      key: 'shopping_bag',
      label: 'Belanja',
      icon: Icons.shopping_bag_rounded,
      group: 'shopping',
      keywords: 'mall fashion baju belanja tas bag',
    ),
    CategoryIconOption(
      key: 'directions_car',
      label: 'Mobil',
      icon: Icons.directions_car_rounded,
      group: 'transport',
      keywords: 'mobil car bensin service parkir tol transportasi',
    ),
    CategoryIconOption(
      key: 'local_gas_station',
      label: 'Bensin',
      icon: Icons.local_gas_station_rounded,
      group: 'transport',
      keywords: 'bensin pertamax spbu fuel solar pertamina',
    ),
    CategoryIconOption(
      key: 'train',
      label: 'KRL/MRT',
      icon: Icons.train_rounded,
      group: 'transport',
      keywords: 'kereta mrt krl lrt stasiun komuter train',
    ),
    CategoryIconOption(
      key: 'flight',
      label: 'Pesawat',
      icon: Icons.flight_rounded,
      group: 'transport',
      keywords: 'pesawat tiket liburan travel penerbangan bandara flight',
    ),
    CategoryIconOption(
      key: 'medical_services',
      label: 'Medis',
      icon: Icons.medical_services_rounded,
      group: 'lifestyle',
      keywords: 'obat dokter rumah sakit apotek klinik sehat kesehatan medical',
    ),
    CategoryIconOption(
      key: 'school',
      label: 'Edukasi',
      icon: Icons.school_rounded,
      group: 'lifestyle',
      keywords: 'kuliah buku sekolah kursus belajar pendidikan education',
    ),
    CategoryIconOption(
      key: 'sports_esports',
      label: 'Game',
      icon: Icons.sports_esports_rounded,
      group: 'lifestyle',
      keywords: 'game steam voucher playstation hobi gaming hiburan',
    ),
    CategoryIconOption(
      key: 'movie',
      label: 'Bioskop',
      icon: Icons.movie_rounded,
      group: 'lifestyle',
      keywords: 'bioskop film nonton cinema netflix movie hiburan',
    ),
    CategoryIconOption(
      key: 'fitness_center',
      label: 'Gym',
      icon: Icons.fitness_center_rounded,
      group: 'lifestyle',
      keywords: 'gym fitness olahraga barbell sehat sport',
    ),
    CategoryIconOption(
      key: 'bolt',
      label: 'Listrik',
      icon: Icons.bolt_rounded,
      group: 'finance',
      keywords: 'listrik pln tagihan utilitas token pulsa daya',
    ),
    CategoryIconOption(
      key: 'smartphone',
      label: 'Pulsa/HP',
      icon: Icons.smartphone_rounded,
      group: 'lifestyle',
      keywords: 'hp handphone kuota internet pulsa wifi komunikasi phone',
    ),
    CategoryIconOption(
      key: 'redeem',
      label: 'Hadiah',
      icon: Icons.redeem_rounded,
      group: 'lifestyle',
      keywords: 'hadiah sedekah kado donasi zakat gift bonus',
    ),
    CategoryIconOption(
      key: 'work',
      label: 'Kerja',
      icon: Icons.work_rounded,
      group: 'finance',
      keywords: 'kantor kerja proyek freelance gaji bisnis work',
    ),
    CategoryIconOption(
      key: 'account_balance',
      label: 'Bank',
      icon: Icons.account_balance_rounded,
      group: 'finance',
      keywords: 'bank rekening reksadana tabungan bunga dividen investasi',
    ),
  ];

  static String encodeIconAndDescription(String iconKey, String description) {
    final trimmed = description.trim();
    if (trimmed.isEmpty) return iconKey;
    return '$iconKey|$trimmed';
  }

  static String extractIconKey(LocalCategory category) {
    final raw = (category.icon ?? '').trim();
    if (raw.isNotEmpty) {
      return raw.split('|').first.trim();
    }
    return inferIconKey(category.name, category.type);
  }

  static String extractDescription(LocalCategory category) {
    final raw = (category.icon ?? '').trim();
    final idx = raw.indexOf('|');
    if (idx >= 0 && idx + 1 < raw.length) {
      return raw.substring(idx + 1).trim();
    }
    return '';
  }

  static String extractSubtitle(LocalCategory category) {
    final customDesc = extractDescription(category);
    if (customDesc.isNotEmpty) return customDesc;

    final lower = category.name.toLowerCase();
    if (lower.contains('makan')) return 'Kebutuhan Pokok';
    if (lower.contains('transport')) return 'KRL, Bensin & Parkir';
    if (lower.contains('belanja')) return 'Supermarket & Kebutuhan';
    if (lower.contains('tagihan')) return 'Listrik, Wi-Fi, Pulsa';
    if (lower.contains('hiburan')) return 'Bioskop, Steam, Wisata';
    if (lower.contains('kesehatan')) return 'Obat, Dokter, Vitamin';
    if (lower.contains('pendidikan')) return 'Buku, Kursus & Kuliah';
    if (lower.contains('gaji')) return 'Pendapatan Utama';
    if (lower.contains('bonus') || lower.contains('hadiah')) {
      return 'Insentif & Reward';
    }
    if (lower.contains('investasi')) return 'Dividen & Imbal Hasil';
    return category.isDefault ? 'Kategori Sistem' : 'Kustom';
  }

  static String inferIconKey(String name, String type) {
    final lower = name.toLowerCase();
    if (lower.contains('kopi') || lower.contains('kafe')) return 'local_cafe';
    if (lower.contains('makan') || lower.contains('food')) return 'restaurant';
    if (lower.contains('transport') || lower.contains('mobil')) {
      return 'directions_car';
    }
    if (lower.contains('bensin')) return 'local_gas_station';
    if (lower.contains('belanja')) return 'shopping_bag';
    if (lower.contains('tagihan') || lower.contains('listrik')) return 'bolt';
    if (lower.contains('hiburan') || lower.contains('game')) {
      return 'sports_esports';
    }
    if (lower.contains('kesehatan') || lower.contains('obat')) {
      return 'medical_services';
    }
    if (lower.contains('pendidikan') || lower.contains('kuliah')) {
      return 'school';
    }
    if (lower.contains('gaji')) return 'payments';
    if (lower.contains('bonus') || lower.contains('hadiah')) return 'redeem';
    if (lower.contains('investasi')) return 'account_balance';
    return type == 'income' ? 'work' : 'local_cafe';
  }

  static IconData iconDataForKey(String? key) {
    final cleanKey = (key ?? '').split('|').first.trim();
    for (final opt in icons) {
      if (opt.key == cleanKey) return opt.icon;
    }
    return switch (cleanKey) {
      'payments' => Icons.payments_rounded,
      'store' => Icons.store_rounded,
      'trending_up' => Icons.trending_up_rounded,
      'card_giftcard' || 'featured_seasonal_and_gifts' => Icons.redeem_rounded,
      'sell' => Icons.sell_rounded,
      'category' => Icons.category_rounded,
      'receipt_long' => Icons.receipt_long_rounded,
      'local_hospital' => Icons.local_hospital_rounded,
      'home' => Icons.home_rounded,
      'phone_android' => Icons.phone_android_rounded,
      'more_horiz' => Icons.more_horiz_rounded,
      'subscriptions' => Icons.subscriptions_rounded,
      'smart_display' => Icons.smart_display_rounded,
      'handyman' || 'build' => Icons.build_rounded,
      'lunch_dining' => Icons.lunch_dining_rounded,
      _ => Icons.category_rounded,
    };
  }

  static Color? parseHexColor(String? rawHex) {
    if (rawHex == null) return null;
    final cleaned = rawHex.trim().replaceAll('#', '');
    if (cleaned.length != 6 && cleaned.length != 8) return null;
    final hexValue = int.tryParse(
      cleaned.length == 6 ? 'FF$cleaned' : cleaned,
      radix: 16,
    );
    if (hexValue == null) return null;
    return Color(hexValue);
  }

  static CategoryColorOption matchColorOption(String? hex) {
    final normalized = (hex ?? '').trim().toUpperCase();
    for (final c in colors) {
      if (c.hex.toUpperCase() == normalized) return c;
    }
    return colors.first;
  }

  static Color resolveCategoryColor(
    LocalCategory category, {
    required bool isDark,
    required FinancialColors financialColors,
  }) {
    final parsed = parseHexColor(category.color);
    if (parsed != null) return parsed;

    final iconKey = extractIconKey(category);
    switch (iconKey) {
      case 'restaurant':
      case 'local_cafe':
      case 'fastfood':
      case 'local_pizza':
        return isDark ? const Color(0xFFFFB95F) : const Color(0xFFD97706);
      case 'directions_car':
      case 'local_gas_station':
      case 'train':
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
      case 'shopping_bag':
      case 'shopping_cart':
        return const Color(0xFFF59E0B);
      case 'bolt':
      case 'receipt_long':
      case 'school':
        return const Color(0xFF6366F1);
      case 'movie':
      case 'sports_esports':
        return isDark ? const Color(0xFF22D3EE) : const Color(0xFF0891B2);
      case 'medical_services':
      case 'local_hospital':
      case 'payments':
        return isDark ? const Color(0xFF4ADE80) : const Color(0xFF059669);
      case 'trending_up':
      case 'account_balance':
        return isDark ? const Color(0xFF00E3FD) : const Color(0xFF1E60FF);
      case 'redeem':
      case 'card_giftcard':
        return const Color(0xFF7C3AED);
    }

    return category.type == 'income'
        ? financialColors.income
        : financialColors.brandBlueLight;
  }
}

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  String _selectedType = 'expense';
  String _searchQuery = '';
  bool _isReorderMode = false;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _openFormSheet({LocalCategory? existing}) async {
    await CategoryFormSheet.show(
      context,
      existing: existing,
      initialType: existing?.type ?? _selectedType,
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
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          cat.isActive
              ? 'Kategori "${cat.name}" dinonaktifkan.'
              : 'Kategori "${cat.name}" dipulihkan.',
        ),
      ),
    );
  }

  Future<void> _moveCategory(
    List<LocalCategory> typeList,
    int index,
    int delta,
  ) async {
    final targetIndex = index + delta;
    if (targetIndex < 0 || targetIndex >= typeList.length) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final reordered = [...typeList];
    final item = reordered.removeAt(index);
    reordered.insert(targetIndex, item);

    await ref.read(categoryRepositoryProvider).reorderCategories(
          userId: session.userId,
          deviceId: session.deviceId,
          orderedCategoryIds: reordered.map((e) => e.id).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final transactions =
        ref.watch(transactionsStreamProvider).valueOrNull ??
            const <LocalTransaction>[];

    // Count posted transactions per category for accurate usage telemetry.
    final txCountByCategory = <String, int>{};
    for (final tx in transactions) {
      if (tx.status == 'voided' || tx.categoryId == null) continue;
      txCountByCategory.update(
        tx.categoryId!,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Kategori Transaksi'),
        actions: [
          IconButton(
            tooltip: 'Cari Kategori',
            onPressed: () => _searchFocusNode.requestFocus(),
            icon: const Icon(Icons.search_rounded),
          ),
          TextButton.icon(
            onPressed: () => _openFormSheet(),
            style: TextButton.styleFrom(
              minimumSize: const Size(
                AppSpacing.minTouchTarget,
                AppSpacing.minTouchTarget,
              ),
              foregroundColor: financialColors.brandGold,
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Tambah',
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
      body: categoriesAsync.when(
        loading: () => const LoadingStateView(
          message: 'Memuat daftar kategori...',
        ),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (allCategories) {
          final expenseList = allCategories
              .where((c) => c.type == 'expense')
              .toList()
            ..sort((a, b) {
              if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
              final orderCmp = a.sortOrder.compareTo(b.sortOrder);
              return orderCmp != 0 ? orderCmp : a.name.compareTo(b.name);
            });

          final incomeList = allCategories
              .where((c) => c.type == 'income')
              .toList()
            ..sort((a, b) {
              if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
              final orderCmp = a.sortOrder.compareTo(b.sortOrder);
              return orderCmp != 0 ? orderCmp : a.name.compareTo(b.name);
            });

          final currentTypeList =
              _selectedType == 'expense' ? expenseList : incomeList;
          final normalizedQuery = _searchQuery.trim().toLowerCase();
          final filtered = normalizedQuery.isEmpty
              ? currentTypeList
              : currentTypeList.where((c) {
                  final subtitle =
                      CategoryVisualCatalog.extractSubtitle(c).toLowerCase();
                  return c.name.toLowerCase().contains(normalizedQuery) ||
                      subtitle.contains(normalizedQuery);
                }).toList();

          final canReorder = _isReorderMode && normalizedQuery.isEmpty;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    24,
                  ),
                  children: [
                    // 1. Segmented Pill Tabs (Pengeluaran / Pemasukan with counts)
                    _SegmentedTypePillBar(
                      selectedType: _selectedType,
                      expenseCount: expenseList.length,
                      incomeCount: incomeList.length,
                      onChanged: (nextType) {
                        setState(() => _selectedType = nextType);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 2. PRD 5.3 Rule Informational Banner
                    _PrdCategoryHintBanner(isDark: isDark),
                    const SizedBox(height: AppSpacing.md),

                    // 3. Search & Reorder Quick Controls
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 46,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF121B2F)
                                  : colorScheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? const Color(0xFF1E335A)
                                    : colorScheme.outlineVariant
                                        .withValues(alpha: 0.65),
                              ),
                              boxShadow: isDark
                                  ? null
                                  : [
                                      BoxShadow(
                                        color: financialColors.brandBlue
                                            .withValues(alpha: 0.04),
                                        blurRadius: 10,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              focusNode: _searchFocusNode,
                              onChanged: (val) =>
                                  setState(() => _searchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Cari nama kategori...',
                                filled: false,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                prefixIcon: Icon(
                                  Icons.search_rounded,
                                  size: 20,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                suffixIcon: _searchQuery.isEmpty
                                    ? null
                                    : IconButton(
                                        tooltip: 'Hapus Pencarian',
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() => _searchQuery = '');
                                        },
                                        icon: const Icon(
                                          Icons.close_rounded,
                                          size: 18,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Tooltip(
                          message: 'Ubah Urutan',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () => setState(
                              () => _isReorderMode = !_isReorderMode,
                            ),
                            child: Container(
                              height: 46,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _isReorderMode
                                    ? (isDark
                                        ? const Color(0xFF1E60FF)
                                        : const Color(0xFFDAE2FF))
                                    : (isDark
                                        ? const Color(0xFF121B2F)
                                        : colorScheme.surface),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _isReorderMode
                                      ? financialColors.brandBlueLight
                                      : (isDark
                                          ? const Color(0xFF1E335A)
                                          : colorScheme.outlineVariant
                                              .withValues(alpha: 0.65)),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.swap_vert_rounded,
                                    size: 20,
                                    color: _isReorderMode
                                        ? (isDark
                                            ? const Color(0xFFFFFFFF)
                                            : const Color(0xFF001847))
                                        : (isDark
                                            ? colorScheme.onSurfaceVariant
                                            : financialColors.transfer),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Urutan',
                                    style: textTheme.labelMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: _isReorderMode
                                          ? (isDark
                                              ? const Color(0xFFFFFFFF)
                                              : const Color(0xFF001847))
                                          : (isDark
                                              ? colorScheme.onSurfaceVariant
                                              : financialColors.transfer),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    if (_isReorderMode && normalizedQuery.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Text(
                          'Kosongkan kolom pencarian untuk mengubah urutan kategori.',
                          style: textTheme.bodySmall?.copyWith(
                            color: financialColors.warning,
                          ),
                        ),
                      ),

                    // 4. Category Feed List or Empty Search State
                    if (filtered.isEmpty)
                      _EmptyCategorySearchCard(
                        hasSearchQuery: normalizedQuery.isNotEmpty,
                        onCreateNew: () => _openFormSheet(),
                      )
                    else
                      Column(
                        children: [
                          for (var i = 0; i < filtered.length; i++) ...[
                            if (i > 0) const SizedBox(height: 10),
                            _StitchCategoryCard(
                              category: filtered[i],
                              transactionCount:
                                  txCountByCategory[filtered[i].id] ?? 0,
                              showReorderControls: canReorder,
                              canMoveUp: canReorder && i > 0,
                              canMoveDown:
                                  canReorder && i < filtered.length - 1,
                              onMoveUp: () =>
                                  _moveCategory(currentTypeList, i, -1),
                              onMoveDown: () =>
                                  _moveCategory(currentTypeList, i, 1),
                              onEdit: () =>
                                  _openFormSheet(existing: filtered[i]),
                              onToggleActive: () =>
                                  _toggleArchive(filtered[i]),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: AppSpacing.xl),

                    // 5. Offline SQLite Status Footnote
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDark
                                ? const Color(0xFF00E3FD)
                                : financialColors.income,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${allCategories.length} Kategori tersimpan aman di perangkat',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 6. Sticky Bottom CTA ("Tambah Kategori Baru")
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: (isDark
                            ? const Color(0xFF091327)
                            : financialColors.canvasBackground)
                        .withValues(alpha: 0.96),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? const Color(0xFF1E335A)
                            : colorScheme.outlineVariant
                                .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  child: FilledButton.icon(
                    onPressed: () => _openFormSheet(),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: isDark
                          ? const Color(0xFF1E60FF)
                          : const Color(0xFF001430),
                      foregroundColor: const Color(0xFFFFFFFF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.add_circle_rounded, size: 20),
                    label: const Text(
                      'Tambah Kategori Baru',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SegmentedTypePillBar extends StatelessWidget {
  const _SegmentedTypePillBar({
    required this.selectedType,
    required this.expenseCount,
    required this.incomeCount,
    required this.onChanged,
  });

  final String selectedType;
  final int expenseCount;
  final int incomeCount;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF121B2F)
            : colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E335A)
              : colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentPillButton(
              label: 'Pengeluaran',
              count: expenseCount,
              isSelected: selectedType == 'expense',
              onTap: () => onChanged('expense'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _SegmentPillButton(
              label: 'Pemasukan',
              count: incomeCount,
              isSelected: selectedType == 'income',
              onTap: () => onChanged('income'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentPillButton extends StatelessWidget {
  const _SegmentPillButton({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final activeBg = isDark ? const Color(0xFF1E60FF) : const Color(0xFFFFFFFF);
    final activeTextColor =
        isDark ? const Color(0xFFF2F2FF) : const Color(0xFF0054CC);
    final activeBadgeBg = isDark
        ? const Color(0xFFFFFFFF).withValues(alpha: 0.2)
        : const Color(0xFFDAE2FF);
    final activeBadgeText =
        isDark ? const Color(0xFFF2F2FF) : const Color(0xFF001847);

    return Material(
      color: isSelected ? activeBg : Colors.transparent,
      borderRadius: BorderRadius.circular(999),
      elevation: isSelected && !isDark ? 1 : 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected
                        ? activeTextColor
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? activeBadgeBg
                      : (isDark
                          ? const Color(0xFF202A3F)
                          : colorScheme.surfaceContainerHigh),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? activeBadgeText
                        : colorScheme.onSurfaceVariant,
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

class _PrdCategoryHintBanner extends StatelessWidget {
  const _PrdCategoryHintBanner({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF121B2F)
            : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E335A)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: financialColors.brandBlueLight,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF202A3F)
                            : const Color(0xFFDAE2FF),
                      ),
                      child: Icon(
                        isDark ? Icons.info_outline_rounded : Icons.lock_reset_rounded,
                        size: 18,
                        color: isDark
                            ? const Color(0xFFB6C4FF)
                            : const Color(0xFF0054CC),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INFO KATEGORI',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: isDark
                                  ? const Color(0xFFB6C4FF)
                                  : const Color(0xFF0054CC),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kategori default bertanda kunci tidak dapat dihapus permanen, namun dapat dinonaktifkan dari transaksi baru kapan saja.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.35,
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
      ),
    );
  }
}

class _StitchCategoryCard extends StatelessWidget {
  const _StitchCategoryCard({
    required this.category,
    required this.transactionCount,
    required this.showReorderControls,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onEdit,
    required this.onToggleActive,
  });

  final LocalCategory category;
  final int transactionCount;
  final bool showReorderControls;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final financialColors = theme.extension<FinancialColors>()!;

    final accentColor = CategoryVisualCatalog.resolveCategoryColor(
      category,
      isDark: isDark,
      financialColors: financialColors,
    );
    final iconKey = CategoryVisualCatalog.extractIconKey(category);
    final iconData = CategoryVisualCatalog.iconDataForKey(iconKey);
    final subtitle = CategoryVisualCatalog.extractSubtitle(category);

    final statusSummary = !category.isActive && transactionCount == 0
        ? '$subtitle • Dinonaktifkan'
        : '$subtitle • $transactionCount Transaksi';

    final cardBg = isDark
        ? const Color(0xFF121B2F)
        : const Color(0xFFFFFFFF);
    final inactiveOpacity = category.isActive ? 1.0 : (isDark ? 0.72 : 0.64);

    return Opacity(
      opacity: inactiveOpacity,
      child: Material(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E335A)
                    : colorScheme.outlineVariant.withValues(alpha: 0.55),
              ),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: financialColors.brandBlue.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              children: [
                if (showReorderControls) ...[
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: canMoveUp ? onMoveUp : null,
                        borderRadius: BorderRadius.circular(6),
                        child: Icon(
                          Icons.keyboard_arrow_up_rounded,
                          size: 20,
                          color: canMoveUp
                              ? colorScheme.onSurface
                              : colorScheme.outlineVariant,
                        ),
                      ),
                      InkWell(
                        onTap: canMoveDown ? onMoveDown : null,
                        borderRadius: BorderRadius.circular(6),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 20,
                          color: canMoveDown
                              ? colorScheme.onSurface
                              : colorScheme.outlineVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                ],
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    iconData,
                    color: accentColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                decoration: !category.isActive && !isDark
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          if (category.isDefault) ...[
                            const SizedBox(width: 5),
                            Icon(
                              Icons.lock_outline_rounded,
                              size: 14,
                              color: isDark
                                  ? accentColor
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        statusSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: !category.isActive
                        ? (isDark
                            ? const Color(0xFF2B354A)
                            : colorScheme.surfaceContainerHigh)
                        : category.isDefault
                            ? (isDark
                                ? const Color(0xFF202A3F)
                                : colorScheme.surfaceContainer)
                            : (isDark
                                ? const Color(0xFF202A3F)
                                : const Color(0xFFDAE2FF)
                                    .withValues(alpha: 0.65)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    !category.isActive
                        ? 'Nonaktif'
                        : (category.isDefault ? 'Default' : 'Kustom'),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: !category.isActive
                          ? colorScheme.onSurfaceVariant
                          : category.isDefault
                              ? colorScheme.onSurfaceVariant
                              : (isDark
                                  ? const Color(0xFFB6C4FF)
                                  : const Color(0xFF0054CC)),
                    ),
                  ),
                ),
                if (!category.isDefault)
                  IconButton(
                    tooltip: 'Edit Kategori',
                    onPressed: onEdit,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox(width: 6),
                Semantics(
                  toggled: category.isActive,
                  label: category.isActive
                      ? 'Nonaktifkan ${category.name}'
                      : 'Aktifkan ${category.name}',
                  child: _LivinCategorySwitch(
                    value: category.isActive,
                    onTap: onToggleActive,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LivinCategorySwitch extends StatelessWidget {
  const _LivinCategorySwitch({
    required this.value,
    required this.onTap,
  });

  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final trackColor = value
        ? (isDark ? const Color(0xFF1E60FF) : const Color(0xFF0054CC))
        : (isDark ? const Color(0xFF2B354A) : colorScheme.surfaceContainerHighest);

    final thumbColor = value
        ? const Color(0xFFFFFFFF)
        : (isDark ? const Color(0xFF8D90A2) : const Color(0xFFFFFFFF));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 46,
          height: 26,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 160),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: thumbColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyCategorySearchCard extends StatelessWidget {
  const _EmptyCategorySearchCard({
    required this.hasSearchQuery,
    required this.onCreateNew,
  });

  final bool hasSearchQuery;
  final VoidCallback onCreateNew;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121B2F) : colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? const Color(0xFF1E335A)
              : colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.surfaceContainerHigh,
            ),
            child: Icon(
              hasSearchQuery
                  ? Icons.manage_search_rounded
                  : Icons.category_outlined,
              size: 30,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            hasSearchQuery
                ? 'Kategori Tidak Ditemukan'
                : 'Belum Ada Kategori',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            hasSearchQuery
                ? 'Tidak ada kategori yang cocok dengan pencarian Anda. Coba kata kunci lain atau tambahkan baru.'
                : 'Tambahkan kategori kustom sesuai kebutuhan Anda.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: onCreateNew,
            child: const Text('Buat Kategori Baru'),
          ),
        ],
      ),
    );
  }
}

class CategoryFormSheet extends ConsumerStatefulWidget {
  const CategoryFormSheet({
    super.key,
    this.existing,
    this.initialType = 'expense',
  });

  final LocalCategory? existing;
  final String initialType;

  static Future<bool?> show(
    BuildContext context, {
    LocalCategory? existing,
    String initialType = 'expense',
  }) {
    ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF091327)
          : Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => CategoryFormSheet(
        existing: existing,
        initialType: initialType,
      ),
    );
  }

  @override
  ConsumerState<CategoryFormSheet> createState() => _CategoryFormSheetState();
}

class _CategoryFormSheetState extends ConsumerState<CategoryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _iconSearchController;

  late String _type;
  late String _selectedColorHex;
  late String _selectedIconKey;
  String _iconGroupFilter = 'all';
  String _iconQuery = '';
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.type ?? widget.initialType;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _descController = TextEditingController(
      text: existing != null
          ? CategoryVisualCatalog.extractDescription(existing)
          : '',
    );
    _iconSearchController = TextEditingController();

    _selectedColorHex = existing?.color?.trim().isNotEmpty == true
        ? CategoryVisualCatalog.matchColorOption(existing!.color).hex
        : CategoryVisualCatalog.colors.first.hex;
    _selectedIconKey = existing != null
        ? CategoryVisualCatalog.extractIconKey(existing)
        : 'local_cafe';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _iconSearchController.dispose();
    super.dispose();
  }

  void _resetForm() {
    final existing = widget.existing;
    setState(() {
      _type = existing?.type ?? widget.initialType;
      _nameController.text = existing?.name ?? '';
      _descController.text = existing != null
          ? CategoryVisualCatalog.extractDescription(existing)
          : '';
      _iconSearchController.clear();
      _iconQuery = '';
      _iconGroupFilter = 'all';
      _selectedColorHex = existing?.color?.trim().isNotEmpty == true
          ? CategoryVisualCatalog.matchColorOption(existing!.color).hex
          : CategoryVisualCatalog.colors.first.hex;
      _selectedIconKey = existing != null
          ? CategoryVisualCatalog.extractIconKey(existing)
          : 'local_cafe';
      _errorMessage = null;
    });
  }

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Panduan Kategori'),
        content: const Text(
          '• Pilih Pengeluaran atau Pemasukan agar kategori muncul di formulir yang tepat.\n'
          '• Warna dan ikon membantu identifikasi cepat di Riwayat Transaksi, Anggaran, dan Grafik Laporan.\n'
          '• Kategori default tidak dapat dihapus permanen, namun dapat dinonaktifkan kapan saja.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final session = ref.read(activeSessionProvider).valueOrNull;
    if (session == null) return;

    final name = _nameController.text.trim();
    final encodedIcon = CategoryVisualCatalog.encodeIconAndDescription(
      _selectedIconKey,
      _descController.text,
    );

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final repo = ref.read(categoryRepositoryProvider);
      if (widget.existing == null) {
        await repo.createCategory(
          userId: session.userId,
          deviceId: session.deviceId,
          name: name,
          type: _type,
          icon: encodedIcon,
          color: _selectedColorHex,
        );
      } else {
        await repo.updateCategory(
          userId: session.userId,
          deviceId: session.deviceId,
          categoryId: widget.existing!.id,
          name: name,
          type: widget.existing!.isDefault ? null : _type,
          icon: encodedIcon,
          color: _selectedColorHex,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existing == null
                ? 'Kategori "$name" berhasil disimpan.'
                : 'Kategori "$name" diperbarui.',
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
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final financialColors = theme.extension<FinancialColors>()!;

    final existing = widget.existing;
    final transactions =
        ref.watch(transactionsStreamProvider).valueOrNull ??
            const <LocalTransaction>[];
    final txCount = existing == null
        ? 0
        : transactions
            .where((t) => t.categoryId == existing.id && t.status != 'voided')
            .length;
    final isTypeLocked =
        existing != null && (existing.isDefault || txCount > 0);

    final selectedColorOption =
        CategoryVisualCatalog.matchColorOption(_selectedColorHex);
    final previewIconData =
        CategoryVisualCatalog.iconDataForKey(_selectedIconKey);

    final filteredIcons = CategoryVisualCatalog.icons.where((item) {
      if (_iconGroupFilter != 'all' && item.group != _iconGroupFilter) {
        return false;
      }
      if (_iconQuery.trim().isNotEmpty) {
        final q = _iconQuery.trim().toLowerCase();
        return item.label.toLowerCase().contains(q) ||
            item.keywords.contains(q) ||
            item.key.contains(q);
      }
      return true;
    }).toList();

    final maxHeight = math.max(
      280.0,
      MediaQuery.sizeOf(context).height -
          MediaQuery.viewInsetsOf(context).bottom -
          24,
    );

    final previewTitle = _nameController.text.trim().isEmpty
        ? 'Kategori Baru'
        : _nameController.text.trim();
    final previewSubtitle = _descController.text.trim().isEmpty
        ? 'Tambahkan catatan tujuan pemakaian'
        : _descController.text.trim();

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sticky Modal Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.sm,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xs,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        tooltip: 'Tutup',
                        onPressed: () => Navigator.of(context).pop(false),
                        icon: const Icon(Icons.close_rounded),
                      ),
                      Expanded(
                        child: Text(
                          existing == null
                              ? 'Tambah Kategori Baru & Pilih Ikon'
                              : 'Edit Kategori',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? colorScheme.onSurface
                                : const Color(0xFF001430),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Bantuan atau Info',
                        onPressed: _showHelpDialog,
                        icon: const Icon(Icons.help_outline_rounded),
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? const Color(0xFFB6C4FF)
                              : const Color(0xFF001430),
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          size: 16,
                          color: isDark
                              ? const Color(0xFF00287E)
                              : const Color(0xFFFFFFFF),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xs,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Live Preview Header Hero Card
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isDark
                              ? const [
                                  Color(0xFF202A3F),
                                  Color(0xFF161F34),
                                ]
                              : const [
                                  Color(0xFF002855),
                                  Color(0xFF041C3B),
                                  Color(0xFF001430),
                                ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: isDark
                            ? Border.all(color: const Color(0xFF2B3D63))
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isDark
                                            ? const Color(0xFFBDF4FF)
                                            : const Color(0xFF93C5FD),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'PREVIEW KARTU',
                                      style: textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                        color: isDark
                                            ? const Color(0xFFBDF4FF)
                                            : const Color(0xFFDAE2FF),
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
                                  color: _type == 'expense'
                                      ? const Color(0xFFBA1A1A)
                                          .withValues(alpha: 0.25)
                                      : const Color(0xFF136BFB)
                                          .withValues(alpha: 0.28),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _type == 'expense'
                                      ? 'Pengeluaran'
                                      : 'Pemasukan',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: _type == 'expense'
                                        ? const Color(0xFFFFDAD6)
                                        : const Color(0xFFBDF4FF),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: selectedColorOption.color,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    previewIconData,
                                    size: 28,
                                    color: const Color(0xFFFFFFFF),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        previewTitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.titleMedium?.copyWith(
                                          color: const Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        previewSubtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: textTheme.bodySmall?.copyWith(
                                          color: const Color(0xFFDAE2FF),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${existing == null ? 'Kategori Baru' : (existing.isDefault ? 'Kategori Default' : 'Kategori Kustom')} • $txCount Transaksi',
                                        style: textTheme.labelSmall?.copyWith(
                                          color: const Color(0xFF93C5FD),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 1: Tipe Transaksi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '1. Tipe Transaksi',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.errorContainer
                                .withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isTypeLocked ? 'Terkunci' : 'Wajib Diisi',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _TypeSelectionCard(
                            title: 'Pengeluaran',
                            subtitle: 'Biaya, belanja, tagihan',
                            icon: Icons.south_west_rounded,
                            selected: _type == 'expense',
                            accentColor: financialColors.expense,
                            enabled: !isTypeLocked,
                            onTap: () => setState(() => _type = 'expense'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: _TypeSelectionCard(
                            title: 'Pemasukan',
                            subtitle: 'Gaji, bonus, dividen',
                            icon: Icons.north_east_rounded,
                            selected: _type == 'income',
                            accentColor: financialColors.income,
                            enabled: !isTypeLocked,
                            onTap: () => setState(() => _type = 'income'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_rounded,
                            size: 16,
                            color: isDark
                                ? const Color(0xFFBDF4FF)
                                : financialColors.transfer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tipe kategori menentukan apakah muncul di form pengeluaran atau pemasukan. Tidak dapat diubah setelah direferensikan untuk integritas pembukuan.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 2: Informasi Kategori
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '2. Informasi Kategori',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '${_nameController.text.length}/30',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _nameController,
                      maxLength: 30,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: 'Nama Kategori',
                        hintText: 'cth: Kopi & Kafe, Freelance Proyek, Sedekah',
                        counterText: '',
                        suffixIcon: _nameController.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Hapus teks',
                                onPressed: () {
                                  _nameController.clear();
                                  setState(() {});
                                },
                                icon: const Icon(Icons.cancel_rounded, size: 18),
                              ),
                      ),
                      validator: (val) => (val == null || val.trim().isEmpty)
                          ? 'Nama kategori wajib diisi.'
                          : null,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _descController,
                      maxLength: 80,
                      maxLines: 2,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Deskripsi / Sub-catatan (Opsional)',
                        hintText: 'Tambahkan catatan tujuan pemakaian...',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 3: Warna Identitas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '3. Warna Identitas',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          selectedColorOption.name,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? selectedColorOption.color
                                : const Color(0xFF0054CC),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: CategoryVisualCatalog.colors.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 1.55,
                        ),
                        itemBuilder: (ctx, i) {
                          final opt = CategoryVisualCatalog.colors[i];
                          final isSelected =
                              opt.hex.toUpperCase() ==
                                  _selectedColorHex.toUpperCase();
                          return InkWell(
                            onTap: () =>
                                setState(() => _selectedColorHex = opt.hex),
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              decoration: BoxDecoration(
                                color: opt.color,
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: const Color(0xFFFFFFFF),
                                        width: 2.2,
                                      )
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Color(0xFFFFFFFF),
                                      size: 20,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Section 4: Pilih Ikon (21 Pilihan Populer)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '4. Pilih Ikon',
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '21 Pilihan Populer',
                          style: textTheme.labelMedium?.copyWith(
                            color: isDark
                                ? const Color(0xFFB6C4FF)
                                : const Color(0xFF0054CC),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _iconSearchController,
                      onChanged: (val) => setState(() => _iconQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Cari ikon (cth: kopi, makan, mobil)...',
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: _iconQuery.isEmpty
                            ? null
                            : IconButton(
                                onPressed: () {
                                  _iconSearchController.clear();
                                  setState(() => _iconQuery = '');
                                },
                                icon: const Icon(Icons.close_rounded, size: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final chip in const [
                            ('all', 'Semua (21)'),
                            ('fnb', 'Makanan & Minuman'),
                            ('transport', 'Transportasi'),
                            ('lifestyle', 'Gaya Hidup'),
                            ('shopping', 'Belanja'),
                            ('finance', 'Finansial'),
                          ]) ...[
                            ChoiceChip(
                              label: Text(chip.$2),
                              selected: _iconGroupFilter == chip.$1,
                              onSelected: (_) =>
                                  setState(() => _iconGroupFilter = chip.$1),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: filteredIcons.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                'Ikon tidak ditemukan untuk pencarian "$_iconQuery".',
                                textAlign: TextAlign.center,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: filteredIcons.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 4,
                                mainAxisSpacing: 8,
                                crossAxisSpacing: 8,
                                childAspectRatio: 0.96,
                              ),
                              itemBuilder: (ctx, i) {
                                final iconOpt = filteredIcons[i];
                                final isSelected =
                                    iconOpt.key == _selectedIconKey;
                                return InkWell(
                                  onTap: () => setState(
                                    () => _selectedIconKey = iconOpt.key,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 140),
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? (isDark
                                              ? const Color(0xFF202A3F)
                                              : const Color(0xFFEAEDFF))
                                          : colorScheme.surface,
                                      borderRadius: BorderRadius.circular(12),
                                      border: isSelected
                                          ? Border.all(
                                              color: financialColors
                                                  .brandBlueLight,
                                              width: 1.5,
                                            )
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          iconOpt.icon,
                                          size: 24,
                                          color: isSelected
                                              ? (isDark
                                                  ? const Color(0xFFB6C4FF)
                                                  : const Color(0xFF001430))
                                              : colorScheme.onSurfaceVariant,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          iconOpt.label,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: textTheme.labelSmall?.copyWith(
                                            fontSize: 11,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? colorScheme.onSurface
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 15,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Ikon akan dirender konsisten pada daftar riwayat dan grafik laporan.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Offline-first SQLite Callout
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorScheme.surfaceContainerHigh,
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              size: 18,
                              color: isDark
                                  ? const Color(0xFFB6C4FF)
                                  : const Color(0xFF001430),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Penyimpanan Terenkripsi Lokal',
                                  style: textTheme.labelMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Kategori tersimpan aman di perangkat Anda dan siap digunakan kapan saja.',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (_errorMessage != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _errorMessage!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Fixed Sticky Dual Footer (Reset + Simpan Kategori)
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF091327) : colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? const Color(0xFF1E335A)
                        : colorScheme.outlineVariant.withValues(alpha: 0.55),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: OutlinedButton.icon(
                      onPressed: _saving ? null : _resetForm,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: const Icon(Icons.restart_alt_rounded, size: 18),
                      label: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                        backgroundColor: isDark
                            ? const Color(0xFF1E60FF)
                            : const Color(0xFF0054CC),
                        foregroundColor: const Color(0xFFFFFFFF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFFFFFFFF),
                              ),
                            )
                          : const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Simpan Kategori',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeSelectionCard extends StatelessWidget {
  const _TypeSelectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.enabled,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final financialColors = theme.extension<FinancialColors>()!;

    final bgColor = selected
        ? (isDark ? const Color(0xFF202A3F) : colorScheme.surface)
        : (isDark
            ? const Color(0xFF121B2F)
            : colorScheme.surfaceContainerLow);

    return Opacity(
      opacity: enabled ? (selected ? 1.0 : 0.82) : 0.65,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? financialColors.brandBlueLight
                    : colorScheme.outlineVariant.withValues(alpha: 0.45),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accentColor.withValues(alpha: 0.16),
                      ),
                      child: Icon(icon, size: 18, color: accentColor),
                    ),
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? financialColors.brandBlueLight
                            : colorScheme.surfaceContainerHighest,
                      ),
                      child: selected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: Color(0xFFFFFFFF),
                            )
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
