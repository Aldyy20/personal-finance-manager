import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyFormatter {
  const CurrencyFormatter._();

  static final NumberFormat _idrFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static final NumberFormat _thousandsFormat = NumberFormat('#,##0', 'id_ID');

  /// Formats an integer IDR amount, e.g. 1500000 -> "Rp1.500.000", -50000 -> "-Rp50.000".
  static String formatIdr(int amount) {
    final formatted = _idrFormat.format(amount.abs());
    return amount < 0 ? '-$formatted' : formatted;
  }

  /// Formats an integer with dot thousands separators, e.g. 1500000 -> "1.500.000".
  static String formatThousands(int amount) {
    final formatted = _thousandsFormat.format(amount.abs());
    return amount < 0 ? '-$formatted' : formatted;
  }
}

/// Automatically inserts dot (`.`) thousands separators while typing nominal amounts.
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  const ThousandsSeparatorInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    final parsed = int.tryParse(digits);
    if (parsed == null) {
      return oldValue;
    }

    final formatted = CurrencyFormatter.formatThousands(parsed);
    final selEnd = newValue.selection.end;
    if (selEnd < 0 || selEnd >= newValue.text.length) {
      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    final digitsRightOfCursor = newValue.text
        .substring(selEnd)
        .replaceAll(RegExp(r'[^0-9]'), '')
        .length;

    if (digitsRightOfCursor >= digits.length) {
      return TextEditingValue(
        text: formatted,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    var digitsSeenFromRight = 0;
    var targetOffset = formatted.length;
    for (var i = formatted.length - 1; i >= 0; i--) {
      if (digitsSeenFromRight == digitsRightOfCursor) {
        targetOffset = i + 1;
        break;
      }
      final code = formatted.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        digitsSeenFromRight++;
      }
      if (digitsSeenFromRight == digitsRightOfCursor) {
        targetOffset = i;
        break;
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: targetOffset.clamp(0, formatted.length),
      ),
    );
  }
}

