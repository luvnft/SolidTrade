import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class TrStockDetails {
  final String isin;
  final Company company;
  final AnalystRating analystRating;
  final bool hasKpis;

  TrStockDetails(
    this.isin,
    this.company,
    this.analystRating,
    this.hasKpis,
  );
}

@jsonSerializable
class Company {
  final String name;
  double? marketCapSnapshot;
  String? description;
  double? peRatioSnapshot;

  Company(
    this.name,
    this.marketCapSnapshot,
    this.description,
    this.peRatioSnapshot,
  );
}

@jsonSerializable
class AnalystRating {
  final TargetPrice targetPrice;
  final Recommendations recommendations;

  AnalystRating(
    this.targetPrice,
    this.recommendations,
  );
}

@jsonSerializable
class TargetPrice {
  final double average;
  final double high;
  final double low;

  TargetPrice(
    this.average,
    this.high,
    this.low,
  );
}

@jsonSerializable
class Recommendations {
  final int buy;
  final int outperform;
  final int hold;
  final int underperform;
  final int sell;

  Recommendations(
    this.buy,
    this.outperform,
    this.hold,
    this.underperform,
    this.sell,
  );
}
