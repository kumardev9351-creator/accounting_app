import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_helper.dart';

class InvoicesListScreen extends StatelessWidget {
  const InvoicesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Saved Invoices'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DBHelper.invoicesBoxName).listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(
              child: Text('No invoices created yet.', style: TextStyle(fontSize: 16, color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: box.length,
            itemBuilder: (context, index) {
              var invoice = box.getAt(index);
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.indigo,
                    child: Icon(Icons.receipt_long, color: Colors.white),
                  ),
                  title: Text('${invoice['invoiceNumber']} - ${invoice['clientName']}'),
                  subtitle: Text('Date: ${invoice['date'].toString().split('T')[0]}'),
                  trailing: Text(
                    'Rs. ${invoice['grandTotal'].toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}