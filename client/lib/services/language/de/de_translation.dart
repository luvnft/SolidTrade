import 'package:solidtrade/services/language/language.dart';

class DeTranslation implements ITranslation {
  @override
  String get appName => throw UnimplementedError();

  @override
  String get labelInfo => throw UnimplementedError();

  @override
  String get labelSelectLanguage => throw UnimplementedError();

  @override
  IPortfolioLanguage get portfolioTranslation => DePortfolioLanguage();
}

class DePortfolioLanguage implements IPortfolioLanguage {
  @override
  String get labelWelcome => "Willkommen zu solid trade";
}
