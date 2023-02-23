import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'localization.provider.g.dart';

@riverpod
class Localization extends _$Localization {
  @override
  Locale build() => const Locale('en');

  void changeLanguageToEnglish() {
    state = const Locale('en');
  }

  void changeLanguageToGerman() {
    state = const Locale('de');
  }
}
