import 'package:solidtrade/services/language/language.dart';

class EnTranslation implements ITranslation {
  @override
  String get appName => throw UnimplementedError();

  @override
  String get labelInfo => throw UnimplementedError();

  @override
  String get labelSelectLanguage => throw UnimplementedError();

  @override
  IPortfolioLanguage get portfolioTranslation => EnPortfolioLanguage();
}

class EnPortfolioLanguage implements IPortfolioLanguage {
  @override
  String get labelWelcome => "Welcome to solid trade";
}
