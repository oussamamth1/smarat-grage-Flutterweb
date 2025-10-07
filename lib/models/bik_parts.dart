import 'package:cloud_firestore/cloud_firestore.dart';

class BikePart {
  final String id;
  final String ref; // Unique reference/SKU
  final String name;
  final String categoryId; // → references Category.id
  final String? imageUrl;
  final double purchasePrice;
  final double salePrice;
  final int stock;
  final int minThreshold;

  // Relationships
  final String? brandId; // → Brand.id
  final String? modelId; // → MotoModel.id
  final String? supplierId; // → Supplier.id

  // Metadata
  final String? location; // Shelf, aisle, or warehouse bin
  final String? description;
  final String? barcode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  BikePart({
    required this.id,
    required this.ref,
    required this.name,
    required this.categoryId,
    this.imageUrl,
    required this.purchasePrice,
    required this.salePrice,
    required this.stock,
    required this.minThreshold,
    this.brandId,
    this.modelId,
    this.supplierId,
    this.location,
    this.description,
    this.barcode,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // --- 🧩 Firestore Factories ---

  factory BikePart.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BikePart.fromMap(data, doc.id);
  }

  factory BikePart.fromMap(Map<String, dynamic> data, String id) {
    return BikePart(
      id: id,
      ref: data['ref'] ?? '',
      name: data['name'] ?? '',
      categoryId: data['categoryId'] ?? '',
      imageUrl: data['imageUrl'],
      purchasePrice: (data['purchasePrice'] ?? 0).toDouble(),
      salePrice: (data['salePrice'] ?? 0).toDouble(),
      stock: (data['stock'] ?? 0).toInt(),
      minThreshold: (data['minThreshold'] ?? 5).toInt(),
      brandId: data['brandId'],
      modelId: data['modelId'],
      supplierId: data['supplierId'],
      location: data['location'],
      description: data['description'],
      barcode: data['barcode'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // --- 🔁 Conversion to Firestore ---
  Map<String, dynamic> toMap() {
    return {
      'ref': ref,
      'name': name,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'purchasePrice': purchasePrice,
      'salePrice': salePrice,
      'stock': stock,
      'minThreshold': minThreshold,
      'brandId': brandId,
      'modelId': modelId,
      'supplierId': supplierId,
      'location': location,
      'description': description,
      'barcode': barcode,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // --- 📊 Helpers ---
  double get profitMargin => salePrice - purchasePrice;

  double get profitMarginPercentage => purchasePrice > 0
      ? ((salePrice - purchasePrice) / purchasePrice) * 100
      : 0;

  bool get isLowStock => stock <= minThreshold;
  bool get isOutOfStock => stock <= 0;

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  // --- 🧱 Copy Helper ---
  BikePart copyWith({
    String? id,
    String? ref,
    String? name,
    String? categoryId,
    String? imageUrl,
    double? purchasePrice,
    double? salePrice,
    int? stock,
    int? minThreshold,
    String? brandId,
    String? modelId,
    String? supplierId,
    String? location,
    String? description,
    String? barcode,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BikePart(
      id: id ?? this.id,
      ref: ref ?? this.ref,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      minThreshold: minThreshold ?? this.minThreshold,
      brandId: brandId ?? this.brandId,
      modelId: modelId ?? this.modelId,
      supplierId: supplierId ?? this.supplierId,
      location: location ?? this.location,
      description: description ?? this.description,
      barcode: barcode ?? this.barcode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // --- 🧾 Debug ---
  @override
  String toString() =>
      'BikePart(id: $id, ref: $ref, name: $name, stock: $stock, status: $stockStatus)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is BikePart && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
