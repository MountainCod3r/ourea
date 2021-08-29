import 'package:ourea/core/models/time_transaction.dart';
import 'package:flutter/material.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class OureaRecord {
  String id;
  String projectId;
  String taskId;
  String transactionID;
  DateTime start;
  DateTime stop;
  DateTime whenCompleted;
  Duration duration;
  bool completed;

  OureaRecord(TimeTransaction transaction) {
    id = UniqueKey().toString();
    transactionID = transaction.id;
    taskId = transaction.taskId;
    projectId = locator<OureaBloc>().getTaskById(taskId).projectId;
    start = transaction.start;
    stop = transaction.stop;
    duration = stop.difference(start);
    completed = locator<OureaBloc>().getTaskById(taskId).completed;
    if (completed) {
      whenCompleted = locator<OureaBloc>().getTaskById(taskId).whenCompleted;
    }
  }
}
