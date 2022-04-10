import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:rxdart/streams.dart';
import 'package:rxdart/subjects.dart';
import 'package:solidtrade/data/common/error/request_response.dart';
import 'package:solidtrade/data/common/shared/tr/tr_product_price.dart';
import 'package:solidtrade/data/enums/chart_date_range_view.dart';
import 'package:solidtrade/services/storage/aggregate_history_service.dart';
import 'package:solidtrade/services/util/debug/log.dart';
import 'package:solidtrade/services/util/util.dart';

class TrContinuousProductPricesService implements Disposable {
  final BehaviorSubject<List<MapEntry<DateTime, double>>> _secondaryBehaviorSubject = BehaviorSubject.seeded([]);
  final BehaviorSubject<List<MapEntry<DateTime, double>>> _behaviorSubject = BehaviorSubject.seeded([]);
  ValueStream<List<MapEntry<DateTime, double>>> get primaryProductPricesStream$ => _behaviorSubject.stream;
  ValueStream<List<MapEntry<DateTime, double>>> get secondaryStream$ => _secondaryBehaviorSubject.stream;
  bool get currentHasValue => _behaviorSubject.hasValue;
  List<MapEntry<DateTime, double>> get _current => _behaviorSubject.value;

  final AggregateHistoryService _aggregateHistoryService = GetIt.instance.get<AggregateHistoryService>();
  final Stream<RequestResponse<TrProductPrice>?> _priceStream;
  final Stream<ChartDateRangeView> _chartDateRangeStream;
  final String _isinWithExtension;

  late ChartDateRangeView currentView;
  late int expectedClosingTime;
  double? _preOpen;

  StreamSubscription? _priceStreamSubscription;

  TrContinuousProductPricesService(this._chartDateRangeStream, this._priceStream, this._isinWithExtension) {
    _chartDateRangeStream.listen(onChartDateRangeChanged);
  }

  Future<void> onChartDateRangeChanged(ChartDateRangeView view) async {
    await fetchAndAddTrAggregateHistory(view);

    currentView = view;
    _priceStreamSubscription ??= _priceStream.listen(onNewTrProductPrice);
    emitNewTrContinuousProductPrices();
    loadPreOpenPriceToStream();
  }

  Future<void> fetchAndAddTrAggregateHistory(ChartDateRangeView range) async {
    var response = await _aggregateHistoryService.getTrAggregateHistory(_isinWithExtension, Util.chartDateRangeToString(range));

    if (!response.isSuccessful) {
      // TODO: Handle...
      Log.f("Failed to fetch aggregateHistory successfully");
      return;
    }

    _current.clear();
    expectedClosingTime = response.result!.expectedClosingTime;
    var data = response.result!.aggregates.map((e) => MapEntry(DateTime.fromMillisecondsSinceEpoch(e.time), e.close));
    _current.addAll(data);
  }

  Future<void> onNewTrProductPrice(RequestResponse<TrProductPrice>? response) async {
    Future<void> processNewTrProductPrice() async {
      if (response == null) {
        return;
      }

      if (!response.isSuccessful) {
        return;
      }

      var price = response.result!;

      _current.add(MapEntry(DateTime.fromMillisecondsSinceEpoch(price.bid.time), price.bid.price));

      _preOpen = price.pre.price;
      loadPreOpenPriceToStream();
    }

    await processNewTrProductPrice();
    emitNewTrContinuousProductPrices();
  }

  void loadPreOpenPriceToStream() {
    var isOneDay = currentView == ChartDateRangeView.oneDay;

    if (isOneDay && _preOpen == null) {
      return;
    }

    var _preOpenPrice = isOneDay ? _preOpen! : _current.first.value;

    var x1 = MapEntry(_current.first.key, _preOpenPrice);
    var x2 = MapEntry(DateTime.fromMillisecondsSinceEpoch(expectedClosingTime), _preOpenPrice);

    _secondaryBehaviorSubject.add([
      x1,
      x2
    ]);
  }

  void emitNewTrContinuousProductPrices() {
    _behaviorSubject.add(_current);
  }

  @override
  FutureOr onDispose() async {
    await _priceStreamSubscription?.cancel();
  }
}
