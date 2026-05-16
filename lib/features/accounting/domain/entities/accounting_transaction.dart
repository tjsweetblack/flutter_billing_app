import 'package:hive/hive.dart';

part 'accounting_transaction.g.dart';

@HiveType(typeId: 10)
enum TransactionType {
  @HiveField(0)
  sale,
  @HiveField(1)
  purchase,
  @HiveField(2)
  expense,
  @HiveField(3)
  income,
  @HiveField(4)
  refund,
}

@HiveType(typeId: 11)
class AccountingTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime dateTime;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String? paymentMethod;

  @HiveField(6)
  final String? reference;

  @HiveField(7)
  final Map<String, dynamic>? items;

  @HiveField(8)
  final double? profit;

  AccountingTransaction({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.amount,
    required this.description,
    this.paymentMethod,
    this.reference,
    this.items,
    this.profit,
  });

  bool get isEntry => type == TransactionType.sale || type == TransactionType.income || type == TransactionType.refund;
  bool get isExit => type == TransactionType.purchase || type == TransactionType.expense;

  AccountingTransaction copyWith({
    String? id,
    DateTime? dateTime,
    TransactionType? type,
    double? amount,
    String? description,
    String? paymentMethod,
    String? reference,
    Map<String, dynamic>? items,
    double? profit,
  }) {
    return AccountingTransaction(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      reference: reference ?? this.reference,
      items: items ?? this.items,
      profit: profit ?? this.profit,
    );
  }
}
