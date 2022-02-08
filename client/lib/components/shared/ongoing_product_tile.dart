import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/product_view.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/tr/tr_aggregate_history.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/enums/enter_or_exit_position_type.dart';
import 'package:solidtrade/data/models/outstanding_order_model.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class OngoingProductTile extends StatefulWidget {
  const OngoingProductTile({Key? key, required this.info, required this.positionType}) : super(key: key);
  final OutstandingOrderModel info;
  final PositionType positionType;

  @override
  State<OngoingProductTile> createState() => _OngoingProductTileState();
}

class _OngoingProductTileState extends State<OngoingProductTile> with STWidget {
  final trProductPriceService = GetIt.instance.get<TrProductPriceService>();
  late bool isBuy = widget.info.type == EnterOrExitPositionType.buyLimitOrder || widget.info.type == EnterOrExitPositionType.buyStopOrder;
  late bool isLimit = widget.info.type == EnterOrExitPositionType.buyLimitOrder || widget.info.type == EnterOrExitPositionType.sellLimitOrder;

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
        positionType: widget.positionType,
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

            return StreamBuilder<RequestResponse<TrProductPrice>?>(
              stream: trProductPriceService.stream$,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return showLoadingSkeleton(BoxShape.rectangle);
                }

                TrProductPrice priceInfo = snap.data!.result!;

                TrUiProductDetails details = TrUtil.getTrUiProductDetials(
                    priceInfo,
                    productInfo,
                    TrAggregateHistoryEntry(
                      close: -1,
                      open: -1,
                      time: -1,
                    ),
                    widget.positionType);

                final price = isBuy ? priceInfo.ask.price : priceInfo.bid.price;

                final f = NumberFormat("###,##0.00", "tr_TR");
                var currentPrice = f.format(price);

                final percentMissingToFill = !isLimit ? (price / widget.info.price) : (widget.info.price / price);

                return TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.only(left: 0, top: 8, right: 8, bottom: 8),
                    minimumSize: const Size(50, 30),
                    alignment: Alignment.centerLeft,
                  ),
                  onPressed: () => _onClickProduct(productInfo),
                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                    return Column(
                      children: [
                        Row(
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
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 75,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [],
                              ),
                            ),
                          ],
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: constraints.maxWidth * percentMissingToFill,
                            child: Divider(
                              color: colors.foreground,
                              thickness: 4,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.info.price.toStringAsFixed(4) + "€",
                              style: TextStyle(color: colors.foreground),
                            ),
                            Text(
                              currentPrice + "€",
                              style: TextStyle(color: colors.foreground),
                            ),
                          ],
                        ),
                        Text(percentMissingToFill.toStringAsFixed(2) + "%"),
                      ],
                    );
                  }),
                );
              },
            );
          },
        );
      },
    );
  }
}
