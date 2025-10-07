import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgarage/models/Purchase.dart';
import 'package:smartgarage/models/bik_parts.dart';
import 'package:smartgarage/models/client.dart';
import 'package:smartgarage/services/parts_repository.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  final repo = PartsRepository();

  String? selectedClientId; // Add selected client
  String? selectedPartId;
  int quantity = 1;
  double totalPrice = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Purchase')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1️⃣ Select Client
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('clients')
                  .snapshots(),
              builder: (context, clientSnapshot) {
                if (!clientSnapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final clients = clientSnapshot.data!.docs;

                return DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select Client'),
                  value: selectedClientId,
                  items: clients.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(data['name'] ?? 'Unknown'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedClientId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),

            // 2️⃣ Select Part & Quantity
            Expanded(
              child: StreamBuilder<List<BikePart>>(
                stream: repo.streamParts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final parts = snapshot.data ?? [];
                  if (parts.isEmpty) return const Text('No parts available');

                  BikePart? selectedPart = parts.firstWhere(
                    (p) => p.id == selectedPartId,
                    orElse: () => parts.first,
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text('Select Part'),
                        value: selectedPartId,
                        items: parts.map((part) {
                          return DropdownMenuItem<String>(
                            value: part.id,
                            child: Text('${part.name} (${part.ref})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedPartId = value;
                            totalPrice =
                                (parts
                                    .firstWhere((p) => p.id == value!)
                                    .salePrice) *
                                quantity;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        initialValue: quantity.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (val) {
                          setState(() {
                            quantity = int.tryParse(val) ?? 1;
                            totalPrice =
                                (selectedPart?.salePrice ?? 0) * quantity;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                      const SizedBox(height: 24),
  
ElevatedButton(
  onPressed: (selectedPartId == null || selectedClientId == null)
      ? null
      : () async {
          // Create Purchase object
          final newPurchase = Purchase(
            id: '', // Firestore will generate ID
            partId: selectedPartId!,
            quantity: quantity,
            totalPrice: totalPrice,
            date: DateTime.now(),
          );

        final newCartItem = CartItem(
                                  partId: selectedPartId!,
                                  quantity: quantity,
                                );

                                await FirebaseFirestore.instance
                                    .collection('clients')
                                    .doc(selectedClientId)
                                    .update({
                                      'cart': FieldValue.arrayUnion([
                                        newCartItem.toMap(),
                                      ]),
                                    });
          // Optionally, also save in a global 'purchases' collection
          await FirebaseFirestore.instance
              .collection('purchases')
              .add({
                ...newPurchase.toMap(),
                'clientId': selectedClientId,
              });

          // Reset form
          setState(() {
            selectedClientId = null;
            selectedPartId = null;
            quantity = 1;
            totalPrice = 0;
          });
        },
  child: const Text('Save Purchase'),
),
            ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
