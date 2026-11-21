import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../database/app_database.dart';
import '../sync/sync_status.dart';
import '../theme/design_tokens.dart';
import '../theme/financial_colors.dart';
import '../utils/currency_formatter.dart';

class SyncStatusBanner extends StatelessWidget {
  const SyncStatusBanner({
    super.key,
    required this.syncInfo,
    required this.pendingCount,
    required this.isCloudAuthenticated,
    this.onActionPressed,
  });

  final SyncStatusInfo syncInfo;
  final int pendingCount;
  final bool isCloudAuthenticated;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final IconData icon;
    final Color accentColor;
    final Color containerColor;
    final String title;
    final String subtitle;
    final String actionLabel;

    if (syncInfo.status == SyncStateStatus.syncing) {
      icon = Icons.sync;
      accentColor = colorScheme.primary;
      containerColor = colorScheme.primaryContainer.withValues(alpha: 0.45);
      title = 'Menyinkronkan Ledger...';
      subtitle = 'Mengirim antrean perubahan ke server';
      actionLabel = 'Proses';
    } else if (syncInfo.status == SyncStateStatus.conflict) {
      icon = Icons.warning_amber_rounded;
      accentColor = financialColors.warning;
      containerColor = colorScheme.errorContainer.withValues(alpha: 0.35);
      title = 'Konflik Sinkronisasi';
      subtitle = '$pendingCount operasi menunggu penyelesaian';
      actionLabel = 'Sinkronkan';
    } else if (!isCloudAuthenticated) {
      icon = Icons.offline_pin_outlined;
      accentColor = colorScheme.primary;
      containerColor = colorScheme.surfaceContainerHigh;
      title = pendingCount > 0
          ? 'Mode Lokal • $pendingCount antrean sync'
          : 'Mode Offline Aktif';
      subtitle = 'Semua pencatatan tersimpan aman di SQLite perangkat';
      actionLabel = 'Masuk Cloud';
    } else if (pendingCount > 0 || syncInfo.status == SyncStateStatus.error) {
      icon = Icons.cloud_upload_outlined;
      accentColor = financialColors.warning;
      containerColor = colorScheme.surfaceContainerHigh;
      title = '$pendingCount Perubahan Belum Tersinkronisasi';
      subtitle = syncInfo.lastError ?? 'Ketuk sinkronkan saat terhubung ke internet';
      actionLabel = 'Sinkronkan';
    } else {
      icon = Icons.cloud_done_outlined;
      accentColor = financialColors.income;
      containerColor = colorScheme.surfaceContainerHigh;
      title = 'Tersinkronisasi';
      subtitle = syncInfo.lastSyncAt != null
          ? 'Terakhir: ${DateFormat('dd MMM HH:mm').format(syncInfo.lastSyncAt!.toLocal())}'
          : 'Cursor #${syncInfo.lastCursor} • Ledger konsisten';
      actionLabel = 'Sinkronkan';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: accentColor, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onActionPressed != null) ...[
            const SizedBox(width: AppSpacing.sm),
            TextButton(
              onPressed: syncInfo.status == SyncStateStatus.syncing ? null : onActionPressed,
              style: TextButton.styleFrom(
                minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
              ),
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onActionPressed,
  });

  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle!,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onActionPressed != null)
          TextButton(
            onPressed: onActionPressed,
            style: TextButton.styleFrom(
              minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class LoadingStateView extends StatelessWidget {
  const LoadingStateView({
    super.key,
    this.message = 'Memuat data keuangan...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(icon, size: 32, color: colorScheme.primary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 40, color: colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Terjadi Kendala',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class TransactionLedgerRow extends StatelessWidget {
  const TransactionLedgerRow({
    super.key,
    required this.transaction,
    this.categoryName,
    this.subtitleMeta,
    this.onTap,
  });

  final LocalTransaction transaction;
  final String? categoryName;
  final String? subtitleMeta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;
    final isVoided = transaction.status == 'voided';

    final IconData icon;
    final Color semanticColor;
    final String signPrefix;
    final String defaultTitle;

    switch (transaction.type) {
      case 'income':
        icon = Icons.south_west;
        semanticColor = isVoided ? colorScheme.onSurfaceVariant : financialColors.income;
        signPrefix = '+';
        defaultTitle = categoryName ?? 'Pemasukan';
      case 'expense':
        icon = Icons.north_east;
        semanticColor = isVoided ? colorScheme.onSurfaceVariant : financialColors.expense;
        signPrefix = '-';
        defaultTitle = categoryName ?? 'Pengeluaran';
      default:
        icon = Icons.swap_horiz;
        semanticColor = isVoided ? colorScheme.onSurfaceVariant : financialColors.transfer;
        signPrefix = '';
        defaultTitle = 'Transfer Antar Rekening';
    }

    final titleText = (transaction.description != null && transaction.description!.trim().isNotEmpty)
        ? transaction.description!.trim()
        : defaultTitle;

    final txDate = DateTime.fromMillisecondsSinceEpoch(
      transaction.transactionDateMs,
      isUtc: true,
    ).toLocal();
    final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(txDate);
    final metaParts = <String>[
      if (categoryName != null && transaction.type != 'transfer') categoryName!,
      if (subtitleMeta != null && subtitleMeta!.isNotEmpty) subtitleMeta!,
      formattedDate,
    ];

    return ListTile(
      onTap: onTap,
      minVerticalPadding: AppSpacing.md,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: semanticColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Icon(icon, color: semanticColor, size: 22),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              titleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                decoration: isVoided ? TextDecoration.lineThrough : null,
                color: isVoided ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
              ),
            ),
          ),
          if (isVoided) ...[
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'VOID',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        metaParts.join(' • '),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
      ),
      trailing: Text(
        '$signPrefix${CurrencyFormatter.formatIdr(transaction.amount)}',
        style: FinancialTypography.amountList(
          context,
          color: semanticColor,
        ).copyWith(
          decoration: isVoided ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}

IconData accountTypeIcon(String accountType) {
  return switch (accountType) {
    'cash' => Icons.payments_outlined,
    'bank' => Icons.account_balance_outlined,
    'e_wallet' => Icons.account_balance_wallet_outlined,
    _ => Icons.savings_outlined,
  };
}

String accountTypeLabel(String accountType) {
  return switch (accountType) {
    'cash' => 'Tunai',
    'bank' => 'Bank',
    'e_wallet' => 'E-Wallet',
    _ => 'Lainnya',
  };
}

