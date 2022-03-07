import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/st_stream_builder.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/services/storage/aggregate_history_service.dart';
import 'package:solidtrade/services/util/extentions/double_extentions.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductAppBar extends StatelessWidget with STWidget {
  ProductAppBar({
    Key? key,
    required this.trProductPriceStream,
    required this.productInfo,
    required this.positionType,
  }) : super(key: key);

  final aggregateHistoryService = GetIt.instance.get<AggregateHistoryService>();
  final Stream<RequestResponse<TrProductPrice>?> trProductPriceStream;
  final TrProductInfo productInfo;
  final PositionType positionType;

  final TextStyle _subtitleTextStyle = const TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 12,
    color: Colors.grey,
  );

  String _getProductTicker() {
    switch (productInfo.typeId) {
      case "stock":
        return productInfo.name;
      case "crypto":
        return productInfo.homeSymbol!;
      case "fund":
      case "derivative":
      default:
        return productInfo.issuerDisplayName!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return STStreamBuilder<TrProductPrice>(
      stream: trProductPriceStream,
      builder: (context, priceInfo) {
        TrUiProductDetails details = TrUtil.getTrUiProductDetails(
          priceInfo,
          productInfo,
          positionType,
        );

        final color = details.isUp ? colors.stockGreen : colors.stockRed;

        return LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                Util.loadImage(
                  details.imageUrl,
                  50,
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(productInfo.shortName, style: Theme.of(context).textTheme.bodyText1, overflow: TextOverflow.ellipsis),
                      Text(productInfo.intlSymbol ?? _getProductTicker(), style: _subtitleTextStyle),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(priceInfo.bid.price.toDefaultPrice(maxFractionDigits: 2)),
                    Row(
                      children: [
                        Icon(
                          details.isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                          color: color,
                          size: 20,
                        ),
                        Text(
                          details.plusMinusProductNamePrefix + ((details.percentageChange - 1) * 100).toStringAsFixed(2) + "%",
                          style: TextStyle(
                            color: color,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(width: 10)
              ],
            );
          },
        );
      },
    );
  }
}
