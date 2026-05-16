import 'package:equatable/equatable.dart';
import '../../domain/entities/accounting_transaction.dart';

enum AccountingStatus { initial, loading, loaded, error }

class AccountingState extends Equatable {
  final AccountingStatus status;
  final List<AccountingTransaction> transactions;
  final List<AccountingTransaction> filteredTransactions;
  final TransactionType? filterType;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? errorMessage;

  final double totalSales;
  final double totalPurchases;
  final double totalExpenses;
  final double totalIncome;
  final double totalRefunds;
  final double netProfit;

  final int totalTransactions;
  final int salesCount;
  final int purchasesCount;

  const AccountingState({
    this.status = AccountingStatus.initial,
    this.transactions = const [],
    this.filteredTransactions = const [],
    this.filterType,
    this.startDate,
    this.endDate,
    this.errorMessage,
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.totalExpenses = 0,
    this.totalIncome = 0,
    this.totalRefunds = 0,
    this.netProfit = 0,
    this.totalTransactions = 0,
    this.salesCount = 0,
    this.purchasesCount = 0,
  });

  double get totalEntries => totalSales + totalIncome + totalRefunds;
  double get totalExits => totalPurchases + totalExpenses;
  double get balance => totalEntries - totalExits;

  AccountingState copyWith({
    AccountingStatus? status,
    List<AccountingTransaction>? transactions,
    List<AccountingTransaction>? filteredTransactions,
    TransactionType? filterType,
    bool clearFilter = false,
    DateTime? startDate,
    DateTime? endDate,
    String? errorMessage,
    double? totalSales,
    double? totalPurchases,
    double? totalExpenses,
    double? totalIncome,
    double? totalRefunds,
    double? netProfit,
    int? totalTransactions,
    int? salesCount,
    int? purchasesCount,
  }) {
    return AccountingState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filteredTransactions: filteredTransactions ?? this.filteredTransactions,
      filterType: clearFilter ? null : (filterType ?? this.filterType),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      errorMessage: errorMessage ?? this.errorMessage,
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalExpenses: totalExpenses ?? this.totalExpenses,
      totalIncome: totalIncome ?? this.totalIncome,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      netProfit: netProfit ?? this.netProfit,
      totalTransactions: totalTransactions ?? this.totalTransactions,
      salesCount: salesCount ?? this.salesCount,
      purchasesCount: purchasesCount ?? this.purchasesCount,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        filteredTransactions,
        filterType,
        startDate,
        endDate,
        errorMessage,
        totalSales,
        totalPurchases,
        totalExpenses,
        totalIncome,
        totalRefunds,
        netProfit,
        totalTransactions,
        salesCount,
        purchasesCount,
      ];
}
