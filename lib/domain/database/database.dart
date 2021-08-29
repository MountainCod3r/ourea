import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/data/datasource/local_datasource.dart';
import 'package:ourea/data/datasource/remote_datasource.dart';
import 'package:ourea/domain/repository/OureaRepository.dart';

class CompleteDatastore extends OureaRepository {
  OureaRemoteDataSource _remoteDb;
  OureaLocalDataSource _localDb;

  CompleteDatastore(
      {OureaRemoteDataSource remote, OureaLocalDataSource local}) {
    _remoteDb = remote;
    _localDb = local;
  }

  @override
  Future<bool> addProject(Project project) async {
    bool remoteResult = await _remoteDb.addProject(project);
    bool localResult = await _localDb.addProject(project);
    if (remoteResult & localResult) {
      return true;
    } else {
      print('Something when wrong adding project');
      return false;
    }
  }

  @override
  Future<bool> addTask(Task task) async {
    bool remoteResult = await _remoteDb.addTask(task);
    bool localResult = await _localDb.addTask(task);
    if (remoteResult & localResult) {
      return true;
    } else {
      print('Something when wrong adding project');
      return false;
    }
  }

  @override
  Future<bool> addTimeTransaction(TimeTransaction transaction) async {
    bool remoteResult = await _remoteDb.addTimeTransaction(transaction);
    bool localResult = await _localDb.addTimeTransaction(transaction);
    if (remoteResult & localResult) {
      return true;
    } else {
      print('Something when wrong adding project');
      return false;
    }
  }

  @override
  Future<bool> removeProject(Project project) {
    // TODO: implement removeProject
    throw UnimplementedError();
  }

  @override
  Future<bool> removeTask(Task task) {
    // TODO: implement removeTask
    throw UnimplementedError();
  }

  @override
  Future<bool> removeTimeTransaction(TimeTransaction transaction) {
    // TODO: implement removeTimeTransaction
    throw UnimplementedError();
  }

  @override
  Future<bool> updateProject(Project project) {
    // TODO: implement updateProject
    throw UnimplementedError();
  }

  @override
  Future<bool> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }

  @override
  Future<bool> updateTimeTransaction(TimeTransaction transaction) {
    // TODO: implement updateTimeTransaction
    throw UnimplementedError();
  }
}
