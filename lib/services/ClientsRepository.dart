import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';

class ClientsRepository {
  final _db = FirebaseFirestore.instance;

  Future<void> createClient(String name, {String? email}) async {
    await _db.collection('clients').add({
      'name': name,
      'email': email ?? '',
      'cart': [],
      'createdAt': Timestamp.now(),
    });
  }
  Stream<List<Client>> streamClients() {
    return _db
        .collection('clients')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Client.fromDoc(d)).toList());
  }
  Stream<Client> getClient(String clientId) {
    return _db
        .collection('clients')
        .doc(clientId)
        .snapshots()
        .map((doc) => Client.fromDoc(doc));
  }

  Future<void> addToCart(String clientId, CartItem item) async {
    final clientRef = _db.collection('clients').doc(clientId);

    await clientRef.update({
      'cart': FieldValue.arrayUnion([item.toMap()]),
    });
  }

  Future<void> removeFromCart(String clientId, CartItem item) async {
    final clientRef = _db.collection('clients').doc(clientId);

    await clientRef.update({
      'cart': FieldValue.arrayRemove([item.toMap()]),
    });
  }
}
