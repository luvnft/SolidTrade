import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:logger/logger.dart' as l;
import 'package:solidtrade/app/main_common.dart';
import 'package:solidtrade/data/models/enums/client_enums/environment.dart';
import 'package:solidtrade/services/util/extensions/string_extensions.dart';

class Logger {
  static Logger? _instance;

  Logger._();

  factory Logger.create() {
    _instance ??= Logger._();
    return _instance!;
  }

  final _logger = l.Logger(printer: _SimpleLogPrinter());
  final bool _shouldLog = Globals.environment != Environment.production;

  Object? _tryToConvertToJson(Object? object) {
    try {
      return JsonMapper.serialize(object);
    } catch (e) {
      return object;
    }
  }

  void d(Object? value) {
    if (_shouldLog) _logger.d(_tryToConvertToJson(value));
  }

  void i(Object? value) {
    if (_shouldLog) _logger.i(_tryToConvertToJson(value));
  }

  void w(Object? value) {
    if (_shouldLog) _logger.w(_tryToConvertToJson(value));
  }

  void f(Object? value) {
    if (_shouldLog) _logger.e(_tryToConvertToJson(value));
  }
}

class _SimpleLogPrinter extends l.LogPrinter {
  @override
  List<String> log(l.LogEvent event) {
    var color = l.PrettyPrinter.levelColors[event.level];
    var emoji = l.PrettyPrinter.levelEmojis[event.level];

    var c = StackTrace.current.toString();

    return [
      color!('$emoji[${EnumToString.convertToString(event.level).capitalize()}] ${_getClassName(c)} - ${event.message}')
    ];
  }

  String _getClassName(String stackTrace) {
    if (kIsWeb) {
      return _getMethodNameFromWeb(stackTrace);
    }
    return _getClassNameFromMobile(stackTrace);
  }

  String _getMethodNameFromWeb(String stackTrace) {
    final s1 = stackTrace.substring(2);
    final s2 = s1.substring(0, s1.indexOf(":/") - 2);
    final methodName = s2.substring(s2.lastIndexOf(" ") + 1);

    return methodName;
  }

  String _getClassNameFromMobile(String stackTrace) {
    final s1 = stackTrace.substring(stackTrace.indexOf("#4") + 1);
    final s2 = s1.substring(s1.indexOf("#") + 2).trim();
    return s2.substring(0, s2.indexOf("(") - 1).trim();
  }
}
