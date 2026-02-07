import 'package:intl/intl.dart';

String formatCurrency(int value) {
  final formatter = NumberFormat.currency(symbol: '₸', decimalDigits: 0, locale: 'ru');
  return formatter.format(value);
}
