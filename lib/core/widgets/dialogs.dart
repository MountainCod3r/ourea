import 'package:flutter/material.dart';
import 'package:ourea/core/models/task.dart';

class Dialogs {
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

  static Future<Task> createTaskDialog(
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
        ],
      ),
    );
  }
}
