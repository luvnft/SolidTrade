import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/portfolio/portfolio_overview_title.dart';
import 'package:solidtrade/components/shared/product_tile.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';

class PortfolioListTile extends StatelessWidget with STWidget {
  PortfolioListTile({Key? key, required this.title, required this.products}) : super(key: key);
  final List<ProductTileInfo> products;
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
                      child: ProductTile(info: products[index]),
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
