import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/product_view/product_view.dart';
import 'package:solidtrade/data/common/request/request_response.dart';
import 'package:solidtrade/data/enums/position_type.dart';
import 'package:solidtrade/components/base/st_stream_builder.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/enums/enter_or_exit_position_type.dart';
import 'package:solidtrade/data/models/outstanding_order_model.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
import 'package:solidtrade/services/util/extensions/double_extensions.dart';
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
    trProductInfoFuture = trProductPriceService.requestTrProductPriceByIsinWithoutExtension(widget.info.isin);
  }

  Widget _ongoingProductTile(TrProductInfo productInfo, double percentMissingToFill, double currentPrice, TrUiProductDetails details) {
    return _ongoingProductTileWithCustomProperties(
      onPressed: () => _onClickProduct(productInfo),
      imageUrl: details.imageUrl,
      productTitle: details.productTitle,
      productSubtitle: productInfo.typeId == "crypto" ? productInfo.homeSymbol! : details.productSubtitle,
      percentMissingToFill: percentMissingToFill,
      percentMissingToFillString: percentMissingToFill.toStringAsFixed(2) + "%",
      startPriceText: widget.info.price.toDefaultPrice(),
      endPriceText: currentPrice.toDefaultPrice(),
    );
  }

  Widget _ongoingProductTileWithCustomProperties({
    required void Function()? onPressed,
    required String imageUrl,
    required String productTitle,
    required String productSubtitle,
    required double percentMissingToFill,
    required String percentMissingToFillString,
    required String startPriceText,
    required String endPriceText,
    bool showPriceText = true,
    TextAlign? textAlign,
    TextStyle? textStyle,
  }) {
    return TextButton(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.only(left: 0, top: 8, right: 8, bottom: 8),
        minimumSize: const Size(50, 30),
        alignment: Alignment.centerLeft,
      ),
      onPressed: onPressed,
      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Util.loadImage(
                  imageUrl,
                  40,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(productTitle),
                    const SizedBox(height: 2),
                    SizedBox(
                      width: 0,
                      child: Text(
                        productSubtitle,
                        overflow: TextOverflow.visible,
                        softWrap: false,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                const SizedBox(width: 10),
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
            showPriceText
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        startPriceText,
                        style: TextStyle(color: colors.foreground),
                      ),
                      Text(
                        endPriceText,
                        style: TextStyle(color: colors.foreground),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            Text(percentMissingToFillString, textAlign: textAlign, style: textStyle),
          ],
        );
      }),
    );
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
      builder: (context, _) {
        return FutureBuilder<RequestResponse<TrProductInfo>>(
          future: trProductInfoFuture,
          builder: (context, trProductInfoSnap) {
            if (!trProductInfoSnap.hasData) {
              return showLoadingSkeleton(BoxShape.rectangle);
            }

            if (!trProductInfoSnap.data!.isSuccessful) {
              Util.openDialog(context, "Loading product failed", message: "Sorry, something went wrong while trying to load this product.");
              return const Text("Something didn't go right. Please try again later.");
            }

            TrProductInfo productInfo = trProductInfoSnap.data!.result!;

            return STStreamBuilder<TrProductPrice>(
              stream: trProductPriceService.stream$,
              builder: (context, priceInfo) {
                TrUiProductDetails details = TrUtil.getTrUiProductDetails(
                  priceInfo,
                  productInfo,
                  widget.positionType,
                );

                if (!productInfo.active) {
                  return _ongoingProductTileWithCustomProperties(
                    onPressed: () {},
                    imageUrl: details.imageUrl,
                    productTitle: details.productTitle,
                    productSubtitle: productInfo.typeId == "crypto" ? productInfo.homeSymbol! : details.productSubtitle,
                    percentMissingToFill: 0,
                    percentMissingToFillString: "This product can no longer be bought or sold. This might happen if the product is expired or is knocked out. This product may not be showing by next week.",
                    showPriceText: false,
                    startPriceText: "",
                    endPriceText: "",
                    textAlign: TextAlign.center,
                    textStyle: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.normal),
                  );
                }

                final currentPrice = isBuy ? 2.3 : priceInfo.bid.price;

                final percentMissingToFill = !isLimit ? (currentPrice / widget.info.price) : (widget.info.price / currentPrice);
                return _ongoingProductTile(productInfo, percentMissingToFill, currentPrice, details);
              },
            );
          },
        );
      },
    );
  }
}
