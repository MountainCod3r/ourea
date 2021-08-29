import 'package:flutter/material.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/features/stopwatch/flutter_timer.dart';
import 'package:ourea/features/task_list_view/task/task_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class TimedTaskTile extends StatefulWidget {
  final Task task;

  TimedTaskTile(this.task, {Key key}) : super(key: key);

  @override
  _TimedTaskTileState createState() => _TimedTaskTileState(task);
}

class _TimedTaskTileState extends State<TimedTaskTile> {
  final Task task;

  _TimedTaskTileState(this.task);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      //key: UniqueKey(),
      leading: FlatButton(
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: priorityColor(task.priority),
          ),
          width: 20.0,
          height: 20.0,
        ),
        onPressed: () {
          locator<TaskBloc>().add(CompleteTaskEvent(task));
        },
      ),
      title: Text(
        task.name,
        textAlign: TextAlign.left,
        style: TextStyle(
          decoration:
              task.completed ? TextDecoration.lineThrough : TextDecoration.none,
        ),
      ),
      trailing: FlutterTimer(task.id),
      onTap: () {
        Navigator.pushNamed(context, 'task-${task.id}');
      },
    );
  }
}
