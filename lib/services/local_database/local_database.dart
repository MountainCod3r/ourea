import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:path/path.dart';

class LocalDatabase {
  static final LocalDatabase _singleton = LocalDatabase._();

  static LocalDatabase get instance => _singleton;

  //Completer is used for transforming synchronous code into async code
  Completer<Database> _dbOpenCompleter;

  //private constructor. allows creation of database instances
  //within class itself
  LocalDatabase._();

  //Database object accessor
  Future<Database> get database async {
    if (_dbOpenCompleter == null) {
      _dbOpenCompleter = Completer();
      _openDatabase();
    }
    return _dbOpenCompleter.future;
  }

  Future _openDatabase() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();

    final dbPath = join(appDocumentDir.path, 'OureaDB.db');

    _dbOpenCompleter.complete(database);
  }
}
