import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgarage/models/brand.dart';

import 'package:smartgarage/screens/brands_list_screen.dart' show brandsRepositoryProvider;
import 'package:smartgarage/services/brands_repository.dart';

/// 🧠 Notifier for performing Brand CRUD actions
class BrandNotifier extends AsyncNotifier<void> {
  late final BrandsRepository _repo;

  @override
  FutureOr<void> build() {
    _repo = ref.read(brandsRepositoryProvider);
  }

  /// ➕ Add new brand
  Future<void> addBrand(Brand brand) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.addBrand(brand));
  }

  /// ✏️ Update brand by ID
  Future<void> updateBrand(String id, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.updateBrand(id, data));
  }

  /// ❌ Delete brand by ID
  Future<void> deleteBrand(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.deleteBrand(id));
  }
}

/// 🧩 Provider for the BrandNotifier
final brandNotifierProvider = AsyncNotifierProvider<BrandNotifier, void>(
  BrandNotifier.new,
);
