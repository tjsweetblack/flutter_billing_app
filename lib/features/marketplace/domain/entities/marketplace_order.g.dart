// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketplaceOrderAdapter extends TypeAdapter<MarketplaceOrder> {
  @override
  final int typeId = 21;

  @override
  MarketplaceOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarketplaceOrder(
      id: fields[0] as String,
      productId: fields[1] as String,
      productName: fields[2] as String,
      quantity: fields[3] as int,
      unitPrice: fields[4] as double,
      totalAmount: fields[5] as double,
      status: fields[6] as String,
      orderDate: fields[7] as DateTime,
      customerName: fields[8] as String?,
      customerPhone: fields[9] as String?,
      notes: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MarketplaceOrder obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.productName)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.unitPrice)
      ..writeByte(5)
      ..write(obj.totalAmount)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.orderDate)
      ..writeByte(8)
      ..write(obj.customerName)
      ..writeByte(9)
      ..write(obj.customerPhone)
      ..writeByte(10)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MarketplaceCartItemAdapter extends TypeAdapter<MarketplaceCartItem> {
  @override
  final int typeId = 22;

  @override
  MarketplaceCartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarketplaceCartItem(
      productId: fields[0] as String,
      productName: fields[1] as String,
      quantity: fields[2] as int,
      unitPrice: fields[3] as double,
      unit: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MarketplaceCartItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceCartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
