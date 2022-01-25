import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/language/de/de_translation.dart';
import 'package:solidtrade/providers/language/en/en_translation.dart';
import 'package:solidtrade/providers/language/language_provider.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/util/util.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final configurationProvider = GetIt.instance.get<ConfigurationProvider>();
  ITranslation get translation => configurationProvider.languageProvider.language;
  IColorTheme get colors => configurationProvider.themeProvider.theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      backgroundColor: colors.background,
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

                configurationProvider.themeProvider.updateTheme(color);

                Util.replaceWidget(context, SettingsPage());
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

                configurationProvider.languageProvider.updateLanguage(lang);
                Util.replaceWidget(context, SettingsPage());
              },
              child: Text(translation.settingsLanguage.changeLanguage),
            ),
          ],
        ),
      ),
    );
  }
}
