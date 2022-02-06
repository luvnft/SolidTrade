import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/chart/chart.dart';
import 'package:solidtrade/components/shared/product_app_bar.dart';
import 'package:solidtrade/components/shared/product_chart_date_range_selection.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/services/stream/chart_date_range_service.dart';

class ProductView extends StatelessWidget with STWidget {
  ProductView({
    Key? key,
    required this.trProductPriceStream,
    required this.productInfo,
    required this.positionType,
  }) : super(key: key);

  final Stream<RequestResponse<TrProductPrice>?> trProductPriceStream;
  final TrProductInfo productInfo;
  final PositionType positionType;

  final chartDateRangeStream = ChartDateRangeService();

  @override
  Widget build(BuildContext context) {
    final chartHeight = MediaQuery.of(context).size.height * .5;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.background,
        foregroundColor: colors.foreground,
        elevation: 0,
      ),
      body: Column(
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
    );
  }
}
