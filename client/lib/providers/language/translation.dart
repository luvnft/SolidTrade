import 'package:solidtrade/data/enums/lang_ticker.dart';

abstract class ITranslation {
  LanguageTicker get langTicker;

  IPortfolioTranslation get portfolio;
  ISettingsTranslation get settings;
  INavigationBarTranslation get navigationBar;
  ISpashTranslation get splash;
  IUserAppBarTranslation get userAppBar;
  ICommonTranslation get common;
}

class SharedTranslations {
  static const String navigationBarPortfolio = "Portfolio";
  static const String navigationBarChat = "Leaderboard";
}

abstract class ICommonTranslation {
  String get httpFriendlyErrorResponse;
}

abstract class ISpashTranslation {
  String get loading;
}

abstract class IPortfolioTranslation {}

abstract class IUserAppBarTranslation {
  String get invite;
}

abstract class INavigationBarTranslation {
  String get portfolio;
  String get search;
  String get leaderboard;
  String get profile;
}

abstract class ISettingsTranslation {
  String get settings;
  String get changeTheme;
  String get changeLanguage;
}
