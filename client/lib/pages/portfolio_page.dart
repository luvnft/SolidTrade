import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/pages/portfolio/portfolio_overview_page.dart';
import 'package:solidtrade/pages/portfolio/portfolio_positions_page.dart';
import 'package:solidtrade/pages/settings_page.dart';
import 'package:solidtrade/services/stream/floating_action_button_update_service.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with STWidget {
  var floatingActionButtonUpdateService = GetIt.instance.get<FloatingActionButtonUpdateService>();
  final historicalPositionService = GetIt.instance.get<HistoricalPositionService>();

  final scrollController = ScrollController();

  var pages = [
    PortfolioOverviewPage(),
    Container(margin: const EdgeInsets.symmetric(horizontal: 20), child: const PortfolioPositionsPage()),
    PortfolioOverviewPage(),
  ];
  int selectedIndex = 0;

  void _onClickOpenSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  void _onClickFetchForUpdate() {
    historicalPositionService.fetchHistoricalPositions(11003);
  }

  void _changeIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  ButtonStyle buttonStyle(int index) {
    var isMatch = selectedIndex == index;
    return ButtonStyle(
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      backgroundColor: MaterialStateProperty.all<Color>(isMatch ? colors.background : colors.softBackground),
      foregroundColor: MaterialStateProperty.all<Color>(colors.foreground),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: floatingActionButtonUpdateService.stream$,
      builder: (context, snap) {
        if (snap.hasData && !snap.data! && scrollController.offset > 100) {
          scrollController.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.ease);
          floatingActionButtonUpdateService.onClickFloatingActionButtonOrScrollUpFarEnough();
        }

        return NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (scrollController.offset > 100) {
              floatingActionButtonUpdateService.onScrollDownFarEnough();
            } else if (scrollController.offset < 100 && notification.direction != ScrollDirection.reverse) {
              floatingActionButtonUpdateService.onClickFloatingActionButtonOrScrollUpFarEnough();
            }

            return true;
          },
          child: SingleChildScrollView(
            controller: scrollController,
            child: StreamBuilder(
              stream: uiUpdate.stream$,
              builder: (context, snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: EdgeInsets.zero,
                    color: colors.softBackground,
                    elevation: 0,
                    child: Row(
                      children: [
                        const SizedBox(width: 20),
                        SizedBox(height: 35, child: TextButton(onPressed: () => _changeIndex(0), child: const Text("Overview"), style: buttonStyle(0))),
                        const SizedBox(width: 10),
                        SizedBox(height: 35, child: TextButton(onPressed: () => _changeIndex(1), child: const Text("Open positions"), style: buttonStyle(1))),
                        const SizedBox(width: 10),
                        SizedBox(height: 35, child: TextButton(onPressed: () => _changeIndex(2), child: const Text("Closed positions"), style: buttonStyle(2))),
                        const SizedBox(height: 70),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  pages[selectedIndex],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
