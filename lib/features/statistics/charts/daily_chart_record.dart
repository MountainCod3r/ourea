import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class DailyChartRecord {
  final int weekday;
  final String taskId;
  final Duration duration;

  final charts.Color color;

  DailyChartRecord(this.taskId, this.duration, Color color, this.weekday)
      : this.color = new charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}
