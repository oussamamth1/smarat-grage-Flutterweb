import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final List<CartItem> cart;

  Client({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.cart,
  });

  factory Client.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Client(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      cart: (data['cart'] as List<dynamic>? ?? [])
          .map((e) => CartItem.fromMap(e))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'createdAt': Timestamp.fromDate(createdAt),
      'cart': cart.map((e) => e.toMap()).toList(),
    };
  }
}

class CartItem {
  final String partId;
  final int quantity;
  final DateTime addedAt;

  CartItem({required this.partId, required this.quantity, DateTime? addedAt})
    : addedAt = addedAt ?? DateTime.now();

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      partId: map['partId'] ?? '',
      quantity: map['quantity'] ?? 0,
      addedAt: (map['addedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partId': partId,
      'quantity': quantity,
      'addedAt': Timestamp.fromDate(addedAt),
    };
  }
}
