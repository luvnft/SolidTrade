import 'package:solidtrade/data/enums/lang_ticker.dart';

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
  ISpashTranslation get splash => SpashTranslation();

  @override
  IUserAppBarTranslation get userAppBar => EnUserAppBarTranslation();

  @override
  ICommonTranslation get common => EnCommonTranslation();
}

class EnCommonTranslation implements ICommonTranslation {
  @override
  String get httpFriendlyErrorResponse => "Something went wrong. Please make sure your input is valid.";
}

class EnPortfolioTranslation implements IPortfolioTranslation {}

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

class SpashTranslation implements ISpashTranslation {
  @override
  String get loading => "Loading";
}
