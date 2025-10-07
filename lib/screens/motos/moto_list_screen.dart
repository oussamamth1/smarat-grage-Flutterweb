import 'package:flutter/material.dart';
import 'package:smartgarage/models/MotoModel.dart';
import 'package:smartgarage/screens/motos/add_moto_screen.dart';

import 'package:smartgarage/services/moto_repository.dart';


class MotoListScreen extends StatelessWidget {
  final bool isAdmin;

  const MotoListScreen({super.key, required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final repo = MotoRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moto Models'),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddMotoScreen()),
                );
              },
            ),
        ],
      ),
      body: StreamBuilder<List<Moto>>(
        stream: repo.streamMotos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final motos = snapshot.data ?? [];

          if (motos.isEmpty) {
            return const Center(child: Text('No moto models found.'));
          }

          return ListView.separated(
            itemCount: motos.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final moto = motos[index];
              return ListTile(
                leading: moto.imageUrl != null && moto.imageUrl!.isNotEmpty
                    ? Image.network(
                        moto.imageUrl!,
                        width: 60,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.motorcycle, size: 40),
                title: Text(moto.name),
                subtitle: Text('Brand: ${moto.name}'),
                trailing: isAdmin
                    ? IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddMotoScreen(existingMoto: moto),
                            ),
                          );
                        },
                      )
                    : null,
              );
            },
          );
        },
      ),
    );
  }
}
