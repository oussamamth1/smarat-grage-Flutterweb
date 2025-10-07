import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String id;
  final String email;
  final String role; // 'admin' or 'employee'

  AppUser({required this.id, required this.email, required this.role});

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      id: doc.id,
      email: data['email'] ?? '',
      role: data['role'] ?? 'employee',
    );
  }

  Map<String, dynamic> toMap() => {'email': email, 'role': role};

  bool get isAdmin => role == 'admin';
}
