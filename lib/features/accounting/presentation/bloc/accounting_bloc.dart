import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/accounting_transaction.dart';
import '../../domain/repositories/accounting_repository.dart';
import 'accounting_event.dart';
import 'accounting_state.dart';

class AccountingBloc extends Bloc<AccountingEvent, AccountingState> {
  final AccountingRepository repository;

  AccountingBloc({required this.repository}) : super(const AccountingState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTodayTransactions>(_onLoadTodayTransactions);
    on<LoadWeekTransactions>(_onLoadWeekTransactions);
    on<LoadMonthTransactions>(_onLoadMonthTransactions);
    on<LoadCustomDateRange>(_onLoadCustomDateRange);
    on<AddTransaction>(_onAddTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<ClearAllTransactions>(_onClearAllTransactions);
    on<FilterByType>(_onFilterByType);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<AccountingState> emit) async {
    emit(state.copyWith(status: AccountingStatus.loading));
    final result = await repository.getTransactions();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountingStatus.error,
        errorMessage: failure.message,
      )),
      (transactions) {
        final calculated = _calculateTotals(transactions);
        emit(calculated.copyWith(
          status: AccountingStatus.loaded,
          transactions: transactions,
          filteredTransactions: transactions,
        ));
      },
    );
  }

  Future<void> _onLoadTodayTransactions(
      LoadTodayTransactions event, Emitter<AccountingState> emit) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    emit(state.copyWith(startDate: start, endDate: end));
    add(LoadCustomDateRange(start, end));
  }

  Future<void> _onLoadWeekTransactions(
      LoadWeekTransactions event, Emitter<AccountingState> emit) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    emit(state.copyWith(startDate: start, endDate: end));
    add(LoadCustomDateRange(start, end));
  }

  Future<void> _onLoadMonthTransactions(
      LoadMonthTransactions event, Emitter<AccountingState> emit) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    emit(state.copyWith(startDate: start, endDate: end));
    add(LoadCustomDateRange(start, end));
  }

  Future<void> _onLoadCustomDateRange(
      LoadCustomDateRange event, Emitter<AccountingState> emit) async {
    emit(state.copyWith(status: AccountingStatus.loading));
    final result = await repository.getTransactionsByDateRange(
        event.start, event.end);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountingStatus.error,
        errorMessage: failure.message,
      )),
      (transactions) {
        var filtered = transactions;
        if (state.filterType != null) {
          filtered = transactions.where((t) => t.type == state.filterType).toList();
        }
        final calculated = _calculateTotals(filtered);
        emit(calculated.copyWith(
          status: AccountingStatus.loaded,
          transactions: transactions,
          filteredTransactions: filtered,
          startDate: event.start,
          endDate: event.end,
        ));
      },
    );
  }

  Future<void> _onAddTransaction(
      AddTransaction event, Emitter<AccountingState> emit) async {
    final result = await repository.addTransaction(event.transaction);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountingStatus.error,
        errorMessage: failure.message,
      )),
      (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onDeleteTransaction(
      DeleteTransaction event, Emitter<AccountingState> emit) async {
    final result = await repository.deleteTransaction(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountingStatus.error,
        errorMessage: failure.message,
      )),
      (_) => add(LoadTransactions()),
    );
  }

  Future<void> _onClearAllTransactions(
      ClearAllTransactions event, Emitter<AccountingState> emit) async {
    final result = await repository.clearAllTransactions();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AccountingStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(const AccountingState(status: AccountingStatus.loaded)),
    );
  }

  Future<void> _onFilterByType(
      FilterByType event, Emitter<AccountingState> emit) async {
    if (event.type == null) {
      final calculated = _calculateTotals(state.transactions);
      emit(calculated.copyWith(
        status: AccountingStatus.loaded,
        filteredTransactions: state.transactions,
        clearFilter: true,
      ));
    } else {
      final result = await repository.getTransactionsByType(event.type!);
      result.fold(
        (failure) => emit(state.copyWith(
          status: AccountingStatus.error,
          errorMessage: failure.message,
        )),
        (transactions) {
          final calculated = _calculateTotals(transactions);
          emit(calculated.copyWith(
            status: AccountingStatus.loaded,
            filteredTransactions: transactions,
            filterType: event.type,
          ));
        },
      );
    }
  }

  AccountingState _calculateTotals(List<AccountingTransaction> transactions) {
    double sales = 0;
    double purchases = 0;
    double expenses = 0;
    double income = 0;
    double refunds = 0;
    double profit = 0;

    for (final t in transactions) {
      switch (t.type) {
        case TransactionType.sale:
          sales += t.amount;
          profit += t.profit ?? 0;
          break;
        case TransactionType.purchase:
          purchases += t.amount;
          profit -= t.amount;
          break;
        case TransactionType.expense:
          expenses += t.amount;
          profit -= t.amount;
          break;
        case TransactionType.income:
          income += t.amount;
          profit += t.amount;
          break;
        case TransactionType.refund:
          refunds += t.amount;
          profit -= t.amount;
          break;
      }
    }

    return state.copyWith(
      totalSales: sales,
      totalPurchases: purchases,
      totalExpenses: expenses,
      totalIncome: income,
      totalRefunds: refunds,
      netProfit: profit,
      totalTransactions: transactions.length,
      salesCount: transactions.where((t) => t.type == TransactionType.sale).length,
      purchasesCount: transactions.where((t) => t.type == TransactionType.purchase).length,
    );
  }
}
