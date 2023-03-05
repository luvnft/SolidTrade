import 'package:flutter/material.dart';

enum LanguageTicker {
  en,
  de,
}

extension LanguageTickerExtension on LanguageTicker {
  Locale get locale {
    switch (this) {
      case LanguageTicker.en:
        return const Locale('en');
      case LanguageTicker.de:
        return const Locale('de');
    }
  }
}
