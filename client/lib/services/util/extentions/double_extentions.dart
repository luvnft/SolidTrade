import 'package:intl/intl.dart';

const Map<String, String> _currencyTranslations = {
  "USD": "\$",
  "CAD": "\$",
  "EUR": "€",
  "GBP": "£",
  "JPY": "¥",
};

String _currencyCodeToSymbol(String currencyCode) {
  currencyCode = currencyCode.toUpperCase();
  final hasSymbol = _currencyTranslations.containsKey(currencyCode);

  return hasSymbol ? _currencyTranslations[currencyCode]! : currencyCode.toUpperCase();
}

extension StringExtension on double {
  String toDefaultPrice({int maxFractionDigits = 5}) {
    final _format = NumberFormat("###,##0.00", "en_US");
    _format.maximumFractionDigits = maxFractionDigits;

    return _format.format(this) + _currencyCodeToSymbol("EUR");
  }

  String toPrice(String currencyCode, {int maximumFractionDigits = 5}) {
    final _format = NumberFormat("###,##0.00", "en_US");
    _format.maximumFractionDigits = maximumFractionDigits;

    return _format.format(this) + _currencyCodeToSymbol(currencyCode);
  }
}
