part of 'billing_bloc.dart';

abstract class BillingEvent extends Equatable {
  const BillingEvent();
  @override
  List<Object> get props => [];
}

class ScanBarcodeEvent extends BillingEvent {
  final String barcode;
  const ScanBarcodeEvent(this.barcode);
  @override
  List<Object> get props => [barcode];
}

class AddProductToCartEvent extends BillingEvent {
  final Product product;
  const AddProductToCartEvent(this.product);
  @override
  List<Object> get props => [product];
}

class RemoveProductFromCartEvent extends BillingEvent {
  final String productId;
  const RemoveProductFromCartEvent(this.productId);
  @override
  List<Object> get props => [productId];
}

class UpdateQuantityEvent extends BillingEvent {
  final String productId;
  final int quantity;
  const UpdateQuantityEvent(this.productId, this.quantity);
  @override
  List<Object> get props => [productId, quantity];
}

class ClearCartEvent extends BillingEvent {}

class PrintReceiptEvent extends BillingEvent {
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;

  const PrintReceiptEvent({
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
  });

  @override
  List<Object> get props => [shopName, address1, address2, phone, footer];
}

class SelectPaymentMethodEvent extends BillingEvent {
  final String method;
  const SelectPaymentMethodEvent(this.method);
  @override
  List<Object> get props => [method];
}

class ProcessPaymentEvent extends BillingEvent {
  final Map<String, dynamic> paymentData;
  const ProcessPaymentEvent(this.paymentData);
  @override
  List<Object> get props => [paymentData];
}

class CheckPaymentStatusEvent extends BillingEvent {
  final String externalId;
  const CheckPaymentStatusEvent(this.externalId);
  @override
  List<Object> get props => [externalId];
}

class ConfirmPaymentEvent extends BillingEvent {
  const ConfirmPaymentEvent();
  @override
  List<Object> get props => [];
}

class SharePdfReceiptEvent extends BillingEvent {
  final String shopName;
  final String address1;
  final String address2;
  final String phone;
  final String footer;

  const SharePdfReceiptEvent({
    required this.shopName,
    required this.address1,
    required this.address2,
    required this.phone,
    required this.footer,
  });

  @override
  List<Object> get props => [shopName, address1, address2, phone, footer];
}
