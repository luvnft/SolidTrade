import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class TrProductPrice {
  final TrProductPriceItem bid;
  final TrProductPriceItem ask;
  final TrProductPriceItem open;
  const TrProductPrice({required this.bid, required this.ask, required this.open});
}

class TrProductPriceItem {
  final int time;
  final double price;
  const TrProductPriceItem({required this.time, required this.price});
}
