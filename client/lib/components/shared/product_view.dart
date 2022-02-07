import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/chart/chart.dart';
import 'package:solidtrade/components/shared/product_app_bar.dart';
import 'package:solidtrade/components/shared/product_chart_date_range_selection.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/services/stream/chart_date_range_service.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductView extends StatelessWidget with STWidget {
  ProductView({
    Key? key,
    required this.trProductPriceStream,
    required this.productInfo,
    required this.positionType,
  }) : super(key: key);

  final PortfolioService portfolioService = GetIt.instance.get<PortfolioService>();
  final Stream<RequestResponse<TrProductPrice>?> trProductPriceStream;
  final TrProductInfo productInfo;
  final PositionType positionType;

  final chartDateRangeStream = ChartDateRangeService();

  @override
  Widget build(BuildContext context) {
    final chartHeight = MediaQuery.of(context).size.height * .5;
    const double bottomBarHeight = 60;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
          height: constraints.maxHeight,
          child: Column(
            children: [
              SizedBox(
                height: constraints.maxHeight - bottomBarHeight,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      ProductAppBar(
                        positionType: positionType,
                        productInfo: productInfo,
                        trProductPriceStream: trProductPriceStream,
                      ),
                      SizedBox(width: double.infinity, height: chartHeight, child: Chart(chartDateRangeStream: chartDateRangeStream)),
                      const SizedBox(height: 5),
                      Container(margin: const EdgeInsets.symmetric(horizontal: 10), height: 30, child: ProductChartDateRangeSelection(chartDateRangeStream: chartDateRangeStream)),
                    ],
                  ),
                ),
              ),
              Container(
                height: bottomBarHeight,
                width: constraints.maxWidth,
                color: colors.navigationBackground,
                child: StreamBuilder<RequestResponse<Portfolio>?>(
                  stream: portfolioService.stream$,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return showLoadingSkeleton(BoxShape.rectangle);
                    }

                    final bool ownsPosition = TrUtil.userOwnsPosition(snap.data!.result!, productInfo.isin);
                    final buttonWidth = (ownsPosition ? constraints.maxWidth / 2 : constraints.maxWidth) - 20;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: buttonWidth,
                          margin: const EdgeInsets.all(5),
                          child: TextButton(
                            onPressed: null,
                            child: Text("Buy", style: TextStyle(color: Colors.white)),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(colors.stockGreen),
                              foregroundColor: MaterialStateProperty.all(colors.foreground),
                            ),
                          ),
                        ),
                        ownsPosition
                            ? Container(
                                width: buttonWidth,
                                margin: const EdgeInsets.all(5),
                                child: TextButton(
                                  onPressed: null,
                                  child: Text("Sell", style: TextStyle(color: Colors.white)),
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(colors.stockRed),
                                    foregroundColor: MaterialStateProperty.all(colors.foreground),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
