import 'package:equatable/equatable.dart';
import '../../domain/entities/accounting_transaction.dart';

abstract class AccountingEvent extends Equatable {
  const AccountingEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends AccountingEvent {}

class LoadTodayTransactions extends AccountingEvent {}

class LoadWeekTransactions extends AccountingEvent {}

class LoadMonthTransactions extends AccountingEvent {}

class LoadCustomDateRange extends AccountingEvent {
  final DateTime start;
  final DateTime end;

  const LoadCustomDateRange(this.start, this.end);

  @override
  List<Object?> get props => [start, end];
}

class AddTransaction extends AccountingEvent {
  final AccountingTransaction transaction;

  const AddTransaction(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransaction extends AccountingEvent {
  final String id;

  const DeleteTransaction(this.id);

  @override
  List<Object?> get props => [id];
}

class ClearAllTransactions extends AccountingEvent {}

class FilterByType extends AccountingEvent {
  final TransactionType? type;

  const FilterByType(this.type);

  @override
  List<Object?> get props => [type];
}
