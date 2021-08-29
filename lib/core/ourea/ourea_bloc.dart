import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ourea/core/models/ourea_record.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:flutter/material.dart';
import 'package:ourea/data/datasource/local_datasource.dart';
import 'package:ourea/data/datasource/remote_datasource.dart';
import 'package:ourea/services/locator/locator.dart';

part 'ourea_event.dart';

part 'ourea_state.dart';

class OureaBloc extends Bloc<OureaEvent, OureaState> {
  OureaRemoteDataSource _db;
  bool _isEditable;

  List<TimeTransaction> _timeList;
  List<Project> _projectList;
  List<Task> _taskList;
  List<OureaRecord> _recordList;

  List<TimeTransaction> get timeList => _timeList;

  OureaBloc() {
    _db = locator<OureaRemoteDataSource>();
    _isEditable = false;
  }

  Future<OureaState> _oureaEventHandler(
      {Function repoFunction, String functionName, Object object}) async {
    print(
        'calling repoFunction: $functionName on project: ${object.toString()}');
    var result = await repoFunction(object);
    if (result) {
      if (object is Project) {
        _projectList = await _db.projects.first;
      }
      if (object is Task) {
        _taskList = await _db.tasks.first;
      }
      if (object is TimeTransaction) {
        _timeList = await _db.transactions.first;
      }
      return UpdatedOureaState(_isEditable, _projectList, _taskList, _timeList);
    } else {
      return ErrorState(
          'Failed to $functionName Project: ${object.toString()}');
    }
  }

  List<TimeTransaction> getActiveTimeTransactionsForTask(String taskId) {
    var filteredList = _timeList
        .where((element) => (element.taskId == taskId) && (element.isActive));
    return filteredList.toList() ?? [];
  }

  List<TimeTransaction> _getActiveTransactionsForProject(String projectId) {
    List<Task> taskList = getProjectTaskList(projectId);
    List<TimeTransaction> timeList = [];
    for (var task in taskList) {
      List<TimeTransaction> active = getActiveTimeTransactionsForTask(task.id);
      if (active.length > 0) {
        timeList.add(active[0]);
      }
    }
    return timeList;
  }

  String _getProjectIdForTransaction(TimeTransaction transaction) {
    return getTaskById(transaction.taskId).projectId;
  }

  List<TimeTransaction> getActiveTransactions() {
    return _timeList.where((element) => element.isActive);
  }

  Duration getEpochForTask(String taskId) {
    if (_timeList == null) {
      return Duration(seconds: 0);
    }
    if (_timeList.length == 0) {
      return Duration(seconds: 0);
    }
    var filteredList =
        _timeList.where((transaction) => transaction.taskId == taskId).toList();
    print(
        'Filtered TransactionList is: ${filteredList.map((element) => element.toString())}');
    if (filteredList.length == 0) {
      return Duration(seconds: 0);
    } else {
      Duration epoch = Duration();
      for (var transaction in filteredList) {
        var transactionDuration =
            transaction.stop.difference(transaction.start);
        if (transaction.isActive) {
          transactionDuration = DateTime.now().difference(transaction.start);
        }
        epoch = epoch + transactionDuration;
      }
      return epoch;
    }
  }

  bool dateHasDataForProject(DateTime date, Project project) {
    List<TimeTransaction> transactions = _timeList.where((element) {
      bool result = element.start.day == date.day &&
          element.start.month == date.month &&
          element.start.year == date.year;
      return result;
    }).toList();
    List<Task> taskList = getProjectTaskList(project.id);

    for (var task in taskList) {
      List<TimeTransaction> filteredList =
          transactions.where((element) => element.taskId == task.id).toList();
      if (filteredList.length > 0) {
        return true;
      }
    }
    return false;
  }

  List<TimeTransaction> getTransactionsForProjectByDate(
      DateTime date, Project project) {
    List<TimeTransaction> transactions = _timeList.where((element) {
      bool result = element.start.day == date.day &&
          element.start.month == date.month &&
          element.start.year == date.year;
      return result;
    }).toList();
    List<Task> taskList = getProjectTaskList(project.id);
    List<TimeTransaction> fullList = [];
    for (var task in taskList) {
      List<TimeTransaction> filteredList =
          transactions.where((element) => element.taskId == task.id).toList();
      fullList.addAll(filteredList);
    }
    return fullList;
  }

  Project getProjectById(String projectId) {
    return _projectList.where((element) => element.id == projectId).toList()[0];
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

  static Future<String> singleEntryDialog(
    BuildContext context,
    String title,
    String body,
  ) async {
    TextEditingController _controller = TextEditingController();
    String inputText;
    final action = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: body,
              ),
              onChanged: (text) {
                inputText = text;
              },
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  print('Input Text: $inputText');
                  Navigator.of(context).pop('');
                },
                child: Text('Cancel'),
              ),
              RaisedButton(
                onPressed: () {
                  print('Input Text: $inputText');
                  inputText != null
                      ? Navigator.of(context).pop(inputText)
                      : Navigator.of(context).pop('');
                },
                child: Text('OK'),
              ),
            ],
          );
        });
    return (action != null) ? action : inputText;
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

  @override
  OureaState get initialState => InitialOureaState();

  @override
  Stream<OureaState> mapEventToState(OureaEvent event) async* {
    if (event is InitializeOureaBloc) {
      yield UpdatingOureaState();
      _projectList = await _db.projects.first;
      _taskList = await _db.tasks.first;
      _timeList = await _db.transactions.first;
      yield UpdatedOureaState(false, _projectList, _taskList, _timeList);
    }
    if (event is AddProject) {
      print('Event \'AddProject\' on project: ${event.project.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.addProject,
          functionName: 'add',
          object: event.project);
      yield result;
    }
    if (event is UpdateProject) {
      print('Event \'UpdateProject\' on project: ${event.project.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.updateProject,
          functionName: 'update',
          object: event.project);
      yield result;
    }
    if (event is RemoveProject) {
      print('Event \'RemoveProject\' on project: ${event.project.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.removeProject,
          functionName: 'remove',
          object: event.project);
      yield result;
    }
    if (event is ChangeEditStatus) {
      _isEditable = event.isEditable;
      yield UpdatedOureaState(_isEditable, _projectList, _taskList, _timeList);
    }
    if (event is ErrorProjectEvent) {
      yield ErrorState(event.message);
    }
    if (event is ReceivePushNotifications) {}

    if (event is AddTask) {
      print('Event \'AddTask\' on task: ${event.task.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.addTask,
          functionName: 'AddTask',
          object: event.task);
      yield result;
    }
    if (event is UpdateTask) {
      print('Event \'UpdateTask\' on task: ${event.task.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.updateTask,
          functionName: 'UpdateTask',
          object: event.task);
      yield result;
    }
    if (event is RemoveTask) {
      print('Event \'RemoveTask\' on task: ${event.task.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.removeTask,
          functionName: 'RemoveTask',
          object: event.task);
      yield result;
    }
    if (event is ChangeEditStatusTaskEvent) {
      _isEditable = event.isEditable;
      var taskList = await _db.tasks.first;
      yield UpdatedOureaState(_isEditable, _projectList, taskList, _timeList);
    }
    if (event is ErrorTaskEvent) {
      yield ErrorState(event.message);
    }
    if (event is ReceivePushNotifications) {}
    if (event is CompleteTaskEvent) {
      Task task = event.task;
      task.completed = !task.completed;
      if (task.completed) {
        task.whenCompleted = DateTime.now();
      }
      print('Event \'CompleteTask\' on task: ${event.task.toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.updateTask,
          functionName: 'CompleteTask',
          object: task);
      yield result;
    }

    if (event is StartTimeTransactionEvent) {
      String projectId = _getProjectIdForTransaction(event.transaction);
      List<TimeTransaction> active =
      _getActiveTransactionsForProject(projectId);
      for (var transaction in active) {
        this.add(StopTimeTransactionEvent(transaction));
      }
      print(
          'Event \'StartTimer\' for transaction: ${event.transaction
              .toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.addTimeTransaction,
          functionName: 'add',
          object: event.transaction);
      yield result;
    }
    if (event is StopTimeTransactionEvent) {
      print(
          'Event \'StopTimer\' for transaction: ${event.transaction
              .toString()}');
      var trans = event.transaction;
      trans.stopTransaction();
      var result = await _oureaEventHandler(
          repoFunction: _db.updateTimeTransaction,
          functionName: 'update',
          object: trans);
      yield result;
    }
    if (event is UpdateTimeTransaction) {
      print(
          'Event \'UpdateTimer\' for transaction: ${event.transaction
              .toString()}');
      var result = await _oureaEventHandler(
          repoFunction: _db.updateTimeTransaction,
          functionName: 'update',
          object: event.transaction);
      yield result;
    }
    if (event is ChangeEditStateTransactionEvent) {
      _isEditable = event.isEditable;
      yield UpdatedOureaState(_isEditable, _projectList, _taskList, _timeList);
    }
    if (event is ErrorTimeTransactionEvent) {}
    if (event is RefreshOureaBlocEvent) {
      yield UpdatedOureaState(_isEditable, _projectList, _taskList, _timeList);
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
      height: MediaQuery.of(context).size.height * .4,
      width: MediaQuery.of(context).size.width * .5,
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
          ListTile(
            title: Row(
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
          SizedBox(
            height: 10.0,
          ),
        ],
      ),
    );
  }
}
