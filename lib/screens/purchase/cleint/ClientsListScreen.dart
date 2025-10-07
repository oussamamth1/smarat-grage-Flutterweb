import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartgarage/models/client.dart';
import 'package:smartgarage/screens/purchase/cleint/ClientCartScreen.dart';

import 'package:smartgarage/services/ClientsRepository.dart';

class ClientsListScreen extends StatelessWidget {
  final ClientsRepository repo = ClientsRepository();

  ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: StreamBuilder<List<Client>>(
        stream: repo.streamClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final clients = snapshot.data ?? [];

          if (clients.isEmpty) {
            return const Center(child: Text('No clients found.'));
          }

          return ListView.separated(
            itemCount: clients.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final client = clients[index];
              return ListTile(
                title: Text(client.name),
                subtitle: Text('${client.cart.length} items in cart'),
                leading: CircleAvatar(
                  child: Text(
                    client.name.isNotEmpty ? client.name[0].toUpperCase() : '?',
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to the client's cart screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClientCartScreen(client: client),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.person_add),
        onPressed: () {
          _showAddClientDialog(context);
        },
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Client'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Client Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await ClientsRepository().createClient(
                nameController.text.trim(),
              );
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
