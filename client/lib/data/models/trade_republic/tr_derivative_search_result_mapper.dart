import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:solidtrade/data/models/enums/shared_enums/position_type.dart';
import 'package:solidtrade/data/models/trade_republic/tr_derivative_search_result.dart';

@jsonSerializable
class TrDerivativeSearchResultMapper {
  final List<TrSingleDerivativeSearchResultMapper> results;
  final int resultCount;

  TrDerivativeSearchResultMapper(
    this.resultCount,
    this.results,
  );

  Iterable<TrDerivativeSearchResult> convertToTrDerivativeSearchResults(PositionType positionType) {
    switch (positionType) {
      case PositionType.warrant:
        return results.map((e) => TrDerivativeSearchResult.fromWarrantSearchResult(e));
      case PositionType.knockout:
        return results.map((e) => TrDerivativeSearchResult.fromKnockoutSearchResult(e));
      default:
        throw Exception('Expected ${(PositionType).toString()} to be knockout or warrant. But provided argument was $positionType.');
    }
  }
}

@jsonSerializable
class TrSingleDerivativeSearchResultMapper {
  final String isin;
  final String productCategoryName;
  final num? barrier;
  final num? leverage;
  final num strike;
  final num size;
  final num? delta;
  final String currency;
  final String? expiry;
  final String issuerDisplayName;

  TrSingleDerivativeSearchResultMapper(
    this.isin,
    this.productCategoryName,
    this.barrier,
    this.leverage,
    this.strike,
    this.size,
    this.delta,
    this.currency,
    this.expiry,
    this.issuerDisplayName,
  );
}
