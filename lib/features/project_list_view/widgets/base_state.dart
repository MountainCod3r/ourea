import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/core/widgets/dialogs.dart';
import 'package:ourea/core/widgets/task_tile.dart';
import 'package:ourea/core/widgets/timed_task_tile.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:ourea/services/navigation/router.dart';

Widget baseState(BuildContext context, List<Project> projectList) {
  Widget _tileSelect(Task task) {
    if (task.timed == false) {
      return TaskTile(task);
    } else {
      return ListTileTheme(
        contentPadding: EdgeInsets.all(0.0),
        dense: true,
        child: TimedTaskTile(task),
      );
    }
  }

  print('Base State was called');
  return BlocBuilder<OureaBloc, OureaState>(
    bloc: locator<OureaBloc>(),
    builder: (context, state) {
      Widget myListView = ListView.builder(
        padding:
            const EdgeInsets.only(bottom: kFloatingActionButtonMargin + 96),
        itemCount: projectList.length == null ? 1 : projectList.length + 1,
        itemBuilder: (context, index) {
          if (projectList.length == null || index == projectList.length) {
            return ListTile(
              title: FlatButton(
                color: Colors.teal,
                onPressed: () async {
                  String projectName = await Dialogs.singleEntryDialog(
                      context, 'Project Name', 'Enter a name');
                  if (projectName != '') {
                    Project project = Project(projectName);
                    print('Adding: ${project.toString()}');
                    locator<OureaBloc>().add(AddProject(project));
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text('New Project'),
                  ],
                ),
              ),
            );
          }

          Project project = projectList[index];
          List<Task> projectTaskList =
              locator<OureaBloc>().getProjectTaskList(project.id);
          projectTaskList.sort((a, b) {
            Duration aDur = locator<OureaBloc>().getEpochForTask(a.id);
            Duration bDur = locator<OureaBloc>().getEpochForTask(b.id);
            return bDur.compareTo(aDur);
          });
          List<Widget> tileList = [];
          List<Widget> activeTiles = [];
          for (var task in projectTaskList) {
            if (!task.completed) {
              if (locator<OureaBloc>()
                      .getActiveTimeTransactionsForTask(task.id)
                      .length >
                  0) {
                activeTiles.add(_tileSelect(task));
              } else {
                tileList.add(_tileSelect(task));
              }
            }
          }
          var addTile = ListTile(
            title: FlatButton(
              color: Colors.orangeAccent,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('New Task'),
                ],
              ),
              onPressed: () async {
                Task task = Task(
                  name: '',
                  description: '',
                  projectId: '',
                  priority: TaskPriority.none,
                  timed: true,
                );
                var newTask = await locator<OureaBloc>()
                    .createTaskDialog(context, 'Add an Item', task);
                if (newTask.name != '') {
                  newTask.projectId = projectList[index].id;
                  locator<OureaBloc>().add(AddTask(newTask));
                  Navigator.pushReplacementNamed(context, RouterPath.home);
                }
              },
            ),
          );
          tileList.add(addTile);

          return ListTileTheme(
            dense: true,
            child: ExpansionTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(project.name),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.multiline_chart),
                        onPressed: () {
                          Navigator.pushNamed(context, 'project-${project.id}');
                        },
                      ),
                    ],
                  ),
                ],
              ),
              subtitle: activeTiles.length > 0
                  ? activeTiles[0]
                  : SizedBox(
                      width: 10.0,
                    ),
              children: tileList,
            ),
          );
        },
      );

      if (state is UpdatedOureaState) {
        return myListView;
      } else {
        return myListView;
      }
    },
  );
}
