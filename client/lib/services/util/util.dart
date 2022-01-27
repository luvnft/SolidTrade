import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class Util {
  static Widget loadSvgImageForWeb(String url, double width, double height) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      placeholderBuilder: (BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
        width: width,
        height: height,
        child: const CircularProgressIndicator(),
      ),
    );
  }

  // TODO: Test on web
  static ColorThemeType currentDeviceColorTheme(BuildContext context) {
    if (kIsWeb) {
      var brightness = SchedulerBinding.instance!.window.platformBrightness;
      bool isDarkMode = brightness == Brightness.dark;

      return isDarkMode ? ColorThemeType.dark : ColorThemeType.light;
    }

    var brightness = MediaQuery.of(context).platformBrightness;
    bool isDarkMode = brightness == Brightness.dark;

    return isDarkMode ? ColorThemeType.dark : ColorThemeType.light;
  }

  // TODO: Test on web
  static LanguageTicker currentDeviceLanguage(BuildContext context) {
    final Locale appLocale = Localizations.localeOf(context);

    var tickers = LanguageTicker.values.map((e) {
      var s = e.toString();
      return s.substring(s.indexOf("."));
    });

    if (!tickers.any((ticker) => ticker == appLocale.languageCode)) {
      return LanguageTicker.en;
    }

    try {
      ;
    } catch (e) {}

    return EnumToString.fromString(LanguageTicker.values, tickers.firstWhere((ticker) => ticker == appLocale.languageCode))!;
  }
}
