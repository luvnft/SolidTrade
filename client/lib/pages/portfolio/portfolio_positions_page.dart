import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/portfolio/portfolio_list_tile.dart';
import 'package:solidtrade/components/portfolio/portfolio_overview_title.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/product_tile_info.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/util/util.dart';

class PortfolioPositionsPage extends StatefulWidget {
  const PortfolioPositionsPage({Key? key}) : super(key: key);

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
      child: StreamBuilder<RequestResponse<Portfolio>?>(
        stream: portfolioService.stream$,
        builder: (context, snap) {
          const positionTitle = PortfolioOverviewTitle(title: "Positions");

          if (!snap.hasData) {
            return showLoadingSkeleton(BoxShape.rectangle);
          }

          Portfolio portfolio = snap.data!.result!;
          var hasAnyPositions = portfolio.knockOutPositions.isNotEmpty || portfolio.ongoingKnockOutPositions.isNotEmpty || portfolio.ongoingWarrantPositions.isNotEmpty || portfolio.stockPositions.isNotEmpty || portfolio.warrantPositions.isNotEmpty;

          if (!hasAnyPositions) {
            return Column(
              children: const [
                Divider(color: Colors.grey),
                SizedBox(height: 5),
                positionTitle,

                // TODO: Some message the encourage the user to start.
              ],
            );
          }

          final stocks = portfolio.stockPositions.map((e) => ProductTileInfo(PositionType.stock, e.isin)).toList();
          final knockouts = portfolio.knockOutPositions.map((e) => ProductTileInfo(PositionType.knockout, e.isin)).toList();
          final warrants = portfolio.warrantPositions.map((e) => ProductTileInfo(PositionType.warrant, e.isin)).toList();
          final ongoingKnockouts = portfolio.ongoingKnockOutPositions.map((e) => ProductTileInfo(PositionType.knockout, e.isin)).toList();
          final ongoingWarrants = portfolio.ongoingWarrantPositions.map((e) => ProductTileInfo(PositionType.warrant, e.isin)).toList();

          const double spaceBetweenTiles = 10;

          return Column(
            children: [
              positionTitle,
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Stocks", products: stocks),
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Knockouts", products: knockouts),
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Warrants", products: warrants),
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Outstanding knockout orders", products: ongoingKnockouts),
              const SizedBox(height: spaceBetweenTiles),
              PortfolioListTile(title: "Outstanding warrant orders", products: ongoingWarrants),
              const SizedBox(height: spaceBetweenTiles),
            ],
          );
        },
      ),
    );
  }
}
