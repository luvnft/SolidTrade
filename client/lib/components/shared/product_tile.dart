import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/product_view.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_aggregate_history.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/services/storage/aggregate_history_service.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductTile extends StatefulWidget {
  const ProductTile({Key? key, required this.info}) : super(key: key);
  final ProductTileInfo info;

  @override
  State<ProductTile> createState() => _ProductTileState();
}

class _ProductTileState extends State<ProductTile> with STWidget {
  final trProductPriceService = GetIt.instance.get<TrProductPriceService>();
  final aggregateHistoryService = GetIt.instance.get<AggregateHistoryService>();

  late Future<RequestResponse<TrAggregateHistory>> trAggregateHistoryFuture;
  late Future<RequestResponse<TrProductInfo>> trProductInfoFuture;

  @override
  void initState() {
    super.initState();
    trProductInfoFuture = trProductPriceService.requestTrProductPriceByIsinWithoutExtention(widget.info.isin);
  }

  void _onClickProduct(TrProductInfo info) {
    Util.pushToRoute(
      context,
      ProductView(
        positionType: widget.info.positionType,
        productInfo: info,
        trProductPriceStream: trProductPriceService.stream$,
      ),
    );
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

            trAggregateHistoryFuture = aggregateHistoryService.getTrAggregateHistory("${widget.info.isin}.${productInfo.exchangeIds.first}");

            return FutureBuilder<RequestResponse<TrAggregateHistory>>(
              future: trAggregateHistoryFuture,
              builder: (context, trAggregateHistorySnap) {
                if (!trAggregateHistorySnap.hasData) {
                  return showLoadingSkeleton(BoxShape.rectangle);
                }

                if (!trAggregateHistorySnap.data!.isSuccessful) {
                  // TODO: Show popup with the error message.
                  return showLoadingSkeleton(BoxShape.rectangle);
                }

                TrAggregateHistory aggregateHistory = trAggregateHistorySnap.data!.result!;
                aggregateHistory.aggregates.sort((a, b) => a.time.compareTo(b.time));

                return StreamBuilder<RequestResponse<TrProductPrice>?>(
                  stream: trProductPriceService.stream$,
                  builder: (context, snap) {
                    if (!snap.hasData) {
                      return showLoadingSkeleton(BoxShape.rectangle);
                    }

                    TrProductPrice priceInfo = snap.data!.result!;

                    TrUiProductDetails details = TrUtil.getTrUiProductDetials(priceInfo, productInfo, aggregateHistory.aggregates.first, widget.info.positionType);

                    final f = NumberFormat("###,##0.00", "tr_TR");
                    var currentPrice = f.format(priceInfo.bid.price);

                    return TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.only(left: 0, top: 8, right: 8, bottom: 8),
                        minimumSize: const Size(50, 30),
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () => _onClickProduct(productInfo),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Util.loadImage(
                            details.imageUrl,
                            40,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(details.productTitle),
                              const SizedBox(height: 2),
                              SizedBox(
                                width: 0,
                                child: Text(
                                  productInfo.typeId == "crypto" ? productInfo.homeSymbol! : details.productSubtitle,
                                  overflow: TextOverflow.visible,
                                  softWrap: false,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(currentPrice),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 75,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  details.plusMinusProductNamePrefix + ((details.percentageChange - 1) * 100).toStringAsFixed(2) + "%",
                                  style: TextStyle(color: details.textColor),
                                ),
                                Text(
                                  details.plusMinusProductNamePrefix + details.absolutChange.toStringAsFixed(2) + "€",
                                  style: TextStyle(color: details.textColor),
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
      },
    );
  }
}
