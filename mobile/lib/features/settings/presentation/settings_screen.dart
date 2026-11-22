import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../../authentication/application/session_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
    ActiveWorkspaceSession session,
  ) async {
    final formKey = GlobalKey<FormState>();
    var nameText = session.name;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        title: const Text('Edit Profil Pengguna'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: nameText,
            onChanged: (v) => nameText = v,
            decoration: const InputDecoration(
              labelText: 'Nama Tampilan',
            ),
            validator: (val) => (val == null || val.trim().isEmpty)
                ? 'Nama tidak boleh kosong.'
                : null,
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
    );

    final newName = nameText.trim();

    if (confirmed != true) return;
    await ref.read(activeSessionProvider.notifier).updateProfileName(newName);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil diperbarui.')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final financialColors = theme.extension<FinancialColors>()!;
    final sessionAsync = ref.watch(activeSessionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final syncInfo = ref.watch(syncStatusProvider);
    final pendingCount =
        ref.watch(pendingOutboxCountProvider).valueOrNull ?? syncInfo.pendingCount;

    return Scaffold(
      appBar: AppBar(
        title: const StitchAppBarTitle(title: 'Pengaturan'),
      ),
      body: sessionAsync.when(
        loading: () => const LoadingStateView(),
        error: (e, _) => ErrorStateView(message: e.toString()),
        data: (session) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            96,
          ),
          children: [
            // 1. Stitch Executive User Profile Card
            LivinHeroBanner(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: financialColors.brandBlueLight.withValues(alpha: 0.25),
                              border: Border.all(
                                color: const Color(0xFFAAC7FD).withValues(alpha: 0.45),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 32,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                          Positioned(
                            bottom: -3,
                            right: -3,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFFFFFFFF),
                              ),
                              child: Icon(
                                Icons.verified,
                                size: 15,
                                color: financialColors.brandBlueLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  session.name,
                                  style: textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFFFFFFFF),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: financialColors.brandGold,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Priority',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: financialColors.onBrandGold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              session.email,
                              style: textTheme.bodySmall?.copyWith(
                                color: const Color(0xFFDBEAFE),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
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
                                      color: session.isCloudAuthenticated
                                          ? const Color(0xFF34D399)
                                          : financialColors.brandGold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    session.isCloudAuthenticated
                                        ? 'Akun Cloud Terhubung'
                                        : 'Mode Perangkat Lokal',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFFD6E3FF),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Edit Profil',
                        onPressed: () => _showEditProfileDialog(context, ref, session),
                        style: IconButton.styleFrom(
                          backgroundColor: const Color(0xFFFFFFFF).withValues(alpha: 0.14),
                          foregroundColor: const Color(0xFFFFFFFF),
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 19),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  if (!session.isCloudAuthenticated)
                    FilledButton.icon(
                      onPressed: () => context.push('/auth'),
                      style: FilledButton.styleFrom(
                        backgroundColor: financialColors.brandBlueLight,
                        foregroundColor: const Color(0xFFFFFFFF),
                      ),
                      icon: const Icon(Icons.login),
                      label: const Text(
                        'Masuk atau Daftar Akun Cloud',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    )
                  else
                    OutlinedButton.icon(
                      onPressed: () async {
                        await ref.read(activeSessionProvider.notifier).logout();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Sesi cloud ditutup. Beralih ke Mode Lokal.',
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFFFFF),
                        side: BorderSide(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.45),
                        ),
                      ),
                      icon: const Icon(Icons.logout),
                      label: const Text('Keluar dari Akun Cloud'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 2. Seksi Sinkronisasi & Cadangan Data
            const SectionHeader(title: 'Sinkronisasi & Cadangan Data'),
            const SizedBox(height: AppSpacing.sm),
            SyncStatusBanner(
              syncInfo: syncInfo,
              pendingCount: pendingCount,
              isCloudAuthenticated: session.isCloudAuthenticated,
              onActionPressed: () async {
                if (!session.isCloudAuthenticated) {
                  context.push('/auth');
                  return;
                }
                final res = await ref.read(syncStatusProvider.notifier).triggerSync();
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
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MetricMiniCard(
                    title: 'Penyimpanan',
                    value: 'Lokal Aman',
                    caption: 'Di Perangkat',
                    valueColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricMiniCard(
                    title: 'Keamanan',
                    value: 'Terenkripsi',
                    caption: 'Privasi Terjaga',
                    valueColor: financialColors.income,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricMiniCard(
                    title: 'Antrean Sync',
                    value: '$pendingCount Data',
                    caption: pendingCount > 0 ? 'Menunggu' : 'Tersinkron',
                    valueColor: pendingCount > 0
                        ? financialColors.warning
                        : financialColors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),

            // 3. Seksi Preferensi Keuangan & Anggaran
            const SectionHeader(title: 'Preferensi Keuangan & Anggaran'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.payments_outlined),
                    title: const Text('Mata Uang Utama'),
                    subtitle: const Text('Rupiah Indonesia (IDR)'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock_outline, size: 13, color: colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            'Bawaan',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded),
                    title: const Text('Batas Peringatan Anggaran'),
                    subtitle: const Text('Peringatan cerdas saat penggunaan >= 80%'),
                    trailing: Text(
                      '80% Limit',
                      style: FinancialTypography.tabular(textTheme.labelMedium!).copyWith(
                        color: financialColors.brandBlueLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () => context.push('/budgets'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Kelola Kategori'),
                    subtitle: const Text('Kategori pemasukan dan pengeluaran kustom'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/categories'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.pie_chart_outline),
                    title: const Text('Anggaran Bulanan'),
                    subtitle: const Text('Batas belanja & alokasi kategori'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/budgets'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.document_scanner_outlined),
                    title: const Text('Pemindai Struk Cerdas'),
                    subtitle: const Text(
                      'Pindai foto struk belanja otomatis menjadi transaksi',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/receipt-scanner'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Seksi Personalisasi & Tampilan
            const SectionHeader(title: 'Personalisasi & Tampilan'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tema Visual',
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'Sapphire Dynamic',
                          style: textTheme.labelSmall?.copyWith(
                            color: financialColors.brandBlueLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.system,
                          label: Text('Sistem'),
                          icon: Icon(Icons.brightness_auto),
                        ),
                        ButtonSegment(
                          value: ThemeMode.light,
                          label: Text('Terang'),
                          icon: Icon(Icons.light_mode),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          label: Text('Gelap'),
                          icon: Icon(Icons.dark_mode),
                        ),
                      ],
                      selected: {themeMode},
                      onSelectionChanged: (sel) =>
                          ref.read(themeModeProvider.notifier).state = sel.first,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Divider(),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Icon(Icons.schedule_rounded, color: colorScheme.primary, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Zona Waktu Transaksi',
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                'Asia/Jakarta (WIB • UTC+7)',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // 5. Tentang Aplikasi
            const SectionHeader(title: 'Tentang Aplikasi'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  const ListTile(
                    leading: AppLogoBadge(size: 38, borderRadius: 10),
                    title: Text('Personal Finance Manager'),
                    subtitle: Text('Pengelola Keuangan Pribadi'),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.verified_user_outlined),
                    title: Text('Kebijakan Privasi & Enkripsi Data'),
                    subtitle: Text('Data tersimpan aman dan terenkripsi'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('Versi Aplikasi'),
                    trailing: Text(
                      'v1.0.0',
                      style: FinancialTypography.tabular(textTheme.labelMedium!).copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
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

class _MetricMiniCard extends StatelessWidget {
  const _MetricMiniCard({
    required this.title,
    required this.value,
    required this.caption,
    required this.valueColor,
  });

  final String title;
  final String value;
  final String caption;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10.5,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FinancialTypography.tabular(textTheme.labelMedium!).copyWith(
                fontWeight: FontWeight.w800,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                fontSize: 10,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
