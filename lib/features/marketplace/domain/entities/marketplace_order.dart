import 'package:hive/hive.dart';

part 'marketplace_order.g.dart';

@HiveType(typeId: 21)
class MarketplaceOrder extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String productName;

  @HiveField(3)
  final int quantity;

  @HiveField(4)
  final double unitPrice;

  @HiveField(5)
  final double totalAmount;

  @HiveField(6)
  final String status;

  @HiveField(7)
  final DateTime orderDate;

  @HiveField(8)
  final String? customerName;

  @HiveField(9)
  final String? customerPhone;

  @HiveField(10)
  final String? notes;

  MarketplaceOrder({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalAmount,
    this.status = 'pending',
    required this.orderDate,
    this.customerName,
    this.customerPhone,
    this.notes,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}

@HiveType(typeId: 22)
class MarketplaceCartItem {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String productName;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  final double unitPrice;

  @HiveField(4)
  final String unit;

  MarketplaceCartItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.unit = 'unit',
  });

  double get totalPrice => quantity * unitPrice;
}