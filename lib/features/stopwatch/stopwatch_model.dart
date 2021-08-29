import 'dart:async';
import 'package:ourea/core/models/time_transaction.dart';
import 'package:ourea/core/ourea/ourea_bloc.dart';
import 'package:ourea/services/locator/locator.dart';

class StopwatchModel {
  OureaBloc _bloc;
  Timer _timer;
  String _taskId = '';
  TimeTransaction _currentTransaction;
  bool isActive;

  StreamController<int> _hoursController = StreamController<int>();
  StreamController<int> _minutesController = StreamController<int>();
  StreamController<int> _secondsController = StreamController<int>();

  int _iHours = 0;
  int _iMinutes = 0;
  int _iSeconds = 0;
  Duration _epoch;

  Stream<int> get hours => _hoursController.stream;

  Stream<int> get minutes => _minutesController.stream;

  Stream<int> get seconds => _secondsController.stream;

  void refresh() {
    _bloc = locator<OureaBloc>();
    _epoch = _bloc.getEpochForTask(_taskId);
    isActive = false;
    _iSeconds = _epoch.inSeconds % 60;
    _iMinutes = _epoch.inMinutes % 60;
    _iHours = _epoch.inHours;
    print('The Current Epoch for Task: $_taskId is $_epoch}');
    var activeTransactions = _bloc.getActiveTimeTransactionsForTask(_taskId);
    _secondsController.add(_iSeconds);
    _minutesController.add(_iMinutes);
    _hoursController.add(_iHours);
    if (activeTransactions.length > 0) {
      _currentTransaction = activeTransactions[0];
      this.start();
    }
  }

  StopwatchModel([String taskId]) {
    _taskId = taskId;
    _bloc = locator<OureaBloc>();
    _epoch = _bloc.getEpochForTask(taskId);
    isActive = false;
    _iSeconds = _epoch.inSeconds % 60;
    _iMinutes = _epoch.inMinutes % 60;
    _iHours = _epoch.inHours;
    print('The Current Epoch for Task: $_taskId is $_epoch}');
    var activeTransactions = _bloc.getActiveTimeTransactionsForTask(_taskId);
    _secondsController.add(_iSeconds);
    _minutesController.add(_iMinutes);
    _hoursController.add(_iHours);
    if (activeTransactions.length > 0) {
      _currentTransaction = activeTransactions[0];
      this.start();
    }
  }

  void start() {
    var activeTransactions = _bloc.getActiveTimeTransactionsForTask(_taskId);
    if (activeTransactions.length > 0) {
      _currentTransaction = activeTransactions[0];
    } else {
      _currentTransaction = TimeTransaction(_taskId);
      _bloc.add(StartTimeTransactionEvent(_currentTransaction));
    }
    isActive = true;
    Duration difference =
    DateTime.now().difference(_currentTransaction.start.subtract(_epoch));
    _secondsController.add(difference.inSeconds % 60);
    _minutesController.add(difference.inMinutes % 60);
    _hoursController.add(difference.inHours);
    print('iSeconds: $_iSeconds');
    if (_timer == null || _timer.isActive == false) {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        Duration difference = DateTime.now().difference(
            _currentTransaction.start.subtract(
                _epoch)); //_bloc.getActiveTimeTransactionForTask(_taskId).start);
        if (timer.tick.abs() % 1 == 0) {
          _iSeconds = difference.inSeconds;
          if (_iSeconds % 60 == 0) {
            _iMinutes = difference.inMinutes;
            if (_iMinutes % 60 == 0) {
              _iHours = difference.inHours;
              _hoursController.add(difference.inHours);
            }
            _minutesController.add(difference.inMinutes % 60);
          }
          _secondsController.add(difference.inSeconds % 60);
        }
      });
    }
  }

  void stop() {
    isActive = false;
    _bloc.add(StopTimeTransactionEvent(_currentTransaction));
    _timer.cancel();
  }

  void reset() {
    _iMinutes = 0;
    _iHours = 0;
    _iSeconds = 0;
  }

  void dispose() {
    if (_timer != null) {
      _timer.cancel();
    }
    _hoursController.close();
    _minutesController.close();
    _secondsController.close();
  }
}
