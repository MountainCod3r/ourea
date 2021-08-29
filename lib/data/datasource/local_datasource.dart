import 'dart:async';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/domain/repository/OureaRepository.dart';
import 'package:ourea/services/local_database/local_database.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sembast/sembast.dart';

class OureaLocalDataSource extends OureaRepository {
  static const String taskFolder = 'tasks';
  static const String projectFolder = 'projects';
  static const String timeFolder = 'time_transactions';

  final _taskFolder = intMapStoreFactory.store(taskFolder);
  final _projectFolder = intMapStoreFactory.store(projectFolder);
  final _timeFolder = intMapStoreFactory.store(timeFolder);

  final StreamController<List<Project>> _projectController =
      BehaviorSubject<List<Project>>();
  final StreamController<List<Task>> _taskController =
      BehaviorSubject<List<Task>>();
  final StreamController<List<TimeTransaction>> _timeController =
      BehaviorSubject<List<TimeTransaction>>();

  Stream<List<Project>> get projects => _projectController.stream;

  Stream<List<Task>> get tasks => _taskController.stream;

  Stream<List<TimeTransaction>> get transactions => _timeController.stream;

  Future init() async {
    _projectController.add([]);
    _taskController.add([]);
    _timeController.add([]);
    _projectController.add(await _projectList());
    _taskController.add(await _taskList());
    _timeController.add(await _timeList());
  }

  Future<List<Project>> _projectList() async {
    var snapshot = _projectFolder.stream(await _db);
    return snapshot.map((snapshot) {
      return Project.fromJson(snapshot.value);
    }).toList();
  }

  Future<List<Task>> _taskList() async {
    var snapshot = _taskFolder.stream(await _db);
    return snapshot.map((snapshot) {
      return Task.fromJson(snapshot.value);
    }).toList();
  }

  Future<List<TimeTransaction>> _timeList() async {
    var snapshot = _timeFolder.stream(await _db);
    return snapshot.map((snapshot) {
      return TimeTransaction.fromJson(snapshot.value);
    }).toList();
  }

  Future<Database> get _db async => await LocalDatabase.instance.database;

  @override
  Future<bool> addProject(Project project) async {
    try {
      await _projectFolder.add(await _db, project.toJson());
      _projectController.add(await _projectList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> addTask(Task task) async {
    try {
      await _taskFolder.add(await _db, task.toJson());
      _taskController.add(await _taskList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> addTimeTransaction(TimeTransaction transaction) async {
    try {
      await _timeFolder.add(await _db, transaction.toJson());
      _timeController.add(await _timeList());
      return true;
    } catch (e) {
      print(e.toString());
      return true;
    }
  }

  @override
  Future<bool> removeProject(Project project) async {
    try {
      final finder = Finder(filter: Filter.byKey(project.id));
      await _projectFolder.delete(await _db, finder: finder);
      _projectController.add(await _projectList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> removeTask(Task task) async {
    try {
      final finder = Finder(filter: Filter.byKey(task.id));
      await _taskFolder.delete(await _db, finder: finder);
      _taskController.add(await _taskList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> removeTimeTransaction(TimeTransaction transaction) async {
    try {
      final finder = Finder(filter: Filter.byKey(transaction.id));
      await _timeFolder.delete(await _db, finder: finder);
      _timeController.add(await _timeList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateProject(Project project) async {
    try {
      final finder = Finder(filter: Filter.byKey(project.id));
      await _projectFolder.update(await _db, project.toJson(), finder: finder);
      _projectController.add(await _projectList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateTask(Task task) async {
    try {
      final finder = Finder(filter: Filter.byKey(task.id));
      await _taskFolder.update(await _db, task.toJson(), finder: finder);
      _taskController.add(await _taskList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> updateTimeTransaction(TimeTransaction transaction) async {
    try {
      final finder = Finder(filter: Filter.byKey(transaction.id));
      await _timeFolder.update(await _db, transaction.toJson(), finder: finder);
      _timeController.add(await _timeList());
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  void dispose() {
    _projectController.close();
    _taskController.close();
    _timeController.close();
  }
}
