import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class Log {
  static final logger = Logger();

  static void d(Object? value) {
    if (kDebugMode) logger.d(value);
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
