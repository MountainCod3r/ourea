import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TaskPriority {
  static const int high = 3;
  static const int medium = 2;
  static const int low = 1;
  static const int none = 0;
}

Color priorityColor(int priority) {
  switch (priority) {
    case 3:
      return Colors.deepPurple[900];
    case 2:
      return Colors.deepPurple[700];
    case 1:
      return Colors.deepPurple[500];
    case 0:
      return Colors.deepPurple[300];
  }
}

class Task {
  String _id;
  String name;
  String description;
  String projectId;
  bool completed;
  DateTime whenCompleted;
  int priority;
  bool timed;

  String get id => _id;

  Task(
      {this.name,
      this.description,
      this.projectId,
      this.priority,
      this.timed}) {
    _id = UniqueKey().toString();
    completed = false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'projectId': projectId,
      'completed': completed,
      'priority': priority,
      'timed': timed,
      'whenCompleted': whenCompleted ?? null,
    };
  }

  Task.fromJson(Map<String, dynamic> json) {
    this._id = json['id'] ?? '';
    this.name = json['name'] ?? '';
    this.description = json['description'] ?? '';
    this.projectId = json['projectId'] ?? '';
    this.completed = json['completed'] ?? false;
    this.priority = json['priority'] ?? TaskPriority.none;
    this.timed = json['timed'] ?? true;
    this.whenCompleted = json['whenCompleted'];
  }

  Task.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data;
    this._id = data['id'];
    this.name = data['name'];
    this.description = data['description'];
    this.projectId = data['projectId'];
    this.completed = data['completed'];
    this.priority = data['priority'];
    this.timed = data['timed'] ?? true;
    if (this.completed) {
      this.whenCompleted = data['whenCompleted'].toDate() ?? '';
    }
  }

  @override
  String toString() {
    return """
    id: $id,
    name: $name,
    description: $description,
    projectId: $projectId,
    completed: $completed,
    priority: $priority,
    timed: $timed
    ------------------------------------------
    """;
  }
}
