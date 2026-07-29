import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../services/db_helper.dart';
import 'create_invoice_screen.dart';
import 'invoices_list_screen.dart';
import 'clients_list_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var invoiceBox = Hive.box(DBHelper.invoicesBoxName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Accounting Dashboard'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome Back!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                // Real-Time Stats Cards from Hive
                ValueListenableBuilder(
                  valueListenable: invoiceBox.listenable(),
                  builder: (context, Box box, _) {
                    int totalInvoices = box.length;
                    double totalRevenue = 0.0;

                    for (var item in box.values) {
                      if (item is Map && item['grandTotal'] != null) {
                        totalRevenue += (item['grandTotal'] as num).toDouble();
                      }
                    }

                    return Row(
                      children: [
                        _buildStatCard('Total Invoices', '$totalInvoices', Icons.receipt, Colors.blue),
                        const SizedBox(width: 16),
                        _buildStatCard('Total Revenue', 'Rs. ${totalRevenue.toStringAsFixed(2)}', Icons.currency_rupee, Colors.green),
                        const SizedBox(width: 16),
                        _buildStatCard('Pending Payment', 'Rs. 0.00', Icons.pending_actions, Colors.orange),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 32),

                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                const SizedBox(height: 16),

                // Grid Menu with Live Navigation
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                  children: [
                    _buildMenuCard(
                      context,
                      title: 'Create Invoice',
                      icon: Icons.add_circle_outline,
                      color: Colors.indigo,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CreateInvoiceScreen()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Clients Directory',
                      icon: Icons.people,
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ClientsListScreen()),
                        );
                      },
                    ),
                    _buildMenuCard(
                      context,
                      title: 'Saved Invoices',
                      icon: Icons.article,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const InvoicesListScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}