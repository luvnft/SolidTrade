import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:intl/intl.dart';
import 'package:solidtrade/data/models/trade_republic/tr_derivative_search_result_mapper.dart';

@jsonSerializable
class TrDerivativeSearchResult {
  final String name;
  final String isin;
  final String issuerDisplayName;
  final num leverageOrStrike;
  final num knockoutBarrierOrDelta;
  final num size;
  final String currency;
  final String expiryText;

  TrDerivativeSearchResult(
    this.name,
    this.isin,
    this.issuerDisplayName,
    this.leverageOrStrike,
    this.knockoutBarrierOrDelta,
    this.size,
    this.currency,
    this.expiryText,
  );

  static TrDerivativeSearchResult fromKnockoutSearchResult(TrSingleDerivativeSearchResultMapper result) {
    return TrDerivativeSearchResult(
      result.productCategoryName,
      result.isin,
      result.issuerDisplayName,
      result.leverage!,
      result.barrier!,
      result.size,
      result.currency,
      result.productCategoryName,
    );
  }

  static TrDerivativeSearchResult fromWarrantSearchResult(TrSingleDerivativeSearchResultMapper result) {
    return TrDerivativeSearchResult(
      result.productCategoryName,
      result.isin,
      result.issuerDisplayName,
      result.strike,
      result.delta!,
      result.size,
      result.currency,
      DateFormat('dd.MM.yyyy').format(DateTime.parse(result.expiry!)),
    );
  }
}
