import 'dart:async';

import 'package:ourea/core/models/project.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';

abstract class OureaRepository {
  //Create
  Future<bool> addTask(Task task);

  Future<bool> addProject(Project project);

  Future<bool> addTimeTransaction(TimeTransaction transaction);

  //Read
  Stream<List<Project>> projects;
  Stream<List<Task>> tasks;
  Stream<List<TimeTransaction>> transactions;

  //Update
  Future<bool> updateTask(Task task);

  Future<bool> updateProject(Project project);

  Future<bool> updateTimeTransaction(TimeTransaction transaction);

  //Delete
  Future<bool> removeTask(Task task);

  Future<bool> removeProject(Project project);

  Future<bool> removeTimeTransaction(TimeTransaction transaction);
}
