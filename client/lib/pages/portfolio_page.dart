import 'package:flutter/foundation.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/chart/chart.dart';
import 'package:solidtrade/pages/settings_page.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> with STWidget {
  final historicalPositionService = GetIt.instance.get<HistoricalPositionService>();

  void _onClickOpenSettings() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
  }

  void _onClickFetchForUpdate() {
    historicalPositionService.fetchHistoricalPositions(11003);
  }

  @override
  Widget build(BuildContext context) {
    final chartHeight = MediaQuery.of(context).size.height * .5;

    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, snapshot) => Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: chartHeight, child: const Chart()),
            ElevatedButton(
              onPressed: _onClickFetchForUpdate,
              child: const Text("Fetch for update."),
            ),
            ElevatedButton(
              onPressed: _onClickOpenSettings,
              child: const Text("Open settings."),
            )
          ],
        ),
      ),
    );
  }
}
