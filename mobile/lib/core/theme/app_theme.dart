import 'package:material_ui/material_ui.dart';

import 'design_tokens.dart';
import 'financial_colors.dart';

class AppTheme {
  const AppTheme._();

  // Stitch "Sapphire Dynamic" Deep Sapphire Seed
  static const Color _seedColor = Color(0xFF002855);

  static ThemeData get lightTheme => _buildTheme(Brightness.light);

  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final financialColors = isLight ? FinancialColors.light : FinancialColors.dark;
    final baseScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: brightness,
      primary: isLight ? financialColors.brandBlue : const Color(0xFF38BDF8),
      secondary: financialColors.brandBlueLight,
      onSecondary: const Color(0xFFFFFFFF),
      tertiary: financialColors.brandGold,
      onTertiary: financialColors.onBrandGold,
    );

    final colorScheme = baseScheme.copyWith(
      primary: isLight ? const Color(0xFF002855) : const Color(0xFF38BDF8),
      onPrimary: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF00287E),
      primaryContainer: isLight ? const Color(0xFF002855) : const Color(0xFF1E60FF),
      onPrimaryContainer: isLight ? const Color(0xFF7490C3) : const Color(0xFFF2F2FF),
      secondary: isLight ? const Color(0xFF136BFB) : const Color(0xFF1E60FF),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: isLight ? const Color(0xFFDAE2FF) : const Color(0xFF132240),
      onSecondaryContainer: isLight ? const Color(0xFF0040A1) : const Color(0xFF93C5FD),
      surface: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0E1B33),
      onSurface: isLight ? const Color(0xFF131B2E) : const Color(0xFFF8FAFC),
      onSurfaceVariant: isLight ? const Color(0xFF43474F) : const Color(0xFF94A3B8),
      surfaceContainerLow: isLight ? const Color(0xFFF2F3FF) : const Color(0xFF0D172D),
      surfaceContainer: isLight ? const Color(0xFFEAEDFF) : const Color(0xFF11203D),
      surfaceContainerHigh: isLight ? const Color(0xFFE2E7FF) : const Color(0xFF132240),
      surfaceContainerHighest: isLight ? const Color(0xFFDAE2FD) : const Color(0xFF2B354A),
      outlineVariant: isLight ? const Color(0xFFC4C6D0) : const Color(0xFF1E335A),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: financialColors.canvasBackground,
      extensions: [financialColors],
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: isLight ? const Color(0xFF002855) : const Color(0xFF091327),
        foregroundColor: const Color(0xFFFFFFFF),
        iconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        actionsIconTheme: const IconThemeData(color: Color(0xFFFFFFFF)),
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFFFF),
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: isLight ? 1.0 : 0,
        shadowColor: financialColors.brandBlueDark.withValues(alpha: 0.06),
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isLight ? const Color(0xFFEAEDFF) : const Color(0xFF1E335A),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: isLight ? const Color(0xFFEAEDFF) : const Color(0xFF172748),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: AppSpacing.md,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.xs,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.55)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: financialColors.brandBlueLight, width: 1.8),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          backgroundColor: financialColors.brandBlueLight,
          foregroundColor: const Color(0xFFFFFFFF),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
          side: BorderSide(color: colorScheme.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: financialColors.brandBlueLight,
        foregroundColor: const Color(0xFFFFFFFF),
        elevation: 6,
        shape: const CircleBorder(),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.65)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 6,
        backgroundColor: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF091327),
        surfaceTintColor: const Color(0x00000000),
        indicatorColor: financialColors.brandBlueLight.withValues(alpha: isLight ? 0.14 : 0.22),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(
              color: isLight ? financialColors.brandBlueLight : const Color(0xFF38BDF8),
            );
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: isLight ? financialColors.brandBlueLight : const Color(0xFF38BDF8),
            );
          }
          return TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF091327),
        indicatorColor: financialColors.brandBlueLight.withValues(alpha: isLight ? 0.14 : 0.22),
        selectedIconTheme: IconThemeData(
          color: isLight ? financialColors.brandBlueLight : const Color(0xFF38BDF8),
        ),
        labelType: NavigationRailLabelType.all,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: financialColors.brandBlueDark,
        contentTextStyle: const TextStyle(color: Color(0xFFFFFFFF)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
