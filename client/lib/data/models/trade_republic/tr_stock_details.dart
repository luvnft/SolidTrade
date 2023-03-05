import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class TrStockDetails {
  final String isin;
  final Company company;
  final AnalystRating analystRating;
  final bool hasKpis;

  TrStockDetails({
    required this.isin,
    required this.company,
    required this.analystRating,
    required this.hasKpis,
  });
}

class Company {
  final String name;
  double? marketCapSnapshot;
  String? description;
  double? peRatioSnapshot;

  Company({
    required this.name,
    this.marketCapSnapshot,
    this.description,
    this.peRatioSnapshot,
  });
}

class AnalystRating {
  final TargetPrice targetPrice;
  final Recommendations recommendations;

  AnalystRating({
    required this.targetPrice,
    required this.recommendations,
  });
}

class TargetPrice {
  final double average;
  final double high;
  final double low;

  TargetPrice({
    required this.average,
    required this.high,
    required this.low,
  });
}

class Recommendations {
  final int buy;
  final int outperform;
  final int hold;
  final int underperform;
  final int sell;

  Recommendations({
    required this.buy,
    required this.outperform,
    required this.hold,
    required this.underperform,
    required this.sell,
  });
}
