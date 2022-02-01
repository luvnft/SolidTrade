import 'package:solidtrade/data/common/shared/buy_or_sell.dart';
import 'package:solidtrade/data/models/historicalposition.dart';

class TrUtil {
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
