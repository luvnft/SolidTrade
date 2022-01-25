import 'package:solidtrade/data/enums/lang_ticker.dart';

import '../translation.dart';

class EnTranslation implements ITranslation {
  @override
  LanguageTicker get langTicker => LanguageTicker.en;

  @override
  IPortfolioLanguage get portfolioTranslation => EnPortfolioLanguage();

  @override
  ISettingsLanguage get settingsLanguage => EnSettingsLanguage();
}

class EnPortfolioLanguage implements IPortfolioLanguage {
  @override
  String get labelWelcome => "Welcome to solid trade";
}

class EnSettingsLanguage implements ISettingsLanguage {
  @override
  String get changeLanguage => "Change language.";

  @override
  String get changeTheme => "Change theme.";
}
