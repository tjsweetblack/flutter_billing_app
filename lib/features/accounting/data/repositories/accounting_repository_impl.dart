import 'package:fpdart/fpdart.dart';
import '../../../../core/data/hive_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/accounting_transaction.dart';
import '../../domain/repositories/accounting_repository.dart';

class AccountingRepositoryImpl implements AccountingRepository {
  @override
  Future<Either<Failure, List<AccountingTransaction>>> getTransactions() async {
    try {
      final box = HiveDatabase.accountingBox;
      final transactions = box.values.toList();
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccountingTransaction>>> getTransactionsByDateRange(
      DateTime start, DateTime end) async {
    try {
      final box = HiveDatabase.accountingBox;
      final transactions = box.values
          .where((t) =>
              t.dateTime.isAfter(start.subtract(const Duration(seconds: 1))) &&
              t.dateTime.isBefore(end.add(const Duration(seconds: 1))))
          .toList();
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AccountingTransaction>>> getTransactionsByType(
      TransactionType type) async {
    try {
      final box = HiveDatabase.accountingBox;
      final transactions = box.values
          .where((t) => t.type == type)
          .toList();
      transactions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      return Right(transactions);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(AccountingTransaction transaction) async {
    try {
      final box = HiveDatabase.accountingBox;
      await box.put(transaction.id, transaction);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(AccountingTransaction transaction) async {
    try {
      final box = HiveDatabase.accountingBox;
      await box.put(transaction.id, transaction);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String id) async {
    try {
      final box = HiveDatabase.accountingBox;
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearAllTransactions() async {
    try {
      final box = HiveDatabase.accountingBox;
      await box.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
