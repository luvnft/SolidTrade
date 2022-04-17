import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/enums/lang_ticker.dart';
import 'package:solidtrade/app/main_common.dart';
import 'package:solidtrade/providers/language/de/de_translation.dart';
import 'package:solidtrade/providers/language/en/en_translation.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/user_util.dart';
import 'package:solidtrade/services/util/util.dart';

class SettingsPage extends StatelessWidget with STWidget {
  SettingsPage({Key? key}) : super(key: key);

  final userService = GetIt.instance.get<UserService>();

  void _changeLanguage(BuildContext context, ITranslation lang) {
    configurationProvider.languageProvider.updateLanguage(lang);
  }

  void _changeColorTheme(BuildContext context, ColorThemeType type) {
    configurationProvider.themeProvider.updateTheme(type);
  }

  Future<void> handleClickDeleteAccount(BuildContext context) async {
    var response = await UtilUserService.deleteAccount(userService);

    var title = response.isSuccessful ? "Account deleted" : "Account deletion failed";

    await Util.openDialog(
      context,
      title,
      message: response.isSuccessful ? "Account deleted successfully.\nPress okay to continue." : response.error!.userFriendlyMessage,
      closeText: "Okay",
    );

    if (response.isSuccessful) {
      myAppState.restart();
    }
  }

  Future<void> handleClickSignOut(BuildContext context) async {
    await UtilUserService.signOut();

    await Util.openDialog(
      context,
      "Sign out was successful",
      message: "Sign out was successful.\nPress okay to continue.",
      closeText: "Okay",
    );

    myAppState.restart();
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
              const Spacer(),
              TextButton(
                onPressed: () => handleClickSignOut(context),
                child: const Text("Sign out", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => handleClickDeleteAccount(context),
                child: const Text("Delete account", style: TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: 30)
            ],
          ),
        ),
      ),
    );
  }
}
