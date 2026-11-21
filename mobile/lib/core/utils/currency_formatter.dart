import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  /// Formats an integer IDR amount, e.g. 1500000 -> "Rp1.500.000", -50000 -> "-Rp50.000".
  static String formatIdr(int amount) {
    final formatted = _idrFormat.format(amount.abs());
    return amount < 0 ? '-$formatted' : formatted;
  }
}

