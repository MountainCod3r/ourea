part of 'project_bloc.dart';

@immutable
abstract class ProjectEvent {}

class InitializeProjectBloc extends ProjectEvent {}

class ReceivePushNotifications extends ProjectEvent {
  final Map<String, dynamic> notification;

  ReceivePushNotifications(this.notification);
}

class AddProject extends ProjectEvent {
  final Project project;

  AddProject(this.project);
}

class UpdateProject extends ProjectEvent {
  final Project project;

  UpdateProject(this.project);
}

class RemoveProject extends ProjectEvent {
  final Project project;

  RemoveProject(this.project);
}

class ChangeEditStatus extends ProjectEvent {
  final bool isEditable;

  ChangeEditStatus(this.isEditable);
}

class ErrorProjectEvent extends ProjectEvent {
  final String message;

  ErrorProjectEvent(this.message);
}

class TasksChangedForProjects extends ProjectEvent {}
