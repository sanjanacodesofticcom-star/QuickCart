import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static final NumberFormat _formatterWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static String format(num amount, {bool showDecimals = false}) {
    if (showDecimals && amount % 1 != 0) {
      return _formatterWithDecimals.format(amount);
    }
    return _formatter.format(amount);
  }
}
