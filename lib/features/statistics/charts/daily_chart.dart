import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/constants/chart_constants.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/project_overview/project_overview/project_overview_bloc.dart';
import 'package:ourea/features/statistics/charts/daily_chart_record.dart';
import 'package:ourea/services/locator/locator.dart';

class DailyProjectChart extends StatefulWidget {
  final Project project;
  final DateTime day;
  final ProjectOverviewBloc bloc;

  DailyProjectChart(this.project, this.day, this.bloc);

  @override
  _DailyProjectChartState createState() =>
      _DailyProjectChartState(project, day, bloc);
}

class _DailyProjectChartState extends State<DailyProjectChart> {
  final Project project;
  final DateTime day;
  final ProjectOverviewBloc bloc;

  _DailyProjectChartState(this.project, this.day, this.bloc);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: bloc,
      builder: (context, state) {
        if (state is UpdatedProjectOverviewState) {
          List<Task> taskList =
              locator<OureaBloc>().getProjectTaskList(project.id);
          List<DailyChartRecord> data = [];
          for (var task in taskList) {
            DailyChartRecord record = DailyChartRecord(
                task.id,
                state.stats.taskDurationByDay(task, day),
                priorityColor(task.priority),
                day.weekday);
            if (record.duration.inSeconds > 5) {
              data.add(record);
            }
          }

          var series = [
            charts.Series(
              domainFn: (DailyChartRecord record, _) =>
                  locator<OureaBloc>().getTaskById(record.taskId).name,
              measureFn: (DailyChartRecord record, _) =>
                  record.duration.inSeconds,
              colorFn: (DailyChartRecord record, _) => record.color,
              id: 'today',
              data: data,
            ),
          ];

          var chart;
          if (data.length == 0) {
            return Center(
              child: Text('No Data Available'),
            );
          } else {
            chart = charts.PieChart(
              series,
              animate: true,
              defaultRenderer: charts.ArcRendererConfig(
                arcWidth: 30,
                arcRendererDecorators: [
                  charts.ArcLabelDecorator(
                    outsideLabelStyleSpec: charts.TextStyleSpec(
                      fontSize: kChartFontSize,
                      color: kChartTextColor,
                    ),
                  ),
                ],
              ),
            );
          }
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

class DailyTaskChart extends StatefulWidget {
  @override
  _DailyTaskChartState createState() => _DailyTaskChartState();
}

class _DailyTaskChartState extends State<DailyTaskChart> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
