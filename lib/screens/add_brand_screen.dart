import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgarage/models/brand.dart';
import 'package:smartgarage/provider/brand/brandprovider.dart';

class AddBrandScreen extends ConsumerStatefulWidget {
  final Brand? brand;
  const AddBrandScreen({super.key, this.brand});

  @override
  ConsumerState createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends ConsumerState<AddBrandScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final _nameController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _websiteController = TextEditingController();

  // Other fields
  bool _isActive = true;
  bool _isPopular = false;
  int _modelsCount = 0;

  @override
  void initState() {
    super.initState();
    final brand = widget.brand;
    if (brand != null) {
      _nameController.text = brand.name;
      _imageUrlController.text = brand.imageUrl ?? '';
      _descriptionController.text = brand.description ?? '';
      _countryController.text = brand.country ?? '';
      _websiteController.text = brand.website ?? '';
      _isActive = brand.isActive;
      _isPopular = brand.isPopular;
      _modelsCount = brand.modelsCount;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  Future<void> _saveBrand() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(brandNotifierProvider.notifier);

    final name = _nameController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final description = _descriptionController.text.trim();
    final country = _countryController.text.trim();
    final website = _websiteController.text.trim();

    try {
      final now = DateTime.now();

      if (widget.brand == null) {
        // ➕ Add new brand
        final brand = Brand(
          id: '', // Firestore will assign it
          name: name,
          imageUrl: imageUrl.isEmpty ? null : imageUrl,
          description: description.isEmpty ? null : description,
          country: country.isEmpty ? null : country,
          website: website.isEmpty ? null : website,
          isActive: _isActive,
          isPopular: _isPopular,
          modelsCount: _modelsCount,
          createdAt: now,
          updatedAt: now,
        );
        await notifier.addBrand(brand);
      } else {
        // ✏️ Update existing brand
        await notifier.updateBrand(widget.brand!.id, {
          'name': name,
          'imageUrl': imageUrl,
          'description': description,
          'country': country,
          'website': website,
          'isActive': _isActive,
          'isPopular': _isPopular,
          'modelsCount': _modelsCount,
          'updatedAt': now,
        });
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving brand: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.brand != null;
    final brandState = ref.watch(brandNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Brand' : 'Add Brand')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,

                    decoration: const InputDecoration(labelText: 'Brand Name',
                      hintText: 'e.g., Yamaha, Honda',
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter brand name' : null,
                    enabled: !brandState.isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL'),
                    enabled: !brandState.isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    enabled: !brandState.isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country of Origin',
hintText: 'e.g., Japan, Italy, Germany',
                    ),
                    enabled: !brandState.isLoading,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website (optional)',
hintText: 'https://www.brand.com',

                    ),
                    enabled: !brandState.isLoading,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Active'),
                          value: _isActive,
                          onChanged: brandState.isLoading
                              ? null
                              : (v) => setState(() => _isActive = v),
                        ),
                      ),
                      Expanded(
                        child: SwitchListTile(
                          title: const Text('Popular'),
                          value: _isPopular,
                          onChanged: brandState.isLoading
                              ? null
                              : (v) => setState(() => _isPopular = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    initialValue: _modelsCount.toString(),
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Number of Models',
                    ),
                    onChanged: (v) => _modelsCount = int.tryParse(v) ?? 0,
                    enabled: !brandState.isLoading,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: brandState.isLoading ? null : _saveBrand,
                    icon: const Icon(Icons.save),
                    label: Text(isEdit ? 'Update Brand' : 'Add Brand'),
                  ),
                ],
              ),
            ),
          ),
          if (brandState.isLoading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
