import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Project {
  String _id;
  String name;

  String get id => _id;

  Project(this.name) {
    _id = UniqueKey().toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  Project.fromJson(Map<String, dynamic> json) {
    this._id = json['id'] ?? '';
    this.name = json['name'] ?? '';
  }

  Project.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data;
    this._id = data['id'] ?? '';
    this.name = data['name'] ?? '';
  }

  @override
  String toString() {
    // TODO: implement toString
    return """
    id: $id,
    name: $name
    -------------------------------
    """;
  }
}
