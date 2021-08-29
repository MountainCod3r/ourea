part of 'ourea_bloc.dart';

@immutable
abstract class OureaEvent {}

class InitializeOureaBloc extends OureaEvent {}

class ReceivePushNotifications extends OureaEvent {
  final Map<String, dynamic> notification;

  ReceivePushNotifications(this.notification);
}

class AddProject extends OureaEvent {
  final Project project;

  AddProject(this.project);
}

class UpdateProject extends OureaEvent {
  final Project project;

  UpdateProject(this.project);
}

class RemoveProject extends OureaEvent {
  final Project project;

  RemoveProject(this.project);
}

class ChangeEditStatus extends OureaEvent {
  final bool isEditable;

  ChangeEditStatus(this.isEditable);
}

class ErrorProjectEvent extends OureaEvent {
  final String message;

  ErrorProjectEvent(this.message);
}

class TasksChangedForProjects extends OureaEvent {}

class AddTask extends OureaEvent {
  final Task task;

  AddTask(this.task);
}

class UpdateTask extends OureaEvent {
  final Task task;

  UpdateTask(this.task);
}

class RemoveTask extends OureaEvent {
  final Task task;

  RemoveTask(this.task);
}

class ChangeEditStatusTaskEvent extends OureaEvent {
  final bool isEditable;

  ChangeEditStatusTaskEvent(this.isEditable);
}

class CompleteTaskEvent extends OureaEvent {
  final Task task;

  CompleteTaskEvent(this.task);
}

class ErrorTaskEvent extends OureaEvent {
  final String message;

  ErrorTaskEvent(this.message);
}

class StartTimeTransactionEvent extends OureaEvent {
  final TimeTransaction transaction;

  StartTimeTransactionEvent(this.transaction);
}

class StopTimeTransactionEvent extends OureaEvent {
  final TimeTransaction transaction;

  StopTimeTransactionEvent(this.transaction);
}

class UpdateTimeTransaction extends OureaEvent {
  final TimeTransaction transaction;

  UpdateTimeTransaction(this.transaction);
}

class ErrorTimeTransactionEvent extends OureaEvent {
  final String message;

  ErrorTimeTransactionEvent(this.message);
}

class ChangeEditStateTransactionEvent extends OureaEvent {
  final bool isEditable;

  ChangeEditStateTransactionEvent(this.isEditable);
}

class RefreshOureaBlocEvent extends OureaEvent {}
