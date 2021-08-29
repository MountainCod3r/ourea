import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TimeTransaction {
  DateTime _start;
  DateTime _stop;
  String _taskId;
  String _id;
  bool _isActive;

  DateTime get start => _start;

  DateTime get stop => _stop;

  String get taskId => _taskId;

  String get id => _id;

  bool get isActive => _isActive;

  TimeTransaction(String taskId) {
    _start = DateTime.now();
    _stop = DateTime.now();
    _taskId = taskId;
    _id = UniqueKey().toString();
    _isActive = true;
  }

  void stopTransaction() {
    _stop = DateTime.now();
    _isActive = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': _isActive,
      'start': start,
      'stop': stop,
      'taskId': taskId,
      'id': id,
    };
  }

  TimeTransaction.fromJson(Map<String, dynamic> json) {
    this._id = json['id'] ?? '';
    this._taskId = json['taskId'] ?? '';
    this._isActive = json['isActive'];
    this._start = DateTime.parse(json['start']);
    this._stop = DateTime.parse(json['stop']);
  }

  TimeTransaction.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data;
    this._id = data['id'];
    this._taskId = data['taskId'];
    this._isActive = data['isActive'];
    this._start = data['start'].toDate();
    this._stop = data['stop'].toDate() ?? null;
  }

  @override
  String toString() {
    return """
    taskId: $taskId,
    start: ${_start.toString()},
    stop: ${_stop.toString() ?? ''},
    isActive: $_isActive
    ------------------------------------------------
    """;
  }
}
