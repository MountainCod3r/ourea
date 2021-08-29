import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/project_overview/stacked.dart';
import 'package:ourea/features/statistics/charts/chart_types.dart';
import 'package:ourea/features/statistics/charts/daily_chart.dart';
import 'package:ourea/features/statistics/charts/monthly_chart.dart';
import 'package:ourea/features/statistics/charts/weekly_chart.dart';
import 'package:ourea/features/statistics/statistics.dart';
import 'package:flutter/material.dart';
import 'package:ourea/services/locator/locator.dart';

part 'project_overview_event.dart';

part 'project_overview_state.dart';

class ProjectOverviewBloc
    extends Bloc<ProjectOverviewEvent, ProjectOverviewState> {
  Widget chart;
  String _chartType;
  OureaStatistics stats;
  DateTime date;
  OureaBloc _bloc;
  Project project;

  Widget _chartSelect(String chartType) {
    if (chartType == ChartType.daily) {
      return DailyProjectChart(project, date, this);
    }
    if (chartType == ChartType.weekly) {
      return WeeklyProjectChart(project, date);
    }
    if (chartType == ChartType.monthly) {
      return MonthlyProjectChart(project, date);
    }
    if (chartType == ChartType.refresh) {
      return StackedBarChart.withRandomData();
    }
  }

  ProjectOverviewBloc(Project project) {
    this.project = project;
    date = DateTime.now();
    _bloc = locator<OureaBloc>();
    _chartType = ChartType.daily;
    chart = _chartSelect(_chartType);

    _bloc.listen((state) {
      if (state is UpdatedOureaState) {
        stats = OureaStatistics(
            projects: state.projectList,
            tasks: state.taskList,
            time: state.timeList);
      }
    });
  }

  @override
  ProjectOverviewState get initialState => InitialProjectOverviewState();

  @override
  Stream<ProjectOverviewState> mapEventToState(
      ProjectOverviewEvent event) async* {
    if (event is InitializeProjectOverviewEvent) {
      yield UpdatedProjectOverviewState(chart, stats);
    }
    if (event is DateChangedProjectOverviewEvent) {
      date = event.date;
      chart = _chartSelect(_chartType);
      yield UpdatedProjectOverviewState(chart, stats);
    }
    if (event is ChartTypeChangedProjectOverviewEvent) {
      chart = null;
      _chartType = event.chartType;
      chart = _chartSelect(_chartType);
      yield UpdatedProjectOverviewState(chart, stats);
    }
  }
}
