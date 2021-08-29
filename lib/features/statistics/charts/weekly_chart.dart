import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/constants/chart_constants.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/statistics/statistics.dart';
import 'package:ourea/services/locator/locator.dart';

import 'daily_chart_record.dart';

class WeeklyProjectChart extends StatefulWidget {
  final Project project;
  final DateTime date;

  WeeklyProjectChart(this.project, this.date);

  @override
  _WeeklyProjectChartState createState() =>
      _WeeklyProjectChartState(project, date);
}

class _WeeklyProjectChartState extends State<WeeklyProjectChart> {
  final Project project;
  final DateTime date;

  _WeeklyProjectChartState(this.project, this.date);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: locator<OureaBloc>(),
      builder: (context, state) {
        List<String> weekdays = [
          'mon',
          'tues',
          'wed',
          'thurs',
          'fri',
          'sat',
          'sun'
        ];

        if (state is UpdatedOureaState) {
          OureaStatistics stats = OureaStatistics(
              projects: state.projectList,
              tasks: state.taskList,
              time: state.timeList);
          List<Task> taskList = state.taskList
              .where((element) => element.projectId == project.id)
              .toList();
          List<List<DailyChartRecord>> data = [];
          for (int daysago = 6; daysago > 0; daysago--) {
            List<DailyChartRecord> daily = [];
            for (var task in taskList) {
              DailyChartRecord record = DailyChartRecord(
                  task.id,
                  stats.taskDurationByDay(
                      task, date.subtract(Duration(days: daysago))),
                  priorityColor(task.priority),
                  date.subtract(Duration(days: daysago)).weekday);
              if (record.duration.inSeconds > 5) {
                daily.add(record);
              }
            }
            data.add(daily);
          }
          List<charts.Series<DailyChartRecord, String>> series = [];
          for (int i = 0; i < data.length; i++) {
            String dayOfWeek = 'none';
            if (data[i].length > 0) {
              dayOfWeek = weekdays[data[i][0].weekday - 1];
            }
            series.add(charts.Series<DailyChartRecord, String>(
              domainFn: (DailyChartRecord record, _) =>
                  weekdays[record.weekday - 1],
              measureFn: (DailyChartRecord record, _) =>
                  (record.duration.inSeconds / 60) / 60,
              colorFn: (DailyChartRecord record, _) => record.color,
              id: '$dayOfWeek',
              data: data[i],
            ));
          }

          var chart = charts.BarChart(
            series,
            animate: true,
            barGroupingType: charts.BarGroupingType.stacked,
            domainAxis: charts.OrdinalAxisSpec(
              renderSpec: charts.SmallTickRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: kChartFontSize,
                  color: kChartTextColor,

                ),
              ),
            ),
            primaryMeasureAxis: charts.NumericAxisSpec(
              renderSpec: charts.GridlineRendererSpec(
                labelStyle: charts.TextStyleSpec(
                  fontSize: kChartFontSize,
                  color: kChartTextColor,
                ),
                lineStyle: charts.LineStyleSpec(
                  color: kChartTextColor,
                  
                ),
              ),
            ),
          );
          return Padding(
            padding: EdgeInsets.all(32.0),
            child: SizedBox(
              height: 200,
              child: chart,
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
