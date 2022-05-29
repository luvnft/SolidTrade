import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/models/enums/shared_enums/buy_or_sell.dart';

enum OrderType {
  market,
  stop,
  limit,
}

extension OrderTypeExtension on OrderType {
  String get name {
    switch (this) {
      case OrderType.market:
        return "Market";
      case OrderType.stop:
        return "Stop";
      case OrderType.limit:
        return "Limit";
    }
  }

  String get fullName {
    switch (this) {
      case OrderType.market:
        return "Market order";
      case OrderType.stop:
        return "Stop order";
      case OrderType.limit:
        return "Limit order";
    }
  }
}

class _OrderInfo {
  final String title;
  final String subtitle;
  final String emojiAsText;
  final OrderType orderType;

  _OrderInfo(this.title, this.subtitle, this.emojiAsText, this.orderType);
}

class OrderTypeSelection extends StatelessWidget with STWidget {
  OrderTypeSelection({
    Key? key,
    required this.buyOrSell,
    required this.orderType,
  }) : super(key: key);
  final BuyOrSell buyOrSell;
  final OrderType orderType;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            width: MediaQuery.of(context).size.width * 0.2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Divider(
                color: colors.softForeground,
                thickness: 6,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(
              bottom: 20,
            ),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Order types", style: Theme.of(context).textTheme.headline5!.copyWith(fontWeight: FontWeight.w600)),
                const Text("Choose how you would like your order to be executed.")
              ],
            ),
          ),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              color: colors.softBackground,
              child: Column(
                children: [
                  ..._loadButtons(context),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Iterable<Widget> _loadButtons(BuildContext context) => OrderType.values.map((type) => orderTypeButton(context, Key(type.name), type));

  Widget orderTypeButton(BuildContext context, Key key, OrderType type) {
    final orderInfo = _getOrderInfo(buyOrSell, type);

    return Container(
      margin: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Material(
          color: orderType == type ? colors.blueBackground : Colors.transparent,
          child: InkWell(
            key: key,
            hoverColor: colors.blueBackground,
            splashColor: colors.blueBackground,
            highlightColor: Colors.transparent,
            onTap: () => Navigator.pop(context, type),
            child: Container(
              padding: const EdgeInsets.only(top: 5, bottom: 7.5, left: 10),
              child: Row(
                children: [
                  Text(orderInfo.emojiAsText, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(orderInfo.title, style: Theme.of(context).textTheme.bodyText2!.copyWith(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text(
                        orderInfo.subtitle,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.keyboard_arrow_right_rounded),
                  const SizedBox(width: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _OrderInfo _getOrderInfo(BuyOrSell buyOrSell, OrderType type) {
    final isBuy = buyOrSell == BuyOrSell.buy;

    final marketOrderText = isBuy ? "Buy at the current price" : "Sell at the current price";
    final stopOrderText = isBuy ? "Buy when the product rises to a certain price" : "Sell when the product falls to a certain price";
    final limitOrderText = isBuy ? "Buy when the product falls to a certain price" : "Sell when the product rises to a certain price";
    final stopOrderEmoji = isBuy ? "📈" : "📉";
    final limitOrderEmoji = !isBuy ? "📈" : "📉";

    switch (type) {
      case OrderType.market:
        return _OrderInfo("Market order", marketOrderText, "📊", OrderType.market);
      case OrderType.stop:
        return _OrderInfo("Stop order", stopOrderText, stopOrderEmoji, OrderType.stop);
      case OrderType.limit:
        return _OrderInfo("Limit order", limitOrderText, limitOrderEmoji, OrderType.limit);
    }
  }
}
