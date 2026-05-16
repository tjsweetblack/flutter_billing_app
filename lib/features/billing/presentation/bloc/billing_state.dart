part of 'billing_bloc.dart';

class BillingState extends Equatable {
  final List<CartItem> cartItems;
  final String? error;
  final bool isPrinting;
  final bool printSuccess;
  final String? paymentMethod;
  final String? paymentStatus;
  final double? changeAmount;
  final Map<String, dynamic>? paymentDetails;

  const BillingState({
    this.cartItems = const [],
    this.error,
    this.isPrinting = false,
    this.printSuccess = false,
    this.paymentMethod,
    this.paymentStatus,
    this.changeAmount,
    this.paymentDetails,
  });

  double get totalAmount => cartItems.fold(0, (sum, item) => sum + item.total);

  BillingState copyWith({
    List<CartItem>? cartItems,
    String? error,
    bool clearError = false,
    bool? isPrinting,
    bool? printSuccess,
    String? paymentMethod,
    String? paymentStatus,
    double? changeAmount,
    Map<String, dynamic>? paymentDetails,
    bool clearPaymentDetails = false,
  }) {
    return BillingState(
      cartItems: cartItems ?? this.cartItems,
      error: clearError ? null : (error ?? this.error),
      isPrinting: isPrinting ?? this.isPrinting,
      printSuccess: printSuccess ?? this.printSuccess,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentDetails: clearPaymentDetails ? null : (paymentDetails ?? this.paymentDetails),
    );
  }

  @override
  List<Object?> get props => [
        cartItems,
        error,
        isPrinting,
        printSuccess,
        paymentMethod,
        paymentStatus,
        changeAmount,
        paymentDetails,
      ];
}
