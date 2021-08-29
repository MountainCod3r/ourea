import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/data/datasource/remote_datasource.dart';
import 'package:ourea/features/time_transaction_view/time_transaction/time_transaction_bloc.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:ourea/features/task_list_view/task/task_bloc.dart';

part 'project_event.dart';

part 'project_state.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  OureaRemoteDataSource _db;
  bool _isEditable;
  List<Project> _projectList;

  ProjectBloc() {
    _db = locator<OureaRemoteDataSource>();
    _isEditable = false;
  }

  Project getProjectById(String projectId) {
    return _projectList.where((element) => element.id == projectId).toList()[0];
  }

  Future<ProjectState> _projectEventHandler(
      {Function repoFunction, String functionName, Project project}) async {
    print(
        'calling repoFunction: $functionName on project: ${project.toString()}');
    var result = await repoFunction(project);
    if (result) {
      _projectList = await _db.projects.first;
      return UpdatedProjectState(_isEditable, _projectList);
    } else {
      return ErrorState('Failed to $functionName Project: ${project.name}');
    }
  }

  @override
  ProjectState get initialState => InitialProjectState();

  @override
  Stream<ProjectState> mapEventToState(ProjectEvent event) async* {
    if (event is InitializeProjectBloc) {
      locator<TaskBloc>().add(InitializeTaskBloc());
      locator<TimeTransactionBloc>().add(InitializeTimeTransactionBloc());
      yield UpdatingProjectState();
      _projectList = await _db.projects.first;
      yield UpdatedProjectState(false, _projectList);
    }
    if (event is AddProject) {
      print('Event \'AddProject\' on project: ${event.project.toString()}');
      var result = await _projectEventHandler(
          repoFunction: _db.addProject,
          functionName: 'add',
          project: event.project);
      yield result;
    }
    if (event is UpdateProject) {
      print('Event \'UpdateProject\' on project: ${event.project.toString()}');
      var result = await _projectEventHandler(
          repoFunction: _db.updateProject,
          functionName: 'update',
          project: event.project);
      yield result;
    }
    if (event is RemoveProject) {
      print('Event \'RemoveProject\' on project: ${event.project.toString()}');
      var result = await _projectEventHandler(
          repoFunction: _db.removeProject,
          functionName: 'remove',
          project: event.project);
      yield result;
    }
    if (event is ChangeEditStatus) {
      _isEditable = event.isEditable;
      yield UpdatedProjectState(_isEditable, _projectList);
    }
    if (event is ErrorProjectEvent) {
      yield ErrorState(event.message);
    }
    if (event is ReceivePushNotifications) {}
    if (event is TasksChangedForProjects) {
      yield UpdatedProjectState(_isEditable, _projectList);
    }
  }
}
