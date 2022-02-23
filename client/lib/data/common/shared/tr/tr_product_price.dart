import 'package:simple_json_mapper/simple_json_mapper.dart';

@JsonObject()
class TrProductPrice {
  final TrProductPriceItem open;
  final TrProductPriceItem pre;
  final TrProductPriceItem bid;
  TrProductPriceItem? ask;

  TrProductPrice({required this.open, required this.bid, this.ask, required this.pre});
}

class TrProductPriceItem {
  final int time;
  final double price;
  const TrProductPriceItem({required this.time, required this.price});
}
