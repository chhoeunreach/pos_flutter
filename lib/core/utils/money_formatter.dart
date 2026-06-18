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
    final value = _toDouble(amount);

    final formatter = NumberFormat(
      '#,##0.${'0' * _decimalDigits}',
      'en_US',
    );
    return '$_currencySymbol${formatter.format(value)}';
  }

  String formatWithoutSymbol(dynamic amount) {
    final value = _toDouble(amount);

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

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '').trim()) ?? 0.0;
    }
    if (value is Map) {
      for (final key in const [
        'amount',
        'total',
        'value',
        'final_total',
        'total_amount',
        'sum',
      ]) {
        if (value.containsKey(key)) return _toDouble(value[key]);
      }
      for (final entryValue in value.values) {
        final parsed = _toDouble(entryValue);
        if (parsed != 0) return parsed;
      }
      return 0.0;
    }
    if (value is Iterable) {
      return value.fold<double>(0.0, (sum, item) => sum + _toDouble(item));
    }
    return 0.0;
  }
}
