import 'package:material_ui/material_ui.dart';

@immutable
class FinancialColors extends ThemeExtension<FinancialColors> {
  const FinancialColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.balance,
    required this.brandBlue,
    required this.brandBlueDark,
    required this.brandBlueLight,
    required this.brandGold,
    required this.onBrandGold,
    required this.canvasBackground,
  });

  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;
  final Color balance;
  final Color brandBlue;
  final Color brandBlueDark;
  final Color brandBlueLight;
  final Color brandGold;
  final Color onBrandGold;
  final Color canvasBackground;

  static const light = FinancialColors(
    income: Color(0xFF00A86B),
    expense: Color(0xFFBA1A1A),
    transfer: Color(0xFF0054CC),
    warning: Color(0xFFF59E0B),
    balance: Color(0xFF002855),
    brandBlue: Color(0xFF002855),
    brandBlueDark: Color(0xFF001430),
    brandBlueLight: Color(0xFF136BFB),
    brandGold: Color(0xFFFFB956),
    onBrandGold: Color(0xFF2A1800),
    canvasBackground: Color(0xFFFAF8FF),
  );

  static const dark = FinancialColors(
    income: Color(0xFF4ADE80),
    expense: Color(0xFFF87171),
    transfer: Color(0xFF38BDF8),
    warning: Color(0xFFFFB95F),
    balance: Color(0xFF38BDF8),
    brandBlue: Color(0xFF0D286D),
    brandBlueDark: Color(0xFF050F29),
    brandBlueLight: Color(0xFF1E60FF),
    brandGold: Color(0xFFFFB95F),
    onBrandGold: Color(0xFF2A1700),
    canvasBackground: Color(0xFF091327),
  );

  @override
  FinancialColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? warning,
    Color? balance,
    Color? brandBlue,
    Color? brandBlueDark,
    Color? brandBlueLight,
    Color? brandGold,
    Color? onBrandGold,
    Color? canvasBackground,
  }) {
    return FinancialColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      warning: warning ?? this.warning,
      balance: balance ?? this.balance,
      brandBlue: brandBlue ?? this.brandBlue,
      brandBlueDark: brandBlueDark ?? this.brandBlueDark,
      brandBlueLight: brandBlueLight ?? this.brandBlueLight,
      brandGold: brandGold ?? this.brandGold,
      onBrandGold: onBrandGold ?? this.onBrandGold,
      canvasBackground: canvasBackground ?? this.canvasBackground,
    );
  }

  @override
  FinancialColors lerp(ThemeExtension<FinancialColors>? other, double t) {
    if (other is! FinancialColors) return this;
    return FinancialColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      balance: Color.lerp(balance, other.balance, t)!,
      brandBlue: Color.lerp(brandBlue, other.brandBlue, t)!,
      brandBlueDark: Color.lerp(brandBlueDark, other.brandBlueDark, t)!,
      brandBlueLight: Color.lerp(brandBlueLight, other.brandBlueLight, t)!,
      brandGold: Color.lerp(brandGold, other.brandGold, t)!,
      onBrandGold: Color.lerp(onBrandGold, other.onBrandGold, t)!,
      canvasBackground: Color.lerp(canvasBackground, other.canvasBackground, t)!,
    );
  }
}
