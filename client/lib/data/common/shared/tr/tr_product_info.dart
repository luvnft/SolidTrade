import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class TrProductInfo {
  final bool active;
  final List<String> exchangeIds;
  String? intlSymbol;
  final String shortName;
  final String name;
  final String isin;
  final List<ProductTags> tags;
  final DerivativeProductCount derivativeProductCount;
  DerivativeInfo? derivativeInfo;

  TrProductInfo({
    required this.active,
    required this.exchangeIds,
    required this.shortName,
    required this.isin,
    required this.name,
    required this.tags,
    required this.derivativeProductCount,
    this.intlSymbol,
    this.derivativeInfo,
  });
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

  DerivativeInfoProperties({required this.optionType, required this.strike});
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
