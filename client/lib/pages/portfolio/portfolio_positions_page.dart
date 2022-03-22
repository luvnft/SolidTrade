import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/portfolio/outstanding_portfolio_list_tile.dart';
import 'package:solidtrade/components/portfolio/portfolio_list_tile.dart';
import 'package:solidtrade/components/portfolio/portfolio_overview_title.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';
import 'package:solidtrade/data/common/shared/st_stream_builder.dart';
import 'package:solidtrade/data/models/outstanding_order_model.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';

class PortfolioPositionsPage extends StatefulWidget {
  const PortfolioPositionsPage({Key? key, required this.isViewingOutstandingOrders}) : super(key: key);
  final bool isViewingOutstandingOrders;

  @override
  _PortfolioPositionsPageState createState() => _PortfolioPositionsPageState();
}

class _PortfolioPositionsPageState extends State<PortfolioPositionsPage> with STWidget {
  final portfolioService = GetIt.instance.get<PortfolioService>();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      child: STStreamBuilder<Portfolio>(
        stream: portfolioService.stream$,
        builder: (context, portfolio) {
          final positionTitle = PortfolioOverviewTitle(title: !widget.isViewingOutstandingOrders ? "Positions" : "Outstanding Orders");
          var hasAnyPositions = portfolio.knockOutPositions.isNotEmpty || portfolio.ongoingKnockOutPositions.isNotEmpty || portfolio.ongoingWarrantPositions.isNotEmpty || portfolio.stockPositions.isNotEmpty || portfolio.warrantPositions.isNotEmpty;

          if (!hasAnyPositions) {
            const stockViewUserMessage = "Nothing to see here yet 😉\nWhy not start investing and experience how it feels to lose money professionally!";
            const outstandingOrdersViewUserMessage = "No current outstanding orders 😉";
            final userMessage = widget.isViewingOutstandingOrders ? outstandingOrdersViewUserMessage : stockViewUserMessage;

            return Column(
              children: [
                const Divider(color: Colors.grey),
                const SizedBox(height: 5),
                positionTitle,
                const SizedBox(height: 15),
                Text(
                  userMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
              ],
            );
          }

          final stocks = portfolio.stockPositions.map((e) => ProductTileInfo(PositionType.stock, e.isin)).toList();
          final knockouts = portfolio.knockOutPositions.map((e) => ProductTileInfo(PositionType.knockout, e.isin)).toList();
          final warrants = portfolio.warrantPositions.map((e) => ProductTileInfo(PositionType.warrant, e.isin)).toList();
          final ongoingKnockouts = portfolio.ongoingKnockOutPositions.map((e) => OutstandingOrderModel.ongoingKnockoutPositionToOutstandingModel(e)).toList();
          final ongoingWarrants = portfolio.ongoingWarrantPositions.map((e) => OutstandingOrderModel.ongoingWarrantPositionToOutstandingModel(e)).toList();

          const double spaceBetweenTiles = 10;

          return Column(
            children: !widget.isViewingOutstandingOrders
                ? [
                    positionTitle,
                    const SizedBox(height: spaceBetweenTiles),
                    PortfolioListTile(title: "Stocks", products: stocks),
                    const SizedBox(height: spaceBetweenTiles),
                    PortfolioListTile(title: "Knockouts", products: knockouts),
                    const SizedBox(height: spaceBetweenTiles),
                    PortfolioListTile(title: "Warrants", products: warrants),
                    const SizedBox(height: spaceBetweenTiles),
                  ]
                : [
                    positionTitle,
                    OutstandingOrdersPortfolioListTile(title: "Outstanding knockout orders", products: ongoingKnockouts, positionType: PositionType.knockout),
                    const SizedBox(height: spaceBetweenTiles),
                    OutstandingOrdersPortfolioListTile(title: "Outstanding warrant orders", products: ongoingWarrants, positionType: PositionType.warrant),
                    const SizedBox(height: spaceBetweenTiles),
                  ],
          );
        },
      ),
    );
  }
}
