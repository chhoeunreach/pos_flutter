import 'package:intl/intl.dart';

class MoneyFormatter {
  static MoneyFormatter? _instance;
  String _currencySymbol = '\$';
  int _decimalDigits = 2;
  String _thousandSeparator = ',';

  MoneyFormatter._();

  static MoneyFormatter get instance {
    _instance ??= MoneyFormatter._();
    return _instance!;
  }

  void configure({
    String currencySymbol = '\$',
    int decimalDigits = 2,
    String thousandSeparator = ',',
  }) {
    _currencySymbol = currencySymbol;
    _decimalDigits = decimalDigits;
    _thousandSeparator = thousandSeparator;
  }

  String format(dynamic amount) {
    double value;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else if (amount is int) {
      value = amount.toDouble();
    } else {
      value = (amount as num?)?.toDouble() ?? 0.0;
    }

    final formatter = NumberFormat(
      '#,##0.${'0' * _decimalDigits}',
      'en_US',
    );
    return '$_currencySymbol${formatter.format(value)}';
  }

  String formatWithoutSymbol(dynamic amount) {
    double value;
    if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    } else if (amount is int) {
      value = amount.toDouble();
    } else {
      value = (amount as num?)?.toDouble() ?? 0.0;
    }

    final formatter = NumberFormat(
      '#,##0.${'0' * _decimalDigits}',
      'en_US',
    );
    return formatter.format(value);
  }

  double parse(String text) {
    var cleaned = text.replaceAll(_currencySymbol, '');
    cleaned = cleaned.replaceAll(_thousandSeparator, '');
    cleaned = cleaned.replaceAll(' ', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  String get currencySymbol => _currencySymbol;
  int get decimalDigits => _decimalDigits;

  void reset() {
    _currencySymbol = '\$';
    _decimalDigits = 2;
    _thousandSeparator = ',';
  }
}
