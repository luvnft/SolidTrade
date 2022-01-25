import 'package:solidtrade/data/enums/lang_ticker.dart';

import '../translation.dart';

class DeTranslation implements ITranslation {
  @override
  LanguageTicker get langTicker => LanguageTicker.de;

  @override
  IPortfolioLanguage get portfolioTranslation => DePortfolioLanguage();

  @override
  ISettingsLanguage get settingsLanguage => DeSettingsLanguage();
}

class DePortfolioLanguage implements IPortfolioLanguage {
  @override
  String get labelWelcome => "Willkommen zu solid trade";
}

class DeSettingsLanguage implements ISettingsLanguage {
  @override
  String get changeLanguage => "Ändere die spache.";

  @override
  String get changeTheme => "Ändere denn farbmodus.";
}
