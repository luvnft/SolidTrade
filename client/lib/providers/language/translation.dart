import 'package:solidtrade/data/enums/lang_ticker.dart';

abstract class ITranslation {
  LanguageTicker get langTicker;

  IPortfolioLanguage get portfolioTranslation;
  ISettingsLanguage get settingsLanguage;
}

abstract class IPortfolioLanguage {}

abstract class ISettingsLanguage {
  String get changeTheme;
  String get changeLanguage;
}
