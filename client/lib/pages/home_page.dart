import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/pages/portfolio_page.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/language/translation.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final configurationProvider = GetIt.instance.get<ConfigurationProvider>();
  ITranslation get translation => configurationProvider.languageProvider.language;
  IColorTheme get colors => configurationProvider.themeProvider.theme;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translation.portfolioTranslation.labelWelcome),
      ),
      backgroundColor: colors.background,
      body: const PortfolioPage(),
    );
  }
}
