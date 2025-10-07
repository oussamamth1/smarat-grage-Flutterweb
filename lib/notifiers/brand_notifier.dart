import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgarage/provider/brand/brandprovider.dart';

final brandNotifierProvider = AsyncNotifierProvider<BrandNotifier, void>(
  BrandNotifier.new,
);
