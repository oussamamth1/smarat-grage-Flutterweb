import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgarage/models/bik_parts.dart';

class PartsRepository {
  final _db = FirebaseFirestore.instance;

  /// 🔹 Stream all parts in real-time
  Stream<List<BikePart>> streamParts({String? categoryId}) {
    Query query = _db.collection('bike_parts').orderBy('name');

    // If a category filter is applied
    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('category', isEqualTo: categoryId);
    }

    return query.snapshots().map(
      (snap) => snap.docs.map((d) => BikePart.fromDoc(d)).toList(),
    );
  }

  /// 🔹 Get all parts one-time
  Future<List<BikePart>> getAllParts({String? categoryId}) async {
    Query query = _db.collection('bike_parts').orderBy('name');

    if (categoryId != null && categoryId.isNotEmpty) {
      query = query.where('category', isEqualTo: categoryId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((d) => BikePart.fromDoc(d)).toList();
  }

  /// 🔹 Add a new part
  Future<void> addPart(BikePart part) async {
    final doc = _db.collection('bike_parts').doc();
    await doc.set({
      ...part.toMap(),
      'id': doc.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// 🔹 Update an existing part
  Future<void> updatePart(String id, Map<String, dynamic> data) async {
    await _db.collection('bike_parts').doc(id).update(data);
  }

  /// 🔹 Update stock quantity
  Future<void> updateStock(String id, int newStock) {
    return _db.collection('bike_parts').doc(id).update({'stock': newStock});
  }

  /// 🔹 Update image URL for a part
  Future<void> updatePartImageUrl(String id, String imageUrl) {
    return _db.collection('bike_parts').doc(id).update({'imageUrl': imageUrl});
  }

  /// 🔹 Delete a part
  Future<void> deletePart(String id) async {
    await _db.collection('bike_parts').doc(id).delete();
  }
}
