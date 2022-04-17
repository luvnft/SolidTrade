import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/shared/tr/tr_continuous_product_prices_event.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key? key,
    this.secondaryStreamData,
    required this.dateTimeXAxis,
    required this.primaryStreamData,
  }) : super(key: key);

  final Stream<TrContinuousProductPricesEvent>? secondaryStreamData;
  final Stream<TrContinuousProductPricesEvent> primaryStreamData;
  final ChartAxis dateTimeXAxis;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with STWidget {
  final List<MapEntry<DateTime, double>> _secondaryData = [];
  final List<MapEntry<DateTime, double>> _data = [];

  StreamSubscription? _dataSecondarySubscription;
  StreamSubscription? _dataSubscription;
  bool isHoldingDownOnChart = false;

  @override
  void initState() {
    super.initState();
    _dataSubscription = widget.primaryStreamData.listen(onDataStreamUpdate);
    _dataSecondarySubscription = widget.secondaryStreamData?.listen(onSecondaryDataStreamUpdate);
  }

  void onDataStreamUpdate(TrContinuousProductPricesEvent event) {
    switch (event.type) {
      case TrContinuousProductPricesEventType.fullUpdate:
        _data.clear();
        _data.addAll(event.data);
        break;
      case TrContinuousProductPricesEventType.lastValueUpdate:
        if (_data.isNotEmpty) {
          _data.last = event.data.first;
        }
        break;
      case TrContinuousProductPricesEventType.additionUpdate:
        _data.addAll(event.data);
        break;
    }

    if (isHoldingDownOnChart) {
      return;
    }

    setState(() {
      _data;
    });
  }

  void onSecondaryDataStreamUpdate(TrContinuousProductPricesEvent event) {
    switch (event.type) {
      case TrContinuousProductPricesEventType.fullUpdate:
        _secondaryData.clear();
        _secondaryData.addAll(event.data);
        break;
      case TrContinuousProductPricesEventType.lastValueUpdate:
        if (_secondaryData.isNotEmpty) {
          _secondaryData.last = event.data.first;
        }
        break;
      case TrContinuousProductPricesEventType.additionUpdate:
        _secondaryData.addAll(event.data);
        break;
    }

    if (isHoldingDownOnChart) {
      return;
    }

    setState(() {
      _secondaryData;
    });
  }

  @override
  void dispose() {
    super.dispose();
    _dataSubscription?.cancel();
    _dataSecondarySubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: widget.dateTimeXAxis,
      trackballBehavior: TrackballBehavior(
        enable: true,
        tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
        lineColor: colors.lessSoftForeground,
      ),
      onTrackballPositionChanging: (args) {
        args.chartPointInfo.label = args.chartPointInfo.label! + "€";
        var data = args.chartPointInfo.series!.dataSource as List<MapEntry<DateTime, double>>;

        String str;
        if (data.last.key.difference(data.first.key) < const Duration(days: 1)) {
          str = DateFormat("HH:mm").format(args.chartPointInfo.chartDataPoint!.x).trim();
        } else {
          str = DateFormat("dd.MM.yyyy HH:mm").format(args.chartPointInfo.chartDataPoint!.x).trim();
        }

        /// FYI: The character U+0589 "։" could be confused with the character U+003a "։", which is more common in source code.
        // We do this because when the character U+003a ":" is used the text is not centered for some reason.
        // To bypass this issue we use the character U+0589 "։" which looks the same and also keep the text centered.
        args.chartPointInfo.header = str.replaceFirst(":", "։");
      },
      onChartTouchInteractionDown: (_) => isHoldingDownOnChart = true,
      onChartTouchInteractionUp: (_) => isHoldingDownOnChart = false,
      series: <ChartSeries<MapEntry<DateTime, double>, DateTime>>[
        LineSeries<MapEntry<DateTime, double>, DateTime>(
          name: "Current",
          dataSource: _data,
          animationDuration: 500,
          enableTooltip: true,
          xValueMapper: (MapEntry<DateTime, double> x, _) => x.key,
          yValueMapper: (MapEntry<DateTime, double> y, _) => y.value,
          color: _data.last.value >= _data.first.value ? colors.stockGreen : colors.stockRed,
        ),
        FastLineSeries<MapEntry<DateTime, double>, DateTime>(
          name: "Close",
          dataSource: _secondaryData,
          animationDuration: 500,
          isVisible: _secondaryData.isNotEmpty,
          color: Colors.grey,
          dashArray: [
            3,
            6
          ],
          xValueMapper: (MapEntry<DateTime, double> x, _) => x.key,
          yValueMapper: (MapEntry<DateTime, double> y, _) => y.value,
        ),
      ],
    );
  }
}
