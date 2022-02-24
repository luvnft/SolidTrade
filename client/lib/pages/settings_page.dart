import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/providers/language/de/de_translation.dart';
import 'package:solidtrade/providers/language/en/en_translation.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class SettingsPage extends StatelessWidget with STWidget {
  SettingsPage({Key? key}) : super(key: key);

  void _changeLanguage(BuildContext context, ITranslation lang) {
    configurationProvider.languageProvider.updateLanguage(lang);
  }

  void _changeColorTheme(BuildContext context, ColorThemeType type) {
    configurationProvider.themeProvider.updateTheme(type);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(translations.settings.settings),
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
                child: Text(translations.settings.changeTheme),
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
                child: Text(translations.settings.changeLanguage),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
