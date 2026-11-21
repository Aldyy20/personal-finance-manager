import 'package:material_ui/material_ui.dart';

/// 4/8dp spacing rhythm tokens (UI/UX Pro Max & Material Design 3).
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double section = 48;

  static const double minTouchTarget = 48;
  static const double compactBreakpoint = 840;
}

/// Consistent shape radius tokens aligned with Material Design 3 containment.
class AppRadius {
  const AppRadius._();

  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
}

/// Purposeful motion durations and curves with reduced-motion helper.
class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration emphasized = Duration(milliseconds: 280);
  static const Curve standardCurve = Curves.easeOutCubic;

  static Duration resolve(BuildContext context, Duration preferred) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : preferred;
  }
}

/// Numeric typography helpers enforcing tabular figures for financial amounts.
class FinancialTypography {
  const FinancialTypography._();

  static TextStyle tabular(TextStyle base) {
    return base.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  static TextStyle heroBalance(BuildContext context) {
    final base = Theme.of(context).textTheme.headlineLarge ??
        const TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
    return tabular(base).copyWith(
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    );
  }

  static TextStyle amountList(BuildContext context, {Color? color}) {
    final base = Theme.of(context).textTheme.titleMedium ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
    return tabular(base).copyWith(
      fontWeight: FontWeight.w600,
      color: color,
    );
  }
}

