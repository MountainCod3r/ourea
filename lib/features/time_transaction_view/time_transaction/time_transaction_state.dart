part of 'time_transaction_bloc.dart';

@immutable
abstract class TimeTransactionState {}

class InitialTimeTransactionState extends TimeTransactionState {}

class UpdatingTimeTransactionState extends TimeTransactionState {}

class UpdatedTimeTransactionState extends TimeTransactionState {
  final List<TimeTransaction> timeList;
  final bool isEditable;

  UpdatedTimeTransactionState(this.isEditable, this.timeList);
}

class ChangeEditTransactionState extends TimeTransactionState {
  final List<TimeTransaction> timeList;
  final bool isEditable;

  ChangeEditTransactionState(this.isEditable, this.timeList);
}

class ErrorTransactionState extends TimeTransactionState {
  final String message;

  ErrorTransactionState(this.message);
}
