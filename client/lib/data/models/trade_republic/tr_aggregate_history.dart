import 'package:dart_json_mapper/dart_json_mapper.dart';

@jsonSerializable
class TrAggregateHistory {
  final List<TrAggregateHistoryEntry> aggregates;
  final int expectedClosingTime;
  final int lastAggregateEndTime;
  final int resolution;

  TrAggregateHistory(this.aggregates, this.expectedClosingTime, this.lastAggregateEndTime, this.resolution);
}

@jsonSerializable
class TrAggregateHistoryEntry {
  final int time;
  final double open;
  final double close;

  TrAggregateHistoryEntry(this.time, this.open, this.close);
}
