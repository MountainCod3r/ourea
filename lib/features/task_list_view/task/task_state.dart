part of 'task_bloc.dart';

@immutable
abstract class TaskState {}

class InitialTaskState extends TaskState {}

class UpdatingTaskState extends TaskState {}

class UpdatedTaskState extends TaskState {
  final List<Task> taskList;
  final bool isEditable;

  UpdatedTaskState(this.isEditable, this.taskList);
}

class ChangeEditTaskState extends TaskState {
  final List<Task> taskList;
  final bool isEditable;

  ChangeEditTaskState(this.isEditable, this.taskList);
}

class ErrorTaskState extends TaskState {
  final String message;

  ErrorTaskState(this.message);
}
