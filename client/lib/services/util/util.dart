import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletons/skeletons.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
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
        child: const SkeletonAvatar(
          style: SkeletonAvatarStyle(shape: BoxShape.circle),
        ),
      ),
    );
  }

  static Future pushToRoute(BuildContext context, Widget route) {
    return Navigator.push(context, MaterialPageRoute(builder: (context) => route));
  }

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

  static LanguageTicker currentDeviceLanguage(BuildContext context) {
    final Locale appLocale = Localizations.localeOf(context);

    var tickers = LanguageTicker.values.map((e) {
      var s = e.toString();
      return s.substring(s.indexOf(".") + 1);
    });

    if (!tickers.any((ticker) => ticker == appLocale.languageCode)) {
      return LanguageTicker.en;
    }

    return EnumToString.fromString(LanguageTicker.values, tickers.firstWhere((ticker) => ticker == appLocale.languageCode))!;
  }
}

Widget showLoadingWhileWaiting({required bool isLoading, required BoxShape loadingBoxShape, required Widget child}) {
  return isLoading ? showLoadingSkeleton(loadingBoxShape) : child;
}

Widget showLoadingSkeleton(BoxShape loadingBoxShape) {
  return SkeletonAvatar(
    style: SkeletonAvatarStyle(shape: loadingBoxShape),
  );
}
