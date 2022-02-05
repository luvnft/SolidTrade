import 'package:enum_to_string/enum_to_string.dart';
import 'package:solidtrade/services/util/extentions/string_extentions.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static final logger = Logger(printer: SimpleLogPrinter());

  static void d(Object? value) {
    if (kDebugMode) logger.i(value);
  }

  static void i(Object? value) {
    if (kDebugMode) logger.i(value);
  }

  static void w(Object? value) {
    if (kDebugMode) logger.w(value);
  }

  static void f(Object? value) {
    if (kDebugMode) logger.e(value);
  }
}

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.levelColors[event.level];
    var emoji = PrettyPrinter.levelEmojis[event.level];

    var c = StackTrace.current.toString();
    var s1 = c.substring(c.indexOf("Log.") + 1);
    var s2 = s1.substring(s1.indexOf("#") + 2).trim();
    var className = s2.substring(0, s2.indexOf("(") - 1).trim();

    return [
      color!('$emoji[${EnumToString.convertToString(event.level).capitalize()}] $className - ${event.message}')
    ];
  }
}
