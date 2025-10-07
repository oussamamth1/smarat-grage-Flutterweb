import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import 'package:smartgarage/models/OrderItem.dart';
import 'package:smartgarage/models/bik_parts.dart';
import 'package:smartgarage/models/client.dart';
import 'package:smartgarage/models/order.dart';

import 'package:smartgarage/services/parts_repository.dart';
import 'package:intl/intl.dart';

class ClientCartScreen extends StatefulWidget {
  final Client client;

  const ClientCartScreen({super.key, required this.client});

  @override
  State<ClientCartScreen> createState() => _ClientCartScreenState();
}

class _ClientCartScreenState extends State<ClientCartScreen> {
  final PartsRepository partsRepo = PartsRepository();
  late List<CartItem> localCart;
  bool _isProcessingOrder = false;

  @override
  void initState() {
    super.initState();
    // Create a local copy of the client's cart
    localCart = List.from(widget.client.cart);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cart - ${widget.client.name}')),
      body: Column(
        children: [
          // Client Details Card
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${widget.client.name}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${widget.client.email.isNotEmpty ? widget.client.email : 'N/A'}',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Created At: ${DateFormat.yMMMd().add_jm().format(widget.client.createdAt)}',
                  ),
                  const SizedBox(height: 8),
                  Text('Cart Items: ${localCart.length}'),
                ],
              ),
            ),
          ),
          const Divider(),
          // Cart Items List
          Expanded(
            child: StreamBuilder<List<BikePart>>(
              stream: partsRepo.streamParts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final parts = snapshot.data!;
                // Only display parts that are in the cart
                final cartParts = parts
                    .where((p) => localCart.any((c) => c.partId == p.id))
                    .toList();

                if (cartParts.isEmpty)
                  return const Center(child: Text('Cart is empty'));

                // Calculate total
                double totalAmount = 0;
                for (final part in cartParts) {
                  final cartItem = localCart.firstWhere(
                    (c) => c.partId == part.id,
                  );
                  totalAmount += (part.salePrice * cartItem.quantity);
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartParts.length,
                        itemBuilder: (context, index) {
                          final part = cartParts[index];

                          // Find CartItem for this part
                          final cartItem = localCart.firstWhere(
                            (c) => c.partId == part.id,
                          );

                          final subtotal = part.salePrice * cartItem.quantity;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            child: ListTile(
                              title: Text('${part.name} (${part.ref})'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Stock: ${part.stock}'),
                                  Text(
                                    'Price: \$${part.salePrice.toStringAsFixed(2)}',
                                  ),
                                  Text(
                                    'Subtotal: \$${subtotal.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: cartItem.quantity > 0
                                        ? () => _updateCart(
                                            part.id,
                                            cartItem.quantity - 1,
                                          )
                                        : null,
                                  ),
                                  Text(
                                    cartItem.quantity.toString(),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: cartItem.quantity < part.stock
                                        ? () => _updateCart(
                                            part.id,
                                            cartItem.quantity + 1,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    // Total and Checkout Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '\$${totalAmount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _isProcessingOrder
                                  ? null
                                  : () => _createOrder(parts, totalAmount),
                              icon: _isProcessingOrder
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(Icons.shopping_cart_checkout),
                              label: Text(
                                _isProcessingOrder
                                    ? 'Processing...'
                                    : 'Create Order',
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _updateCart(String partId, int quantity) async {
    final clientDoc = FirebaseFirestore.instance
        .collection('clients')
        .doc(widget.client.id);

    // Clone current cart
    List<CartItem> updatedCart = List.from(localCart);

    final index = updatedCart.indexWhere((c) => c.partId == partId);
    if (index >= 0) {
      if (quantity <= 0) {
        updatedCart.removeAt(index);
      } else {
        updatedCart[index] = CartItem(partId: partId, quantity: quantity);
      }
    } else if (quantity > 0) {
      updatedCart.add(CartItem(partId: partId, quantity: quantity));
    }

    // Save to Firestore
    await clientDoc.update({
      'cart': updatedCart.map((c) => c.toMap()).toList(),
    });

    // Update local state
    setState(() {
      localCart = updatedCart;
    });
  }

  Future<void> _createOrder(List<BikePart> allParts, double totalAmount) async {
    if (localCart.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cart is empty')));
      return;
    }

    setState(() {
      _isProcessingOrder = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      // Generate order number
      final orderNumber = await _generateOrderNumber();

      // Create Order document
      final orderRef = firestore.collection('orders').doc();
      final order = Order(
        id: orderRef.id,
        orderNumber: orderNumber,
        userId: widget.client.id, // Replace with actual user ID from auth
        customerName: widget.client.name,
        customerPhone: widget.client.email, // Or add phone field to Client
        status: OrderStatus.pending,
        totalAmount: totalAmount,
        createdAt: DateTime.now(),
      );

      batch.set(orderRef, order.toMap());

      // Create OrderItem documents and update stock
      for (final cartItem in localCart) {
        final part = allParts.firstWhere((p) => p.id == cartItem.partId);

        // Check if enough stock
        if (part.stock < cartItem.quantity) {
          throw Exception('Not enough stock for ${part.name}');
        }

        // Create order item
        final orderItemRef = firestore.collection('order_items').doc();
        final orderItem = OrderItem(
          id: orderItemRef.id,
          orderId: orderRef.id,
          partId: part.id,
          partName: part.name,
          quantity: cartItem.quantity,
          unitPrice: part.salePrice,
          subtotal: part.salePrice * cartItem.quantity,
        );

        batch.set(orderItemRef, orderItem.toMap());

        // Update part stock
        final partRef = firestore.collection('bike_parts').doc(part.id);
        batch.update(partRef, {
          'stock': FieldValue.increment(-cartItem.quantity),
        });
      }

      // Clear client cart
      final clientRef = firestore.collection('clients').doc(widget.client.id);
      batch.update(clientRef, {'cart': []});

      // Commit batch
      await batch.commit();

      setState(() {
        localCart = [];
        _isProcessingOrder = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order $orderNumber created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isProcessingOrder = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String> _generateOrderNumber() async {
    final now = DateTime.now();
    final year = now.year;

    // Get count of orders for this year
    final ordersQuery = await FirebaseFirestore.instance
        .collection('orders')
        .where('orderNumber', isGreaterThanOrEqualTo: 'ORD-$year-')
        .where('orderNumber', isLessThan: 'ORD-${year + 1}-')
        .get();

    final count = ordersQuery.docs.length + 1;
    return 'ORD-$year-${count.toString().padLeft(3, '0')}';
  }
}
