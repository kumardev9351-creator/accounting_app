import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_helper.dart';

class ClientsListScreen extends StatelessWidget {
  const ClientsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clients Directory'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DBHelper.clientsBoxName).listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No clients saved yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              var client = box.getAt(index);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(client['name'] ?? 'Unknown Client'),
                  subtitle: Text('Firm: ${client['companyName'] ?? 'N/A'} | Phone: ${client['phone'] ?? 'N/A'}'),
                  trailing: Text(client['gstin']?.isNotEmpty == true ? 'GST: ${client['gstin']}' : '', style: const TextStyle(fontSize: 11)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}