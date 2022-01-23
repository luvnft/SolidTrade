import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solidtrade/pages/spash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Provider.of<MaterialColor>(context),
      ),
      home: const Splash(),
    );
  }
}
