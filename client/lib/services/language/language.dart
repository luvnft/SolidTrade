abstract class ITranslation {
  String get appName;

  String get labelInfo;

  String get labelSelectLanguage;

  IPortfolioLanguage get portfolioTranslation;
}

abstract class IPortfolioLanguage {
  String get labelWelcome;
}
