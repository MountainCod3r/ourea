import 'package:flutter/material.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/widgets/dialogs.dart';
import 'package:ourea/features/project_list_view/project/project_bloc.dart';
import 'package:ourea/features/task_list_view/task/task_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

Widget editState(BuildContext context, List<Task> data) {
  print('Length of data is ${data.length}');

  return ListView.builder(
      itemCount: data.length == null ? 0 : data.length,
      itemBuilder: (context, index) {
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            locator<TaskBloc>().add(RemoveTask(data[index]));
          },
          child: ListTile(
            dense: true,
            title: Text(data[index].name),
            trailing: Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      //TODO: implement task dialog
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
