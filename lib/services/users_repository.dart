import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgarage/models/AppUser.dart';


class UsersRepository {
  final _db = FirebaseFirestore.instance;

  /// Stream users (for admin dashboard)
  Stream<List<AppUser>> streamUsers() {
    return _db
        .collection('users')
        .snapshots()
        .map((snap) => snap.docs.map((d) => AppUser.fromDoc(d)).toList());
  }

  /// Fetch user by UID
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromDoc(doc);
  }

  /// Add user after auth registration
  Future<void> addUser(AppUser user) async {
    await _db.collection('users').doc(user.id).set(user.toMap());
  }

  /// Update user info (role, name, etc.)
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  /// Delete user document (not from Auth)
  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  /// Check admin privileges
  Future<bool> isAdmin(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return false;
    final data = doc.data()!;
    return data['role'] == 'admin' || data['isAdmin'] == true;
  }
}
