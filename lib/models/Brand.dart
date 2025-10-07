import 'package:cloud_firestore/cloud_firestore.dart';

class Brand {
  final String id;
  final String name;
  final String? imageUrl;
  final String? description;
  final String? country; // Country of origin
  final String? website;
  final bool isActive; // Currently active brand
  final bool isPopular; // Featured/popular brand
  final int modelsCount; // Number of motorcycle models
  final DateTime createdAt;
  final DateTime updatedAt;

  Brand({
    required this.id,
    required this.name,
    this.imageUrl,
    this.description,
    this.country,
    this.website,
    this.isActive = true,
    this.isPopular = false,
    this.modelsCount = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Factory constructor from Firestore document
  factory Brand.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Brand(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      description: data['description'],
      country: data['country'],
      website: data['website'],
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
      modelsCount: (data['modelsCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Factory constructor from Map
  factory Brand.fromMap(Map<String, dynamic> data, String id) {
    return Brand(
      id: id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'],
      description: data['description'],
      country: data['country'],
      website: data['website'],
      isActive: data['isActive'] ?? true,
      isPopular: data['isPopular'] ?? false,
      modelsCount: (data['modelsCount'] ?? 0).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'description': description,
      'country': country,
      'website': website,
      'isActive': isActive,
      'isPopular': isPopular,
      'modelsCount': modelsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }

  // Computed properties
  String get displayName => name;

  String get statusLabel {
    if (!isActive) return 'Inactive';
    if (isPopular) return 'Popular';
    return 'Active';
  }

  bool get hasLogo => imageUrl != null && imageUrl!.isNotEmpty;

  String get modelsText {
    if (modelsCount == 0) return 'No models';
    if (modelsCount == 1) return '1 model';
    return '$modelsCount models';
  }

  // Country flag emoji (optional)
  String? get countryFlag {
    if (country == null) return null;

    final countryFlags = {
      'Japan': '🇯🇵',
      'Italy': '🇮🇹',
      'Germany': '🇩🇪',
      'USA': '🇺🇸',
      'UK': '🇬🇧',
      'India': '🇮🇳',
      'Austria': '🇦🇹',
      'Spain': '🇪🇸',
      'France': '🇫🇷',
      'China': '🇨🇳',
      'Korea': '🇰🇷',
      'Taiwan': '🇹🇼',
    };

    return countryFlags[country];
  }

  // CopyWith method for creating modified copies
  Brand copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? description,
    String? country,
    String? website,
    bool? isActive,
    bool? isPopular,
    int? modelsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Brand(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      country: country ?? this.country,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
      isPopular: isPopular ?? this.isPopular,
      modelsCount: modelsCount ?? this.modelsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Increment models count when new motorcycle is added
  Brand incrementModelsCount() {
    return copyWith(modelsCount: modelsCount + 1);
  }

  // Decrement models count when motorcycle is removed
  Brand decrementModelsCount() {
    return copyWith(modelsCount: modelsCount > 0 ? modelsCount - 1 : 0);
  }

  @override
  String toString() {
    return 'Brand(id: $id, name: $name, models: $modelsCount, status: $statusLabel)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Brand && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Popular motorcycle brands for reference
class PopularBrands {
  static const japanese = ['Yamaha', 'Honda', 'Suzuki', 'Kawasaki'];
  static const european = ['Ducati', 'BMW', 'KTM', 'Aprilia', 'Triumph'];
  static const american = ['Harley-Davidson', 'Indian'];
  static const indian = ['Royal Enfield', 'Bajaj', 'TVS', 'Hero'];

  static List<String> get all => [
    ...japanese,
    ...european,
    ...american,
    ...indian,
  ];
}
