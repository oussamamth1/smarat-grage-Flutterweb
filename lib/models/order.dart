import 'package:cloud_firestore/cloud_firestore.dart';

enum OrderStatus { pending, completed, cancelled, returned }

class Order {
  final String id;
  final String orderNumber; // e.g., "ORD-2025-001"
  final String userId; // who created the order
  final String? customerName;
  final String? customerPhone;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime? completedAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.userId,
    this.customerName,
    this.customerPhone,
    this.status = OrderStatus.pending,
    required this.totalAmount,
    required this.createdAt,
    this.completedAt,
  });

  factory Order.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Order(
      id: doc.id,
      orderNumber: data['orderNumber'] ?? '',
      userId: data['userId'] ?? '',
      customerName: data['customerName'],
      customerPhone: data['customerPhone'],
      status: _statusFromString(data['status']),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'orderNumber': orderNumber,
      'userId': userId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'status': status.name,
      'totalAmount': totalAmount,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
    };
  }

  static OrderStatus _statusFromString(String? value) {
    switch (value) {
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'returned':
        return OrderStatus.returned;
      case 'pending':
      default:
        return OrderStatus.pending;
    }
  }
}
// orders/
//   └── orderId123
//         orderNumber: "ORD-2025-001"
//         userId: "user_abc"
//         customerName: "Oussama"
//         totalAmount: 150.0
//         status: "pending"
//         createdAt: <timestamp>
//         completedAt: <timestamp?>

// order_items/
//   └── itemId456
//         orderId: "orderId123"
//         partId: "partId789"
//         partName: "Brake Pad"
//         quantity: 2
//         unitPrice: 75.0
//         subtotal: 150.0
