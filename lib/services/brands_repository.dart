import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgarage/models/brand.dart';

/// Repository class for managing Firestore 'brands' collection.
class BrandsRepository {
  final FirebaseFirestore _db;

  BrandsRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  /// 🔁 Stream all brands (real-time updates)
  Stream<List<Brand>> streamBrands() {
    return _db
        .collection('brands')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map((d) => Brand.fromDoc(d)).toList());
  }

  /// ➕ Add a new brand
  Future<void> addBrand(Brand brand) async {
    await _db.collection('brands').add(brand.toMap());
  }

  /// ✏️ Update a brand by ID
  Future<void> updateBrand(String id, Map<String, dynamic> data) async {
    await _db.collection('brands').doc(id).update(data);
  }

  /// ❌ Delete a brand by ID
  Future<void> deleteBrand(String id) async {
    await _db.collection('brands').doc(id).delete();
  }

  /// 📋 Fetch all brands once (non-stream)
  Future<List<Brand>> getAllBrands() async {
    final snapshot = await _db.collection('brands').orderBy('name').get();
    return snapshot.docs.map((d) => Brand.fromDoc(d)).toList();
  }

  /// 🔍 Get a single brand by ID
  Future<Brand?> getBrandById(String id) async {
    final doc = await _db.collection('brands').doc(id).get();
    if (!doc.exists) return null;
    return Brand.fromDoc(doc);
  }
}
