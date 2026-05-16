// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounting_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AccountingTransactionAdapter extends TypeAdapter<AccountingTransaction> {
  @override
  final int typeId = 11;

  @override
  AccountingTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountingTransaction(
      id: fields[0] as String,
      dateTime: fields[1] as DateTime,
      type: fields[2] as TransactionType,
      amount: fields[3] as double,
      description: fields[4] as String,
      paymentMethod: fields[5] as String?,
      reference: fields[6] as String?,
      items: (fields[7] as Map?)?.cast<String, dynamic>(),
      profit: fields[8] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, AccountingTransaction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.dateTime)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.reference)
      ..writeByte(7)
      ..write(obj.items)
      ..writeByte(8)
      ..write(obj.profit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountingTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 10;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.sale;
      case 1:
        return TransactionType.purchase;
      case 2:
        return TransactionType.expense;
      case 3:
        return TransactionType.income;
      case 4:
        return TransactionType.refund;
      default:
        return TransactionType.sale;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.sale:
        writer.writeByte(0);
        break;
      case TransactionType.purchase:
        writer.writeByte(1);
        break;
      case TransactionType.expense:
        writer.writeByte(2);
        break;
      case TransactionType.income:
        writer.writeByte(3);
        break;
      case TransactionType.refund:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
