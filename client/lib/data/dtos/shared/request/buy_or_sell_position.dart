import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class BuyOrSellRequestDto {
  final String isin;
  final num numberOfShares;

  BuyOrSellRequestDto({required this.isin, required this.numberOfShares});
}
