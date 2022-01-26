import 'package:flutter/material.dart';

abstract class IColorTheme {
  Color get background;
  String get logoAsGif;
}

class LightColorTheme implements IColorTheme {
  @override
  Color get background => Colors.white;

  @override
  String get logoAsGif => "assets/images/light-logo.gif";
}

class DarkColorTheme implements IColorTheme {
  @override
  Color get background => Colors.black;

  @override
  String get logoAsGif => "assets/images/dark-logo.gif";
}

class ThemeProvider {
  IColorTheme get theme => _currentTheme;
  IColorTheme _currentTheme;

  ThemeProvider(this._currentTheme);

  factory ThemeProvider.byThemeType(ColorThemeType theme) {
    return ThemeProvider(colorTypeToColorTheme(theme));
  }

  void updateTheme(ColorThemeType theme) {
    _currentTheme = colorTypeToColorTheme(theme);
  }

  static IColorTheme colorTypeToColorTheme(ColorThemeType type) {
    switch (type) {
      case ColorThemeType.light:
        return LightColorTheme();
      case ColorThemeType.dark:
        return DarkColorTheme();
    }
  }
}

enum ColorThemeType {
  light,
  dark,
}
