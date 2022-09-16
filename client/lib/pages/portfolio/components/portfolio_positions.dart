import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_stream_builder.dart';
import 'package:solidtrade/data/entities/outstanding_order_model.dart';
import 'package:solidtrade/data/entities/portfolio.dart';
import 'package:solidtrade/data/models/common/product_tile_info.dart';
import 'package:solidtrade/data/models/enums/shared_enums/position_type.dart';
import 'package:solidtrade/pages/portfolio/components/outstanding_portfolio_list_tile.dart';
import 'package:solidtrade/pages/portfolio/components/portfolio_list_tile.dart';
import 'package:solidtrade/pages/portfolio/components/portfolio_overview_title.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';

class PortfolioPositions extends StatelessWidget {
  PortfolioPositions({Key? key, required this.isViewingOutstandingOrders}) : super(key: key);
  final bool isViewingOutstandingOrders;

  final _portfolioService = GetIt.instance.get<PortfolioService>();
  late final _positionTitle = PortfolioOverviewTitle(
    title: !isViewingOutstandingOrders ? "Positions" : "Outstanding Orders",
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      child: STStreamBuilder<Portfolio>(
        stream: _portfolioService.stream$,
        builder: (context, portfolio) {
          if (!portfolio.hasAnyPositions) {
            const stockViewUserMessage = "Nothing to see here yet 😉\nWhy not start investing and experience how it feels to lose money professionally!";
            const outstandingOrdersViewUserMessage = "No current outstanding orders 😉";
            final userMessage = isViewingOutstandingOrders ? outstandingOrdersViewUserMessage : stockViewUserMessage;

            return Column(
              children: [
                const Divider(color: Colors.grey),
                const SizedBox(height: 5),
                _positionTitle,
                const SizedBox(height: 15),
                Text(
                  userMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
              ],
            );
          }

          return PortfolioPositionsContent(
            isViewingOutstandingOrders: isViewingOutstandingOrders,
            positionTitleWidget: _positionTitle,
            portfolio: portfolio,
          );
        },
      ),
    );
  }
}

class PortfolioPositionsContent extends StatelessWidget {
  PortfolioPositionsContent({
    Key? key,
    required this.isViewingOutstandingOrders,
    required this.positionTitleWidget,
    required this.portfolio,
  }) : super(key: key);
  final bool isViewingOutstandingOrders;
  final Widget positionTitleWidget;
  final Portfolio portfolio;

  static const double spaceBetweenTiles = 10;
  late final stocks = portfolio.stockPositions.map((e) => ProductTileInfo(PositionType.stock, e.isin)).toList();
  late final knockouts = portfolio.knockOutPositions.map((e) => ProductTileInfo(PositionType.knockout, e.isin)).toList();
  late final warrants = portfolio.warrantPositions.map((e) => ProductTileInfo(PositionType.warrant, e.isin)).toList();
  late final ongoingKnockouts = portfolio.ongoingKnockOutPositions.map((e) => OutstandingOrderModel.ongoingKnockoutPositionToOutstandingModel(e)).toList();
  late final ongoingWarrants = portfolio.ongoingWarrantPositions.map((e) => OutstandingOrderModel.ongoingWarrantPositionToOutstandingModel(e)).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: !isViewingOutstandingOrders
          ? [
              positionTitleWidget,
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Stocks", products: stocks),
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Knockouts", products: knockouts),
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Warrants", products: warrants),
              const SizedBox(height: spaceBetweenTiles),
            ]
          : [
              positionTitleWidget,
              OutstandingOrdersPortfolioListTile(title: "Outstanding knockout orders", products: ongoingKnockouts, positionType: PositionType.knockout),
              const SizedBox(height: spaceBetweenTiles),
              OutstandingOrdersPortfolioListTile(title: "Outstanding warrant orders", products: ongoingWarrants, positionType: PositionType.warrant),
              const SizedBox(height: spaceBetweenTiles),
            ],
    );
  }
}
