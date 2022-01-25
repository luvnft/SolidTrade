import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/providers/language/translation.dart';

import 'de/de_translation.dart';
import 'en/en_translation.dart';

class LanguageProvider {
  ITranslation get language => _currentTranslation;
  late ITranslation _currentTranslation;

  factory LanguageProvider.byTicker(LanguageTicker ticker) {
    ITranslation lang;
    switch (ticker) {
      case LanguageTicker.en:
        lang = EnTranslation();
        break;
      case LanguageTicker.de:
        lang = DeTranslation();
        break;
    }

    return LanguageProvider(lang);
  }

  LanguageProvider(this._currentTranslation);

  void updateLanguage(ITranslation lang) {
    _currentTranslation = lang;
  }
}
