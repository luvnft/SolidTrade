import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Util {
  static void replaceWidget(BuildContext context, Widget newWidget) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newWidget));
  }
}
