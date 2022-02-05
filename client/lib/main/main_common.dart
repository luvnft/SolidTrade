import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/data/enums/shared_preferences_keys.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/app/app_update_stream_provider.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/floating_action_button_update_service.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/enums/environment.dart';
import 'package:solidtrade/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/tr_product_info_service.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';

import '../mapper.g.dart' as mapper;

class Startup {
  static bool languageHasToBeInitialized = false;
  static bool colorThemeHasToBeInitialized = false;
}

Future<void> commonMain(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();

  mapper.init();

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await ConfigReader.initialize();

  final languageTickerIndex = prefs.getInt(SharedPreferencesKeys.langTicker.toString()) ?? initialLanguage().index;
  final languageProvider = LanguageProvider.byTicker(LanguageTicker.values[languageTickerIndex]);

  final colorThemeIndex = prefs.getInt(SharedPreferencesKeys.colorTheme.toString()) ?? initialColorTheme().index;
  final themeProvider = ThemeProvider.byThemeType(ColorThemeType.values[colorThemeIndex]);

  final updateProvider = UIUpdateStreamProvider();

  GetIt getItService = GetIt.instance;
  getItService.registerSingleton<SharedPreferences>(prefs);
  getItService.registerSingleton<UserService>(UserService());
  getItService.registerSingleton<PortfolioService>(PortfolioService());
  getItService.registerSingleton<HistoricalPositionService>(HistoricalPositionService());

  getItService.registerFactory<TrProductInfoService>(() => TrProductInfoService());
  getItService.registerFactory<TrProductPriceService>(() => TrProductPriceService());

  // Component services.
  getItService.registerSingleton<FloatingActionButtonUpdateService>(FloatingActionButtonUpdateService());

  getItService.registerSingleton<ConfigurationProvider>(ConfigurationProvider(languageProvider, themeProvider, updateProvider));

  runApp(MyApp());
}

LanguageTicker initialLanguage() {
  const defaultTicker = LanguageTicker.en;
  Startup.languageHasToBeInitialized = true;

  return defaultTicker;
}

ColorThemeType initialColorTheme() {
  const defaultTheme = ColorThemeType.light;
  Startup.colorThemeHasToBeInitialized = true;

  return defaultTheme;
}
