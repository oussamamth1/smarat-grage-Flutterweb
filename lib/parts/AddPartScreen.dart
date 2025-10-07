import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smartgarage/models/MotoModel.dart';
import 'package:smartgarage/models/bik_parts.dart';
import 'package:smartgarage/models/brand.dart';
import 'package:smartgarage/models/supplier.dart';
import 'package:smartgarage/models/category.dart';
import 'package:smartgarage/provider/brand/brandprovider.dart';
import 'package:smartgarage/screens/add_brand_screen.dart';
import 'package:smartgarage/screens/brands_list_screen.dart';
import 'package:smartgarage/services/parts_repository.dart';

class AddPartScreen extends ConsumerStatefulWidget {
  const AddPartScreen({super.key});

  @override
  ConsumerState<AddPartScreen> createState() => _AddPartScreenState();
}

class _AddPartScreenState extends ConsumerState<AddPartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _refController = TextEditingController();
  final _nameController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _stockController = TextEditingController(text: '0');
  final _minThresholdController = TextEditingController(text: '5');
  final _descController = TextEditingController();

  String? selectedCategoryId;
  String? selectedBrandId;
  String? selectedModelId;
  String? selectedSupplierId;
  List<Category> categories = [];
  List<Moto> models = [];
  List<Supplier> suppliers = [];

  final repo = PartsRepository();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  @override
  void dispose() {
    _refController.dispose();
    _nameController.dispose();
    _purchasePriceController.dispose();
    _salePriceController.dispose();
    _stockController.dispose();
    _minThresholdController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadReferences() async {
    try {
      final catSnap = await FirebaseFirestore.instance
          .collection('categories')
          .get();
      final modelSnap = await FirebaseFirestore.instance
          .collection('moto_models')
          .get();
      final supSnap = await FirebaseFirestore.instance
          .collection('suppliers')
          .get();

      if (mounted) {
        setState(() {
          categories = catSnap.docs.map((d) => Category.fromDoc(d)).toList();
          models = modelSnap.docs.map((d) => Moto.fromDoc(d)).toList();
          suppliers = supSnap.docs.map((d) => Supplier.fromDoc(d)).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading data: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(brandsStreamProvider);
    final brandNotifier = ref.read(brandNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Add New Part')),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _refController,
                    decoration: const InputDecoration(labelText: 'Reference'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter reference' : null,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Part Name'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Enter part name' : null,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategoryId,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: categories.map((c) {
                      return DropdownMenuItem(value: c.id, child: Text(c.name));
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => selectedCategoryId = v),
                    validator: (v) => v == null ? 'Select category' : null,
                  ),
                  const SizedBox(height: 12),

                  // 🏍️ Brand Dropdown (using Riverpod)
                  brandsAsync.when(
                    data: (brands) => Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedBrandId,
                            decoration: const InputDecoration(
                              labelText: 'Brand',
                            ),
                            items: brands.map((b) {
                              return DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name),
                              );
                            }).toList(),
                            onChanged: _isSaving
                                ? null
                                : (v) => setState(() => selectedBrandId = v),
                            validator: (v) => v == null ? 'Select brand' : null,
                          ),
                        ),
            IconButton(
                          icon: const Icon(Icons.add),
                          tooltip: 'Add Brand',
                          onPressed: () async {
                            // Navigate to AddBrandScreen and wait for result
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddBrandScreen(),
                              ),
                            );

                            if (result != null && result is Brand) {
                              setState(() {
                                brands.add(result);
                                selectedBrandId = result.id;
                              });
                            }
                          },
                        ),       ],
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text('Error loading brands: $err'),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 🚲 Moto Model Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedModelId,
                    decoration: const InputDecoration(labelText: 'Moto Model'),
                    items: models.map((m) {
                      return DropdownMenuItem(value: m.id, child: Text(m.name));
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => selectedModelId = v),
                    validator: (v) => v == null ? 'Select moto' : null,
                  ),
                  const SizedBox(height: 12),

                  // 🧑‍🔧 Supplier Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedSupplierId,
                    decoration: const InputDecoration(labelText: 'Supplier'),
                    items: suppliers.map((s) {
                      return DropdownMenuItem(value: s.id, child: Text(s.name));
                    }).toList(),
                    onChanged: _isSaving
                        ? null
                        : (v) => setState(() => selectedSupplierId = v),
                    validator: (v) => v == null ? 'Select supplier' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _purchasePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Purchase Price (DT)',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _salePriceController,
                    decoration: const InputDecoration(
                      labelText: 'Sale Price (DT)',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _stockController,
                    decoration: const InputDecoration(
                      labelText: 'Initial Stock',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _minThresholdController,
                    decoration: const InputDecoration(
                      labelText: 'Min Threshold Alert',
                    ),
                    keyboardType: TextInputType.number,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                    enabled: !_isSaving,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Part'),
                    onPressed: _isSaving ? null : _savePart,
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Future<void> _savePart() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final part = BikePart(
        id: '',
        ref: _refController.text.trim(),
        name: _nameController.text.trim(),
        categoryId: selectedCategoryId ?? '',
        brandId: selectedBrandId ?? '',
        modelId: selectedModelId ?? '',
        supplierId: selectedSupplierId ?? '',
        purchasePrice:
            double.tryParse(_purchasePriceController.text.trim()) ?? 0,
        salePrice: double.tryParse(_salePriceController.text.trim()) ?? 0,
        stock: int.tryParse(_stockController.text.trim()) ?? 0,
        minThreshold: int.tryParse(_minThresholdController.text.trim()) ?? 5,
        description: _descController.text.trim(),
      );

      await repo.addPart(part);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving part: $e')));
    }
  }

  Future<String?> _showAddBrandDialog() async {
    final controller = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Brand'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Brand Name'),
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context, text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    controller.dispose();
    return result;
  }
}
