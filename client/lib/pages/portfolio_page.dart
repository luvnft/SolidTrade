import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:solidtrade/services/stream/historicalpositions_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class PortfolioPage extends StatefulWidget {
  const PortfolioPage({Key? key}) : super(key: key);

  @override
  _PortfolioPageState createState() => _PortfolioPageState();
}

class _PortfolioPageState extends State<PortfolioPage> {
  final historicalPositionService = GetIt.instance.get<HistoricalPositionService>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to solid trade"),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StreamBuilder<RequestResponse<List<HistoricalPosition>>?>(
              stream: historicalPositionService.stream$,
              builder: (context, snap) => Text("The count of historical positions is ${snap.data?.result?.length}"),
            ),
            ElevatedButton(
                onPressed: () {
                  historicalPositionService.fetchHistoricalPositions(11003);
                },
                child: const Text("Fetch for update."))
          ],
        ),
      ),
    );
  }
}
