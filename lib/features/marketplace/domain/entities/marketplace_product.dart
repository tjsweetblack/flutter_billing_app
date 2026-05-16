import 'package:hive/hive.dart';

part 'marketplace_product.g.dart';

@HiveType(typeId: 20)
class MarketplaceProduct extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double price;

  @HiveField(4)
  final int stockQuantity;

  @HiveField(5)
  final String category;

  @HiveField(6)
  final String imageUrl;

  @HiveField(7)
  final String unit;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final bool isActive;

  @HiveField(10)
  final int minOrderQuantity;

  @HiveField(11)
  final double? bulkDiscount;

  MarketplaceProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.category,
    this.imageUrl = '',
    this.unit = 'unit',
    required this.createdAt,
    this.isActive = true,
    this.minOrderQuantity = 1,
    this.bulkDiscount,
  });

  bool get inStock => stockQuantity > 0;

  double get effectivePrice {
    if (bulkDiscount != null && bulkDiscount! > 0) {
      return price * (1 - bulkDiscount! / 100);
    }
    return price;
  }

  MarketplaceProduct copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    String? category,
    String? imageUrl,
    String? unit,
    DateTime? createdAt,
    bool? isActive,
    int? minOrderQuantity,
    double? bulkDiscount,
  }) {
    return MarketplaceProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      unit: unit ?? this.unit,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      minOrderQuantity: minOrderQuantity ?? this.minOrderQuantity,
      bulkDiscount: bulkDiscount ?? this.bulkDiscount,
    );
  }
}