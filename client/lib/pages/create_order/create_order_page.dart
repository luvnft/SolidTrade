import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:solidtrade/components/custom/prevent_render_flex_overflow_wrapper.dart';
import 'package:solidtrade/components/base/st_stream_builder.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/components/shared/create_order_view/order_settings_view.dart';
import 'package:solidtrade/components/shared/create_order_view/order_type_description_view.dart';
import 'package:solidtrade/components/shared/create_order_view/order_type_selection.dart';
import 'package:solidtrade/components/shared/create_order_view/order_validation_hint.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_info.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/enums/buy_or_sell.dart';
import 'package:solidtrade/data/models/portfolio.dart';
import 'package:solidtrade/services/stream/portfolio_service.dart';
import 'package:solidtrade/services/util/extensions/double_extensions.dart';
import 'package:solidtrade/services/util/local_auth_util.dart';
import 'package:solidtrade/services/util/tr_util.dart';
import 'package:solidtrade/services/util/util.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({
    Key? key,
    required this.productInfo,
    required this.buyOrSell,
    required this.trProductPriceStream,
    required this.productDetails,
  }) : super(key: key);
  final Stream<TrProductPrice?> trProductPriceStream;
  final TrUiProductDetails productDetails;
  final TrProductInfo productInfo;
  final BuyOrSell buyOrSell;

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> with STWidget {
  final _portfolioService = GetIt.instance.get<PortfolioService>();
  late TrProductPrice _currentPrice;

  UserInputValidationResult _inputValidation = UserInputValidationResult.validInput();
  OrderType _orderType = OrderType.market;
  double _definedStopLimitPrice = 0;
  double _numberOfShares = 0;

  bool get _enableCreateOrderButton => !_isMarketOrder && _totalPrice != 0 || _totalPrice != 0 && _inputValidation.isValid;
  bool get _isMarketOrder => _orderType == OrderType.market;

  double get _totalPrice {
    double _getPriceOfSingleShare() {
      switch (_orderType) {
        case OrderType.market:
          return _currentPrice.getPriceDependingOfBuyOrSell(widget.buyOrSell);
        case OrderType.stop:
        case OrderType.limit:
          return _definedStopLimitPrice;
      }
    }

    return (_getPriceOfSingleShare() * _numberOfShares);
  }

  double _getNumberOfSharesOwned(Portfolio portfolio) {
    var stocks = portfolio.stockPositions.where((stock) => stock.isin == widget.productInfo.isin);
    return stocks.isEmpty ? 0 : stocks.first.numberOfShares;
  }

  @override
  Widget build(BuildContext context) {
    return STStreamBuilder<Portfolio>(
      stream: _portfolioService.stream$,
      builder: (_, portfolio) {
        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.productInfo.shortName, style: Theme.of(context).textTheme.bodyText1),
                const SizedBox(height: 1),
                Text(translations.CreateOrderPage.cashAvailable(portfolio.cash), style: Theme.of(context).textTheme.bodyText1!.copyWith(fontWeight: FontWeight.w400)),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: _selectOrderType,
                child: Row(
                  children: [
                    const Icon(Icons.keyboard_arrow_down),
                    Text(_orderType.fullName),
                  ],
                ),
              ),
            ],
            elevation: 0,
            backgroundColor: colors.background,
            foregroundColor: colors.foreground,
          ),
          body: Container(
            margin: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
            child: STStreamBuilder<TrProductPrice>(
              stream: widget.trProductPriceStream,
              builder: (_, price) {
                _currentPrice = price;
                return PreventColumnRenderFlexOverflowWrapper(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            translations.CreateOrderPage.buySellProduct(
                              widget.buyOrSell,
                              widget.productInfo.tickerOrShortName,
                            ),
                            style: Theme.of(context).textTheme.headline4!.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.left,
                          ),
                          const Spacer(),
                          Util.loadImage(
                            widget.productDetails.imageUrl,
                            60,
                            backgroundColor: colors.softBackground,
                          ),
                          const SizedBox(width: 10),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          "➚ 1 ${widget.productInfo.tickerOrShortName} = ${price.getPriceDependingOfBuyOrSell(widget.buyOrSell).toDefaultPrice()}",
                          style: Theme.of(context).textTheme.bodyText1!.copyWith(color: colors.blueText, fontSize: 17),
                        ),
                      ),
                      SharesInput(
                        name: widget.productInfo.tickerOrShortName,
                        isBuy: widget.buyOrSell.isBuy,
                        onChanged: _onNumberOfSharesChanged,
                        totalPrice: _totalPrice,
                        numberOfSharesOwned: _getNumberOfSharesOwned(portfolio),
                      ),
                      const SizedBox(height: 10),
                      !_isMarketOrder
                          ? EditStopLimitPrice(
                              name: widget.productInfo.tickerOrShortName,
                              orderType: _orderType,
                              price: _definedStopLimitPrice,
                              onPressed: () => _openOrderSettingsAndSet(withOrderDescription: false),
                            )
                          : const SizedBox.shrink(),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        height: 20,
                        child: OrderValidationHint(inputValidation: _inputValidation),
                      ),
                      const Spacer(),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                          ).copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.disabled)) {
                                  return colors.softBackground;
                                }

                                return Theme.of(context).colorScheme.primary;
                              },
                            ),
                          ),
                          onPressed: _enableCreateOrderButton ? _createOrder : null,
                          child: Text(
                            _isMarketOrder
                                ? translations.CreateOrderPage.buySellProduct(
                                    widget.buyOrSell,
                                    widget.productInfo.tickerOrShortName,
                                  )
                                : translations.CreateOrderPage.createOrderAsTextLiteral,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Future<void> _createOrder() async {
    if (!(await UtilLocalAuth.authenticate())) {
      return;
    }

    // TODO: Create order
  }

  OrderSettingsView get _getOrderSettingsView => OrderSettingsView(
        buyOrSell: widget.buyOrSell,
        name: widget.productInfo.shortName,
        orderType: _orderType,
        trProductPrice: widget.trProductPriceStream,
      );

  Future<double?> _openOrderDescription() {
    return Util.pushToRoute<double>(
      context,
      OrderTypeDescriptionView(
        orderType: _orderType,
        buyOrSell: widget.buyOrSell,
        name: widget.productInfo.shortName,
        nextPage: _getOrderSettingsView,
      ),
    );
  }

  Future<void> _openOrderSettingsAndSet({bool withOrderDescription = true}) async {
    double? price;
    if (withOrderDescription) {
      price = await _openOrderDescription();
    } else {
      price = await Util.pushToRoute<double>(
        context,
        _getOrderSettingsView,
      );
    }

    price = price ?? _definedStopLimitPrice;

    setState(() {
      _definedStopLimitPrice = price!;
    });
  }

  void _onNumberOfSharesChanged(String numberOfSharesAsString) {
    _updateNumberOfShares(numberOfSharesAsString);
    _validateInput();
  }

  void _updateNumberOfShares(String numberOfSharesAsString) {
    setState(() {
      if (numberOfSharesAsString.isEmpty) {
        _numberOfShares = 0;
      }

      _numberOfShares = double.tryParse(numberOfSharesAsString) ?? _numberOfShares;
    });

    _validateInput();
  }

  void _validateInput() {
    if (_totalPrice > _portfolioService.current!.cash && _isMarketOrder) {
      setState(() {
        _inputValidation = UserInputValidationResult.insufficientFunds();
      });
      return;
    }

    setState(() {
      _inputValidation = UserInputValidationResult.validInput();
    });
  }

  Future<void> _selectOrderType() async {
    var selectedOrderType = await showMaterialModalBottomSheet<OrderType>(
      expand: false,
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Material(
        color: colors.background,
        child: SafeArea(
          top: false,
          child: OrderTypeSelection(buyOrSell: widget.buyOrSell, orderType: _orderType),
        ),
      ),
    );

    if (selectedOrderType == null || selectedOrderType == _orderType) {
      return;
    }

    setState(() {
      _orderType = selectedOrderType;
    });

    if (selectedOrderType != OrderType.market) {
      await _openOrderSettingsAndSet();
    }
  }
}

class SharesInput extends StatelessWidget with STWidget {
  SharesInput({
    Key? key,
    required this.name,
    required this.isBuy,
    required this.onChanged,
    required this.totalPrice,
    required this.numberOfSharesOwned,
  }) : super(key: key);
  final void Function(String) onChanged;
  final double numberOfSharesOwned;
  final double totalPrice;
  final String name;
  final bool isBuy;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: colors.softBackground,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2.5),
                  Text(translations.CreateOrderPage.sharesOwned(numberOfSharesOwned), style: TextStyle(fontSize: 16.5, color: colors.lessSoftForeground))
                ],
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      autofocus: true,
                      textAlign: TextAlign.right,
                      onChanged: onChanged,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,5}')),
                      ],
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: isBuy ? "+0" : "-0",
                        contentPadding: const EdgeInsets.only(bottom: 2),
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: colors.lessSoftForeground),
                      ),
                      style: TextStyle(color: colors.foreground),
                    ),
                    Text(translations.CreateOrderPage.totalPrice(totalPrice), style: TextStyle(fontSize: 16.5, color: colors.lessSoftForeground))
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditStopLimitPrice extends StatelessWidget with STWidget {
  EditStopLimitPrice({
    Key? key,
    required this.name,
    required this.orderType,
    required this.price,
    required this.onPressed,
  }) : super(key: key);
  final void Function() onPressed;
  final String name;
  final OrderType orderType;
  final double price;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Container(
        color: colors.softBackground,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translations.CreateOrderPage.stopLimitText(orderType), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2.5),
                  Text("1 $name = ${price.toDefaultPrice()}", style: const TextStyle(fontWeight: FontWeight.w400)),
                ],
              ),
              Util.roundedButton(
                [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(translations.CreateOrderPage.changeAsTextLiteral),
                  )
                ],
                height: 40,
                colors: colors,
                onPressed: onPressed,
                borderRadius: BorderRadius.circular(10),
              )
            ],
          ),
        ),
      ),
    );
  }
}
