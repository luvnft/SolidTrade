import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Util {
  static Widget loadSvgImageForWeb(String url, double width, double height) {
    return SvgPicture.network(
      url,
      width: width,
      height: height,
      placeholderBuilder: (BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: width, vertical: height),
        width: width,
        height: height,
        child: const CircularProgressIndicator(),
      ),
    );
  }
}
