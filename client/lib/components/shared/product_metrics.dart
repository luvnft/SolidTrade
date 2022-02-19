import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductMetrics extends StatelessWidget with STWidget {
  ProductMetrics({required this.trProductPriceStream, required this.trStockDetailsStream, required this.isStock, Key? key}) : super(key: key);
  final Stream<RequestResponse<TrProductPrice>?> trProductPriceStream;
  final Stream<RequestResponse<TrStockDetails>?> trStockDetailsStream;
  final bool isStock;

  Widget _constructMetric(double itemWidth, String name, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: itemWidth * 0.03),
      width: itemWidth * 0.44,
      child: Row(
        children: [
          Text(name),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }

  Widget _constructMetricWithDouble(double itemWidth, String name, double value, {String extention = "€"}) {
    return _constructMetric(itemWidth, name, value.toStringAsFixed(2) + extention);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.9;

    return Card(
      elevation: 0,
      borderOnForeground: false,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: colors.themeColorType == ColorThemeType.dark ? colors.softForeground : colors.background,
          width: 3.5,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      color: colors.themeColorType == ColorThemeType.dark ? colors.softBackground : colors.background,
      child: StreamBuilder<RequestResponse<TrProductPrice>?>(
        stream: trProductPriceStream,
        builder: (context, snap) {
          if (!snap.hasData) {
            return showLoadingSkeleton(BoxShape.rectangle);
          }
          TrProductPrice prices = snap.data!.result!;

          return StreamBuilder<RequestResponse<TrStockDetails>?>(
            stream: trStockDetailsStream,
            builder: (context, stockDetailsSnap) {
              if (!stockDetailsSnap.hasData) {
                return showLoadingSkeleton(BoxShape.rectangle);
              }

              final tupleNameForNumber = TrUtil.getNameForNumber(stockDetailsSnap.data!.result!.company.marketCapSnapshot);

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _constructMetricWithDouble(width, "Open", prices.open.price),
                        _constructMetricWithDouble(width, "Close", prices.pre.price),
                      ],
                    ),
                    Row(
                      children: [
                        _constructMetricWithDouble(width, "Bid", prices.bid.price),
                        _constructMetricWithDouble(width, "Ask", prices.ask.price),
                      ],
                    ),
                    isStock
                        ? Row(
                            children: [
                              _constructMetric(
                                width,
                                translations.productView.marketCap,
                                tupleNameForNumber.t2.toStringAsFixed(3) + " " + translations.productView.nameOfNumberPrefix(tupleNameForNumber.t1),
                              ),
                              _constructMetric(width, "P/E", stockDetailsSnap.data!.result!.company.peRatioSnapshot?.toStringAsFixed(2) ?? "--"),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
