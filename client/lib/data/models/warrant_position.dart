class WarrantPosition {
  @override
  final int id;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  final String isin;
  final double buyInPrice;
  final int numberOfShares;

  const WarrantPosition({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.isin,
    required this.buyInPrice,
    required this.numberOfShares,
  });

  factory WarrantPosition.fromJson(Map<String, dynamic> json) {
    return WarrantPosition(
      id: json["id"],
      createdAt: DateTime.parse(json["createdAt"]),
      updatedAt: DateTime.parse(json["updatedAt"]),
      isin: json["isin"],
      buyInPrice: json["buyInPrice"],
      numberOfShares: json["numberOfShares"],
    );
  }
}
