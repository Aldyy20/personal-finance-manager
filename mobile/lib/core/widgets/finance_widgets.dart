import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../database/app_database.dart';
import '../sync/sync_status.dart';
import '../theme/design_tokens.dart';
import '../theme/financial_colors.dart';
import '../utils/currency_formatter.dart';

/// Displays the bundled application logo (`assets/images/app_logo.png`).
class AppLogoBadge extends StatelessWidget {
  const AppLogoBadge({
    super.key,
    this.size = 36,
    this.borderRadius = 11,
  });

  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final financialColors = Theme.of(context).extension<FinancialColors>();
    final accentBorder = financialColors?.brandGold ?? const Color(0xFFFFB956);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.08),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: accentBorder.withValues(alpha: 0.75),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular((borderRadius - 3).clamp(4, 24)),
        child: Image.asset(
          'assets/images/app_logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => Icon(
            Icons.account_balance_wallet_rounded,
            size: size * 0.52,
            color: const Color(0xFF002855),
          ),
        ),
      ),
    );
  }
}

/// Stitch "Finansial Mandiri" two-line branded AppBar title.
class StitchAppBarTitle extends StatelessWidget {
  const StitchAppBarTitle({
    super.key,
    required this.title,
    this.overline = 'FINANSIAL MANDIRI',
  });

  final String title;
  final String overline;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const AppLogoBadge(size: 36, borderRadius: 10),
        const SizedBox(width: 10),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                overline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF93C5FD),
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFFFFFFF),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Stitch "Sapphire Dynamic" deep sapphire gradient mesh hero container.
class LivinHeroBanner extends StatelessWidget {
  const LivinHeroBanner({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.borderRadius = 20,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    final gradientColors = isDark
        ? const [
            Color(0xFF0D286D),
            Color(0xFF091A44),
            Color(0xFF050F29),
          ]
        : const [
            Color(0xFF002855),
            Color(0xFF001430),
            Color(0xFF0054CC),
          ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: isDark
            ? Border.all(
                color: const Color(0xFF1E3A7A).withValues(alpha: 0.65),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: financialColors.brandBlueDark.withValues(alpha: isDark ? 0.5 : 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(
          children: [
            Positioned(
              top: -42,
              right: -36,
              child: IgnorePointer(
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: financialColors.brandBlueLight.withValues(alpha: 0.26),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -48,
              left: -28,
              child: IgnorePointer(
                child: Container(
                  width: 136,
                  height: 136,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: financialColors.brandGold.withValues(alpha: 0.14),
                  ),
                ),
              ),
            ),
            Padding(
              padding: padding,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// Stitch-styled virtual bank / e-wallet card (supports horizontal slider compact
/// cards and ISO ID-1 virtual debit cards with metallic gold EMV chip).
class LivinAccountCard extends StatelessWidget {
  const LivinAccountCard({
    super.key,
    required this.account,
    this.hideBalance = false,
    this.compact = true,
    this.featured = false,
    this.onTap,
    this.onCopyNumber,
  });

  final LocalAccount account;
  final bool hideBalance;
  final bool compact;
  final bool featured;
  final VoidCallback? onTap;
  final VoidCallback? onCopyNumber;

  String _codeBadge() {
    final source = (account.institutionName?.trim().isNotEmpty == true)
        ? account.institutionName!.trim()
        : account.name.trim();
    final parts = source.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return source.length >= 3
        ? source.substring(0, 3).toUpperCase()
        : source.toUpperCase();
  }

  String _maskedAccountNumber() {
    final numStr = account.accountNumber?.trim() ?? '';
    if (numStr.length >= 4) {
      final last4 = numStr.substring(numStr.length - 4);
      return '•••• •••• •••• $last4';
    }
    if (numStr.isNotEmpty) return numStr;
    return switch (account.accountType) {
      'cash' => 'Kas Harian',
      'e_wallet' => 'Dompet Digital',
      _ => '•••• •••• •••• 0001',
    };
  }

  String _balanceCaption() {
    return switch (account.accountType) {
      'cash' => 'Dompet Fisik',
      'e_wallet' => 'Kombinasi Saldo',
      'bank' => 'Saldo Utama',
      _ => 'Saldo Pos',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;

    if (compact) {
      return _buildCompactSliderCard(
        context,
        colorScheme,
        textTheme,
        financialColors,
        isDark,
      );
    }

    return _buildIsoDebitCard(context, textTheme, financialColors, isDark);
  }

  Widget _buildCompactSliderCard(
    BuildContext context,
    ColorScheme colorScheme,
    TextTheme textTheme,
    FinancialColors financialColors,
    bool isDark,
  ) {
    final useGradient = featured;
    final fgPrimary = useGradient ? const Color(0xFFFFFFFF) : colorScheme.onSurface;
    final fgMuted = useGradient
        ? const Color(0xFF93C5FD).withValues(alpha: 0.9)
        : colorScheme.onSurfaceVariant;

    final BoxDecoration decoration;
    if (useGradient) {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF0D1B38), Color(0xFF081226)]
              : const [Color(0xFF002855), Color(0xFF0054CC)],
        ),
        border: isDark ? Border.all(color: const Color(0xFF233B68)) : null,
        boxShadow: [
          BoxShadow(
            color: financialColors.brandBlueDark.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF11203D) : const Color(0xFFFFFFFF),
        border: Border.all(
          color: isDark ? const Color(0xFF1E335A) : const Color(0xFFEAEDFF),
        ),
        boxShadow: [
          BoxShadow(
            color: financialColors.brandBlueDark.withValues(alpha: isDark ? 0.25 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      );
    }

    return Container(
      decoration: decoration,
      child: Material(
        color: const Color(0x00000000),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(9),
                        color: useGradient
                            ? financialColors.brandGold.withValues(alpha: 0.20)
                            : (isDark
                                ? const Color(0xFF1A2D54)
                                : const Color(0xFFEAEDFF)),
                        border: useGradient
                            ? Border.all(
                                color: financialColors.brandGold.withValues(alpha: 0.35),
                              )
                            : null,
                      ),
                      child: Center(
                        child: account.accountType == 'bank'
                            ? Text(
                                _codeBadge(),
                                style: FinancialTypography.tabular(
                                  textTheme.labelSmall!,
                                ).copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: useGradient
                                      ? financialColors.brandGold
                                      : financialColors.brandBlueLight,
                                ),
                              )
                            : Icon(
                                accountTypeIcon(account.accountType),
                                size: 17,
                                color: useGradient
                                    ? financialColors.brandGold
                                    : (account.accountType == 'cash'
                                        ? financialColors.income
                                        : financialColors.brandBlueLight),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Expanded(
                      child: Text(
                        account.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleSmall?.copyWith(
                          color: fgPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: useGradient
                            ? financialColors.brandGold.withValues(alpha: 0.22)
                            : (isDark
                                ? const Color(0xFF1E2F50)
                                : const Color(0xFFDAE2FD)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        account.isActive
                            ? accountTypeLabel(account.accountType)
                            : 'ARSIP',
                        style: textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: useGradient
                              ? financialColors.brandGold
                              : (isDark
                                  ? const Color(0xFF93C5FD)
                                  : colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _balanceCaption(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall?.copyWith(color: fgMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hideBalance
                          ? 'Rp ••••••••'
                          : CurrencyFormatter.formatIdr(account.balanceCache),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FinancialTypography.amountList(
                        context,
                        color: account.balanceCache < 0 && !hideBalance
                            ? financialColors.expense
                            : fgPrimary,
                      ).copyWith(fontSize: 17, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: useGradient
                            ? const Color(0xFFFFFFFF).withValues(alpha: 0.14)
                            : (isDark
                                ? const Color(0xFF1A2D54)
                                : const Color(0xFFEAEDFF)),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          _maskedAccountNumber(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: FinancialTypography.tabular(
                            textTheme.labelSmall!,
                          ).copyWith(fontSize: 11, color: fgMuted),
                        ),
                      ),
                      Icon(
                        account.accountType == 'bank'
                            ? Icons.credit_card_outlined
                            : (account.accountType == 'cash'
                                ? Icons.wallet_outlined
                                : Icons.sync_alt_rounded),
                        size: 15,
                        color: useGradient
                            ? financialColors.brandGold
                            : financialColors.brandBlueLight,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIsoDebitCard(
    BuildContext context,
    TextTheme textTheme,
    FinancialColors financialColors,
    bool isDark,
  ) {
    final gradientColors = !account.isActive
        ? [
            const Color(0xFF334155),
            const Color(0xFF1E293B),
          ]
        : (isDark
            ? const [Color(0xFF0D286D), Color(0xFF091A44), Color(0xFF050F29)]
            : const [Color(0xFF002855), Color(0xFF003875), Color(0xFF041D40)]);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        border: isDark
            ? Border.all(color: const Color(0xFF1E3A7A).withValues(alpha: 0.7))
            : null,
        boxShadow: [
          BoxShadow(
            color: financialColors.brandBlueDark.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: const Color(0x00000000),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                Positioned(
                  right: -42,
                  bottom: -42,
                  child: IgnorePointer(
                    child: Container(
                      width: 156,
                      height: 156,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFFFFF).withValues(alpha: 0.06),
                          width: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 20,
                  top: 38,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.contactless_outlined,
                      size: 48,
                      color: const Color(0xFFFFFFFF).withValues(alpha: 0.16),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Card Top: Brand & Metallic Gold EMV Chip
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: AppSpacing.xs,
                                  runSpacing: AppSpacing.xxs,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF)
                                            .withValues(alpha: 0.18),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        account.name,
                                        style: textTheme.titleSmall?.copyWith(
                                          color: const Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      account.isActive
                                          ? accountTypeLabel(account.accountType).toUpperCase()
                                          : 'DIARSIPKAN',
                                      style: textTheme.labelSmall?.copyWith(
                                        color: const Color(0xFFAAC7FD),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  account.institutionName?.trim().isNotEmpty == true
                                      ? account.institutionName!
                                      : 'Rekening ${accountTypeLabel(account.accountType)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF93C5FD),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Metallic Gold EMV Chip
                          Container(
                            width: 38,
                            height: 26,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: const LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Color(0xFFFCD34D),
                                  Color(0xFFFDE68A),
                                  Color(0xFFEAB308),
                                ],
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 24,
                                height: 16,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0x6692400E),
                                  ),
                                ),
                                child: Icon(
                                  accountTypeIcon(account.accountType),
                                  size: 12,
                                  color: const Color(0xFF78350F),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Card Mid: Account Number Mask + Opening Balance inline
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${_maskedAccountNumber()} • Awal ${CurrencyFormatter.formatIdr(account.openingBalance)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FinancialTypography.tabular(
                                textTheme.bodySmall!,
                              ).copyWith(
                                color: const Color(0xFFFFFFFF).withValues(alpha: 0.88),
                                letterSpacing: 0.6,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (onCopyNumber != null)
                            IconButton(
                              onPressed: onCopyNumber,
                              tooltip: 'Salin Nomor Rekening',
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: const Icon(
                                Icons.content_copy_rounded,
                                size: 15,
                                color: Color(0xFFAAC7FD),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Card Bottom: Balance & Active Status
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SALDO BERJALAN',
                                  style: textTheme.labelSmall?.copyWith(
                                    fontSize: 10,
                                    color: const Color(0xFF7490C3),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Text(
                                  hideBalance
                                      ? 'Rp ••••••••'
                                      : CurrencyFormatter.formatIdr(account.balanceCache),
                                  style: FinancialTypography.amountList(
                                    context,
                                    color: account.balanceCache < 0 && !hideBalance
                                        ? financialColors.brandGold
                                        : const Color(0xFFFFFFFF),
                                  ).copyWith(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Status',
                                style: textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                  color: const Color(0xFFAAC7FD),
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: account.isActive
                                          ? const Color(0xFF6EE7B7)
                                          : const Color(0xFFFCA5A5),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    account.isActive ? 'Aktif' : 'Arsip',
                                    style: textTheme.labelMedium?.copyWith(
                                      color: account.isActive
                                          ? const Color(0xFF6EE7B7)
                                          : const Color(0xFFFCA5A5),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final IconData icon;
    final Color accentColor;
    final Color badgeBg;
    final String title;
    final String subtitle;
    final String actionLabel;

    if (syncInfo.status == SyncStateStatus.syncing) {
      icon = Icons.sync;
      accentColor = financialColors.brandBlueLight;
      badgeBg = financialColors.brandBlueLight.withValues(alpha: 0.14);
      title = 'Menyinkronkan Ledger...';
      subtitle = 'Mengirim antrean perubahan ke server';
      actionLabel = 'Proses';
    } else if (syncInfo.status == SyncStateStatus.conflict) {
      icon = Icons.warning_amber_rounded;
      accentColor = financialColors.warning;
      badgeBg = financialColors.warning.withValues(alpha: 0.16);
      title = 'Konflik Sinkronisasi';
      subtitle = '$pendingCount operasi menunggu penyelesaian';
      actionLabel = 'Sinkronkan';
    } else if (!isCloudAuthenticated) {
      icon = Icons.offline_bolt_rounded;
      accentColor = financialColors.brandBlueLight;
      badgeBg = financialColors.brandBlueLight.withValues(alpha: 0.14);
      title = pendingCount > 0
          ? 'Mode Lokal • $pendingCount antrean sync'
          : 'Mode Offline Aktif';
      subtitle = 'Data tersimpan aman secara lokal di SQLite perangkat';
      actionLabel = 'Masuk Cloud';
    } else if (pendingCount > 0 || syncInfo.status == SyncStateStatus.error) {
      icon = Icons.cloud_upload_outlined;
      accentColor = financialColors.warning;
      badgeBg = financialColors.warning.withValues(alpha: 0.16);
      title = '$pendingCount Perubahan Belum Tersinkronisasi';
      subtitle = syncInfo.lastError ?? 'Ketuk sinkronkan saat terhubung ke internet';
      actionLabel = 'Sinkronkan';
    } else {
      icon = Icons.cloud_done_rounded;
      accentColor = financialColors.income;
      badgeBg = financialColors.income.withValues(alpha: 0.14);
      title = 'Tersinkron Penuh (Cloud & Lokal)';
      subtitle = syncInfo.lastSyncAt != null
          ? 'Terakhir: ${DateFormat('dd MMM HH:mm').format(syncInfo.lastSyncAt!.toLocal())}'
          : 'Cursor #${syncInfo.lastCursor} • Ledger konsisten';
      actionLabel = 'Sinkronkan';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
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
              FilledButton.tonal(
                onPressed: syncInfo.status == SyncStateStatus.syncing ? null : onActionPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(AppSpacing.minTouchTarget, 40),
                  backgroundColor: isDark
                      ? financialColors.brandBlueLight.withValues(alpha: 0.22)
                      : colorScheme.secondaryContainer,
                  foregroundColor:
                      isDark ? const Color(0xFF93C5FD) : financialColors.brandBlueLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ],
        ),
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
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: financialColors.brandBlueLight,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
              foregroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF38BDF8)
                  : financialColors.brandBlueLight,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 2),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
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
    final financialColors = Theme.of(context).extension<FinancialColors>()!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: financialColors.brandBlueLight.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 32, color: financialColors.brandBlueLight),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isDark = theme.brightness == Brightness.dark;
    final financialColors = theme.extension<FinancialColors>()!;
    final isVoided = transaction.status == 'voided';

    final IconData icon;
    final Color semanticColor;
    final String signPrefix;
    final String defaultTitle;
    final String typeCaption;

    switch (transaction.type) {
      case 'income':
        icon = Icons.account_balance_wallet_outlined;
        semanticColor = isVoided ? colorScheme.onSurfaceVariant : financialColors.income;
        signPrefix = '+';
        defaultTitle = categoryName ?? 'Pemasukan';
        typeCaption = subtitleMeta ?? 'Masuk';
      case 'expense':
        icon = Icons.shopping_cart_outlined;
        semanticColor = isVoided ? colorScheme.onSurfaceVariant : financialColors.expense;
        signPrefix = '-';
        defaultTitle = categoryName ?? 'Pengeluaran';
        typeCaption = subtitleMeta ?? 'Keluar';
      default:
        icon = Icons.swap_horiz_rounded;
        semanticColor = isVoided ? colorScheme.onSurfaceVariant : financialColors.transfer;
        signPrefix = '';
        defaultTitle = 'Transfer Antar Rekening';
        typeCaption = subtitleMeta ?? 'Transfer';
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
      formattedDate,
      if (categoryName != null && transaction.type != 'transfer') categoryName!,
      if (transaction.type == 'transfer') 'Transfer Internal',
    ];

    return ListTile(
      onTap: onTap,
      minVerticalPadding: AppSpacing.md,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? const Color(0xFF18284C) : colorScheme.surfaceContainer,
          border: isDark ? Border.all(color: const Color(0xFF223B6B)) : null,
        ),
        child: Icon(icon, color: semanticColor, size: 21),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              titleText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
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
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '$signPrefix${CurrencyFormatter.formatIdr(transaction.amount)}',
            style: FinancialTypography.amountList(
              context,
              color: semanticColor,
            ).copyWith(
              fontWeight: FontWeight.w800,
              decoration: isVoided ? TextDecoration.lineThrough : null,
            ),
          ),
          Text(
            typeCaption,
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
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
