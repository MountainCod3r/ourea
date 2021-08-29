import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/data/datasource/remote_datasource.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:flutter/material.dart';
import 'package:ourea/features/project_list_view/project/project_bloc.dart';

part 'task_event.dart';

part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  OureaRemoteDataSource _db;
  bool _isEditable;
  List<Task> _taskList = [];

  TaskBloc() {
    _db = locator<OureaRemoteDataSource>();
    _isEditable = false;
  }

  Task getTaskById(String taskId) {
    return _taskList.where((element) => element.id == taskId).toList()[0];
  }

  Future<Task> createTaskDialog(
      BuildContext context, String title, Task task) async {
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: Text(title),
            content: AddTaskDialog(task),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.of(context).pop(task);
                },
                child: Text('Cancel'),
              ),
              RaisedButton(
                onPressed: () {
                  Navigator.of(context).pop(task);
                },
                child: Text('OK'),
              ),
            ],
          );
        });
    print('Task is: ${task.toString()}');
    return (action != null) ? action : task;
  }

  List<Task> getProjectTaskList(String projectId) {
    List<Task> projectTaskList = [];
    for (var task in _taskList) {
      if (task.projectId == projectId) {
        projectTaskList.add(task);
      }
    }
    return projectTaskList;
  }

  Future<TaskState> _taskEventHandler(
      {Function repoFunction, String functionName, Task task}) async {
    print('calling repoFunction: $functionName on task: ${task.toString()}');
    var result = await repoFunction(task);
    if (result) {
      _taskList = await _db.tasks.first;
      locator<ProjectBloc>().add(TasksChangedForProjects());
      return UpdatedTaskState(_isEditable, _taskList);
    } else {
      return ErrorTaskState('Failed to $functionName Task: ${task.name}');
    }
  }

  @override
  TaskState get initialState => InitialTaskState();

  @override
  Stream<TaskState> mapEventToState(TaskEvent event) async* {
    if (event is InitializeTaskBloc) {
      yield UpdatingTaskState();
      _taskList = await _db.tasks.first;
      yield UpdatedTaskState(_isEditable, _taskList);
    }
    if (event is AddTask) {
      print('Event \'AddTask\' on task: ${event.task.toString()}');
      var result = await _taskEventHandler(
          repoFunction: _db.addTask, functionName: 'AddTask', task: event.task);
      yield result;
    }
    if (event is UpdateTask) {
      print('Event \'UpdateTask\' on task: ${event.task.toString()}');
      var result = await _taskEventHandler(
          repoFunction: _db.updateTask,
          functionName: 'UpdateTask',
          task: event.task);
      yield result;
    }
    if (event is RemoveTask) {
      print('Event \'RemoveTask\' on task: ${event.task.toString()}');
      var result = await _taskEventHandler(
          repoFunction: _db.removeTask,
          functionName: 'RemoveTask',
          task: event.task);
      yield result;
    }
    if (event is ChangeEditStatusTaskEvent) {
      _isEditable = event.isEditable;
      var taskList = await _db.tasks.first;
      yield UpdatedTaskState(_isEditable, taskList);
    }
    if (event is ErrorTaskEvent) {
      yield ErrorTaskState(event.message);
    }
    if (event is ReceivePushNotifications) {}
    if (event is CompleteTaskEvent) {
      Task task = event.task;
      task.completed = !task.completed;
      print('Event \'CompleteTask\' on task: ${event.task.toString()}');
      var result = await _taskEventHandler(
          repoFunction: _db.updateTask,
          functionName: 'CompleteTask',
          task: task);
      yield result;
    }
  }
}

class AddTaskDialog extends StatefulWidget {
  final Task task;

  AddTaskDialog(this.task);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState(task);
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  Task task;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String _name = '';
  String _description = '';

  _AddTaskDialogState(Task task) {
    this.task = task;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery
          .of(context)
          .size
          .height * .4,
      width: MediaQuery
          .of(context)
          .size
          .width * .5,
      child: ListView(
        children: <Widget>[
          ListTile(
            title: TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: task.name == '' ? 'name' : task.name,
              ),
              onChanged: (name) {
                _name = name;
                task.name = name;
              },
            ),
          ),
          ListTile(
            title: TextField(
              minLines: 1,
              maxLines: 8,
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText:
                task.description == '' ? 'description' : task.description,
              ),
              onChanged: (description) {
                _description = description;
                task.description = description;
              },
            ),
          ),
          ListTile(
            title: Center(child: Text('Priority')),
          ),
          ListTile(title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Radio(
                value: 0,
                  activeColor: priorityColor(0),
                  groupValue: task.priority,
                onChanged: (value) {
                  setState(() {
                    task.priority = value;
                  });
                },
              ),
              Radio(
                value: 1,
                activeColor: priorityColor(1),
                groupValue: task.priority,
                onChanged: (value) {
                  setState(() {
                    task.priority = value;
                  });
                },
              ),
              Radio(
                value: 2,
                activeColor: priorityColor(2),
                groupValue: task.priority,
                onChanged: (value) {
                  setState(() {
                    task.priority = value;
                  });
                },
              ),
              Radio(
                value: 3,
                activeColor: priorityColor(3),
                groupValue: task.priority,
                onChanged: (value) {
                  setState(() {
                    task.priority = value;
                  });
                },
              ),
            ],
          ),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Low'),
                Text('-'),
                Text('-'),
                Text('-'),
                Text('-'),
                Text('-'),
                Text('High')
              ],
            ),
          ),
          SizedBox(height: 10.0,),
          ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Checkbox(
                  value: task.timed,
                  onChanged: (value) {
                    setState(() {
                      task.timed = value;
                    });
                  },
                ),
                Text('timed?')
              ],
            ),
          ),
        ],
      ),
    );
  }
}
