part of 'ourea_bloc.dart';

@immutable
abstract class OureaState {}

class InitialOureaState extends OureaState {}

class UpdatingOureaState extends OureaState {}

class UpdatedOureaState extends OureaState {
  final List<Project> projectList;
  final List<Task> taskList;
  final List<TimeTransaction> timeList;
  final bool isEditable;

  UpdatedOureaState(
      this.isEditable, this.projectList, this.taskList, this.timeList);
}

class ChangeEditState extends OureaState {
  final List<Project> projectList;
  final List<Task> taskList;
  final List<TimeTransaction> timeList;
  final bool isEditable;

  ChangeEditState(
      this.isEditable, this.projectList, this.taskList, this.timeList);
}

class ErrorState extends OureaState {
  final String message;

  ErrorState(this.message);
}
