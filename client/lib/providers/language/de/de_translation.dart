import 'package:solidtrade/data/enums/lang_ticker.dart';

import '../translation.dart';

class DeTranslation implements ITranslation {
  @override
  LanguageTicker get langTicker => LanguageTicker.de;

  @override
  IPortfolioTranslation get portfolio => DePortfolioTranslation();

  @override
  ISettingsTranslation get settings => DeSettingsTranslation();

  @override
  INavigationBarTranslation get navigationBar => DeNavigationBarTranslation();

  @override
  ISpashTranslation get splash => DeSpashTranslation();

  @override
  IUserAppBarTranslation get userAppBar => DeUserAppBarTranslation();

  @override
  ICommonTranslation get common => DeCommonTranslation();
}

class DeCommonTranslation implements ICommonTranslation {
  @override
  String get httpFriendlyErrorResponse => "Es ist ein Fehler aufgetreten. Bitte vergewissern Sie sich, dass Ihre Eingabe gültig ist.";
}

class DePortfolioTranslation implements IPortfolioTranslation {}

class DeUserAppBarTranslation implements IUserAppBarTranslation {
  @override
  String get invite => "Einladen";
}

class DeSpashTranslation implements ISpashTranslation {
  @override
  String get loading => "Lädt";
}

class DeNavigationBarTranslation implements INavigationBarTranslation {
  @override
  String get chat => SharedTranslations.navigationBarChat;

  @override
  String get portfolio => SharedTranslations.navigationBarPortfolio;

  @override
  String get profile => "Profil";

  @override
  String get search => "Suchen";
}

class DeSettingsTranslation implements ISettingsTranslation {
  @override
  String get changeLanguage => "Ändere die spache.";

  @override
  String get changeTheme => "Ändere denn farbmodus.";

  @override
  String get settings => "Einstellungen";
}
