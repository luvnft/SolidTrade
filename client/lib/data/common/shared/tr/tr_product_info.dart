import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class TrProductInfo {
  final bool active;
  final List<String> exchangeIds;
  final List<Exchange> exchanges;
  final String shortName;
  final String name;
  final String typeId;
  final String isin;
  final List<ProductTags> tags;
  final DerivativeProductCount derivativeProductCount;
  final String wkn;
  final ProductCompanyInfo company;
  String? intlSymbol;
  String? homeSymbol;
  String? issuerDisplayName;
  DerivativeInfo? derivativeInfo;

  TrProductInfo({
    required this.active,
    required this.exchangeIds,
    required this.shortName,
    required this.typeId,
    required this.wkn,
    required this.isin,
    required this.homeSymbol,
    required this.name,
    required this.tags,
    required this.derivativeProductCount,
    required this.exchanges,
    required this.company,
    this.issuerDisplayName,
    this.derivativeInfo,
    this.intlSymbol,
  });
}

class ProductCompanyInfo {
  int? ipoDate;

  ProductCompanyInfo({this.ipoDate});
}

class Exchange {
  TradingTimes? tradingTimes;

  Exchange({this.tradingTimes});
}

class TradingTimes {
  final int start;
  final int end;

  TradingTimes({required this.start, required this.end});
}

class ProductTags {
  final String name;
  final String icon;

  ProductTags({required this.name, required this.icon});
}

class DerivativeInfo {
  final String productCategoryName;
  final DerivativeUnderlying underlying;
  final bool knocked;
  final DerivativeInfoProperties properties;

  DerivativeInfo({required this.productCategoryName, required this.knocked, required this.underlying, required this.properties});
}

class DerivativeInfoProperties {
  final String optionType;
  final double strike;
  final String currency;
  final double size;
  final String settlementType;
  final String firstTradingDay;
  final double delta;
  String? lastTradingDay;
  double? leverage;
  String? expiry;

  DerivativeInfoProperties({
    required this.optionType,
    required this.strike,
    required this.currency,
    required this.size,
    required this.settlementType,
    required this.firstTradingDay,
    required this.delta,
    this.lastTradingDay,
    this.leverage,
    this.expiry,
  });
}

class DerivativeUnderlying {
  final String isin;
  final String name;

  DerivativeUnderlying({required this.isin, required this.name});
}

class DerivativeProductCount {
  int? knockOutProduct;
  int? vanillaWarrant;

  DerivativeProductCount({this.knockOutProduct, this.vanillaWarrant});
}
