import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class TrProductInfo {
  final bool active;
  final List<String> exchangeIds;
  String? intlSymbol;
  final String shortName;
  final String isin;
  final List<ProductTags> tags;
  final DerivativeProductCount derivativeProductCount;

  TrProductInfo({
    required this.active,
    required this.exchangeIds,
    this.intlSymbol,
    required this.shortName,
    required this.isin,
    required this.tags,
    required this.derivativeProductCount,
  });
}

class ProductTags {
  final String name;
  final String icon;

  ProductTags({required this.name, required this.icon});
}

class DerivativeProductCount {
  int? knockOutProduct;
  int? vanillaWarrant;

  DerivativeProductCount({this.knockOutProduct, this.vanillaWarrant});
}
