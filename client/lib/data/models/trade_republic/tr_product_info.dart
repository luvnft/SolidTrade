import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:solidtrade/data/models/enums/shared_enums/position_type.dart';

@jsonSerializable
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

  String get tickerOrShortName => isCrypto ? homeSymbol! : intlSymbol ?? derivativeInfo?.underlying.name ?? shortName;
  bool get isCrypto => typeId == 'crypto';
  bool get isStock => typeId == 'stock';
  bool get isDerivative => typeId == 'derivative';
  bool get isFund => typeId == 'fund';
  String get isinWithExchangeExtension => '$isin.${exchangeIds.first}';

  PositionType get positionType {
    if (isStock || isCrypto || isFund) {
      return PositionType.stock;
    }

    if (isDerivative) {
      switch (derivativeInfo!.productGroupType) {
        case 'knockOutProduct':
          return PositionType.knockout;
        case 'vanillaWarrant':
          return PositionType.warrant;
      }
    }

    throw 'Undefined product type';
  }

  TrProductInfo(
    this.active,
    this.exchangeIds,
    this.shortName,
    this.typeId,
    this.wkn,
    this.isin,
    this.homeSymbol,
    this.name,
    this.tags,
    this.derivativeProductCount,
    this.exchanges,
    this.company,
    this.issuerDisplayName,
    this.derivativeInfo,
    this.intlSymbol,
  );
}

@jsonSerializable
class ProductCompanyInfo {
  int? ipoDate;

  ProductCompanyInfo(this.ipoDate);
}

@jsonSerializable
class Exchange {
  TradingTimes? tradingTimes;

  Exchange(this.tradingTimes);
}

@jsonSerializable
class TradingTimes {
  final int start;
  final int end;

  TradingTimes(this.start, this.end);
}

@jsonSerializable
class ProductTags {
  final String name;
  final String icon;

  ProductTags(this.name, this.icon);
}

@jsonSerializable
class DerivativeInfo {
  final String productCategoryName;
  final String productGroupType;
  final DerivativeUnderlying underlying;
  final bool knocked;
  final DerivativeInfoProperties properties;

  DerivativeInfo(this.productCategoryName, this.knocked, this.underlying, this.properties, this.productGroupType);
}

@jsonSerializable
class DerivativeInfoProperties {
  final String optionType;
  final double strike;
  final String currency;
  final double size;
  final String settlementType;
  final String firstTradingDay;
  double? barrier;
  double? delta;
  String? lastTradingDay;
  double? leverage;
  String? expiry;

  DerivativeInfoProperties(
    this.optionType,
    this.strike,
    this.currency,
    this.size,
    this.settlementType,
    this.firstTradingDay,
    this.lastTradingDay,
    this.leverage,
    this.expiry,
    this.barrier,
    this.delta,
  );
}

@jsonSerializable
class DerivativeUnderlying {
  final String isin;
  final String name;

  DerivativeUnderlying(this.isin, this.name);
}

@jsonSerializable
class DerivativeProductCount {
  int? knockOutProduct;
  int? vanillaWarrant;

  DerivativeProductCount(this.knockOutProduct, this.vanillaWarrant);
}
