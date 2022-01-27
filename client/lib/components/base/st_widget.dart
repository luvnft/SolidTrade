import 'package:get_it/get_it.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/app/app_update_stream_provider.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class STWidget {
  final configurationProvider = GetIt.instance.get<ConfigurationProvider>();

  ITranslation get translation => configurationProvider.languageProvider.language;
  IColorTheme get colors => configurationProvider.themeProvider.theme;
  UIUpdateStreamProvider get uiUpdate => configurationProvider.uiUpdateProvider;
}
