import 'package:ourea/core/models/task.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:ourea/core/models/time_transaction.dart';
import 'package:flutter/material.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class TaskDuration {
  final Task task;
  Duration duration;
  final DateTime startTime;
  final DateTime stopTime;
  final charts.Color color;
  List<TimeTransaction> _timeList = [];

  TaskDuration({this.task, this.startTime, this.stopTime, Color color})
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha) {
    _timeList = locator<OureaBloc>().timeList;
    duration = Duration();
    List<TimeTransaction> filteredList = _timeList
        .where((element) =>
            (element.taskId == task.id) &&
            (element.stop.isAfter(startTime) &&
                element.stop.isBefore(stopTime)))
        .toList();
    for (var transaction in filteredList) {
      Duration transactionDuration;
      if (transaction.isActive) {
        transactionDuration = DateTime.now().difference(transaction.start);
      } else {
        transactionDuration = transaction.stop.difference(transaction.start);
      }
      duration += transactionDuration;
    }
  }

  String toString() {
    return """
      task: ${task.name},
      totalDuration: ${duration.inSeconds},
    """;
  }
}
