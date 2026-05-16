import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/accounting_transaction.dart';

abstract class AccountingRepository {
  Future<Either<Failure, List<AccountingTransaction>>> getTransactions();
  Future<Either<Failure, List<AccountingTransaction>>> getTransactionsByDateRange(
      DateTime start, DateTime end);
  Future<Either<Failure, List<AccountingTransaction>>> getTransactionsByType(
      TransactionType type);
  Future<Either<Failure, void>> addTransaction(AccountingTransaction transaction);
  Future<Either<Failure, void>> updateTransaction(AccountingTransaction transaction);
  Future<Either<Failure, void>> deleteTransaction(String id);
  Future<Either<Failure, void>> clearAllTransactions();
}
