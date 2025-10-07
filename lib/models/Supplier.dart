import 'package:cloud_firestore/cloud_firestore.dart';

class Supplier {
  final String id;
  final String name;
  final String? company; // Company name if different from contact name
  final String? phone;
  final String? email;
  final String? address;
  final String? city;
  final String? country;
  final String? taxId; // Tax identification number
  final String? notes; // Additional notes about supplier

  // Payment terms
  final int paymentTermDays; // e.g., 30 days, 60 days
  final String? bankAccount; // Bank account details

  // Performance tracking
  final double rating; // 0-5 star rating
  final int totalOrders; // Total purchase orders placed
  final double totalSpent; // Total amount spent with this supplier

  // Status
  final bool isActive; // Active or inactive supplier
  final bool isPreferred; // Mark as preferred supplier

  final DateTime createdAt;
  final DateTime updatedAt;

  Supplier({
    required this.id,
    required this.name,
    this.company,
    this.phone,
    this.email,
    this.address,
    this.city,
    this.country,
    this.taxId,
    this.notes,
    this.paymentTermDays = 30,
    this.bankAccount,
    this.rating = 0.0,
    this.totalOrders = 0,
    this.totalSpent = 0.0,
    this.isActive = true,
    this.isPreferred = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor from Firestore document
  factory Supplier.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Supplier(
      id: doc.id,
      name: data['name'] ?? '',
      company: data['company'],
      phone: data['phone'],
      email: data['email'],
      address: data['address'],
      city: data['city'],
      country: data['country'] ?? 'Tunisia',
      taxId: data['taxId'],
      notes: data['notes'],
      paymentTermDays: (data['paymentTermDays'] ?? 30).toInt(),
      bankAccount: data['bankAccount'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalOrders: (data['totalOrders'] ?? 0).toInt(),
      totalSpent: (data['totalSpent'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      isPreferred: data['isPreferred'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map
  factory Supplier.fromMap(Map<String, dynamic> data, String id) {
    return Supplier(
      id: id,
      name: data['name'] ?? '',
      company: data['company'],
      phone: data['phone'],
      email: data['email'],
      address: data['address'],
      city: data['city'],
      country: data['country'] ?? 'Tunisia',
      taxId: data['taxId'],
      notes: data['notes'],
      paymentTermDays: (data['paymentTermDays'] ?? 30).toInt(),
      bankAccount: data['bankAccount'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalOrders: (data['totalOrders'] ?? 0).toInt(),
      totalSpent: (data['totalSpent'] ?? 0.0).toDouble(),
      isActive: data['isActive'] ?? true,
      isPreferred: data['isPreferred'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'company': company,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'country': country,
      'taxId': taxId,
      'notes': notes,
      'paymentTermDays': paymentTermDays,
      'bankAccount': bankAccount,
      'rating': rating,
      'totalOrders': totalOrders,
      'totalSpent': totalSpent,
      'isActive': isActive,
      'isPreferred': isPreferred,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Computed properties
  String get displayName => company ?? name;

  String get fullAddress {
    List<String> parts = [];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);
    return parts.isEmpty ? 'No address' : parts.join(', ');
  }

  double get averageOrderValue =>
      totalOrders > 0 ? totalSpent / totalOrders : 0.0;

  String get ratingStars {
    int fullStars = rating.floor();
    return '⭐' * fullStars + (rating - fullStars >= 0.5 ? '½' : '');
  }

  String get statusLabel {
    if (!isActive) return 'Inactive';
    if (isPreferred) return 'Preferred';
    return 'Active';
  }

  bool get hasContact => phone != null || email != null;

  // CopyWith method
  Supplier copyWith({
    String? id,
    String? name,
    String? company,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? taxId,
    String? notes,
    int? paymentTermDays,
    String? bankAccount,
    double? rating,
    int? totalOrders,
    double? totalSpent,
    bool? isActive,
    bool? isPreferred,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Supplier(
      id: id ?? this.id,
      name: name ?? this.name,
      company: company ?? this.company,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      taxId: taxId ?? this.taxId,
      notes: notes ?? this.notes,
      paymentTermDays: paymentTermDays ?? this.paymentTermDays,
      bankAccount: bankAccount ?? this.bankAccount,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      totalSpent: totalSpent ?? this.totalSpent,
      isActive: isActive ?? this.isActive,
      isPreferred: isPreferred ?? this.isPreferred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Method to update performance metrics
  Supplier updatePerformance({required double orderAmount, double? newRating}) {
    return copyWith(
      totalOrders: totalOrders + 1,
      totalSpent: totalSpent + orderAmount,
      rating: newRating ?? rating,
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, name: $displayName, status: $statusLabel, rating: ${rating.toStringAsFixed(1)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for supplier status filter
enum SupplierStatus { all, active, inactive, preferred }

extension SupplierStatusExtension on SupplierStatus {
  String get displayName {
    switch (this) {
      case SupplierStatus.all:
        return 'All Suppliers';
      case SupplierStatus.active:
        return 'Active';
      case SupplierStatus.inactive:
        return 'Inactive';
      case SupplierStatus.preferred:
        return 'Preferred';
    }
  }
}
