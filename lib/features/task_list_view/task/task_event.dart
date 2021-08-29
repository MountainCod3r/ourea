part of 'task_bloc.dart';

@immutable
abstract class TaskEvent {}

class InitializeTaskBloc extends TaskEvent {}

class ReceivePushNotifications extends TaskEvent {
  final Map<String, dynamic> notification;

  ReceivePushNotifications(this.notification);
}

class AddTask extends TaskEvent {
  final Task task;

  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;

  UpdateTask(this.task);
}

class RemoveTask extends TaskEvent {
  final Task task;

  RemoveTask(this.task);
}

class ChangeEditStatusTaskEvent extends TaskEvent {
  final bool isEditable;

  ChangeEditStatusTaskEvent(this.isEditable);
}

class CompleteTaskEvent extends TaskEvent {
  final Task task;

  CompleteTaskEvent(this.task);
}

class ErrorTaskEvent extends TaskEvent {
  final String message;

  ErrorTaskEvent(this.message);
}
