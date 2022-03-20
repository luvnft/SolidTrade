import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/data/enums/shared_preferences_keys.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/app/app_update_stream_provider.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/storage/aggregate_history_service.dart';
import 'package:solidtrade/services/stream/floating_action_button_update_service.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/enums/environment.dart';
import 'package:solidtrade/app.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/tr_product_info_service.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/stream/tr_stock_details_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/util.dart';

import '../mapper.g.dart' as mapper;

var navigatorKey = GlobalKey<NavigatorState>();
late MyAppState myAppState;
bool hadFatalException = false;

Future<void> commonMain(Environment environment) async {
  await Startup.initializeApp();

  FlutterError.onError = (details) {
    if (hadFatalException || kDebugMode) return;
    hadFatalException = true;

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      String? token;
      FirebaseAuth.instance.currentUser?.getIdToken().then(((value) {
        token = value;
      }));

      Util.openDialog(navigatorKey.currentState!.context, "Error", messages: [
        FirebaseAuth.instance.currentUser?.uid ?? "uff",
        FirebaseAuth.instance.currentUser?.email ?? "uff",
        token ?? "uff",
      ]);
      // navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) {

      //   return _showErrorHandleMessage(context);
      // }));
    });
  };

  runApp(MyApp(navigatorKey: navigatorKey));
}

class Startup {
  static bool languageHasToBeInitialized = false;
  static bool colorThemeHasToBeInitialized = false;

  static Future<void> initializeApp() async {
    colorThemeHasToBeInitialized = false;
    languageHasToBeInitialized = false;
    hadFatalException = false;

    WidgetsFlutterBinding.ensureInitialized();

    mapper.init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await ConfigReader.initialize();

    final languageTickerIndex = prefs.getInt(SharedPreferencesKeys.langTicker.toString()) ?? _initialLanguage().index;
    final languageProvider = LanguageProvider.byTicker(LanguageTicker.values[languageTickerIndex]);

    final colorThemeIndex = prefs.getInt(SharedPreferencesKeys.colorTheme.toString()) ?? _initialColorTheme().index;
    final themeProvider = ThemeProvider.byThemeType(ColorThemeType.values[colorThemeIndex]);

    final updateProvider = UIUpdateStreamProvider();

    GetIt getItService = GetIt.instance;
    getItService.allowReassignment = true;
    getItService.registerSingleton<SharedPreferences>(prefs);
    getItService.registerSingleton<UserService>(UserService());
    getItService.registerSingleton<PortfolioService>(PortfolioService());
    getItService.registerSingleton<TrStockDetailsService>(TrStockDetailsService());
    getItService.registerSingleton<AggregateHistoryService>(AggregateHistoryService());
    getItService.registerSingleton<HistoricalPositionService>(HistoricalPositionService());

    getItService.registerFactory<TrProductInfoService>(() => TrProductInfoService());
    getItService.registerFactory<TrProductPriceService>(() => TrProductPriceService());

    // Component services.
    getItService.registerSingleton<FloatingActionButtonUpdateService>(FloatingActionButtonUpdateService());

    getItService.registerSingleton<ConfigurationProvider>(ConfigurationProvider(languageProvider, themeProvider, updateProvider));

    DataRequestService.initialize();
  }

  static LanguageTicker _initialLanguage() {
    const defaultTicker = LanguageTicker.en;
    Startup.languageHasToBeInitialized = true;

    return defaultTicker;
  }

  static ColorThemeType _initialColorTheme() {
    const defaultTheme = ColorThemeType.light;
    Startup.colorThemeHasToBeInitialized = true;

    return defaultTheme;
  }
}

Widget _showErrorHandleMessage(BuildContext context) {
  DataRequestService.trApiDataRequestService.disconnect();

  final config = GetIt.instance.get<ConfigurationProvider>();

  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  final shouldAdjust = screenWidth * 0.70 > screenHeight;
  double horizontalMargin = 0;

  if (shouldAdjust) {
    horizontalMargin = 0.15 * screenWidth;
  }

  return SafeArea(
    child: Container(
      margin: shouldAdjust ? EdgeInsets.symmetric(horizontal: horizontalMargin) : const EdgeInsets.all(0),
      child: Scaffold(
        appBar: AppBar(leading: const SizedBox.shrink()),
        backgroundColor: config.themeProvider.theme.background,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Material(
              color: config.themeProvider.theme.softBackground,
              elevation: 5,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    "assets/images/confused_travolta.gif",
                  ),
                  Text(
                    "That's not supposed to happen 🤔",
                    style: Theme.of(context).textTheme.headline5!.copyWith(
                          fontSize: 30,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Well well well, see who's app just crashed.\nThis should not happen again. You can reopen the app to continue.\nSorry for the inconvenience.",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    height: 35,
                    width: screenWidth * .8,
                    child: TextButton(
                      style: ButtonStyle(
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor: MaterialStateProperty.all<Color>(const Color.fromARGB(255, 0, 165, 255)),
                      ),
                      onPressed: () {
                        myAppState.restart();
                      },
                      child: const Text(
                        "Reopen app",
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10)
                ],
              ),
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    ),
  );
}
