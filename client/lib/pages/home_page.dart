import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/user_app_bar.dart';
import 'package:solidtrade/pages/portfolio_page.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/floating_action_button_update_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with STWidget {
  var floatingActionButtonUpdateService = GetIt.instance.get<FloatingActionButtonUpdateService>();

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

  void _handleFloatingActionButtonClick() {
    floatingActionButtonUpdateService.onClickFloatingActionButtonOrScrollUpFarEnough();
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

    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, _) => Container(
        color: colors.navigationBackground,
        child: SafeArea(
          child: Container(
            margin: shouldAdjust ? EdgeInsets.symmetric(horizontal: horizontalMargin) : const EdgeInsets.all(0),
            child: Scaffold(
              body: Column(
                children: [
                  UserAppBar(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
                        height: constraints.maxHeight,
                        child: _widgetOptions[_selectedIndex],
                      ),
                    ),
                  )
                ],
              ),
              bottomNavigationBar: BottomNavigationBar(
                items: [
                  BottomNavigationBarItem(label: translations.navigationBar.portfolio, icon: Icon(Icons.insights, color: _getItemColor(0))),
                  BottomNavigationBarItem(label: translations.navigationBar.search, icon: Icon(Icons.search, color: _getItemColor(1))),
                  BottomNavigationBarItem(label: translations.navigationBar.leaderboard, icon: Icon(Icons.leaderboard, color: _getItemColor(2))),
                  BottomNavigationBarItem(label: translations.navigationBar.profile, icon: Icon(Icons.person, color: _getItemColor(3))),
                ],
                backgroundColor: colors.navigationBackground,
                type: BottomNavigationBarType.fixed,
                showSelectedLabels: false,
                showUnselectedLabels: false,
                currentIndex: _selectedIndex,
                onTap: _handleItemIndexClick,
              ),
              floatingActionButton: StreamBuilder<bool>(
                stream: floatingActionButtonUpdateService.stream$,
                builder: (context, snap) {
                  if (snap.hasData && !snap.data!) {
                    return const SizedBox.shrink();
                  }

                  return FloatingActionButton(
                    onPressed: _handleFloatingActionButtonClick,
                    tooltip: 'Scroll up',
                    backgroundColor: colors.themeColorType == ColorThemeType.light ? colors.background : colors.softBackground,
                    child: Icon(
                      Icons.arrow_circle_up,
                      color: colors.foreground,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
