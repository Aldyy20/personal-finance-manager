import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/config/env_config.dart';
import '../../../core/database/app_database.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/widgets/finance_widgets.dart';
import '../../authentication/application/session_controller.dart';
import '../../receipt_scanner/presentation/ai_vision_keys_dialog.dart';

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

  void _showOutboxSheet(BuildContext context, ActiveWorkspaceSession session) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Consumer(
        builder: (context, ref, _) {
          final entriesAsync = ref.watch(outboxEntriesProvider);
          final textTheme = Theme.of(context).textTheme;
          final colorScheme = Theme.of(context).colorScheme;

          return DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.45,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Antrean Sync & Info Perangkat',
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
                  child: ListTile(
                    leading: const Icon(Icons.smartphone_outlined),
                    title: const Text('Device ID Terdaftar'),
                    subtitle: Text(session.deviceId),
                    trailing: Text(
                      session.isCloudAuthenticated ? 'Cloud Aktif' : 'Lokal',
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.primary),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const SectionHeader(
                  title: 'Riwayat Sync Outbox (Maks. 50)',
                ),
                const SizedBox(height: AppSpacing.sm),
                entriesAsync.when(
                  loading: () => const LoadingStateView(),
                  error: (e, _) => ErrorStateView(message: e.toString()),
                  data: (entries) {
                    if (entries.isEmpty) {
                      return const Card(
                        child: EmptyStateView(
                          icon: Icons.check_circle_outline,
                          title: 'Antrean Outbox Bersih',
                          message:
                              'Tidak ada mutasi lokal yang tercatat di outbox saat ini.',
                        ),
                      );
                    }
                    return Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < entries.length; i++) ...[
                            if (i > 0) const Divider(),
                            _OutboxRow(entry: entries[i]),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
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
    final localDbAsync = ref.watch(localDbHealthProvider);
    final backendAsync = ref.watch(backendHealthProvider);
    final env = ref.watch(envConfigProvider);

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
                                        ? 'Cloud Terhubung (Laravel Sanctum)'
                                        : 'Mode Lokal Offline',
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

            // 2. Seksi Sinkronisasi & Offline Data + 3-Col SQLite Metric Grid
            const SectionHeader(title: 'Sinkronisasi & Offline Data'),
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
                    value: 'SQLite Local',
                    caption: 'Drift Engine',
                    valueColor: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricMiniCard(
                    title: 'Status DB',
                    value: localDbAsync.valueOrNull == true ? 'Terenkripsi' : 'Memeriksa',
                    caption: 'Offline-First',
                    valueColor: financialColors.income,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _MetricMiniCard(
                    title: 'Outbox Pending',
                    value: '$pendingCount Antrean',
                    caption: 'Siap kirim',
                    valueColor: pendingCount > 0
                        ? financialColors.warning
                        : financialColors.income,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: const Text('Detail Outbox & Info Perangkat'),
                subtitle: Text('Pending: $pendingCount • Cursor: #${syncInfo.lastCursor}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showOutboxSheet(context, session),
              ),
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
                    title: const Text('Pemindai Struk OCR'),
                    subtitle: const Text(
                      'Ekstrak foto struk dengan AI Vision & OCR ke transaksi',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/receipt-scanner'),
                  ),
                  const Divider(),
                  const _AiVisionSettingsTile(),
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

            // 5. Diagnostik Sistem & Tentang Aplikasi
            const SectionHeader(title: 'Diagnostik & Tentang Aplikasi'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const AppLogoBadge(size: 38, borderRadius: 10),
                    title: const Text('Personal Finance Manager'),
                    subtitle: Text('Backend: ${EnvConfig.productionDomain}'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.storage_outlined),
                    title: const Text('Database Lokal SQLite (Drift)'),
                    subtitle: localDbAsync.when(
                      data: (ok) => Text(ok ? 'Terhubung (SELECT 1 OK)' : 'Terputus'),
                      loading: () => const Text('Memeriksa database lokal...'),
                      error: (err, _) => Text('Error: $err'),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.cloud_outlined),
                    title: Text('Server API (${env.environment.name.toUpperCase()})'),
                    subtitle: backendAsync.when(
                      data: (data) => Text(
                        'Status: ${data["status"]} | DB: ${data["database"]} | Ver: ${data["version"]}',
                      ),
                      loading: () => const Text('Memeriksa koneksi backend...'),
                      error: (_, _) =>
                          Text('Offline / Tidak terjangkau (${env.apiBaseUrl})'),
                    ),
                    trailing: IconButton(
                      tooltip: 'Periksa Ulang Backend',
                      onPressed: () => ref.invalidate(backendHealthProvider),
                      icon: const Icon(Icons.refresh),
                    ),
                  ),
                  const Divider(),
                  const ListTile(
                    leading: Icon(Icons.verified_user_outlined),
                    title: Text('Kebijakan Privasi & Enkripsi Data'),
                    subtitle: Text('Standar AES-256 Cloud & Local DB'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.terminal_rounded),
                    title: const Text('Versi Aplikasi'),
                    trailing: Text(
                      'v1.0.0 (Build 2026.11)',
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

class _OutboxRow extends StatelessWidget {
  const _OutboxRow({required this.entry});

  final SyncOutboxData entry;

  @override
  Widget build(BuildContext context) {
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final dt =
        DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMs, isUtc: true).toLocal();
    final color = switch (entry.status) {
      'synced' => financialColors.income,
      'failed' => colorScheme.error,
      _ => financialColors.warning,
    };

    return ListTile(
      leading: Icon(
        switch (entry.status) {
          'synced' => Icons.cloud_done_outlined,
          'failed' => Icons.error_outline,
          _ => Icons.schedule,
        },
        color: color,
      ),
      title: Text('${entry.entityType} • ${entry.operationType.toUpperCase()}'),
      subtitle: Text(
        '${DateFormat('dd MMM HH:mm:ss').format(dt)} • Percobaan ${entry.retryCount}'
        '${entry.lastError != null ? '\n${entry.lastError}' : ''}',
      ),
      trailing: Text(
        entry.status.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _AiVisionSettingsTile extends ConsumerStatefulWidget {
  const _AiVisionSettingsTile();

  @override
  ConsumerState<_AiVisionSettingsTile> createState() =>
      _AiVisionSettingsTileState();
}

class _AiVisionSettingsTileState extends ConsumerState<_AiVisionSettingsTile> {
  late Future<({bool hasGeminiKey, bool hasGroqKey})> _statusFuture;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  void _loadStatus() {
    _statusFuture =
        ref.read(aiReceiptVisionServiceProvider).getConfiguredKeyStatus();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<({bool hasGeminiKey, bool hasGroqKey})>(
      future: _statusFuture,
      builder: (context, snapshot) {
        final hasGemini = snapshot.data?.hasGeminiKey ?? false;
        final hasGroq = snapshot.data?.hasGroqKey ?? false;
        final subtitle = (hasGemini || hasGroq)
            ? 'Gemini: ${hasGemini ? 'Aktif' : 'Belum'} • Groq Fallback: ${hasGroq ? 'Aktif' : 'Belum'}'
            : 'Atur API Key gratis Google AI Studio & Groq';

        return ListTile(
          leading: const Icon(Icons.auto_awesome_outlined),
          title: const Text('AI Vision Struk (Gemini + Groq)'),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.key_rounded),
          onTap: () async {
            final updated = await showConfigureAiVisionKeysDialog(context, ref);
            if (updated && mounted) {
              setState(_loadStatus);
            }
          },
        );
      },
    );
  }
}
