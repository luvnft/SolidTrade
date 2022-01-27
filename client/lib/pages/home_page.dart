import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/user_app_bar.dart';
import 'package:solidtrade/pages/portfolio_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    Text("data"),
    Text("data"),
  ];

  void _handleItemIndexClick(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Color _getItemColor(int itemIndex) {
    return itemIndex == _selectedIndex ? colors.selectedItem : colors.unselectedItem;
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
          margin: shouldAdjust ? EdgeInsets.symmetric(horizontal: horizontalMargin) : const EdgeInsets.all(0),
          child: Scaffold(
            body: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 35, left: 10, right: 10, bottom: 20),
                  child: UserAppBar(),
                ),
                _widgetOptions[_selectedIndex]
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: [
                BottomNavigationBarItem(label: translations.navigationBar.portfolio, icon: Icon(Icons.insights, color: _getItemColor(0))),
                BottomNavigationBarItem(label: translations.navigationBar.search, icon: Icon(Icons.search, color: _getItemColor(1))),
                BottomNavigationBarItem(label: translations.navigationBar.chat, icon: Icon(Icons.chat_bubble, color: _getItemColor(2))),
                BottomNavigationBarItem(label: translations.navigationBar.profile, icon: Icon(Icons.person, color: _getItemColor(3))),
              ],
              backgroundColor: colors.navigationBackground,
              type: BottomNavigationBarType.fixed,
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: _selectedIndex,
              onTap: _handleItemIndexClick,
            ),
          ),
        );
      },
    );
  }
}
