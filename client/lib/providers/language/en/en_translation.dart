import 'package:solidtrade/data/enums/name_for_large_number.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/services/util/tr_util.dart';

import '../translation.dart';

class EnTranslation implements ITranslation {
  @override
  LanguageTicker get langTicker => LanguageTicker.en;

  @override
  IPortfolioTranslation get portfolio => EnPortfolioTranslation();

  @override
  ISettingsTranslation get settings => EnSettingsTranslation();

  @override
  INavigationBarTranslation get navigationBar => EnNavigationBarTranslation();

  @override
  ISplashTranslation get splash => SplashTranslation();

  @override
  IUserAppBarTranslation get userAppBar => EnUserAppBarTranslation();

  @override
  ICommonTranslation get common => EnCommonTranslation();

  @override
  IProductViewTranslation get productView => EnProductViewTranslation();

  @override
  IChartTranslation get chart => EnChartTranslation();
}

class EnChartTranslation implements IChartTranslation {
  @override
  IChartDateRangeViewTranslation get chartDateRangeView => EnChartDateRangeViewTranslation();
}

class EnChartDateRangeViewTranslation implements IChartDateRangeViewTranslation {
  @override
  String get fiveYear => "5Y";

  @override
  String get oneDay => "1D";

  @override
  String get oneMonth => "1M";

  @override
  String get oneWeek => "1W";

  @override
  String get oneYear => "1Y";

  @override
  String get sixMonth => "6M";
}

class EnCommonTranslation implements ICommonTranslation {
  @override
  String get httpFriendlyErrorResponse => "Something went wrong. Please make sure your input is valid.";
}

class EnPortfolioTranslation implements IPortfolioTranslation {}

class EnProductViewTranslation implements IProductViewTranslation {
  @override
  String whatAnalystsSayContent(TrStockDetails details) {
    return "The average share price estimate lays by ${details.analystRating.targetPrice.average.toStringAsFixed(2)}. The highest estimate is ${details.analystRating.targetPrice.high.toStringAsFixed(2)}€ and the lowest estimate ${details.analystRating.targetPrice.low.toStringAsFixed(2)}€.\n\nThis stock is evaluated by ${TrUtil.productViewGetAnalystsCount(details.analystRating.recommendations)} analysts.";
  }

  @override
  String nameOfNumberPrefix(NameForLargeNumber nameForLargeNumber) {
    switch (nameForLargeNumber) {
      case NameForLargeNumber.billion:
        return "B";
      case NameForLargeNumber.million:
        return "M";
      case NameForLargeNumber.thousand:
      case NameForLargeNumber.trillion:
        return "T";
    }
  }

  @override
  String get marketCap => "Market cap";

  @override
  String get derivativesRiskDisclaimer => "Please be aware that these types of investments come with high risk.";
}

class EnUserAppBarTranslation implements IUserAppBarTranslation {
  @override
  String get invite => "Invite";
}

class EnSettingsTranslation implements ISettingsTranslation {
  @override
  String get changeLanguage => "Change language.";

  @override
  String get changeTheme => "Change theme.";

  @override
  String get settings => "Settings";
}

class EnNavigationBarTranslation implements INavigationBarTranslation {
  @override
  String get leaderboard => SharedTranslations.navigationBarChat;

  @override
  String get portfolio => SharedTranslations.navigationBarPortfolio;

  @override
  String get profile => "Profile";

  @override
  String get search => "Search";
}

class SplashTranslation implements ISplashTranslation {
  @override
  String get loading => "Loading";
}
