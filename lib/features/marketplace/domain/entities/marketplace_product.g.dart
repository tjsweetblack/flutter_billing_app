// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MarketplaceProductAdapter extends TypeAdapter<MarketplaceProduct> {
  @override
  final int typeId = 20;

  @override
  MarketplaceProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MarketplaceProduct(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      price: fields[3] as double,
      stockQuantity: fields[4] as int,
      category: fields[5] as String,
      imageUrl: fields[6] as String,
      unit: fields[7] as String,
      createdAt: fields[8] as DateTime,
      isActive: fields[9] as bool,
      minOrderQuantity: fields[10] as int,
      bulkDiscount: fields[11] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, MarketplaceProduct obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.stockQuantity)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.unit)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.isActive)
      ..writeByte(10)
      ..write(obj.minOrderQuantity)
      ..writeByte(11)
      ..write(obj.bulkDiscount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MarketplaceProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
