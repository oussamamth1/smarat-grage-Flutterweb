import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType {
  stockIn, // Receiving from supplier
  stockOut, // Sold to customer
  adjustment, // Manual correction
  returnItem, // Customer return
  damage, // Damaged/lost items
}

class StockTransaction {
  final String id;
  final String partId; // → references BikePart.id
  final String userId; // → references AppUser.id
  final TransactionType type; // IN, OUT, ADJUSTMENT
  final int quantity; // +10 or -5
  final int stockBefore; // Stock before transaction
  final int stockAfter; // Stock after transaction
  final String? reason; // "Purchase", "Sale", "Damage"
  final String? orderId; // → references Order.id (if sale)
  final DateTime createdAt;

  StockTransaction({
    required this.id,
    required this.partId,
    required this.userId,
    required this.type,
    required this.quantity,
    required this.stockBefore,
    required this.stockAfter,
    this.reason,
    this.orderId,
    required this.createdAt,
  });

  factory StockTransaction.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return StockTransaction(
      id: doc.id,
      partId: data['partId'] ?? '',
      userId: data['userId'] ?? '',
      type: _typeFromString(data['type']),
      quantity: data['quantity'] ?? 0,
      stockBefore: data['stockBefore'] ?? 0,
      stockAfter: data['stockAfter'] ?? 0,
      reason: data['reason'],
      orderId: data['orderId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'partId': partId,
      'userId': userId,
      'type': type.name,
      'quantity': quantity,
      'stockBefore': stockBefore,
      'stockAfter': stockAfter,
      'reason': reason,
      'orderId': orderId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static TransactionType _typeFromString(String? value) {
    switch (value) {
      case 'stockIn':
        return TransactionType.stockIn;
      case 'stockOut':
        return TransactionType.stockOut;
      case 'adjustment':
        return TransactionType.adjustment;
      case 'returnItem':
      case 'return':
        return TransactionType.returnItem;
      case 'damage':
        return TransactionType.damage;
      default:
        return TransactionType.adjustment;
    }
  }
}
// stock_transactions/
//   └── trans_001
//         partId: "brake_pad_123"
//         userId: "admin_001"
//         type: "stockOut"
//         quantity: 2
//         stockBefore: 15
//         stockAfter: 13
//         reason: "Customer Sale"
//         orderId: "order_045"
//         createdAt: <timestamp>