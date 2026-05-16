import 'package:flutter/material.dart';
import '../../domain/entities/marketplace_product.dart';
import '../../domain/entities/marketplace_order.dart';

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  final List<MarketplaceProduct> _dummyProducts = [
    MarketplaceProduct(
      id: '1',
      name: 'Coca Cola 1L (Pack of 12)',
      description: 'Wholesale pack of Coca Cola 1L bottles.',
      price: 6000,
      stockQuantity: 100,
      category: 'Beverages',
      createdAt: DateTime.now(),
    ),
    MarketplaceProduct(
      id: '2',
      name: 'Rice 25kg Sack',
      description: 'Premium long grain white rice.',
      price: 15000,
      stockQuantity: 50,
      category: 'Groceries',
      createdAt: DateTime.now(),
    ),
    MarketplaceProduct(
      id: '3',
      name: 'Sunflower Oil 5L',
      description: 'Pure cooking oil.',
      price: 8500,
      stockQuantity: 80,
      category: 'Groceries',
      createdAt: DateTime.now(),
    ),
    MarketplaceProduct(
      id: '4',
      name: 'Sugar 5kg',
      description: 'Refined white sugar.',
      price: 4500,
      stockQuantity: 120,
      category: 'Groceries',
      createdAt: DateTime.now(),
    ),
    MarketplaceProduct(
      id: '5',
      name: 'Pasta 500g (Pack of 20)',
      description: 'Spaghetti pasta in a carton.',
      price: 12000,
      stockQuantity: 40,
      category: 'Groceries',
      createdAt: DateTime.now(),
    ),
  ];

  final List<MarketplaceCartItem> _cart = [];

  void _addToCart(MarketplaceProduct product) {
    final existingItemIndex =
        _cart.indexWhere((item) => item.productId == product.id);

    setState(() {
      if (existingItemIndex >= 0) {
        _cart[existingItemIndex].quantity += 1;
      } else {
        _cart.add(MarketplaceCartItem(
          productId: product.id,
          productName: product.name,
          quantity: 1,
          unitPrice: product.price,
        ));
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} adicionado ao carrinho.'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setModalState) {
          final double totalAmount = _cart.fold(0, (sum, item) => sum + item.totalPrice);

          return Container(
            padding: const EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const Text(
                  'Carrinho de Pedidos',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _cart.isEmpty
                      ? const Center(child: Text('Seu carrinho está vazio'))
                      : ListView.builder(
                          itemCount: _cart.length,
                          itemBuilder: (context, index) {
                            final item = _cart[index];
                            return ListTile(
                              title: Text(item.productName),
                              subtitle: Text('Kz ${item.unitPrice.toStringAsFixed(2)} x ${item.quantity}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () {
                                      setModalState(() {
                                        setState(() {
                                          if (item.quantity > 1) {
                                            item.quantity--;
                                          } else {
                                            _cart.removeAt(index);
                                          }
                                        });
                                      });
                                    },
                                  ),
                                  Text(
                                    'Kz ${item.totalPrice.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
                if (_cart.isNotEmpty) ...[
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Kz ${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        // Place order
                        setState(() {
                          _cart.clear();
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Pedido realizado com sucesso! Vamos processá-lo em breve.'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      child: const Text('Colocar Pedido'),
                    ),
                  ),
                ],
              ],
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalCartItems = _cart.fold(0, (sum, item) => sum + item.quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Encomendar Estoque'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: _openCart,
              ),
              if (totalCartItems > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$totalCartItems',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _dummyProducts.length,
        itemBuilder: (context, index) {
          final product = _dummyProducts[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(product.description),
                  const SizedBox(height: 8),
                  Text(
                    'Kz ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text('Em estoque: ${product.stockQuantity}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () => _addToCart(product),
                child: const Text('Adicionar'),
              ),
            ),
          );
        },
      ),
    );
  }
}
