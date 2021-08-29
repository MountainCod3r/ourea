import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ourea/core/models/task.dart';

part 'task_overview_event.dart';

part 'task_overview_state.dart';

class TaskOverviewBloc extends Bloc<TaskOverviewEvent, TaskOverviewState> {
  final Task task;

  TaskOverviewBloc(this.task);
  @override
  TaskOverviewState get initialState => InitialTaskOverviewState();

  @override
  Stream<TaskOverviewState> mapEventToState(TaskOverviewEvent event) async* {
    // TODO: Add your event logic
  }
}
