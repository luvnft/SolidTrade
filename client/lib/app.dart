import 'package:get_it/get_it.dart';
import 'package:solidtrade/app/main_common.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/pages/common/splash.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/services/request/data_request_service.dart';

// TODO: Try nato font
// TODO: Maybe try stock preview to a product tile
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

  Future<void> restart() async {
    await DataRequestService.trApiDataRequestService.disconnect();

    Startup.initializeApp(environment);
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
      builder: (context, _) {
        final colors = configurationProvider.themeProvider.theme;
        return MaterialApp(
          navigatorKey: widget.navigatorKey,
          title: 'Solidtrade™',
          theme: ThemeData(
            backgroundColor: colors.background,
            scaffoldBackgroundColor: colors.background,
            textTheme: Theme.of(context).textTheme.apply(bodyColor: colors.foreground, displayColor: colors.foreground),
          ),
          home: const PreSplash(),
        );
      },
    );
  }
}

class PreSplash extends StatefulWidget {
  const PreSplash({Key? key}) : super(key: key);

  @override
  State<PreSplash> createState() => PreSplashState();
}

class PreSplashState extends State<PreSplash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const Splash(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, -1.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
