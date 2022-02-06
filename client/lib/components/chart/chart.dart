import 'dart:math';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:solidtrade/components/base/st_widget.dart';
import 'package:solidtrade/services/stream/chart_date_range_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Chart extends StatefulWidget {
  const Chart({Key? key, required this.chartDateRangeStream}) : super(key: key);

  // TODO: Consume stream into chart.
  final ChartDateRangeService chartDateRangeStream;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> with STWidget {
  final Random random = Random();

  late TrackballBehavior _trackballBehavior;

  @override
  void initState() {
    _trackballBehavior = TrackballBehavior(
      enable: true,
      tooltipSettings: const InteractiveTooltip(format: 'point.y€'),
      tooltipDisplayMode: TrackballDisplayMode.floatAllPoints,
    );
    super.initState();
  }

  List<_SalesData> data = [
    _SalesData('Jan', 35),
    _SalesData('Feb', 28),
    _SalesData('Mar', 34),
    _SalesData('Apr', 32),
    _SalesData('May', 40)
  ];

  List<_SalesData> lastTradingDayCClose = [
    _SalesData('Jan', 20),
    _SalesData('May', 20)
  ];
  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      primaryXAxis: CategoryAxis(),
      trackballBehavior: _trackballBehavior,
      annotations: <CartesianChartAnnotation>[
        CartesianChartAnnotation(
          widget: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) => SizedBox(
              width: constraints.maxWidth - 26,
              child: DottedLine(dashColor: colors.foreground),
            ),
          ),
          coordinateUnit: CoordinateUnit.point,
          region: AnnotationRegion.plotArea,
          x: (data.length - 1) * 0.503,
          y: 12,
        ),
      ],
      series: <ChartSeries<_SalesData, String>>[
        LineSeries<_SalesData, String>(
          dataSource: data,
          xValueMapper: (_SalesData sales, _) => sales.year,
          yValueMapper: (_SalesData sales, _) => sales.sales,
        ),
      ],
    );
  }
}

class _SalesData {
  _SalesData(this.year, this.sales);

  final String year;
  final double sales;
}
