import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/language/en/en_translation.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/enums/environment.dart';
import 'package:solidtrade/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> commonMain(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  GetIt getItService = GetIt.instance;
  getItService.registerSingleton<HistoricalPositionService>(HistoricalPositionService());

  // TODO: Load the language depending on what language what saved.
  final languageProvider = LanguageProvider(EnTranslation());
  final themeProvider = ThemeProvider(LightColorTheme());

  getItService.registerSingleton<ConfigurationProvider>(ConfigurationProvider(languageProvider, themeProvider));

  runApp(
    const MyApp(),
  );
}
