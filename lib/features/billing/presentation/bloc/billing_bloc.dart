import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/cart_item.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import '../../../../core/utils/printer_helper.dart';
import '../../../../core/data/hive_database.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/pdf_receipt_generator.dart';
import '../../../../features/accounting/domain/repositories/accounting_repository.dart';
import '../../../../features/accounting/domain/entities/accounting_transaction.dart';

part 'billing_event.dart';
part 'billing_state.dart';

class BillingBloc extends Bloc<BillingEvent, BillingState> {
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final AccountingRepository accountingRepository;

  BillingBloc({
    required this.getProductByBarcodeUseCase,
    required this.updateProductUseCase,
    required this.accountingRepository,
  }) : super(const BillingState()) {
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<AddProductToCartEvent>(_onAddProductToCart);
    on<RemoveProductFromCartEvent>(_onRemoveProductFromCart);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<ClearCartEvent>(_onClearCart);
    on<PrintReceiptEvent>(_onPrintReceipt);
    
    on<SelectPaymentMethodEvent>(_onSelectPaymentMethod);
    on<ProcessPaymentEvent>(_onProcessPayment);
    on<CheckPaymentStatusEvent>(_onCheckPaymentStatus);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
    on<SharePdfReceiptEvent>(_onSharePdfReceipt);
  }

  Future<void> _onScanBarcode(
      ScanBarcodeEvent event, Emitter<BillingState> emit) async {
    final result = await getProductByBarcodeUseCase(event.barcode);
    result.fold(
      (failure) =>
          emit(state.copyWith(error: 'Product not found: ${event.barcode}')),
      (product) {
        add(AddProductToCartEvent(product));
      },
    );
  }

  void _onAddProductToCart(
      AddProductToCartEvent event, Emitter<BillingState> emit) {
    // Clear error when adding
    final cleanState = state.copyWith(error: null);

    final existingIndex = cleanState.cartItems
        .indexWhere((item) => item.product.id == event.product.id);
    if (existingIndex >= 0) {
      final existingItem = cleanState.cartItems[existingIndex];
      final backendItems = List<CartItem>.from(cleanState.cartItems);
      backendItems[existingIndex] =
          existingItem.copyWith(quantity: existingItem.quantity + 1);
      emit(cleanState.copyWith(cartItems: backendItems, error: null));
    } else {
      final newItem = CartItem(product: event.product);
      emit(cleanState.copyWith(
          cartItems: [...cleanState.cartItems, newItem], error: null));
    }
  }

  void _onRemoveProductFromCart(
      RemoveProductFromCartEvent event, Emitter<BillingState> emit) {
    final updatedList = state.cartItems
        .where((item) => item.product.id != event.productId)
        .toList();
    emit(state.copyWith(cartItems: updatedList));
  }

  void _onUpdateQuantity(
      UpdateQuantityEvent event, Emitter<BillingState> emit) {
    if (event.quantity <= 0) {
      add(RemoveProductFromCartEvent(event.productId));
      return;
    }

    final index = state.cartItems
        .indexWhere((item) => item.product.id == event.productId);
    if (index >= 0) {
      final items = List<CartItem>.from(state.cartItems);
      items[index] = items[index].copyWith(quantity: event.quantity);
      emit(state.copyWith(cartItems: items));
    }
  }

  void _onClearCart(ClearCartEvent event, Emitter<BillingState> emit) {
    emit(const BillingState());
  }

  Future<void> _onPrintReceipt(
      PrintReceiptEvent event, Emitter<BillingState> emit) async {
    final printerHelper = PrinterHelper();

    if (!printerHelper.isConnected) {
      final savedMac = HiveDatabase.settingsBox.get('printer_mac');
      if (savedMac != null) {
        final connected = await printerHelper.connect(savedMac);
        if (!connected) {
          emit(state.copyWith(
              error: 'Failed to auto-connect to printer!', clearError: false));
          emit(state.copyWith(clearError: true));
          return;
        }
      } else {
        emit(state.copyWith(
            error: 'Printer not connected & no saved printer found!',
            clearError: false));
        emit(state.copyWith(clearError: true));
        return;
      }
    }

    emit(state.copyWith(
        isPrinting: true, printSuccess: false, clearError: true));

    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.product.price,
                'total': item.total,
              })
          .toList();

      await printerHelper.printReceipt(
          shopName: event.shopName,
          address1: event.address1,
          address2: event.address2,
          phone: event.phone,
          items: items,
          total: state.totalAmount,
          footer: event.footer);

      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(
          isPrinting: false, error: 'Print failed: $e', clearError: false));
      // Reset error instantly avoids sticky error
      emit(state.copyWith(clearError: true));
    }
  }

  void _onSelectPaymentMethod(SelectPaymentMethodEvent event, Emitter<BillingState> emit) {
    emit(state.copyWith(paymentMethod: event.method, paymentStatus: 'initial', clearPaymentDetails: true));
  }

  Future<void> _onProcessPayment(ProcessPaymentEvent event, Emitter<BillingState> emit) async {
    emit(state.copyWith(paymentStatus: 'processing', paymentDetails: event.paymentData));
    
    if (state.paymentMethod == 'Cash') {
      double amountGiven = double.tryParse(event.paymentData['amount_given'].toString()) ?? 0;
      double change = amountGiven - state.totalAmount;
      emit(state.copyWith(paymentStatus: 'success', changeAmount: change));
    } else if (state.paymentMethod == 'TPA') {
      emit(state.copyWith(paymentStatus: 'success'));
    } else {
      // Dizanpay (UI will handle API calls and send status updates or ConfirmPaymentEvent directly)
      emit(state.copyWith(paymentStatus: 'pending'));
    }
  }

  Future<void> _onCheckPaymentStatus(CheckPaymentStatusEvent event, Emitter<BillingState> emit) async {
     // Intentionally left blank as UI handles polling to decouple UI-specific loading loops.
  }

  Future<void> _onConfirmPayment(ConfirmPaymentEvent event, Emitter<BillingState> emit) async {
    try {
      // 1. Stock reduction
      for (final item in state.cartItems) {
        final newStock = item.product.stock - item.quantity;
        final updatedProduct = item.product.copyWith(stock: newStock >= 0 ? newStock : 0);
        await updateProductUseCase(updatedProduct);
      }

      // 2. Accounting
      final itemsMap = {
        for (var item in state.cartItems) item.product.name: item.quantity
      };
      
      final transaction = AccountingTransaction(
        id: const Uuid().v4(),
        dateTime: DateTime.now(),
        type: TransactionType.sale,
        amount: state.totalAmount,
        description: 'Sale - ${state.paymentMethod}',
        paymentMethod: state.paymentMethod,
        items: itemsMap,
      );
      await accountingRepository.addTransaction(transaction);

      emit(state.copyWith(paymentStatus: 'confirmed'));
    } catch (e) {
      emit(state.copyWith(error: 'Failed to confirm order: $e'));
    }
  }

  Future<void> _onSharePdfReceipt(SharePdfReceiptEvent event, Emitter<BillingState> emit) async {
    emit(state.copyWith(isPrinting: true, clearError: true));
    try {
      final items = state.cartItems
          .map((item) => {
                'name': item.product.name,
                'qty': item.quantity,
                'price': item.product.price,
                'total': item.total,
              })
          .toList();

      await PdfReceiptGenerator.generateAndShareReceipt(
        shopName: event.shopName,
        address1: event.address1,
        address2: event.address2,
        phone: event.phone,
        items: items,
        total: state.totalAmount,
        footer: event.footer,
      );
      emit(state.copyWith(isPrinting: false, printSuccess: true));
    } catch (e) {
      emit(state.copyWith(isPrinting: false, error: 'Failed to share PDF: $e'));
    }
  }
}
