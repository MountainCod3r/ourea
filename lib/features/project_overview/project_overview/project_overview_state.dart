part of 'project_overview_bloc.dart';

@immutable
abstract class ProjectOverviewState {}

class InitialProjectOverviewState extends ProjectOverviewState {}

class UpdatedProjectOverviewState extends ProjectOverviewState {
  final Widget chart;
  final OureaStatistics stats;

  UpdatedProjectOverviewState(this.chart, this.stats);
}

class UpdatingProjectOverviewState extends ProjectOverviewState {
  final Widget chart;
  final OureaStatistics stats;

  UpdatingProjectOverviewState(this.chart, this.stats);
}
