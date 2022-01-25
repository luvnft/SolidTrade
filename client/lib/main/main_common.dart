import 'package:solidtrade/services/language/en/en_translation.dart';
import 'package:solidtrade/services/language/language.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/enums/environment.dart';
import 'package:solidtrade/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> commonMain(Environment environment) async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigReader.initialize();

  GetIt getItService = GetIt.instance;
  getItService.registerSingleton<HistoricalPositionService>(HistoricalPositionService());
  getItService.registerSingleton<ITranslation>(EnTranslation());

  MaterialColor primaryColor;
  switch (environment) {
    case Environment.production:
      primaryColor = Colors.blue;
      break;
    case Environment.staging:
      primaryColor = Colors.red;
      break;
    case Environment.development:
      primaryColor = Colors.green;
      break;
  }

  runApp(
    Provider.value(
      value: primaryColor,
      child: const MyApp(),
    ),
  );
}
