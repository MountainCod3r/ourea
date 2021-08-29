import 'package:flutter/material.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/widgets/timed_task_tile.dart';
import 'package:ourea/features/stopwatch/flutter_timer.dart';

Widget baseState(BuildContext context, List<Task> taskList) {
  print('Base State was called');
  return ListView.builder(
    itemCount: taskList.length == null ? 0 : taskList.length,
    itemBuilder: (context, index) {
      Task task = taskList[index];
      return ListTileTheme(
          child: TimedTaskTile(task),
          contentPadding: EdgeInsets.all(1.0),
          dense: true,
      );
    },
  );
}
