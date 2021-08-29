import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heatmap_calendar/heatmap_calendar.dart';
import 'package:heatmap_calendar/time_utils.dart';
import 'package:ourea/core/models/ourea_record.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/project_overview/project_overview/project_overview_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class MonthlyProjectChart extends StatefulWidget {
  final Project project;
  final DateTime date;

  MonthlyProjectChart(this.project, this.date);

  @override
  _MonthlyProjectChartState createState() =>
      _MonthlyProjectChartState(project, date);
}

class _MonthlyProjectChartState extends State<MonthlyProjectChart> {
  final Project project;
  final DateTime date;
  ProjectOverviewBloc _bloc;

  _MonthlyProjectChartState(this.project, this.date) {
    _bloc = ProjectOverviewBloc(project);
    _bloc.add(InitializeProjectOverviewEvent());
  }

  @override
  Widget build(BuildContext context) {
    Map<DateTime, int> _map = {};
    return BlocBuilder<ProjectOverviewBloc, ProjectOverviewState>(
        bloc: _bloc,
        builder: (context, state) {
          if (state is UpdatedProjectOverviewState) {
            List<OureaRecord> records =
                state.stats.getAllRecordsForProject(project);
            for (var item in records) {
              var time = TimeUtils.removeTime(item.start);
              if (_map.containsKey(time)) {
                _map[time] += 4;
              } else {
                _map[time] = 4;
              }
            }
          }
          return HeatMapCalendar(
            input: _map,
            colorThresholds: {
              1: Colors.green[100],
              10: Colors.green[300],
              30: Colors.green[500]
            },
            weekDaysLabels: ['S', 'M', 'T', 'W', 'T', 'F', 'S'],
            monthsLabels: [
              "",
              "Jan",
              "Feb",
              "Mar",
              "Apr",
              "May",
              "Jun",
              "Jul",
              "Aug",
              "Sep",
              "Oct",
              "Nov",
              "Dec",
            ],
            squareSize: 25.0,
            textOpacity: 0.3,
            labelTextColor: Colors.blueGrey,
            dayTextColor: Colors.blue[500],
          );
        });
  }

  void dispose() {
    _bloc.close();
    super.dispose();
  }
}
