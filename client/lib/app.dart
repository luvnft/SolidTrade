import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/pages/splash.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget with STWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, snapshot) => MaterialApp(
        title: 'Solidtrade',
        theme: ThemeData(
          backgroundColor: colors.background,
          scaffoldBackgroundColor: colors.background,
          textTheme: Theme.of(context).textTheme.apply(
                bodyColor: colors.foreground,
                displayColor: colors.foreground,
              ),
        ),
        home: const Splash(),
      ),
    );
  }
}
