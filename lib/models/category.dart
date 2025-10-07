import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name; // e.g., "Engine", "Brakes"
  final String? icon; // Optional UI icon (can be Material icon name)
  final String? description; // Optional short text about the category
  final int partsCount; // Number of parts in this category
  final bool isActive; // For filtering visible/hidden categories

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.description,
    this.partsCount = 0,
    this.isActive = true,
  });

  /// Factory: create Category from Firestore document
  factory Category.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      name: data['name'] ?? '',
      icon: data['icon'],
      description: data['description'],
      partsCount: data['partsCount'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  /// Convert Category to Firestore map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon,
      'description': description,
      'partsCount': partsCount,
      'isActive': isActive,
    };
  }

  /// Create a copy with updated fields (useful for updating count or name)
  Category copyWith({
    String? id,
    String? name,
    String? icon,
    String? description,
    int? partsCount,
    bool? isActive,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      description: description ?? this.description,
      partsCount: partsCount ?? this.partsCount,
      isActive: isActive ?? this.isActive,
    );
  }
}
// categories/
//   ├── engine
//   │     name: "Engine"
//   │     icon: "build"
//   │     description: "Engine components and accessories"
//   │     partsCount: 12
//   │     isActive: true
//   ├── brakes
//   │     name: "Brakes"
//   │     icon: "stop_circle"
//   │     description: "Brake discs, pads, and fluids"
//   │     partsCount: 8
//   │     isActive: true