import 'package:get_it/get_it.dart';
import 'package:solidtrade/main/main_common.dart';
import 'package:solidtrade/pages/splash.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';

// ignore: must_be_immutable
class MyApp extends StatefulWidget {
  MyApp({Key? key, required this.navigatorKey}) : super(key: key);
  GlobalKey<NavigatorState> navigatorKey;

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  void initState() {
    myAppState = this;
    super.initState();
  }

  void restart() {
    Startup.initializeApp();
    setState(() {
      widget.navigatorKey = GlobalKey<NavigatorState>();
      navigatorKey = widget.navigatorKey;
    });
  }

  @override
  Widget build(BuildContext context) {
    var configurationProvider = GetIt.instance.get<ConfigurationProvider>();
    final uiUpdate = configurationProvider.uiUpdateProvider;

    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, snapshot) {
        final colors = configurationProvider.themeProvider.theme;
        return MaterialApp(
          navigatorKey: widget.navigatorKey,
          title: 'Solidtrade',
          theme: ThemeData(
            backgroundColor: colors.background,
            scaffoldBackgroundColor: colors.background,
            textTheme: Theme.of(context).textTheme.apply(bodyColor: colors.foreground, displayColor: colors.foreground),
          ),
          home: const Splash(),
        );
      },
    );
  }
}
