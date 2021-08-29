import 'package:flutter/material.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/features/task_list_view/task/task_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class TaskTile extends StatefulWidget {
  final Task task;

  TaskTile(this.task);

  @override
  _TaskTileState createState() => _TaskTileState(task);
}

class _TaskTileState extends State<TaskTile> {
  final Task task;

  _TaskTileState(this.task);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //key: UniqueKey(),
      leading: FlatButton(
        child: Container(
          width: 20.0,
          height: 20.0,
          color: priorityColor(task.priority),
        ),
        onPressed: () {
          locator<TaskBloc>().add(CompleteTaskEvent(task));
        },
      ),
      title: Text(
        task.name,
        style: TextStyle(
          decoration:
              task.completed ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
    );
  }
}
