import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:solidtrade/app/main_common.dart';
import 'package:solidtrade/data/models/enums/client_enums/lang_ticker.dart';
import 'package:solidtrade/pages/common/pre_splash.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

// ignore: must_be_immutable
class SolidtradeApp extends StatefulWidget {
  SolidtradeApp({Key? key, required this.navigatorKey}) : super(key: key);
  GlobalKey<NavigatorState> navigatorKey;

  @override
  State<SolidtradeApp> createState() => SolidtradeAppState();
}

class SolidtradeAppState extends State<SolidtradeApp> {
  @override
  void initState() {
    Globals.appState = this;
    super.initState();
  }

  Future<void> restart() async {
    await DataRequestService.trApiDataRequestService.disconnect();

    Startup.initializeApp(Globals.environment);
    setState(() {
      widget.navigatorKey = GlobalKey<NavigatorState>();
      Globals.navigatorKey = widget.navigatorKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    var configurationProvider = GetIt.instance.get<ConfigurationProvider>();
    final uiUpdate = configurationProvider.uiUpdateProvider;

    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, _) {
        final colors = configurationProvider.themeProvider.theme;
        final ticker = configurationProvider.languageProvider.language.langTicker;

        return MaterialApp(
          title: 'Solidtrade™',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          locale: ticker.locale,
          supportedLocales: const [
            Locale('en'),
            Locale('de'),
          ],
          themeMode: colors.themeColorType == ColorThemeType.light ? ThemeMode.light : ThemeMode.dark,
          theme: ThemeData.light().copyWith(
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          darkTheme: ThemeData.dark().copyWith(
            useMaterial3: true,
            textTheme: GoogleFonts.poppinsTextTheme(
              ThemeData(brightness: Brightness.dark).textTheme,
            ),
          ),
          home: const PreSplash(),
        );
      },
    );
  }
}
