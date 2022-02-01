import 'package:flutter/material.dart';
import 'package:solidtrade/components/portfolio/portfolio_overview_title.dart';
import 'package:solidtrade/components/shared/product_tile.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';

class PortfolioListTile extends StatelessWidget {
  const PortfolioListTile({Key? key, required this.title, required this.products}) : super(key: key);
  final List<ProductTileInfo> products;
  final String title;

  @override
  Widget build(BuildContext context) {
    return products.isEmpty
        ? const SizedBox.shrink()
        : Column(
            children: [
              PortfolioOverviewTitle(title: title + " (${products.length})", textStyle: Theme.of(context).textTheme.subtitle1),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: products.length,
                itemBuilder: (_, index) => ProductTile(info: products[index]),
              ),
            ],
          );
  }
}
