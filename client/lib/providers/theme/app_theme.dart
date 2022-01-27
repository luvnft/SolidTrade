import 'package:flutter/material.dart';

abstract class IColorTheme {
  Color get foreground;
  Color get background;
  String get logoAsGif;

  Color get selectedItem;
  Color get unselectedItem;
  Color get navigationBackground;
}

class LightColorTheme implements IColorTheme {
  @override
  Color get background => Colors.white;

  @override
  Color get foreground => Colors.black;

  @override
  String get logoAsGif => "assets/images/light-logo.gif";

  @override
  Color get selectedItem => Colors.black;

  @override
  Color get unselectedItem => Colors.grey;

  @override
  Color get navigationBackground => Colors.white;
}

class DarkColorTheme implements IColorTheme {
  @override
  Color get background => Colors.black;

  @override
  Color get foreground => Colors.white;

  @override
  String get logoAsGif => "assets/images/dark-logo.gif";

  @override
  Color get selectedItem => Colors.white;

  @override
  Color get unselectedItem => Colors.grey;

  @override
  Color get navigationBackground => Colors.grey[900]!;
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
