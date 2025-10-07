import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgarage/models/brand.dart';
import 'package:smartgarage/screens/add_brand_screen.dart';
import 'package:smartgarage/services/brands_repository.dart';


final brandsRepositoryProvider = Provider((ref) => BrandsRepository());

final brandsStreamProvider = StreamProvider<List<Brand>>((ref) {
  final repo = ref.watch(brandsRepositoryProvider);
  return repo.streamBrands();
});

class BrandsListScreen extends ConsumerWidget {
  const BrandsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final brandsAsync = ref.watch(brandsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brands'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBrandScreen()),
            ),
          ),
        ],
      ),
      body: brandsAsync.when(
        data: (brands) {
          if (brands.isEmpty) {
            return const Center(child: Text('No brands found.'));
          }
          return ListView.builder(
            itemCount: brands.length,
            itemBuilder: (context, i) {
              final brand = brands[i];
              return ListTile(
                leading: brand.imageUrl != null && brand.imageUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(brand.imageUrl!),
                      )
                    : const CircleAvatar(child: Icon(Icons.motorcycle)),
                title: Text(brand.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddBrandScreen(brand: brand),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
