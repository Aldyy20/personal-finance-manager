import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/database/app_database.dart';
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
                          message: 'Tidak ada mutasi lokal yang tercatat di outbox saat ini.',
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sessionAsync = ref.watch(activeSessionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final syncInfo = ref.watch(syncStatusProvider);
    final pendingCount = ref.watch(pendingOutboxCountProvider).valueOrNull ?? syncInfo.pendingCount;
    final localDbAsync = ref.watch(localDbHealthProvider);
    final backendAsync = ref.watch(backendHealthProvider);
    final env = ref.watch(envConfigProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            session.isCloudAuthenticated
                                ? Icons.verified_user_outlined
                                : Icons.person_outline,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                session.name,
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                session.email,
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                session.isCloudAuthenticated
                                    ? 'Akun Cloud Terhubung (Laravel Sanctum)'
                                    : 'Mode Lokal Offline (Tanpa Akun Cloud)',
                                style: textTheme.labelSmall?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit Profil',
                          onPressed: () => _showEditProfileDialog(context, ref, session),
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (!session.isCloudAuthenticated)
                      FilledButton.icon(
                        onPressed: () => context.push('/auth'),
                        icon: const Icon(Icons.login),
                        label: const Text('Masuk atau Daftar Akun Cloud'),
                      )
                    else
                      OutlinedButton.icon(
                        onPressed: () async {
                          await ref.read(activeSessionProvider.notifier).logout();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sesi cloud ditutup. Beralih ke Mode Lokal.'),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Keluar dari Akun Cloud'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Sinkronisasi & Multi-Perangkat'),
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
                    content: Text(res.lastError ?? 'Sinkronisasi selesai (${res.pendingCount} tersisa).'),
                  ),
                );
              },
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
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Tampilan & Tema'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Mode Tema Aplikasi',
                      style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Master Data & Alat'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
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
                    subtitle: const Text('Ekstrak teks struk menjadi transaksi pengeluaran'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/receipt-scanner'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SectionHeader(title: 'Diagnostik Sistem'),
            const SizedBox(height: AppSpacing.sm),
            Card(
              child: Column(
                children: [
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
                      error: (_, _) => Text('Offline / Tidak terjangkau (${env.apiBaseUrl})'),
                    ),
                    trailing: IconButton(
                      tooltip: 'Periksa Ulang Backend',
                      onPressed: () => ref.invalidate(backendHealthProvider),
                      icon: const Icon(Icons.refresh),
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

class _OutboxRow extends StatelessWidget {
  const _OutboxRow({required this.entry});

  final SyncOutboxData entry;

  @override
  Widget build(BuildContext context) {
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final colorScheme = Theme.of(context).colorScheme;
    final dt = DateTime.fromMillisecondsSinceEpoch(entry.updatedAtMs, isUtc: true).toLocal();
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

