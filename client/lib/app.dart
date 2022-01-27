import 'package:flutter/material.dart';
import 'package:solidtrade/pages/spash.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Solidtrade',
      home: Splash(),
    );
  }
}
