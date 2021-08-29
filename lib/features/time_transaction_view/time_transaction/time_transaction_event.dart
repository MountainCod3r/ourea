part of 'time_transaction_bloc.dart';

@immutable
abstract class TimeTransactionEvent {}

class InitializeTimeTransactionBloc extends TimeTransactionEvent {}

class StartTimeTransactionEvent extends TimeTransactionEvent {
  final TimeTransaction transaction;

  StartTimeTransactionEvent(this.transaction);
}

class StopTimeTransactionEvent extends TimeTransactionEvent {
  final TimeTransaction transaction;

  StopTimeTransactionEvent(this.transaction);
}

class UpdateTimeTransaction extends TimeTransactionEvent {
  final TimeTransaction transaction;

  UpdateTimeTransaction(this.transaction);
}

class ErrorTimeTransactionEvent extends TimeTransactionEvent {
  final String message;

  ErrorTimeTransactionEvent(this.message);
}

class ChangeEditStateTransactionEvent extends TimeTransactionEvent {
  final bool isEditable;

  ChangeEditStateTransactionEvent(this.isEditable);
}
