import 'package:material_ui/material_ui.dart';

@immutable
class FinancialColors extends ThemeExtension<FinancialColors> {
  const FinancialColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.balance,
  });

  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;
  final Color balance;

  static const light = FinancialColors(
    income: Color(0xFF1B8A5A),
    expense: Color(0xFFBA1A1A),
    transfer: Color(0xFF3F5F90),
    warning: Color(0xFFD97706),
    balance: Color(0xFF00695C),
  );

  static const dark = FinancialColors(
    income: Color(0xFF6DD58C),
    expense: Color(0xFFFFB4AB),
    transfer: Color(0xFFA8C7FA),
    warning: Color(0xFFFBBF24),
    balance: Color(0xFF80CBC4),
  );

  @override
  FinancialColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? warning,
    Color? balance,
  }) {
    return FinancialColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      warning: warning ?? this.warning,
      balance: balance ?? this.balance,
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
    );
  }
}

