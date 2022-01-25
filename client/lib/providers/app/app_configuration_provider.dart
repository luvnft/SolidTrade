import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class ConfigurationProvider {
  LanguageProvider get languageProvider => _languageProvider;
  final LanguageProvider _languageProvider;

  ThemeProvider get themeProvider => _themeProvider;
  final ThemeProvider _themeProvider;

  ConfigurationProvider(this._languageProvider, this._themeProvider);
}
