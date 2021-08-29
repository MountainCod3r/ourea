part of 'project_overview_bloc.dart';

@immutable
abstract class ProjectOverviewEvent {}

class InitializeProjectOverviewEvent extends ProjectOverviewEvent {}

class DateChangedProjectOverviewEvent extends ProjectOverviewEvent {
  final DateTime date;

  DateChangedProjectOverviewEvent(this.date);
}

class ChartTypeChangedProjectOverviewEvent extends ProjectOverviewEvent {
  final String chartType;

  ChartTypeChangedProjectOverviewEvent(this.chartType);
}
