import 'package:dart_json_mapper/dart_json_mapper.dart';
import 'package:solidtrade/data/models/enums/shared_enums/buy_or_sell.dart';

@jsonSerializable
class TrProductPrice {
  final TrProductPriceItem open;
  final TrProductPriceItem pre;
  final TrProductPriceItem bid;
  TrProductPriceItem? ask;

  double getPriceDependingOfBuyOrSell(BuyOrSell buyOrSell) {
    return buyOrSell.isBuy ? ask!.price : bid.price;
  }

  TrProductPrice(this.open, this.bid, this.ask, this.pre);
}

@jsonSerializable
class TrProductPriceItem {
  final int time;
  final double price;
  const TrProductPriceItem(this.time, this.price);
}
