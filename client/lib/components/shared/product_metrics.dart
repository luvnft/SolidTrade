import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/st_stream_builder.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/util/extentions/double_extentions.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductMetrics extends StatelessWidget with STWidget {
  ProductMetrics({
    required this.trProductPriceStream,
    required this.trStockDetailsStream,
    required this.isStock,
    required this.productInfo,
    Key? key,
  }) : super(key: key);
  final Stream<RequestResponse<TrProductPrice>?> trProductPriceStream;
  final Stream<RequestResponse<TrStockDetails>?> trStockDetailsStream;
  final TrProductInfo productInfo;
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

  Widget _additionalStockInfoIfExistent(double width) {
    if (!isStock) {
      return const SizedBox.shrink();
    }

    return STStreamBuilder<TrStockDetails>(
      stream: trStockDetailsStream,
      builder: (context, result) {
        final hasMarketCapValue = result.company.marketCapSnapshot != null;

        final tupleNameForNumber = hasMarketCapValue ? TrUtil.getNameForNumber(result.company.marketCapSnapshot!) : null;
        return Row(
          children: [
            _constructMetric(
              width,
              translations.productView.marketCap,
              tupleNameForNumber == null ? "--" : tupleNameForNumber.t2.toStringAsFixed(3) + " " + translations.productView.nameOfNumberPrefix(tupleNameForNumber.t1),
            ),
            _constructMetric(width, "P/E", result.company.peRatioSnapshot?.toStringAsFixed(2) ?? "--"),
          ],
        );
      },
    );
  }

  Widget _additionalDerivativesInfoIfExistent(
    double width,
  ) {
    if (productInfo.derivativeInfo == null) {
      return const SizedBox.shrink();
    }

    DerivativeInfo di = productInfo.derivativeInfo!;

    return Row(
      children: [
        _constructMetric(width, "Strike", di.properties.strike.toPrice(di.properties.currency)),
        productInfo.derivativeInfo!.productCategoryName == "Warrant"
            ? _constructMetric(
                width,
                "Delta",
                di.properties.delta.toStringAsFixed(2),
              )
            : _constructMetric(
                width,
                "Leverage",
                di.properties.leverage?.toStringAsFixed(2) ?? "Not specified",
              ),
      ],
    );
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
      child: STStreamBuilder<TrProductPrice>(
        stream: trProductPriceStream,
        builder: (context, prices) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            child: Column(
              children: [
                Row(
                  children: [
                    _constructMetric(width, "Bid", prices.bid.price.toDefaultPrice()),
                    _constructMetric(width, "Ask", prices.ask?.price.toDefaultPrice() ?? "--"),
                  ],
                ),
                productInfo.derivativeInfo == null
                    ? Row(
                        children: [
                          _constructMetric(width, "Open", prices.open.price.toDefaultPrice()),
                          _constructMetric(width, "Close", prices.pre.price.toDefaultPrice()),
                        ],
                      )
                    : const SizedBox.shrink(),
                _additionalStockInfoIfExistent(width),
                _additionalDerivativesInfoIfExistent(width),
              ],
            ),
          );
        },
      ),
    );
  }
}
