import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/portfolio/portfolio_overview_title.dart';
import 'package:solidtrade/components/portfolio/ongoing_product_tile.dart';
import 'package:solidtrade/data/enums/position_type.dart';
import 'package:solidtrade/data/models/outstanding_order_model.dart';

class OutstandingOrdersPortfolioListTile extends StatelessWidget with STWidget {
  OutstandingOrdersPortfolioListTile({Key? key, required this.title, required this.products, required this.positionType}) : super(key: key);
  final List<OutstandingOrderModel> products;
  final PositionType positionType;
  final String title;

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? const SizedBox.shrink()
        : Column(
            children: [
              PortfolioOverviewTitle(title: title + " (${products.length})", textStyle: Theme.of(context).textTheme.subtitle1),
              const SizedBox(height: 5),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (_, index) => Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: OngoingProductTile(info: products[index], positionType: positionType),
                    ),
                    index == products.length - 1
                        ? const SizedBox.shrink()
                        : Divider(
                            thickness: 1,
                            color: colors.softForeground,
                            height: 5,
                          ),
                  ],
                ),
              ),
            ],
          );
  }
}
