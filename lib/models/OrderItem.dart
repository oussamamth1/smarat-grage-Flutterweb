import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String id;
  final String orderId; // references Order.id
  final String partId; // references BikePart.id
  final String partName; // snapshot of part name
  final int quantity;
  final double unitPrice; // price at sale time
  final double subtotal; // quantity × unitPrice

  OrderItem({
    required this.id,
    required this.orderId,
    required this.partId,
    required this.partName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItem.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderItem(
      id: doc.id,
      orderId: data['orderId'] ?? '',
      partId: data['partId'] ?? '',
      partName: data['partName'] ?? '',
      quantity: data['quantity'] ?? 0,
      unitPrice: (data['unitPrice'] ?? 0).toDouble(),
      subtotal: (data['subtotal'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'partId': partId,
      'partName': partName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'subtotal': subtotal,
    };
  }
}
