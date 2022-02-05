import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/main/main_common.dart';
import 'package:solidtrade/pages/home_page.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/debug/log.dart';
import 'package:solidtrade/services/util/util.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with STWidget {
  final historicalPositionService = GetIt.instance.get<HistoricalPositionService>();
  final portfolioService = GetIt.instance.get<PortfolioService>();
  final userService = GetIt.instance.get<UserService>();

  bool _visible = false;

  @override
  void initState() {
    super.initState();

    _fadeContent();
    _navigateToHome();
  }

  void _fadeContent() {
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        _visible = !_visible;
      });
    });
  }

  Future<void> _navigateToHome() async {
    var delay = Future.delayed(const Duration(seconds: 1));

    var userRequest = await userService.fetchUser();
    if (userRequest.isSuccessful) {
      await historicalPositionService.fetchHistoricalPositions(userRequest.result!.id);
      await portfolioService.fetchPortfolioByUserId();

      Log.d("fetched user info successfully");
    } else {
      // TODO: Navigate to login page.
      delay.ignore();
      Log.d(userRequest.error!.userFriendlyMessage);
      Log.d("User request failed.");
      return;
    }

    await delay;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    if (Startup.colorThemeHasToBeInitialized) {
      final theme = Util.currentDeviceColorTheme(context);
      configurationProvider.themeProvider.updateTheme(theme, savePermanently: false);

      Startup.colorThemeHasToBeInitialized = false;
    }

    if (Startup.languageHasToBeInitialized) {
      final ticker = Util.currentDeviceLanguage(context);
      configurationProvider.languageProvider.updateLanguage(LanguageProvider.tickerToTranslation(ticker));

      Startup.languageHasToBeInitialized = false;
    }

    return Scaffold(
      backgroundColor: configurationProvider.themeProvider.theme.themeColorType == ColorThemeType.light ? const Color.fromRGBO(251, 251, 251, 1) : colors.background,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 50),
            const Spacer(),
            Image.asset(
              colors.logoAsGif,
              height: 100.0,
              width: 100.0,
            ),
            const Spacer(),
            AnimatedOpacity(
              opacity: _visible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Text(translations.splash.loading),
                  SizedBox(
                    width: 220,
                    child: Divider(thickness: 2, color: colors.softForeground),
                  ),
                  const Text("Solid trade"),
                ],
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
