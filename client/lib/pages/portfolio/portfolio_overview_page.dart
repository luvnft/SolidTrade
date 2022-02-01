import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/chart/chart.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/data/models/user.dart';
import 'package:solidtrade/pages/portfolio/portfolio_positions_page.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/stream/user_service.dart';
import 'package:solidtrade/services/util/util.dart';

class PortfolioOverviewPage extends StatelessWidget with STWidget {
  PortfolioOverviewPage({Key? key}) : super(key: key);

  final userService = GetIt.instance.get<UserService>();
  final portfolioService = GetIt.instance.get<PortfolioService>();

  @override
  Widget build(BuildContext context) {
    final chartHeight = MediaQuery.of(context).size.height * .25;

    return StreamBuilder<RequestResponse<Portfolio>?>(
      initialData: portfolioService.current,
      stream: portfolioService.stream$,
      builder: (context, snap) {
        if (!snap.hasData) {
          return showLoadingSkeleton(BoxShape.rectangle);
        }

        Portfolio portfolio = snap.data!.result!;

        return Column(
          children: [
            SizedBox(
              height: chartHeight,
              child: const Chart(),
            ),
            StreamBuilder<RequestResponse<User>?>(
              initialData: userService.current,
              stream: userService.stream$,
              builder: (context, snap) => showLoadingWhileWaiting(
                isLoading: !snap.hasData,
                loadingBoxShape: BoxShape.rectangle,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 35, vertical: 5),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          // "Good morning,\n${snap.data!.result!.displayName}👋",
                          "Good morning,\n${snap.data!.result!.displayName}👋.",
                          style: Theme.of(context).textTheme.headline4!.copyWith(fontSize: 30),
                          // style: Theme.of(context).textTheme.headline4!,
                          textAlign: TextAlign.left,
                        ),
                      ),
                      const SizedBox(height: 5),
                      RichText(
                        text: TextSpan(
                          text: 'Your portfolio is today up ',
                          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 15),
                          children: <TextSpan>[
                            TextSpan(text: '+3.20%', style: TextStyle(fontWeight: FontWeight.bold, color: colors.stockGreen)),
                            const TextSpan(text: ' while the S&P 500 is down '),
                            const TextSpan(text: '-1.30%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            const TextSpan(text: '. Therefore out performing the index by '),
                            const TextSpan(text: '+4.50%', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            // TextSpan(text: '+3.21%', style: TextStyle(fontWeight: FontWeight.bold, color: colors.stockGreen)),
                            // const TextSpan(text: ' and out performing the S&P 500 by '),
                            // TextSpan(text: '1.2%', style: TextStyle(fontWeight: FontWeight.bold, color: colors.stockGreen)),
                            // const TextSpan(text: ' percent.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      const PortfolioPositionsPage()
                      // const Text("Here are your top movers today:"),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
