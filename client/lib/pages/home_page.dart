import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/data/components/base/st_widget.dart';
import 'package:solidtrade/pages/portfolio_page.dart';

class HomePage extends StatelessWidget with STWidget {
  HomePage({Key? key}) : super(key: key);

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
