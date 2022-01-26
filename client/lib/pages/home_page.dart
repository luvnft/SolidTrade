import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/home/bottom_navigation_bar.dart';
import 'package:solidtrade/pages/portfolio_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with STWidget {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    PortfolioPage(),
    Text("data"),
  ];

  void _handleOnIndexCallbackClicked(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
              body: _widgetOptions[_selectedIndex],
              bottomNavigationBar: Container(
                margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
                child: CustomBottomNavigationBar(selectedIndexCallback: _handleOnIndexCallbackClicked),
              ),
            ),
          ),
        );
      },
    );
  }
}
