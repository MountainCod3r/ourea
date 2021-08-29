import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ourea/core/models/task.dart';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/data/datasource/remote_datasource.dart';
import 'package:ourea/features/project_list_view/project/project_bloc.dart';
import 'package:ourea/features/task_list_view/task/task_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

part 'time_transaction_event.dart';

part 'time_transaction_state.dart';

class TimeTransactionBloc
    extends Bloc<TimeTransactionEvent, TimeTransactionState> {
  OureaRemoteDataSource _db;
  bool _isEditable;
  List<TimeTransaction> _timeList;

  TimeTransactionBloc() {
    _db = locator<OureaRemoteDataSource>();
    _isEditable = false;
  }

  List<TimeTransaction> getActiveTimeTransactionsForTask(String taskId) {
    var filteredList = _timeList
        .where((element) => (element.taskId == taskId) && (element.isActive));
    return filteredList.toList() ?? [];
  }

  List<TimeTransaction> _getActiveTransactionsForProject(String projectId) {
    List<Task> taskList = locator<TaskBloc>().getProjectTaskList(projectId);
    List<TimeTransaction> timeList = [];
    for (var task in taskList) {
      List<TimeTransaction> active = getActiveTimeTransactionsForTask(task.id);
      if (active.length > 0) {
        timeList.add(active[0]);
      }
    }
    return timeList;
  }

  String _getProjectIdForTransaction(TimeTransaction transaction) {
    return locator<TaskBloc>().getTaskById(transaction.taskId).projectId;
  }

  List<TimeTransaction> getActiveTransactions() {
    return _timeList.where((element) => element.isActive);
  }

  Duration getEpochForTask(String taskId) {
    if (_timeList == null) {
      return Duration(seconds: 0);
    }
    if (_timeList.length == 0) {
      return Duration(seconds: 0);
    }
    var filteredList =
        _timeList.where((transaction) => transaction.taskId == taskId).toList();
    print(
        'Filtered TransactionList is: ${filteredList.map((element) => element.toString())}');
    if (filteredList.length == 0) {
      return Duration(seconds: 0);
    } else {
      Duration epoch = Duration();
      for (var transaction in filteredList) {
        var transactionDuration =
            transaction.stop.difference(transaction.start);
        if (transaction.isActive) {
          transactionDuration = DateTime.now().difference(transaction.start);
        }
        epoch = epoch + transactionDuration;
      }
      return epoch;
    }
  }

  Future<TimeTransactionState> _transactionEventHandler(
      {Function repoFunction,
      String functionName,
      TimeTransaction transaction}) async {
    print(
        'calling repoFunction: $functionName on transaction: ${transaction.toString()}');
    var result = await repoFunction(transaction);
    if (result) {
      _timeList = await _db.transactions.first;
      return UpdatedTimeTransactionState(_isEditable, _timeList);
    } else {
      return ErrorTransactionState(
          'Failed to $functionName TimeTransaction: ${transaction.id}');
    }
  }

  @override
  TimeTransactionState get initialState => InitialTimeTransactionState();

  @override
  Stream<TimeTransactionState> mapEventToState(
      TimeTransactionEvent event) async* {
    if (event is InitializeTimeTransactionBloc) {
      yield UpdatingTimeTransactionState();
      print('Initializing _timelist');
      _timeList = await _db.transactions.first;
      yield UpdatedTimeTransactionState(_isEditable, _timeList);
    }
    if (event is StartTimeTransactionEvent) {
      String projectId = _getProjectIdForTransaction(event.transaction);
      List<TimeTransaction> active =
          _getActiveTransactionsForProject(projectId);
      for (var transaction in active) {
        this.add(StopTimeTransactionEvent(transaction));
      }
      print(
          'Event \'StartTimer\' for transaction: ${event.transaction.toString()}');
      var result = await _transactionEventHandler(
          repoFunction: _db.addTimeTransaction,
          functionName: 'add',
          transaction: event.transaction);
      yield result;
    }
    if (event is StopTimeTransactionEvent) {
      print(
          'Event \'StopTimer\' for transaction: ${event.transaction.toString()}');
      var trans = event.transaction;
      trans.stopTransaction();
      var result = await _transactionEventHandler(
          repoFunction: _db.updateTimeTransaction,
          functionName: 'update',
          transaction: trans);
      yield result;
    }
    if (event is UpdateTimeTransaction) {
      print(
          'Event \'UpdateTimer\' for transaction: ${event.transaction.toString()}');
      var result = await _transactionEventHandler(
          repoFunction: _db.updateTimeTransaction,
          functionName: 'update',
          transaction: event.transaction);
      yield result;
    }
    if (event is ChangeEditStateTransactionEvent) {
      _isEditable = event.isEditable;
      yield UpdatedTimeTransactionState(_isEditable, _timeList);
    }
    if (event is ErrorTimeTransactionEvent) {}
  }
}
