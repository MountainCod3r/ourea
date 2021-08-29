import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/features/task_list_view/widgets/base_state.dart';
import 'package:ourea/features/task_list_view/widgets/edit_state.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:ourea/services/navigation/router.dart';

class TaskListView extends StatefulWidget {
  final String projectId;

  TaskListView(this.projectId);
  @override
  _TaskListViewState createState() => _TaskListViewState(locator<OureaBloc>().getProjectById(projectId));
}

class _TaskListViewState extends State<TaskListView>
    with WidgetsBindingObserver {
  final Project project;
  bool _editMode;

  _TaskListViewState(this.project) {
    _editMode = false;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('state = $state');
    if (state == AppLifecycleState.resumed) {
      //forces a refresh after resume
      locator<OureaBloc>().add(ChangeEditStatusTaskEvent(_editMode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.watch_later),
            onPressed: () {
              Navigator.pushReplacementNamed(context, RouterPath.transactions);
            },
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _editMode = !_editMode;
                locator<OureaBloc>().add(ChangeEditStatusTaskEvent(_editMode));
              });
            },
          ),
        ],
      ),
//      floatingActionButton: FloatingActionButton(
//        mini: true,
//        child: Icon(
//          Icons.add,
//        ),
//        onPressed: () async {
//          Task task = Task(name: '', description: '', projectId: '', priority: TaskPriority.none);
//          var newTask =
//              await locator<TaskBloc>().createTaskDialog(context, 'Add an Item', task);
//          if (newTask.name != '') {
//            newTask.priority = 2;
//            newTask.projectId = (locator<ProjectBloc>().state as UpdatedProjectState).projectList[0].id;
//            locator<TaskBloc>().add(AddTask(newTask));
//          }
//        },
//      ),
      body: BlocBuilder<OureaBloc, OureaState>(
        bloc: locator<OureaBloc>(),
        builder: (BuildContext context, OureaState state) {
          Widget editStateSelect(bool edit, List<Task> taskList) {
            print('editstateselect was called from Task');
            if (taskList == null) {
              print('Task List is Empty');
              taskList = [];
            }
            if (edit) {
              return editState(context, taskList);
            } else {
              return baseState(context, taskList);
            }
          }

          if (state is InitialOureaState) {
            locator<OureaBloc>().add(InitializeOureaBloc());
          }
          if (state is ChangeEditState) {
            return editStateSelect(_editMode, locator<OureaBloc>().getProjectTaskList(project.id));
          }
          if (state is UpdatingOureaState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is UpdatedOureaState) {
            return editStateSelect(_editMode, locator<OureaBloc>().getProjectTaskList(project.id));
          }
          if (state is ErrorState) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          }
          print('Failed to capture State-');
          print(state.runtimeType);
          return Center(
            child: Text('Could not determine state'),
          );
        },
      ),
    );
  }
}
