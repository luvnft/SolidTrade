import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/data/components/base/st_widget.dart';
import 'package:solidtrade/pages/portfolio_page.dart';

class HomePage extends StatelessWidget with STWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final shouldAdjust = screenWidth * 0.70 > screenHeight;
    double horizontalMargin = 0;

    if (shouldAdjust) {
      horizontalMargin = 0.15 * screenWidth;
    }

    return StreamBuilder<int>(
      stream: uiUpdate.stream$,
      builder: (context, snap) {
        return Container(
          color: colors.background,
          child: Container(
            margin: shouldAdjust ? EdgeInsets.symmetric(horizontal: horizontalMargin) : const EdgeInsets.all(0),
            child: Scaffold(
              appBar: AppBar(
                title: Text(translation.portfolioTranslation.labelWelcome),
              ),
              backgroundColor: colors.background,
              body: const PortfolioPage(),
            ),
          ),
        );
      },
    );
  }
}
