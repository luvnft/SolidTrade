import 'package:solidtrade/data/enums/name_for_large_number.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';

abstract class ITranslation {
  LanguageTicker get langTicker;

  IProductViewTranslation get productView;
  IPortfolioTranslation get portfolio;
  ISettingsTranslation get settings;
  INavigationBarTranslation get navigationBar;
  ISplashTranslation get splash;
  IUserAppBarTranslation get userAppBar;
  IChartTranslation get chart;
  ICommonTranslation get common;
  IWelcomeTranslation get welcome;
}

class SharedTranslations {
  static const String navigationBarPortfolio = "Portfolio";
  static const String navigationBarChat = "Leaderboard";

  static const List<String> welcomeMessages = [
    "Welcome to",
    "Willkommen zu",
    "Velkommen til",
    "Bienvenue à",
    "ようこそ",
    "Bienvenido a",
    "欢迎来到",
  ];
}

abstract class IChartTranslation {
  IChartDateRangeViewTranslation get chartDateRangeView;
}

abstract class IWelcomeTranslation {
  String get getStarted;
}

abstract class IChartDateRangeViewTranslation {
  String get oneDay;
  String get oneWeek;
  String get oneMonth;
  String get sixMonth;
  String get oneYear;
  String get fiveYear;
}

abstract class ICommonTranslation {
  String get httpFriendlyErrorResponse;
}

abstract class ISplashTranslation {
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
