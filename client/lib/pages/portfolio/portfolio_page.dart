import 'package:flutter/rendering.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/pages/portfolio/components/portfolio_positions.dart';
import 'package:solidtrade/pages/portfolio/portfolio_overview_page.dart';
import 'package:solidtrade/services/stream/floating_action_button_update_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with STWidget {
  final _floatingActionButtonUpdateService = GetIt.instance.get<FloatingActionButtonUpdateService>();
  final _scrollController = ScrollController();

  int _selectedTabIndex = 0;

  final _pages = [
    PortfolioOverviewPage(),
    Container(margin: const EdgeInsets.symmetric(horizontal: 20), child: PortfolioPositions(isViewingOutstandingOrders: true)),
    PortfolioOverviewPage(),
  ];

  void _changeIndex(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  ButtonStyle buttonStyle(int index) {
    var isMatch = _selectedTabIndex == index;
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
      stream: _floatingActionButtonUpdateService.stream$,
      builder: (context, snap) {
        if (snap.hasData && !snap.data! && _scrollController.offset > 100) {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 150), curve: Curves.ease);
          _floatingActionButtonUpdateService.onClickFloatingActionButtonOrScrollUpFarEnough();
        }

        return NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            if (_scrollController.offset > 100) {
              _floatingActionButtonUpdateService.onScrollDownFarEnough();
            } else if (_scrollController.offset < 100 && notification.direction != ScrollDirection.reverse) {
              _floatingActionButtonUpdateService.onClickFloatingActionButtonOrScrollUpFarEnough();
            }

            return true;
          },
          child: SingleChildScrollView(
            controller: _scrollController,
            child: StreamBuilder(
              stream: uiUpdate.stream$,
              builder: (context, snapshot) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: colors.softBackground,
                    child: Card(
                      color: colors.softBackground,
                      margin: EdgeInsets.zero,
                      elevation: 0,
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          SizedBox(height: 35, child: TextButton(onPressed: () => _changeIndex(0), style: buttonStyle(0), child: const Text('Overview'))),
                          const SizedBox(width: 10),
                          SizedBox(height: 35, child: TextButton(onPressed: () => _changeIndex(1), style: buttonStyle(1), child: const Text('Open positions'))),
                          const SizedBox(width: 10),
                          SizedBox(height: 35, child: TextButton(onPressed: () => _changeIndex(2), style: buttonStyle(2), child: const Text('Closed positions'))),
                          const SizedBox(height: 70),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  _pages[_selectedTabIndex],
                  Divider(thickness: 5, color: colors.softBackground),
                  Container(
                    margin: const EdgeInsets.all(10),
                    child: Text(
                      'In the event of disruptions, outdated data may occur. When transactions are made, it is ensured that these disturbances are taken into account.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.lessSoftForeground, fontSize: 13),
                    ),
                  ),
                  Text(
                    'Solidtrade™',
                    style: TextStyle(color: colors.lessSoftForeground, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
