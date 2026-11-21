import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../app/providers.dart';
import '../../../core/theme/financial_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class FoundationHomeScreen extends ConsumerWidget {
  const FoundationHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final financialColors = theme.extension<FinancialColors>()!;
    final env = ref.watch(envConfigProvider);
    final localDbAsync = ref.watch(localDbHealthProvider);
    final backendAsync = ref.watch(backendHealthProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Finance Manager'),
        actions: [
          IconButton(
            tooltip: 'Ganti Tema',
            onPressed: () {
              final next = switch (themeMode) {
                ThemeMode.system => ThemeMode.light,
                ThemeMode.light => ThemeMode.dark,
                ThemeMode.dark => ThemeMode.system,
              };
              ref.read(themeModeProvider.notifier).state = next;
            },
            icon: Icon(
              switch (themeMode) {
                ThemeMode.light => Icons.light_mode,
                ThemeMode.dark => Icons.dark_mode,
                ThemeMode.system => Icons.brightness_auto,
              },
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phase 1 — Foundation Status',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Material Design 3: ${theme.useMaterial3 ? "Active" : "Inactive"}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Environment: ${env.environment.name.toUpperCase()} (${env.apiBaseUrl})',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semantic Financial Colors & Currency Preview',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Income', style: TextStyle(color: financialColors.income)),
                      Text(
                        CurrencyFormatter.formatIdr(5000000),
                        style: TextStyle(
                          color: financialColors.income,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Expense', style: TextStyle(color: financialColors.expense)),
                      Text(
                        CurrencyFormatter.formatIdr(-150000),
                        style: TextStyle(
                          color: financialColors.expense,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text('Local SQLite (Drift)'),
              subtitle: localDbAsync.when(
                data: (ok) => Text(ok ? 'Connected (SELECT 1 OK)' : 'Disconnected'),
                loading: () => const Text('Checking local database...'),
                error: (err, _) => Text('Error: $err'),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.cloud_done_outlined),
              title: const Text('Laravel Backend API (/api/v1/health)'),
              subtitle: backendAsync.when(
                data: (data) => Text(
                  'Status: ${data["status"]} | DB: ${data["database"]} | Ver: ${data["version"]}',
                ),
                loading: () => const Text('Checking backend connection...'),
                error: (err, _) => Text('Offline / Unreachable: $err'),
              ),
              trailing: IconButton(
                tooltip: 'Refresh Backend Status',
                onPressed: () => ref.invalidate(backendHealthProvider),
                icon: const Icon(Icons.refresh),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

