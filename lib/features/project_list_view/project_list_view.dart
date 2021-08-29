import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/core/widgets/dialogs.dart';
import 'package:ourea/features/project_list_view/widgets/base_state.dart';
import 'package:ourea/features/project_list_view/widgets/edit_state.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:ourea/services/navigation/router.dart';

class ProjectListView extends StatefulWidget {
  @override
  _ProjectListViewState createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView>
    with WidgetsBindingObserver {
  bool _editMode;

  _ProjectListViewState() {
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
      locator<OureaBloc>().add(ChangeEditStatus(_editMode));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
        actions: [
//          IconButton(
//            icon: Icon(Icons.watch_later),
//            onPressed: () {
//              Navigator.pushReplacementNamed(context, RouterPath.transactions);
//            },
//          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _editMode = !_editMode;
                locator<OureaBloc>().add(ChangeEditStatus(_editMode));
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
//          String projectName = await Dialogs.singleEntryDialog(
//              context, 'Project Name', 'Enter a name');
//          if (projectName != '') {
//            Project project = Project(projectName);
//            print('Adding: ${project.toString()}');
//            locator<ProjectBloc>().add(AddProject(project));
//          }
//        },
//      ),
//        body: StreamBuilder<List<Project>>(
//          stream: locator<OureaRemoteDataSource>().projects,
//          builder: (BuildContext context, AsyncSnapshot<List<Project>> snapshot) {
//            if(snapshot.hasData) {
//              return ListView.builder(
//                  itemCount: snapshot.data.length,
//                  itemBuilder: (context, index) {
//                    return ListTile(
//                      title: Text('${snapshot.data[index].name}'),
//                    );
//                  }
//                  );
//            }
//            return Text('I got nothing');
//          },
//        ),
      body: BlocBuilder<OureaBloc, OureaState>(
        bloc: locator<OureaBloc>(),
        builder: (BuildContext context, OureaState state) {
          Widget editStateSelect(bool edit, List<Project> projectList) {
            print('editstateselect was called');
            if (projectList == null) {
              print('Project List is Empty');
              projectList = [];
            }
            if (edit) {
              return editState(context, projectList);
            } else {
              return baseState(context, projectList);
            }
          }

          if (state is InitialOureaState) {
            print('ProjectBloc State: InitialProjectState');
            locator<OureaBloc>().add(InitializeOureaBloc());
          }
          if (state is ChangeEditState) {
            return editStateSelect(_editMode, state.projectList);
          }
          if (state is UpdatingOureaState) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (state is UpdatedOureaState) {
            return editStateSelect(_editMode, state.projectList);
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
