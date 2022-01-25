import 'package:flutter/material.dart';

class ThemeProvider {
  IColorTheme get theme => _currentTheme;
  IColorTheme _currentTheme;

  ThemeProvider(this._currentTheme);

  void updateTheme(ColorThemeType theme) {
    switch (theme) {
      case ColorThemeType.light:
        _currentTheme = LightColorTheme();
        break;
      case ColorThemeType.dark:
        _currentTheme = DarkColorTheme();
        break;
    }
  }
}

enum ColorThemeType {
  light,
  dark,
}

abstract class IColorTheme {
  Color get background;
}

class LightColorTheme implements IColorTheme {
  @override
  Color get background => Colors.white;
}

class DarkColorTheme implements IColorTheme {
  @override
  Color get background => Colors.black;
}
