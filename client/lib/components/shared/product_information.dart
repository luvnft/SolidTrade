import 'package:flutter/material.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/services/util/util.dart';

class ProductInformation extends StatelessWidget {
  const ProductInformation({Key? key, required this.trStockDetailsStream}) : super(key: key);
  final Stream<RequestResponse<TrStockDetails>?> trStockDetailsStream;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<RequestResponse<TrStockDetails>?>(
      stream: trStockDetailsStream,
      builder: (context, snap) {
        if (!snap.hasData) {
          return showLoadingSkeleton(BoxShape.rectangle);
        }

        TrStockDetails details = snap.data!.result!;

        return Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.only(bottom: 2.5),
          child: Text(details.company.description ?? "No Information about this stock yet. 😔", textAlign: TextAlign.start),
        );
      },
    );
  }
}
