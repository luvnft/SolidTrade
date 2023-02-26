import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme.provider.g.dart';

@riverpod
class Theme extends _$Theme {
  @override
  ThemeMode build() => ThemeMode.light;

  void changeToLightTheme() {
    state = ThemeMode.light;
  }

  void changeToDarkTheme() {
    state = ThemeMode.dark;
  }
}
