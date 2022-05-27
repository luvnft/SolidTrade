import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/prevent_render_flex_overflow_wrapper.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/common/learn_about_order_types_button.dart';
import 'package:solidtrade/components/shared/create_order_view/order_type_selection.dart';
import 'package:solidtrade/data/enums/buy_or_sell.dart';
import 'package:solidtrade/services/util/util.dart';

class OrderTypeDescriptionView extends StatelessWidget with STWidget {
  OrderTypeDescriptionView({
    Key? key,
    required this.name,
    required this.orderType,
    required this.buyOrSell,
    required this.nextPage,
  }) : super(key: key);
  final String name;
  final BuyOrSell buyOrSell;
  final OrderType orderType;
  final Widget nextPage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors.orderDescriptionColor,
      appBar: AppBar(elevation: 0, backgroundColor: colors.orderDescriptionColor, foregroundColor: colors.foreground),
      body: Container(
        margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        child: PreventColumnRenderFlexOverflowWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                orderType.fullName,
                style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w600),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
              Text(_orderDescription, style: TextStyle(fontSize: 16.5, color: colors.lessSoftForeground)),
              const Spacer(),
              Image.asset(_orderTypeImage),
              const Spacer(flex: 3),
              LearnAboutOrderTypesButton(),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: () => _pushToNextPage(context),
                  child: const Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String get _orderTypeImage {
    switch (buyOrSell) {
      case BuyOrSell.buy:
        switch (orderType) {
          case OrderType.market:
            throw ("Did not expect market order");
          case OrderType.stop:
            return colors.stopOrderBuy;
          case OrderType.limit:
            return colors.limitOrderBuy;
        }
      case BuyOrSell.sell:
        switch (orderType) {
          case OrderType.market:
            throw ("Did not expect market order");
          case OrderType.stop:
            return colors.stopOrderSell;
          case OrderType.limit:
            return colors.limitOrderSell;
        }
    }
  }

  String get _orderDescription {
    switch (buyOrSell) {
      case BuyOrSell.buy:
        switch (orderType) {
          case OrderType.market:
            throw ("Did not expect market order");
          case OrderType.stop:
            return translations.createOrderView.buyStopOrderDescription(name);
          case OrderType.limit:
            return translations.createOrderView.buyLimitOrderDescription(name);
        }
      case BuyOrSell.sell:
        switch (orderType) {
          case OrderType.market:
            throw ("Did not expect market order");
          case OrderType.stop:
            return translations.createOrderView.sellStopOrderDescription(name);
          case OrderType.limit:
            return translations.createOrderView.sellLimitOrderDescription(name);
        }
    }
  }

  Future<void> _pushToNextPage(BuildContext context) async {
    var result = await Util.pushToRoute(context, nextPage);
    Navigator.pop(context, result);
  }
}
