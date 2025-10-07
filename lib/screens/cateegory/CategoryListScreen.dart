  import 'package:flutter/material.dart';
import 'package:smartgarage/models/category.dart';
import 'package:smartgarage/services/categoryRepository.dart';


class CategoryListScreen extends StatelessWidget {
  final bool isAdmin;
  const CategoryListScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final repo = CategoryRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => _showCategoryDialog(context, repo),
              child: const Icon(Icons.add),
            )
          : null,
      body: StreamBuilder<List<Category>>(
        stream: repo.streamCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snapshot.data ?? [];
          if (cats.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }
          return ListView.builder(
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final c = cats[i];
              return ListTile(
                leading: Icon(
                  Icons.category,
                  color: c.isActive ? Colors.green : Colors.grey,
                ),
                title: Text(c.name),
                subtitle: Text(c.description ?? 'No description'),
                trailing: isAdmin
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _showCategoryDialog(context, repo, category: c),
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }

  void _showCategoryDialog(
    BuildContext context,
    CategoryRepository repo, {
    Category? category,
  }) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final descController = TextEditingController(
      text: category?.description ?? '',
    );
    bool isActive = category?.isActive ?? true;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category == null ? 'Add Category' : 'Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            SwitchListTile(
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => isActive = v,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              final newCat = Category(
                id: category?.id ?? '',
                name: nameController.text.trim(),
                description: descController.text.trim(),
                isActive: isActive,
              );
              if (category == null) {
                await repo.addCategory(newCat);
              } else {
                await repo.updateCategory(category.id, newCat.toMap());
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
