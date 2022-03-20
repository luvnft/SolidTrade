import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:solidtrade/components/shared/name_for_large_number.dart';
import 'package:solidtrade/config/config_reader.dart';
import 'package:solidtrade/data/common/shared/buy_or_sell.dart';
import 'package:solidtrade/data/common/shared/constants.dart';
import 'package:solidtrade/data/common/shared/position_type.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/common/shared/tr/tr_stock_details.dart';
import 'package:solidtrade/data/common/shared/tuple.dart';
import 'package:solidtrade/data/models/historicalposition.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/providers/app/app_configuration_provider.dart';
import 'package:solidtrade/providers/theme/app_theme.dart';
import 'package:solidtrade/services/util/extensions/string_extensions.dart';

class TrUtil {
  static final _configurationProvider = GetIt.instance.get<ConfigurationProvider>();
  static final _baseUrl = "https://" + ConfigReader.getBaseUrl();

  static TrUiProductDetails getTrUiProductDetails(TrProductPrice priceInfo, TrProductInfo productInfo, PositionType positionType) {
    final isStockPosition = positionType == PositionType.stock;

    final percentageChange = priceInfo.bid.price / priceInfo.pre.price;
    final absoluteChange = priceInfo.bid.price - priceInfo.pre.price;

    final isUp = percentageChange == 1 || 1 < percentageChange;
    final plusMinus = isUp ? "+" : "";

    final productTitle = isStockPosition ? productInfo.shortName : _getDerivitiveProductTitle(productInfo);
    final productSubtitle = isStockPosition ? _getStockProductSubtitle(productInfo.shortName, productInfo.name) : _getDerivitiveProductSubtitle(productInfo);

    final colorMode = _configurationProvider.themeProvider.theme.themeColorType == ColorThemeType.light ? "light" : "dark";

    var imageIsin = isStockPosition ? productInfo.isin : productInfo.derivativeInfo!.underlying.isin;

    return TrUiProductDetails(
      percentageChange: percentageChange,
      absolutChange: absoluteChange,
      isUp: isUp,
      plusMinusProductNamePrefix: plusMinus,
      productTitle: productTitle,
      productSubtitle: productSubtitle,
      imageUrl: _baseUrl + "/image?Isin=$imageIsin&ThemeColor=$colorMode",
      textColor: isUp ? _configurationProvider.themeProvider.theme.stockGreen : _configurationProvider.themeProvider.theme.stockRed,
    );
  }

  static Tuple<NameForLargeNumber, double> getNameForNumber(double number) {
    if (number > Constants.trillion) {
      return Tuple(t1: NameForLargeNumber.trillion, t2: number / Constants.trillion);
    } else if (number > Constants.billion) {
      return Tuple(t1: NameForLargeNumber.billion, t2: number / Constants.billion);
    } else if (number > Constants.million) {
      return Tuple(t1: NameForLargeNumber.million, t2: number / Constants.million);
    }
    return Tuple(t1: NameForLargeNumber.thousand, t2: number / Constants.thousand);
  }

  static String _getStockProductSubtitle(String shortName, String name) {
    return name.length > 18 ? shortName : name;
  }

  static String _getDerivitiveProductTitle(TrProductInfo info) {
    return "${info.derivativeInfo!.properties.optionType.capitalize()} @${info.derivativeInfo!.properties.strike.toStringAsFixed(2)}";
  }

  static String _getDerivitiveProductSubtitle(TrProductInfo info) {
    return "${info.derivativeInfo!.productCategoryName} ${info.derivativeInfo!.underlying.name}";
  }

  static int productViewGetAnalystsCount(Recommendations recommendations) {
    return recommendations.buy + recommendations.hold + recommendations.outperform + recommendations.sell + recommendations.underperform;
  }

  static bool userOwnsPosition(Portfolio portfolio, String isin) {
    bool ownsPosition = portfolio.stockPositions.any((position) => position.isin == isin);
    if (ownsPosition) return true;

    ownsPosition = portfolio.knockOutPositions.any((position) => position.isin == isin);
    if (ownsPosition) return true;

    ownsPosition = portfolio.warrantPositions.any((position) => position.isin == isin);
    if (ownsPosition) return true;

    return false;
  }

  // List<HistoricalPosition> getRemaindingHistoricalPositions(List<HistoricalPosition> positions) {
  //   List<HistoricalPosition> results = [];
  //   for (var position in positions) {
  //     int index = results.indexWhere((p) => p.isin == position.isin);
  //     if (index != -1) {
  //       var result = results[index];
  //       result[index] = HistoricalPosition.copy(result, numberOfShares);
  //     }
  //   }
  //   return results;
  // }

  static Map<DateTime, HistoricalPosition> getCurrentNumberOfSharesForPortfolioPosition(List<DateTime> dates, List<HistoricalPosition> pps) {
    final Map<DateTime, HistoricalPosition> map = {};
    List<HistoricalPosition> positions = [];
    List<int> ids = [];

    var d = dates.reduce((a, b) => a.difference(pps.first.createdAt).abs() < b.difference(pps.first.createdAt).abs() ? a : b);

    var index = dates.indexWhere((element) => element == d);

    for (var i = index; i < dates.length; i++) {
      for (var pp in pps) {
        if (!pp.createdAt.compareTo(dates[i]).isNegative || ids.any((id) => id == pp.id)) {
          continue;
        }

        var index = positions.indexWhere((element) => element.isin == pp.isin);

        if (index == -1) {
          ids.add(pp.id);
          positions.add(pp);
          map[dates[i]] = pp;
          continue;
        }
        var pos = positions[index];
        if (pp.buyOrSell == BuyOrSell.buy) {
          positions[index] = HistoricalPosition.copy(pos, pos.numberOfShares + pp.numberOfShares);
        } else {
          positions[index] = HistoricalPosition.copy(pos, pos.numberOfShares - pp.numberOfShares);
        }

        ids.add(pp.id);
        map[dates[i]] = positions[index];
      }
    }

    return map;
  }
}

class TrUiProductDetails {
  final double percentageChange;
  final double absolutChange;
  final bool isUp;
  final String plusMinusProductNamePrefix;
  final String productTitle;
  final String productSubtitle;
  final String imageUrl;
  final Color textColor;

  TrUiProductDetails({
    required this.percentageChange,
    required this.absolutChange,
    required this.isUp,
    required this.plusMinusProductNamePrefix,
    required this.productTitle,
    required this.productSubtitle,
    required this.imageUrl,
    required this.textColor,
  });
}
