import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Util {
  static void replaceWidget(BuildContext context, Widget newWidget) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => newWidget));
  }

  static Widget loadSvgImageForWeb(String url, double width, double height) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      placeholderBuilder: (BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
