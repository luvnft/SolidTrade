import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class TrProductPrice {
  final TrProductPriceItem pre;
  final TrProductPriceItem bid;
  final TrProductPriceItem ask;
  const TrProductPrice({required this.bid, required this.ask, required this.pre});
}

class TrProductPriceItem {
  final int time;
  final double price;
  const TrProductPriceItem({required this.time, required this.price});
}
