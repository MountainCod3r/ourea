import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/domain/repository/OureaRepository.dart';
import 'package:ourea/services/authentication/auth_service.dart';
import 'package:ourea/services/locator/locator.dart';
import 'package:rxdart/rxdart.dart';

class OureaRemoteDataSource extends OureaRepository {
  FirebaseUser _firebaseUser;
  Firestore _db = Firestore.instance;

  //Stream Controllers
  final StreamController<List<Project>> _projectController =
      BehaviorSubject<List<Project>>();
  final StreamController<List<Task>> _taskController =
      BehaviorSubject<List<Task>>();
  final StreamController<List<TimeTransaction>> _timeController =
      BehaviorSubject<List<TimeTransaction>>();

  //Public Streams
  Stream<List<Project>> get projects => _projectController.stream;

  Stream<List<Task>> get tasks => _taskController.stream;

  Stream<List<TimeTransaction>> get transactions => _timeController.stream;

  //private stream handler
  void _projectAdded(QuerySnapshot snapshot) {
    var projects = _getProjectFromSnapshot(snapshot);
    for (var project in projects) {
      print('project added: ${project.toString()}');
    }
    _projectController.add(projects);
  }

  void _taskAdded(QuerySnapshot snapshot) {
    var tasks = _getTaskFromSnapshot(snapshot);
    _taskController.add(tasks);
  }

  void _timeAdded(QuerySnapshot snapshot) {
    var transactions = _getTransactionFromSnapshot(snapshot);
    _timeController.add(transactions);
  }

  //Private document handlers
  List<Project> _getProjectFromSnapshot(QuerySnapshot snapshot) {
    var projectItems = List<Project>();
    var documents = snapshot.documents;
    bool hasDocuments = documents.length > 0;

    if (hasDocuments) {
      for (var doc in documents) {
        projectItems.add(Project.fromFirestore(doc));
      }
    }
    return projectItems;
  }

  List<Task> _getTaskFromSnapshot(QuerySnapshot snapshot) {
    var taskItems = List<Task>();
    var documents = snapshot.documents;
    bool hasDocuments = documents.length > 0;

    if (hasDocuments) {
      for (var doc in documents) {
        taskItems.add(Task.fromFirestore(doc));
      }
    }
    return taskItems;
  }

  List<TimeTransaction> _getTransactionFromSnapshot(QuerySnapshot snapshot) {
    var timeItems = List<TimeTransaction>();
    var documents = snapshot.documents;
    bool hasDocuments = documents.length > 0;

    if (hasDocuments) {
      for (var doc in documents) {
        timeItems.add(TimeTransaction.fromFirestore(doc));
      }
    }
    return timeItems;
  }

  Stream<QuerySnapshot> _projectListStream() {
    return _db
        .collection('users')
        .document(_firebaseUser.uid)
        .collection('ProjectList')
        .snapshots();
  }

  Stream<QuerySnapshot> _taskListStream() {
    return _db
        .collection('users')
        .document(_firebaseUser.uid)
        .collection('TaskList')
        .snapshots();
  }

  Stream<QuerySnapshot> _timeListStream() {
    return _db
        .collection('users')
        .document(_firebaseUser.uid)
        .collection('TimeList')
        .snapshots();
  }

  OureaRemoteDataSource() {
    _firebaseUser = locator<AuthService>().user;
    _projectListStream().listen(_projectAdded);
    _taskListStream().listen(_taskAdded);
    _timeListStream().listen(_timeAdded);
  }

  Future<bool> addItem(
      String collection, String itemId, Map<String, dynamic> data) async {
    try {
      print('adding item: $data');
      await _db
          .collection('users')
          .document(_firebaseUser.uid)
          .collection(collection)
          .document(itemId)
          .setData(data);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> updateItem(
      String collection, String itemId, Map<String, dynamic> data) async {
    try {
      await _db
          .collection('users')
          .document(_firebaseUser.uid)
          .collection(collection)
          .document(itemId)
          .updateData(data);
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<bool> deleteItem(String collection, String itemId) async {
    try {
      await _db
          .collection('users')
          .document(_firebaseUser.uid)
          .collection(collection)
          .document(itemId)
          .delete();
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  @override
  Future<bool> addProject(Project project) async {
    print('Adding Project: ${project.toString()}');
    return await addItem('ProjectList', project.id, project.toJson());
  }

  @override
  Future<bool> addTask(Task task) async {
    return await addItem('TaskList', task.id, task.toJson());
  }

  @override
  Future<bool> addTimeTransaction(TimeTransaction transaction) async {
    return await addItem('TimeList', transaction.id, transaction.toJson());
  }

  @override
  Future<bool> removeProject(Project project) async {
    return await deleteItem('ProjectList', project.id);
  }

  @override
  Future<bool> removeTask(Task task) async {
    return await deleteItem('TaskList', task.id);
  }

  @override
  Future<bool> removeTimeTransaction(TimeTransaction transaction) async {
    return await deleteItem('TimeList', transaction.id);
  }

  @override
  Future<bool> updateProject(Project project) async {
    return await updateItem('ProjectList', project.id, project.toJson());
  }

  @override
  Future<bool> updateTask(Task task) async {
    return await updateItem('TaskList', task.id, task.toJson());
  }

  @override
  Future<bool> updateTimeTransaction(TimeTransaction transaction) async {
    return await updateItem('TimeList', transaction.id, transaction.toJson());
  }

  Future<bool> saveDeviceToken(var token) async {
    try {
      var tokens = _db
          .collection('users')
          .document(_firebaseUser.uid)
          .collection('tokens')
          .document(token);

      await tokens.setData({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Failed to save token');
      return false;
    }
  }
}
