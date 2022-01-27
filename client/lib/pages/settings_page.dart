import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/data/enums/shared_preferences_keys.dart';
import 'package:solidtrade/providers/language/de/de_translation.dart';
import 'package:solidtrade/providers/language/en/en_translation.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class SettingsPage extends StatelessWidget with STWidget {
  SettingsPage({Key? key}) : super(key: key);
  final prefs = GetIt.instance.get<SharedPreferences>();

  void _changeLanguage(BuildContext context, ITranslation lang) {
    prefs.setInt(SharedPreferencesKeys.langTicker.toString(), lang.langTicker.index);
    configurationProvider.languageProvider.updateLanguage(lang);
  }

  void _changeColorTheme(BuildContext context, ColorThemeType type) {
    prefs.setInt(SharedPreferencesKeys.colorTheme.toString(), type.index);
    configurationProvider.themeProvider.updateTheme(type);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                ColorThemeType color;
                if (configurationProvider.themeProvider.theme.background == Colors.black) {
                  color = (ColorThemeType.light);
                } else {
                  color = ColorThemeType.dark;
                }

                _changeColorTheme(context, color);
              },
              child: Text(translation.settingsLanguage.changeTheme),
            ),
            ElevatedButton(
              onPressed: () {
                ITranslation lang;
                if (configurationProvider.languageProvider.language.langTicker == LanguageTicker.en) {
                  lang = DeTranslation();
                } else {
                  lang = EnTranslation();
                }

                _changeLanguage(context, lang);
              },
              child: Text(translation.settingsLanguage.changeLanguage),
            ),
          ],
        ),
      ),
    );
  }
}
