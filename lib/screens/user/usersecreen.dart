import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  final User? user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  File? _imageFile;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user?.displayName ?? '';
    _emailController.text = widget.user?.email ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
    if (widget.user == null) return;

    setState(() => _isUpdating = true);

    String? photoUrl = widget.user!.photoURL;

    if (_imageFile != null) {
      // Upload image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref().child(
        'profile_images/${widget.user!.uid}.jpg',
      );

      await storageRef.putFile(_imageFile!);
      photoUrl = await storageRef.getDownloadURL();
    }

    await widget.user!.updateDisplayName(_nameController.text);
    if (photoUrl != null) {
      await widget.user!.updatePhotoURL(photoUrl);
    }

    // Force refresh user
    await widget.user!.reload();
    setState(() => _isUpdating = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _imageFile != null
                    ? FileImage(_imageFile!)
                    : (widget.user?.photoURL != null
                              ? NetworkImage(widget.user!.photoURL!)
                              : null)
                          as ImageProvider?,
                child: widget.user?.photoURL == null && _imageFile == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: InkWell(
                  onTap: _pickImage,
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.edit, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isUpdating ? null : _updateProfile,
            child: _isUpdating
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Update Profile'),
          ),
        ],
      ),
    );
  }
}
