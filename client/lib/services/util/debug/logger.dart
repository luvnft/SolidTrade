import 'dart:convert';
import 'dart:developer' as dev;

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart' as l;
import 'package:simple_json_mapper/simple_json_mapper.dart';
import 'package:solidtrade/app/main_common.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/models/enums/client_enums/environment.dart';
import 'package:solidtrade/services/util/extensions/string_extensions.dart';
import 'package:http/http.dart' as http;

class Logger {
  static Logger? _instance;

  Logger._();

  factory Logger.create() {
    _instance ??= Logger._();
    return _instance!;
  }

  final _logger = l.Logger(
    filter: l.ProductionFilter(),
    // printer: _SimpleLogPrinter(),
    output: _STLoggingOutput(),
  );
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
    var color = l.PrettyPrinter.levelColors[event.level]!;
    var emoji = l.PrettyPrinter.levelEmojis[event.level];

    return [
      color('$emoji[${EnumToString.convertToString(event.level).capitalize()}] - ${event.message} - ${event.error} - ${event.stackTrace}')
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

class _STLoggingOutput extends l.LogOutput {
  final _logsUri = Uri.https(ConfigReader.getBaseUrl(), "/logs");

  @override
  void output(l.OutputEvent event) {
    // ignore: avoid_print
    event.lines.forEach(print);

    _makeRequest("r921", event.level.name, event.lines.join(", "));
  }

  void _makeRequest(String id, String title, String? message) {
    Map<String, dynamic> map = {};
    map["SenderId"] = id;
    map["Title"] = title;
    map["Message"] = message;

    var data = json.encode(map);

    dev.log("json: $data");
    http.post(
      _logsUri,
      headers: {
        "Content-Type": "application/json"
      },
      body: data,
    );
  }
}
