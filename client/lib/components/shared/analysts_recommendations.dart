import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/st_stream_builder.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

enum BuyHoldSell { buy, hold, sell }

class AnalystsRecommendations extends StatelessWidget with STWidget {
  AnalystsRecommendations({Key? key, required this.trStockDetailsStream}) : super(key: key);
  final Stream<RequestResponse<TrStockDetails>?> trStockDetailsStream;

  Widget _analystsResultWidget(BuildContext context, BuyHoldSell buyHoldSell, double percent) {
    Color color;
    String buyHoldSellText;
    Color? textColor = percent == 0 ? colors.lessSoftForeground : null;

    switch (buyHoldSell) {
      case BuyHoldSell.buy:
        color = colors.stockGreen;
        buyHoldSellText = "Buy";
        break;
      case BuyHoldSell.hold:
        color = colors.lessSoftForeground;
        buyHoldSellText = "Hold";
        break;
      case BuyHoldSell.sell:
        color = colors.stockRed;
        buyHoldSellText = "Sell";
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          buyHoldSellText,
          style: Theme.of(context).textTheme.subtitle1!.copyWith(color: color),
        ),
        Text(
          (percent * 100).toStringAsFixed(1) + "%",
          style: Theme.of(context).textTheme.headline6!.copyWith(color: textColor),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * .85;

    return STStreamBuilder<TrStockDetails>(
      stream: trStockDetailsStream,
      builder: (context, details) {
        Recommendations recommendations = details.analystRating.recommendations;
        double buyRecommendation = (recommendations.buy + recommendations.outperform) / (TrUtil.productViewGetAnalystsCount(recommendations));
        double holdRecommendation = recommendations.hold / (TrUtil.productViewGetAnalystsCount(recommendations));
        double sellRecommendation = (recommendations.sell + recommendations.underperform) / (TrUtil.productViewGetAnalystsCount(recommendations));

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              translations.productView.whatAnalystsSayContent(details),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: width + 5,
              child: Row(
                children: [
                  Container(color: colors.stockGreen, height: 10, width: width * buyRecommendation),
                  const SizedBox(width: 2.5),
                  Container(color: colors.softForeground, height: 10, width: width * holdRecommendation),
                  const SizedBox(width: 2.5),
                  Container(color: colors.stockRed, height: 10, width: width * sellRecommendation),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Row(children: [
              _analystsResultWidget(context, BuyHoldSell.buy, buyRecommendation),
              const SizedBox(width: 15),
              _analystsResultWidget(context, BuyHoldSell.hold, holdRecommendation),
              const SizedBox(width: 15),
              _analystsResultWidget(context, BuyHoldSell.sell, sellRecommendation),
            ]),
            const SizedBox(height: 10),
            Text(
              "This data is updated every banking day, but analysts only update their estimates periodically.",
              style: Theme.of(context).textTheme.bodyText2!.copyWith(color: colors.lessSoftForeground, fontSize: 12),
            )
          ],
        );
      },
    );
  }
}
