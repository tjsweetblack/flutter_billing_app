import 'dart:convert';
import 'package:billing_app/core/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import '../../../shop/presentation/bloc/shop_bloc.dart';
import '../bloc/billing_bloc.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String _selectedMethod = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cashController = TextEditingController();
  
  bool _isLoadingPayment = false;
  String _dizanpayEntity = '';
  String _dizanpayReference = '';

  Future<void> _createDizanpayPayment(double amount, String method, String? phone) async {
    setState(() {
      _isLoadingPayment = true;
      _dizanpayEntity = '';
      _dizanpayReference = '';
    });

    final externalId = 'ORD-$method-${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'amount': amount,
      'external_id': externalId,
      if (phone != null && phone.isNotEmpty) 'customer_phone': phone,
    };

    try {
      final response = await http.post(
        Uri.parse('https://app.dizanpay.com/api/v1/payments.php'),
        headers: {
          'Authorization': 'Bearer pk_live_4c1c22b27d8b5e00da0b5af826a67eff67b97722874e5eb3',
          'Content-Type': 'application/json'
        },
        body: jsonEncode({...payload, 'method': method}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _dizanpayEntity = data['entity'] ?? '';
          _dizanpayReference = data['reference'] ?? '';
        });
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error creating payment: ${response.statusCode}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoadingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const borderColor = Color(0xFFE5E5EA);

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) {
          if (didPop) return;
          context.read<BillingBloc>().add(ClearCartEvent());
          context.go('/');
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Checkout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: 28, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.read<BillingBloc>().add(ClearCartEvent());
                context.go('/');
              },
            ),
          ),
          body: BlocConsumer<BillingBloc, BillingState>(
            listener: (context, state) {
              if (state.printSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Receipt handled successfully'), backgroundColor: Colors.green));
              }
              if (state.error != null && state.error!.isNotEmpty) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(state.error!), backgroundColor: Colors.red));
              }
            },
            builder: (context, billingState) {
              return BlocBuilder<ShopBloc, ShopState>(
                  builder: (context, shopState) {
                
                String shopName = 'Shop';
                String address1 = '';
                String address2 = '';
                String phone = '';
                String footer = '';

                if (shopState is ShopLoaded) {
                  shopName = shopState.shop.name;
                  address1 = shopState.shop.addressLine1;
                  address2 = shopState.shop.addressLine2;
                  phone = shopState.shop.phoneNumber;
                  footer = shopState.shop.footerText;
                }

                return Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Column(
                          children: [
                            // Table
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: borderColor),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  )
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Table(
                                  border: const TableBorder(
                                    horizontalInside: BorderSide(color: borderColor),
                                    bottom: BorderSide(color: borderColor),
                                  ),
                                  children: [
                                    TableRow(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF8FAFC),
                                        border: Border(bottom: BorderSide(color: borderColor)),
                                      ),
                                      children: [
                                        _buildHeaderCell('Product Name', TextAlign.left),
                                        _buildHeaderCell('Price', TextAlign.right),
                                        _buildHeaderCell('Total', TextAlign.right),
                                      ],
                                    ),
                                    ...billingState.cartItems.map((item) {
                                      return TableRow(
                                        children: [
                                          _buildDataCell('${item.quantity} x ${item.product.name}', TextAlign.left),
                                          _buildDataCell('₹${item.product.price.toStringAsFixed(2)}', TextAlign.right, isSubtitle: true),
                                          _buildDataCell('₹${item.total.toStringAsFixed(2)}', TextAlign.right, isBold: true),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Payment Options
                            if (billingState.paymentStatus != 'confirmed') ...[
                              const Text('Select Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildMethodButton('Express', Icons.phone_android),
                                  _buildMethodButton('Referência', Icons.numbers),
                                  _buildMethodButton('QR', Icons.qr_code),
                                  _buildMethodButton('Cash', Icons.money),
                                  _buildMethodButton('TPA', Icons.credit_card),
                                ],
                              ),
                              const SizedBox(height: 24),
                              
                              _buildPaymentDetails(billingState.totalAmount),
                            ] else ...[
                              const Icon(Icons.check_circle, color: Colors.green, size: 64),
                              const SizedBox(height: 16),
                              const Text('Payment Confirmed!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Stock reduced and transaction saved.', style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 24),
                              PrimaryButton(
                                onPressed: () {
                                  context.read<BillingBloc>().add(PrintReceiptEvent(
                                    shopName: shopName, address1: address1, address2: address2, phone: phone, footer: footer
                                  ));
                                },
                                label: 'Print Receipt',
                                icon: Icons.print,
                                isLoading: billingState.isPrinting,
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  context.read<BillingBloc>().add(SharePdfReceiptEvent(
                                    shopName: shopName, address1: address1, address2: address2, phone: phone, footer: footer
                                  ));
                                },
                                icon: const Icon(Icons.share),
                                label: const Text('Share Receipt as PDF'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  context.read<BillingBloc>().add(ClearCartEvent());
                                  context.go('/');
                                },
                                child: const Text('New Order'),
                              )
                            ],

                            const SizedBox(height: 120), 
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom Bar Total (Only if not confirmed)
                    if (billingState.paymentStatus != 'confirmed')
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4)),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('GRAND TOTAL', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.2)),
                          Text('₹${billingState.totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                    ),
                  ],
                );
              });
            },
          ),
        ));
  }

  Widget _buildMethodButton(String method, IconData icon) {
    final isSelected = _selectedMethod == method;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedMethod = method;
          context.read<BillingBloc>().add(SelectPaymentMethodEvent(method));
          _dizanpayEntity = '';
          _dizanpayReference = '';
          _phoneController.clear();
          _cashController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).primaryColor : Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            Text(method, style: TextStyle(
              color: isSelected ? Theme.of(context).primaryColor : Colors.grey[800],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetails(double totalAmount) {
    if (_selectedMethod.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedMethod == 'Express') ...[
            const Text('Enter Customer Phone Number'),
            const SizedBox(height: 8),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'e.g. 923000000'),
            ),
            const SizedBox(height: 12),
            if (_dizanpayEntity.isEmpty)
              PrimaryButton(
                onPressed: _isLoadingPayment ? null : () {
                  _createDizanpayPayment(totalAmount, 'EXP', _phoneController.text);
                },
                label: 'Send Payment Request',
                isLoading: _isLoadingPayment,
              )
            else
              _buildDizanpayStatus('Express request sent. Awaiting confirmation...'),
          ] else if (_selectedMethod == 'Referência') ...[
            if (_dizanpayEntity.isEmpty)
              PrimaryButton(
                onPressed: _isLoadingPayment ? null : () {
                  _createDizanpayPayment(totalAmount, 'REF', null);
                },
                label: 'Generate Reference',
                isLoading: _isLoadingPayment,
              )
            else
              _buildDizanpayStatus('Reference Generated'),
          ] else if (_selectedMethod == 'QR') ...[
            if (_dizanpayEntity.isEmpty)
              PrimaryButton(
                onPressed: _isLoadingPayment ? null : () {
                  _createDizanpayPayment(totalAmount, 'PIX', null); // Or QR if supported
                },
                label: 'Generate QR',
                isLoading: _isLoadingPayment,
              )
            else
              _buildDizanpayStatus('QR Generated (Use Entity & Ref for now)'),
          ] else if (_selectedMethod == 'Cash') ...[
             const Text('Amount Given by Customer'),
             const SizedBox(height: 8),
             TextField(
              controller: _cashController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '0.00'),
              onChanged: (val) => setState((){}),
            ),
            const SizedBox(height: 12),
            if (_cashController.text.isNotEmpty) ...[
              Builder(
                builder: (context) {
                  final given = double.tryParse(_cashController.text) ?? 0;
                  final change = given - totalAmount;
                  return Text('Change Needed: ₹${change.toStringAsFixed(2)}', 
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: change >= 0 ? Colors.green : Colors.red));
                }
              ),
              const SizedBox(height: 16),
            ],
            PrimaryButton(
              onPressed: () {
                 final given = double.tryParse(_cashController.text) ?? 0;
                 if (given < totalAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Amount given is less than total')));
                    return;
                 }
                 context.read<BillingBloc>().add(const ConfirmPaymentEvent());
              },
              label: 'Confirm Cash Payment',
            )
          ] else if (_selectedMethod == 'TPA') ...[
             const Text('Process payment on the TPA terminal.'),
             const SizedBox(height: 16),
             PrimaryButton(
              onPressed: () {
                 context.read<BillingBloc>().add(const ConfirmPaymentEvent());
              },
              label: 'Confirm TPA Payment',
            )
          ]
        ],
      ),
    );
  }

  Widget _buildDizanpayStatus(String title) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              children: [
                const Text('Entity', style: TextStyle(color: Colors.grey)),
                Text(_dizanpayEntity, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            Column(
              children: [
                const Text('Reference', style: TextStyle(color: Colors.grey)),
                Text(_dizanpayReference, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        PrimaryButton(
          onPressed: () {
            // Here you would ideally poll, but for manual confirmation:
            context.read<BillingBloc>().add(const ConfirmPaymentEvent());
          },
          label: 'Confirm Payment Received',
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text, TextAlign align) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(text.toUpperCase(), textAlign: align, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
    );
  }

  Widget _buildDataCell(String text, TextAlign align, {bool isBold = false, bool isSubtitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Text(text, textAlign: align, style: TextStyle(fontSize: isSubtitle ? 12 : 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: isSubtitle ? Colors.grey[500] : Colors.black87)),
    );
  }
}
