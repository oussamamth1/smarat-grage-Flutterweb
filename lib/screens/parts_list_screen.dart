import 'package:flutter/material.dart';
import 'package:smartgarage/models/bik_parts.dart';

import 'package:smartgarage/parts/AddPartScreen.dart';

import '../services/parts_repository.dart';

class PartsListScreen extends StatelessWidget {
  final bool isAdmin;

  const PartsListScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final repo = PartsRepository();

    return Scaffold(
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddPartScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
      appBar: AppBar(
        title: const Text('Parts Inventory'),
        actions: isAdmin
            ? [
                IconButton(
                  icon: const Icon(Icons.cleaning_services),
                  tooltip: 'Clean Invalid Image URLs',
                  onPressed: () => _cleanupInvalidImageUrls(context, repo),
                ),
              ]
            : null,
      ),
      body: StreamBuilder<List<BikePart>>(
        stream: repo.streamParts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final parts = snapshot.data ?? [];
          if (parts.isEmpty) {
            return const Center(child: Text('No parts found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(8),
            itemCount: parts.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = parts[index];
              final lowStock = p.stock <= p.minThreshold;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildPartImage(p.imageUrl),
                  ),
                  title: Text(
                    '${p.name} (${p.ref})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        p.categoryId.isNotEmpty ? p.categoryId : 'No category',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 16,
                            color: lowStock ? Colors.red : Colors.green,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Stock: ${p.stock}',
                            style: TextStyle(
                              color: lowStock ? Colors.red : Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (lowStock) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'LOW',
                                style: TextStyle(
                                  color: Colors.red[900],
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  trailing: Text(
                    '\$${p.salePrice.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: lowStock ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onTap: isAdmin
                      ? () => _showPartDetailsDialog(context, p)
                      : null,
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔹 Image Builder
  Widget _buildPartImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty || !_isValidImageUrl(imageUrl)) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl,
      width: 60,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Image load error: $error');
        return _buildPlaceholder();
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: 60,
          height: 60,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() => Container(
    width: 60,
    height: 60,
    color: Colors.grey[300],
    child: const Icon(Icons.image_not_supported, color: Colors.grey),
  );

  // 🔹 Image URL Validator
  bool _isValidImageUrl(String url) {
    if (url.startsWith('<') || url.startsWith('<!')) return false;
    if (!url.startsWith('http://') && !url.startsWith('https://')) return false;

    final patterns = [
      'firebasestorage.googleapis.com',
      'localhost:9199',
      '127.0.0.1:9199',
    ];
    if (patterns.any((p) => url.contains(p))) return true;

    final validExt = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    return validExt.any((ext) => url.toLowerCase().endsWith(ext));
  }

  // 🔹 Detail Dialog
  void _showPartDetailsDialog(BuildContext context, BikePart p) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(p.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildPartImage(p.imageUrl)),
              const SizedBox(height: 16),
              _buildDetailRow('Reference', p.ref),
              _buildDetailRow('Category ID', p.categoryId),
              _buildDetailRow('Stock', p.stock.toString()),
              _buildDetailRow('Min Threshold', p.minThreshold.toString()),
              _buildDetailRow(
                'Sale Price',
                '\$${p.salePrice.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Purchase Price',
                '\$${p.purchasePrice.toStringAsFixed(2)}',
              ),
              _buildDetailRow(
                'Profit Margin',
                '${p.profitMarginPercentage.toStringAsFixed(1)}%',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // 🔹 Cleanup Invalid URLs
  Future<void> _cleanupInvalidImageUrls(
    BuildContext context,
    PartsRepository repo,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clean Invalid URLs?'),
        content: const Text(
          'This will reset invalid image URLs (like "carb", "ak", etc.) to empty strings. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Clean Now'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Cleaning database...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final parts = await repo.streamParts().first;
      int fixed = 0;

      for (var part in parts) {
        if (part.imageUrl != null &&
            part.imageUrl!.isNotEmpty &&
            !_isValidImageUrl(part.imageUrl!)) {
          await repo.updatePartImageUrl(part.id, '');
          fixed++;
        }
      }

      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Cleaned $fixed invalid URLs')),
      );
    } catch (e) {
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
