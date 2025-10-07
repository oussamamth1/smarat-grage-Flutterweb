import 'package:cloud_firestore/cloud_firestore.dart';

class Purchase {
  final String id;
  final String partId;
  final int quantity;
  final double totalPrice;
  final DateTime date;

  Purchase({
    required this.id,
    required this.partId,
    required this.quantity,
    required this.totalPrice,
    required this.date,
  });

  factory Purchase.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Purchase(
      id: doc.id,
      partId: data['partId'] ?? '',
      quantity: data['quantity'] ?? 0,
      totalPrice: (data['totalPrice'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'partId': partId,
    'quantity': quantity,
    'totalPrice': totalPrice,
    'date': Timestamp.fromDate(date),
  };
}
