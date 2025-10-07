import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:smartgarage/models/MotoModel.dart';
import 'package:smartgarage/models/Brand.dart';
import 'package:smartgarage/services/moto_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Conditional imports
import 'dart:io' if (dart.library.html) 'dart:html' as html;

class AddMotoScreen extends StatefulWidget {
  final Moto? existingMoto;

  const AddMotoScreen({super.key, this.existingMoto});

  @override
  State<AddMotoScreen> createState() => _AddMotoScreenState();
}

class _AddMotoScreenState extends State<AddMotoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repo = MotoRepository();

  // Basic info
  String _name = '';
  String? _brandId;
  int _year = DateTime.now().year;

  // Engine specs
  int? _engineCapacity;
  String? _engineType;
  String? _fuelType;

  // Technical specs
  double? _weight;
  int? _maxPower;
  int? _maxTorque;
  String? _transmission;

  // Other
  String? _category;
  String? _description;
  String? _imageUrl;
  XFile? _imageFile;
  bool _isActive = true;
  bool _isPopular = false;
  bool _isSaving = false;

  List<Brand> _brands = [];
  bool _isLoadingBrands = true;

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadBrands();

    if (widget.existingMoto != null) {
      final moto = widget.existingMoto!;
      _name = moto.name;
      _brandId = moto.brandId;
      _year = moto.year;
      _engineCapacity = moto.engineCapacity;
      _engineType = moto.engineType;
      _fuelType = moto.fuelType;
      _weight = moto.weight;
      _maxPower = moto.maxPower;
      _maxTorque = moto.maxTorque;
      _transmission = moto.transmission;
      _category = moto.category;
      _description = moto.description;
      _imageUrl = moto.imageUrl;
      _isActive = moto.isActive;
      _isPopular = moto.isPopular;
    }
  }

  Future<void> _loadBrands() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('brands')
          .orderBy('name')
          .get();

      setState(() {
        _brands = snapshot.docs.map((doc) => Brand.fromDoc(doc)).toList();
        _isLoadingBrands = false;
      });
    } catch (e) {
      print('❌ Error loading brands: $e');
      setState(() => _isLoadingBrands = false);
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = picked;
      });
    }
  }

  Future<void> _saveMoto() async {
    if (!_formKey.currentState!.validate()) return;
    if (_brandId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a brand')));
      return;
    }

    setState(() => _isSaving = true);
    _formKey.currentState!.save();

    try {
      String? imageUrl = _imageUrl;

      // Upload image if new one is selected
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance.ref().child(
          'motos/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        if (kIsWeb) {
          final bytes = await _imageFile!.readAsBytes();
          await ref.putData(bytes);
        } else {
          await ref.putFile(File(_imageFile!.path));
        }

        imageUrl = await ref.getDownloadURL();
      }

      final moto = Moto(
        id: widget.existingMoto?.id ?? '',
        name: _name,
        brandId: _brandId!,
        year: _year,
        engineCapacity: _engineCapacity,
        engineType: _engineType,
        fuelType: _fuelType,
        imageUrl: imageUrl,
        description: _description,
        weight: _weight,
        maxPower: _maxPower,
        maxTorque: _maxTorque,
        transmission: _transmission,
        category: _category,
        isActive: _isActive,
        isPopular: _isPopular,
      );

      if (widget.existingMoto == null) {
        await _repo.addMoto(moto);
      } else {
        await _repo.updateMoto(moto);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      print('❌ Error saving moto: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingMoto == null ? 'Add Motorcycle' : 'Edit Motorcycle',
        ),
      ),
      body: _isLoadingBrands
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Preview & Upload
                    Center(
                      child: Column(
                        children: [
                          if (_imageFile != null)
                            kIsWeb
                                ? FutureBuilder<Uint8List>(
                                    future: _imageFile!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.memory(
                                            snapshot.data!,
                                            height: 200,
                                            width: 300,
                                            fit: BoxFit.cover,
                                          ),
                                        );
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(_imageFile!.path),
                                      height: 200,
                                      width: 300,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                          else if (_imageUrl != null && _imageUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                _imageUrl!,
                                height: 200,
                                width: 300,
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 200,
                              width: 300,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.motorcycle,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text('Pick Image'),
                            onPressed: _pickImage,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Basic Information
                    Text(
                      'Basic Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _brandId,
                      decoration: const InputDecoration(
                        labelText: 'Brand *',
                        border: OutlineInputBorder(),
                      ),
                      items: _brands.map((brand) {
                        return DropdownMenuItem(
                          value: brand.id,
                          child: Text(brand.name),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() => _brandId = value),
                      validator: (v) =>
                          v == null ? 'Please select a brand' : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: _name,
                      decoration: const InputDecoration(
                        labelText: 'Model Name *',
                        hintText: 'e.g., YZF-R15, CBR150R',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) =>
                          v == null || v.isEmpty ? 'Required' : null,
                      onSaved: (v) => _name = v!.trim(),
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: _year.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Year *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final year = int.tryParse(v);
                        if (year == null ||
                            year < 1900 ||
                            year > DateTime.now().year + 1) {
                          return 'Enter valid year';
                        }
                        return null;
                      },
                      onSaved: (v) => _year = int.parse(v!),
                    ),
                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Sport',
                          child: Text('🏍️ Sport'),
                        ),
                        DropdownMenuItem(
                          value: 'Cruiser',
                          child: Text('🛵 Cruiser'),
                        ),
                        DropdownMenuItem(
                          value: 'Scooter',
                          child: Text('🛴 Scooter'),
                        ),
                        DropdownMenuItem(
                          value: 'Touring',
                          child: Text('🚵 Touring'),
                        ),
                        DropdownMenuItem(
                          value: 'Adventure',
                          child: Text('⛰️ Adventure'),
                        ),
                        DropdownMenuItem(
                          value: 'Naked',
                          child: Text('🏁 Naked/Street'),
                        ),
                        DropdownMenuItem(
                          value: 'Dirt Bike',
                          child: Text('🏜️ Dirt Bike'),
                        ),
                        DropdownMenuItem(
                          value: 'Electric',
                          child: Text('⚡ Electric'),
                        ),
                      ],
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    const SizedBox(height: 24),

                    // Engine Specifications
                    Text(
                      'Engine Specifications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _engineCapacity?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Engine CC',
                              hintText: 'e.g., 155, 250',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onSaved: (v) => _engineCapacity =
                                v?.isNotEmpty == true ? int.tryParse(v!) : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _fuelType,
                            decoration: const InputDecoration(
                              labelText: 'Fuel Type',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'Petrol',
                                child: Text('Petrol'),
                              ),
                              DropdownMenuItem(
                                value: 'Electric',
                                child: Text('Electric'),
                              ),
                              DropdownMenuItem(
                                value: 'Hybrid',
                                child: Text('Hybrid'),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => _fuelType = value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: _engineType ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Engine Type',
                        hintText: 'e.g., Single Cylinder, Parallel Twin',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (v) =>
                          _engineType = v?.isNotEmpty == true ? v : null,
                    ),
                    const SizedBox(height: 24),

                    // Technical Specifications
                    Text(
                      'Technical Specifications',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _maxPower?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Max Power (HP)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onSaved: (v) => _maxPower = v?.isNotEmpty == true
                                ? int.tryParse(v!)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _maxTorque?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Max Torque (Nm)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onSaved: (v) => _maxTorque = v?.isNotEmpty == true
                                ? int.tryParse(v!)
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _weight?.toString() ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onSaved: (v) => _weight = v?.isNotEmpty == true
                                ? double.tryParse(v!)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _transmission ?? '',
                            decoration: const InputDecoration(
                              labelText: 'Transmission',
                              hintText: 'e.g., 6-speed manual',
                              border: OutlineInputBorder(),
                            ),
                            onSaved: (v) => _transmission =
                                v?.isNotEmpty == true ? v : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description
                    Text(
                      'Additional Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      initialValue: _description ?? '',
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        hintText: 'Additional information about this model',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onSaved: (v) =>
                          _description = v?.isNotEmpty == true ? v : null,
                    ),
                    const SizedBox(height: 24),

                    // Status switches
                    SwitchListTile(
                      title: const Text('Currently Active'),
                      subtitle: const Text(
                        'Is this model currently in production?',
                      ),
                      value: _isActive,
                      onChanged: (v) => setState(() => _isActive = v),
                    ),
                    SwitchListTile(
                      title: const Text('Mark as Popular'),
                      subtitle: const Text('Highlight this as a popular model'),
                      value: _isPopular,
                      onChanged: (v) => setState(() => _isPopular = v),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMoto,
                        child: _isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.existingMoto == null
                                    ? 'Add Motorcycle'
                                    : 'Save Changes',
                                style: const TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
