import 'dart:async';
import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  const Chart({
    Key? key,
    this.secondaryStreamData,
    required this.primaryXAxis,
    required this.primaryStreamData,
  }) : super(key: key);

  final Stream<List<MapEntry<dynamic, double>>>? secondaryStreamData;
  final Stream<List<MapEntry<dynamic, double>>> primaryStreamData;
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

  void onDataStreamUpdate(List<MapEntry<dynamic, double>> event) {
    _data.clear();
    setState(() {
      _data.addAll(event);
    });
  }

  void onSecondaryDataStreamUpdate(List<MapEntry<dynamic, double>> event) {
    _secondaryData.clear();
    setState(() {
      _secondaryData.addAll(event);
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
