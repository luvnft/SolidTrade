import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/models/enums/client_enums/environment.dart';
import 'package:solidtrade/data/models/enums/client_enums/lang_ticker.dart';
import 'package:solidtrade/data/models/enums/client_enums/shared_preferences_keys.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/app/app_update_stream_provider.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/request/data_request_service.dart';
import 'package:solidtrade/services/stream/aggregate_history_service.dart';
import 'package:solidtrade/services/stream/floating_action_button_update_service.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/app.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/services/stream/knockout_service.dart';
import 'package:solidtrade/services/stream/messaging_service.dart';
import 'package:solidtrade/services/stream/ongoing_knockout_service.dart';
import 'package:solidtrade/services/stream/ongoing_warrant_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/stock_service.dart';
import 'package:solidtrade/services/stream/tr_derivatives_search_service.dart';
import 'package:solidtrade/services/stream/tr_product_info_service.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/stream/tr_product_search_service.dart';
import 'package:solidtrade/services/stream/tr_stock_details_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/stream/warrant_service.dart';
import 'package:http/http.dart' as http;

import '../mapper.g.dart' as mapper;

String generateRandomString(int len) {
  var r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}

Future<void> commonMain(Environment env) async {
  await Startup.initializeApp(env);

  var _logsUri = Uri.https(ConfigReader.getBaseUrl(), "/logs");
  var id = generateRandomString(10);

  runZoned(() {
    _registerFlutterErrorHandler(env);

    runApp(SolidtradeApp(navigatorKey: Globals.navigatorKey));
  },
      // ignore: unnecessary_new
      zoneSpecification: new ZoneSpecification(
        print: (Zone self, ZoneDelegate parent, Zone zone, String line) => _makeRequest(_logsUri, id, "log", line),
        errorCallback: (Zone self, ZoneDelegate parent, Zone zone, Object object, StackTrace? stacktrace) {
          _makeRequest(_logsUri, id, "error - $object", stacktrace.toString());
        },
      ));
}

void _makeRequest(Uri uri, String id, String title, String? message) {
  Map<String, dynamic> map = {};
  map["SenderId"] = id;
  map["Title"] = title;
  map["Message"] = message;

  var data = json.encode(map);

  dev.log("json: $data");
  http.post(
    uri,
    headers: {
      "Content-Type": "application/json"
    },
    body: data,
  );
}

void _registerFlutterErrorHandler(Environment environment) {
  var isShowingErrorSnackBar = false;

  FlutterError.onError = (details) {
    // We can exclude image errors, because these are already being handled.
    if (details.exception is Exception && (details.exception as Exception).toString().contains("Invalid image data")) {
      return;
    }

    if (environment != Environment.production) {
      // ignore: avoid_print
      print(details);
    }

    WidgetsBinding.instance?.addPostFrameCallback((_) {
      // We dont want to stack error snack bars. There for we only create one, if there currently is not other.
      if (isShowingErrorSnackBar) {
        return;
      }

      isShowingErrorSnackBar = true;
      Future.delayed(const Duration(seconds: 1), () {
        final context = Globals.navigatorKey.currentState!.context;
        final snackBar = SnackBar(
          duration: const Duration(seconds: 15),
          content: Row(children: [
            const Flexible(
              child: Text('We are sorry. Something went wrong. If you are facing any issues reload the app.'),
            ),
            SnackBarAction(
              label: 'Reload',
              onPressed: () async => await Globals.appState.restart(),
              textColor: Colors.red,
            ),
            SnackBarAction(
              label: 'Dismiss',
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              textColor: Colors.blue,
            ),
          ]),
        );

        ScaffoldMessenger.of(context).showSnackBar(snackBar).closed.then((_) => isShowingErrorSnackBar = false);
      });
    });
  };
}

class Globals {
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  static late SolidtradeAppState appState;
  static late Environment environment;
}

class Startup {
  static bool languageHasToBeInitialized = false;
  static bool colorThemeHasToBeInitialized = false;

  static Future<void> initializeApp(Environment env) async {
    Globals.environment = env;
    colorThemeHasToBeInitialized = false;
    languageHasToBeInitialized = false;

    WidgetsFlutterBinding.ensureInitialized();
    mapper.init();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await ConfigReader.initialize();

    _initializeServices(prefs);
    _initializeGoogleFonts();

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

  static void _initializeServices(SharedPreferences prefs) {
    final languageTickerIndex = prefs.getInt(SharedPreferencesKeys.langTicker.toString()) ?? _initialLanguage().index;
    final languageProvider = LanguageProvider.byTicker(LanguageTicker.values[languageTickerIndex]);

    final colorThemeIndex = prefs.getInt(SharedPreferencesKeys.colorTheme.toString()) ?? _initialColorTheme().index;
    final themeProvider = ThemeProvider.byThemeType(ColorThemeType.values[colorThemeIndex]);

    final updateProvider = UIUpdateStreamProvider();

    GetIt services = GetIt.instance;
    services.allowReassignment = true;
    services.registerSingleton<Logger>(Logger.create());
    services.registerSingleton<SharedPreferences>(prefs);
    services.registerSingleton<UserService>(UserService());
    services.registerSingleton<StockService>(StockService());
    services.registerSingleton<WarrantService>(WarrantService());
    services.registerSingleton<KnockoutService>(KnockoutService());
    services.registerSingleton<OngoingWarrantService>(OngoingWarrantService());
    services.registerSingleton<OngoingKnockoutService>(OngoingKnockoutService());
    services.registerSingleton<PortfolioService>(PortfolioService());
    services.registerSingleton<MessagingService>(MessagingService());
    services.registerSingleton<TrStockDetailsService>(TrStockDetailsService());
    services.registerSingleton<TrProductSearchService>(TrProductSearchService());
    services.registerSingleton<TrDerivativesSearchService>(TrDerivativesSearchService());
    services.registerSingleton<AggregateHistoryService>(AggregateHistoryService());
    services.registerSingleton<HistoricalPositionService>(HistoricalPositionService());

    services.registerFactory<TrProductInfoService>(() => TrProductInfoService());
    services.registerFactory<TrProductPriceService>(() => TrProductPriceService());

    // Component services.
    services.registerSingleton<FloatingActionButtonUpdateService>(FloatingActionButtonUpdateService());

    services.registerSingleton<ConfigurationProvider>(ConfigurationProvider(languageProvider, themeProvider, updateProvider));
  }

  static void _initializeGoogleFonts() {
    GoogleFonts.config.allowRuntimeFetching = false;

    LicenseRegistry.addLicense(() async* {
      final license = await rootBundle.loadString('assets/fonts/OFL.txt');
      yield LicenseEntryWithLineBreaks([
        'google_fonts'
      ], license);
    });
  }
}
