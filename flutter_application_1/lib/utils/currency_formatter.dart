import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String format(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 2,
    );
    return format.format(amount);
  }
}
