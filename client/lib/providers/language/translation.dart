import 'package:solidtrade/components/shared/name_for_large_number.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';

abstract class ITranslation {
  LanguageTicker get langTicker;

  IProductViewTranslation get productView;
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

abstract class IProductViewTranslation {
  String whatAnalystsSayContent(TrStockDetails details);
  String nameOfNumberPrefix(NameForLargeNumber nameForLargeNumber);
  String get marketCap;
  String get derivativesRiskDisclaimer;
}

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
