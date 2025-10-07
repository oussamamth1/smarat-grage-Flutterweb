import 'package:cloud_firestore/cloud_firestore.dart';

class Moto {
  final String id;
  final String name; // Model name (e.g., "YZF-R15", "CBR150R")
  final String brandId; // Reference to Brand
  final int year; // Model year (e.g., 2024)
  final int? engineCapacity; // CC (e.g., 155, 250, 600)
  final String? engineType; // e.g., "Single Cylinder", "Parallel Twin"
  final String? fuelType; // e.g., "Petrol", "Electric"
  final String? imageUrl; // Model image
  final String? description; // Additional details

  // Technical specs (optional)
  final double? weight; // kg
  final int? maxPower; // HP
  final int? maxTorque; // Nm
  final String? transmission; // e.g., "6-speed manual"

  // Categorization
  final String? category; // e.g., "Sport", "Cruiser", "Scooter", "Touring"

  // Status
  final bool isActive; // Currently in production/supported
  final bool isPopular; // Mark popular models

  // Stats
  final int partsCount; // Number of compatible parts

  final DateTime createdAt;
  final DateTime updatedAt;

  Moto({
    required this.id,
    required this.name,
    required this.brandId,
    required this.year,
    this.engineCapacity,
    this.engineType,
    this.fuelType,
    this.imageUrl,
    this.description,
    this.weight,
    this.maxPower,
    this.maxTorque,
    this.transmission,
    this.category,
    this.isActive = true,
    this.isPopular = false,
    this.partsCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor from Firestore document
  factory Moto.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Moto(
      id: doc.id,
      name: data['name'] ?? '',
      brandId: data['brandId'] ?? '',
      year: (data['year'] ?? DateTime.now().year).toInt(),
      engineCapacity: data['engineCapacity'] != null
          ? (data['engineCapacity'] as num).toInt()
          : null,
      engineType: data['engineType'],
      fuelType: data['fuelType'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      weight: data['weight'] != null
          ? (data['weight'] as num).toDouble()
          : null,
      maxPower: data['maxPower'] != null
          ? (data['maxPower'] as num).toInt()
          : null,
      maxTorque: data['maxTorque'] != null
          ? (data['maxTorque'] as num).toInt()
          : null,
      transmission: data['transmission'],
      category: data['category'],
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
      partsCount: (data['partsCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map
  factory Moto.fromMap(Map<String, dynamic> data, String id) {
    return Moto(
      id: id,
      name: data['name'] ?? '',
      brandId: data['brandId'] ?? '',
      year: (data['year'] ?? DateTime.now().year).toInt(),
      engineCapacity: data['engineCapacity'] != null
          ? (data['engineCapacity'] as num).toInt()
          : null,
      engineType: data['engineType'],
      fuelType: data['fuelType'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      weight: data['weight'] != null
          ? (data['weight'] as num).toDouble()
          : null,
      maxPower: data['maxPower'] != null
          ? (data['maxPower'] as num).toInt()
          : null,
      maxTorque: data['maxTorque'] != null
          ? (data['maxTorque'] as num).toInt()
          : null,
      transmission: data['transmission'],
      category: data['category'],
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
      partsCount: (data['partsCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'brandId': brandId,
      'year': year,
      'engineCapacity': engineCapacity,
      'engineType': engineType,
      'fuelType': fuelType,
      'imageUrl': imageUrl,
      'description': description,
      'weight': weight,
      'maxPower': maxPower,
      'maxTorque': maxTorque,
      'transmission': transmission,
      'category': category,
      'isActive': isActive,
      'isPopular': isPopular,
      'partsCount': partsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Computed properties
  String get displayName {
    if (engineCapacity != null) {
      return '$name ($engineCapacity cc)';
    }
    return name;
  }

  String get fullName {
    // Will be combined with brand name in UI: "Yamaha YZF-R15"
    return '$name ${year > 0 ? "($year)" : ""}';
  }

  String get engineInfo {
    List<String> info = [];
    if (engineCapacity != null) info.add('${engineCapacity}cc');
    if (engineType != null) info.add(engineType!);
    if (fuelType != null) info.add(fuelType!);
    return info.isEmpty ? 'N/A' : info.join(' • ');
  }

  String get powerInfo {
    List<String> info = [];
    if (maxPower != null) info.add('${maxPower}HP');
    if (maxTorque != null) info.add('${maxTorque}Nm');
    return info.isEmpty ? 'N/A' : info.join(' / ');
  }

  String get categoryIcon {
    switch (category?.toLowerCase()) {
      case 'sport':
        return '🏍️';
      case 'cruiser':
        return '🛵';
      case 'scooter':
        return '🛴';
      case 'touring':
        return '🚵';
      case 'adventure':
        return '⛰️';
      case 'naked':
        return '🏁';
      default:
        return '🏍️';
    }
  }

  bool get hasSpecs =>
      engineCapacity != null || maxPower != null || maxTorque != null;

  String get statusLabel {
    if (!isActive) return 'Discontinued';
    if (isPopular) return 'Popular';
    return 'Active';
  }

  // CopyWith method
  Moto copyWith({
    String? id,
    String? name,
    String? brandId,
    int? year,
    int? engineCapacity,
    String? engineType,
    String? fuelType,
    String? imageUrl,
    String? description,
    double? weight,
    int? maxPower,
    int? maxTorque,
    String? transmission,
    String? category,
    bool? isActive,
    bool? isPopular,
    int? partsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Moto(
      id: id ?? this.id,
      name: name ?? this.name,
      brandId: brandId ?? this.brandId,
      year: year ?? this.year,
      engineCapacity: engineCapacity ?? this.engineCapacity,
      engineType: engineType ?? this.engineType,
      fuelType: fuelType ?? this.fuelType,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      weight: weight ?? this.weight,
      maxPower: maxPower ?? this.maxPower,
      maxTorque: maxTorque ?? this.maxTorque,
      transmission: transmission ?? this.transmission,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      partsCount: partsCount ?? this.partsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Increment parts count when new part is added
  Moto incrementPartsCount() {
    return copyWith(partsCount: partsCount + 1);
  }

  // Decrement parts count when part is removed
  Moto decrementPartsCount() {
    return copyWith(partsCount: partsCount > 0 ? partsCount - 1 : 0);
  }

  @override
  String toString() {
    return 'Moto(id: $id, name: $displayName, year: $year, status: $statusLabel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Moto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Enum for motorcycle categories
enum MotoCategory {
  sport,
  cruiser,
  scooter,
  touring,
  adventure,
  naked,
  dirtBike,
  electric,
  other,
}

extension MotoCategoryExtension on MotoCategory {
  String get displayName {
    switch (this) {
      case MotoCategory.sport:
        return 'Sport';
      case MotoCategory.cruiser:
        return 'Cruiser';
      case MotoCategory.scooter:
        return 'Scooter';
      case MotoCategory.touring:
        return 'Touring';
      case MotoCategory.adventure:
        return 'Adventure';
      case MotoCategory.naked:
        return 'Naked/Street';
      case MotoCategory.dirtBike:
        return 'Dirt Bike';
      case MotoCategory.electric:
        return 'Electric';
      case MotoCategory.other:
        return 'Other';
    }
  }

  String get icon {
    switch (this) {
      case MotoCategory.sport:
        return '🏍️';
      case MotoCategory.cruiser:
        return '🛵';
      case MotoCategory.scooter:
        return '🛴';
      case MotoCategory.touring:
        return '🚵';
      case MotoCategory.adventure:
        return '⛰️';
      case MotoCategory.naked:
        return '🏁';
      case MotoCategory.dirtBike:
        return '🏜️';
      case MotoCategory.electric:
        return '⚡';
      case MotoCategory.other:
        return '🏍️';
    }
  }
}
