import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:skeletons/skeletons.dart';
import 'package:solidtrade/data/enums/chart_date_range_view.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class Util {
  // TODO: Should use language translation in the future.
  static String chartDateRangeToString(ChartDateRangeView range) {
    switch (range) {
      case ChartDateRangeView.oneDay:
        return "1D";
      case ChartDateRangeView.oneWeek:
        return "1W";
      case ChartDateRangeView.oneMonth:
        return "1M";
      case ChartDateRangeView.sixMonth:
        return "6M";
      case ChartDateRangeView.oneYear:
        return "1Y";
      case ChartDateRangeView.fiveYear:
        return "5Y";
    }
  }

  static Future<void> openDialog(
    BuildContext context,
    String title, {
    String closeText = "Okay",
    String? message,
    Iterable<String>? messages,
    Iterable<Widget>? widgets,
  }) {
    if (widgets == null) {
      if (messages == null) {
        widgets = [
          Text(message!)
        ];
      } else {
        widgets = messages.map((text) => Text(text));
      }
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                ...widgets!
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(closeText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static Widget loadImage(String url, double size, {BorderRadius? borderRadius, BoxFit? boxFit, BoxShape loadingBoxShape = BoxShape.circle}) {
    borderRadius ??= BorderRadius.circular(90);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: CachedNetworkImage(
          fit: boxFit,
          imageUrl: url,
          height: size,
          width: size,
          placeholder: (context, url) => SkeletonAvatar(
            style: SkeletonAvatarStyle(shape: loadingBoxShape),
          ),
          errorWidget: (context, url, error) => loadSvgImage(url, size, size),
        ),
      ),
    );
  }

  static Widget loadImageFromMemory(Uint8List bytes, double size, {BorderRadius? borderRadius, BoxFit? boxFit, BoxShape loadingBoxShape = BoxShape.circle}) {
    borderRadius ??= BorderRadius.circular(90);

    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Image.memory(
          bytes,
          fit: boxFit,
          height: size,
          width: size,
        ),
      ),
    );
  }

  static Widget loadSvgImage(String url, double width, double height) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      placeholderBuilder: (BuildContext _) => Container(
        padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
        width: width,
        height: height,
        child: SizedBox(
          width: width,
          height: height,
          child: const SkeletonAvatar(
            style: SkeletonAvatarStyle(shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }

  static Widget roundedButton(
    List<Widget> content, {
    required void Function() onPressed,
    required IColorTheme colors,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    foregroundColor ??= colors.foreground;
    backgroundColor ??= colors.background;

    return ClipRRect(
      borderRadius: BorderRadius.circular(45),
      child: SizedBox(
        height: 50,
        child: TextButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(foregroundColor),
            backgroundColor: MaterialStateProperty.all(backgroundColor),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...content
            ],
          ),
        ),
      ),
    );
  }

  static Future<T?> pushToRoute<T>(BuildContext context, Widget route) {
    return Navigator.push<T>(context, MaterialPageRoute(builder: (context) => route));
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

Widget showLoadingSkeleton(BoxShape shape) {
  return SkeletonAvatar(
    style: SkeletonAvatarStyle(shape: shape),
  );
}
