import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/services/stream/tr_product_price_service.dart';
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

  @override
  void initState() {
    super.initState();

    trProductInfoFuture = trProductPriceService.requestTrProductPriceByIsinWithoutExtention(widget.info.isin);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: FutureBuilder<RequestResponse<TrProductInfo>>(
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

              return ListTile(
                tileColor: colors.softBackground,
                title: Text(productInfo.shortName + " : " + priceInfo.bid.price.toString()),
              );
            },
          );
        },
      ),
    );
  }
}
