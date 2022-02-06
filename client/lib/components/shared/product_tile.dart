import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/util/extentions/string_extentions.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductTile extends StatefulWidget {
  const ProductTile({Key? key, required this.info}) : super(key: key);
  final ProductTileInfo info;

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> with STWidget {
  final trProductPriceService = GetIt.instance.get<TrProductPriceService>();
  late Future<RequestResponse<TrProductInfo>> trProductInfoFuture;

  late bool isStockPosition = widget.info.positionType == PositionType.stock;
  late String? imageIsin;

  @override
  void initState() {
    super.initState();

    imageIsin = isStockPosition ? widget.info.isin : null;
    trProductInfoFuture = trProductPriceService.requestTrProductPriceByIsinWithoutExtention(widget.info.isin);
  }

  String _getStockProductSubtitle(String shortName, String name) {
    return name.length > 18 ? shortName : name;
  }

  String _getDerivitiveProductTitle(TrProductInfo info) {
    return "${info.derivativeInfo!.properties.optionType.capitalize()} @${info.derivativeInfo!.properties.strike.toStringAsFixed(2)}";
  }

  String _getDerivitiveProductSubtitle(TrProductInfo info) {
    return "${info.derivativeInfo!.productCategoryName} ${info.derivativeInfo!.underlying.name}";
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: uiUpdate.stream$,
      builder: (context, snapshot) {
        return FutureBuilder<RequestResponse<TrProductInfo>>(
          future: trProductInfoFuture,
          builder: (context, trProductInfoSnap) {
            if (!trProductInfoSnap.hasData) {
              return showLoadingSkeleton(BoxShape.rectangle);
            }

            if (!trProductInfoSnap.data!.isSuccessful) {
              // TODO: Show popup with the error message.
              return showLoadingSkeleton(BoxShape.rectangle);
            }

            TrProductInfo productInfo = trProductInfoSnap.data!.result!;

            return StreamBuilder<RequestResponse<TrProductPrice>?>(
              stream: trProductPriceService.stream$,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return showLoadingSkeleton(BoxShape.rectangle);
                }

                TrProductPrice priceInfo = snap.data!.result!;

                // TODO: When the market is closed, we dont want to use these metrics anymore. Instad use priceInfo.close (which has to be implemented still)
                final percentageChange = priceInfo.bid.price / priceInfo.open.price;
                final absolutChange = priceInfo.bid.price - priceInfo.open.price;

                final isUp = percentageChange == 1 || percentageChange > 1;
                final plusMinus = isUp ? "+" : "";

                final productTitle = isStockPosition ? productInfo.shortName : _getDerivitiveProductTitle(productInfo);
                final productSubtitle = isStockPosition ? _getStockProductSubtitle(productInfo.shortName, productInfo.name) : _getDerivitiveProductSubtitle(productInfo);

                final colorMode = colors.themeColorType == ColorThemeType.light ? "light" : "dark";

                final textStyleForNumbers = TextStyle(color: isUp ? colors.stockGreen : colors.stockRed);

                imageIsin ??= productInfo.derivativeInfo!.underlying.isin;

                return TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0, top: 8, right: 8, bottom: 8),
                    minimumSize: const Size(50, 30),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () {},
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Util.loadImage(
                        "https://assets.traderepublic.com/img/logos/$imageIsin/$colorMode.svg",
                        40,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(productTitle),
                          Text(productSubtitle, style: Theme.of(context).textTheme.bodyText2!.copyWith()),
                        ],
                      ),
                      const Spacer(),
                      Text(priceInfo.bid.price.toStringAsFixed(2)),
                      SizedBox(
                        width: 68,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              plusMinus + ((percentageChange - 1) * 100).toStringAsFixed(2) + "%",
                              style: textStyleForNumbers,
                            ),
                            Text(
                              plusMinus + absolutChange.toStringAsFixed(2) + "€",
                              style: textStyleForNumbers,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
