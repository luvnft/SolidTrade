import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/data/common/shared/tr/tr_continuous_product_prices_event.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key? key,
    this.secondaryStreamData,
    required this.primaryXAxis,
    required this.primaryStreamData,
  }) : super(key: key);

  final Stream<TrContinuousProductPricesEvent>? secondaryStreamData;
  final Stream<TrContinuousProductPricesEvent> primaryStreamData;
  final ChartAxis primaryXAxis;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with STWidget {
  final List<MapEntry<dynamic, double>> _secondaryData = [];
  final List<MapEntry<dynamic, double>> _data = [];

  final TrackballBehavior _trackballBehavior = TrackballBehavior(
    enable: true,
    tooltipSettings: const InteractiveTooltip(format: 'point.y€'),
    tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
  );

  StreamSubscription? _dataSecondarySubscription;
  StreamSubscription? _dataSubscription;

  @override
  void initState() {
    super.initState();
    _dataSubscription = widget.primaryStreamData.listen(onDataStreamUpdate);
    _dataSecondarySubscription = widget.secondaryStreamData?.listen(onSecondaryDataStreamUpdate);
  }

  void onDataStreamUpdate(TrContinuousProductPricesEvent event) {
    setState(() {
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
    });
  }

  void onSecondaryDataStreamUpdate(TrContinuousProductPricesEvent event) {
    setState(() {
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
      primaryXAxis: widget.primaryXAxis,
      trackballBehavior: _trackballBehavior,
      series: <ChartSeries<MapEntry<dynamic, double>, dynamic>>[
        LineSeries<MapEntry<dynamic, double>, dynamic>(
          dataSource: _data,
          animationDuration: 500,
          enableTooltip: true,
          xValueMapper: (MapEntry<dynamic, double> x, _) => x.key,
          yValueMapper: (MapEntry<dynamic, double> y, _) => y.value,
        ),
        LineSeries<MapEntry<dynamic, double>, dynamic>(
          dataSource: _secondaryData,
          animationDuration: 500,
          enableTooltip: false,
          color: Colors.grey,
          dashArray: [
            6,
            8
          ],
          xValueMapper: (MapEntry<dynamic, double> x, _) => x.key,
          yValueMapper: (MapEntry<dynamic, double> y, _) => y.value,
        ),
      ],
    );
  }
}
