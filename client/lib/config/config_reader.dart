import 'package:flutter/services.dart';
import 'package:solidtrade/services/util/debug/logger.dart';
import 'package:yaml/yaml.dart';

abstract class ConfigReader {
  static late YamlMap _config;

  static Future<void> initialize() async {
    const String configPath = 'assets/config/config.yml';
    try {
      final configString = await rootBundle.loadString(configPath);
      _config = loadYaml(configString) as YamlMap;
    } catch (e) {
      final logger = Logger.create()..f('Failed to load config file at path $configPath. Make sure this file exists. See following Exception for more info');
      logger.f(e);

      rethrow;
    }
  }

  static String getBaseUrl() {
    return _config['baseUrl'];
  }

  static String getTrEndpoint() {
    return _config['trEndpoint'];
  }

  static String getTrConnectString() {
    return _config['initialTrConnectString'];
  }
}
