part of 'project_bloc.dart';

@immutable
abstract class ProjectState {}

class InitialProjectState extends ProjectState {}

class UpdatingProjectState extends ProjectState {}

class UpdatedProjectState extends ProjectState {
  final List<Project> projectList;
  final bool isEditable;

  UpdatedProjectState(this.isEditable, this.projectList);
}

class ChangeEditState extends ProjectState {
  final List<Project> projectList;
  final bool isEditable;

  ChangeEditState(this.isEditable, this.projectList);
}

class ErrorState extends ProjectState {
  final String message;

  ErrorState(this.message);
}
