import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';

class CategoryRepository {
  final _ref = FirebaseFirestore.instance.collection('categories');

  Stream<List<Category>> streamCategories() {
    return _ref.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => Category.fromDoc(doc)).toList(),
    );
  }

  Future<void> addCategory(Category category) async {
    await _ref.add(category.toMap());
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    await _ref.doc(id).update(data);
  }

  Future<void> deleteCategory(String id) async {
    await _ref.doc(id).delete();
  }
}
