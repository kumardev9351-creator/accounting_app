import 'package:flutter/material.dart';
import '../models/firm_details.dart';
import 'pdf_preview_screen.dart';

class CreateInvoiceScreen extends StatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final nameController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final gstinController = TextEditingController();
  final addressController = TextEditingController();

  final gstPercentController = TextEditingController(text: "18");
  final invoiceNoController = TextEditingController(text: "INV-001");

  List<InvoiceItem> items = [];

  final itemDescController = TextEditingController();
  final itemAmountController = TextEditingController();

  void addItem() {
    if (itemDescController.text.isNotEmpty && itemAmountController.text.isNotEmpty) {
      setState(() {
        items.add(InvoiceItem(
          description: itemDescController.text,
          amount: double.tryParse(itemAmountController.text) ?? 0.0,
        ));
        itemDescController.clear();
        itemAmountController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dev Accounting - Create Invoice'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 700),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Client Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Client Name *', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: companyController, decoration: const InputDecoration(labelText: 'Company / Firm Name', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: invoiceNoController, decoration: const InputDecoration(labelText: 'Invoice Number', border: OutlineInputBorder()))),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address', border: OutlineInputBorder())),

                const SizedBox(height: 24),
                const Text('Items / Services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        title: Text(items[index].description),
                        trailing: Text('Rs. ${items[index].amount.toStringAsFixed(2)}'),
                        leading: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => setState(() => items.removeAt(index)),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(flex: 2, child: TextField(controller: itemDescController, decoration: const InputDecoration(labelText: 'Service Description', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    Expanded(child: TextField(controller: itemAmountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount (Rs.)', border: OutlineInputBorder()))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: addItem, child: const Text('Add')),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gstPercentController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'GST %', border: OutlineInputBorder()),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('GENERATE INVOICE PDF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      ClientDetails client = ClientDetails(
                        name: nameController.text,
                        companyName: companyController.text,
                        phone: phoneController.text,
                        email: emailController.text,
                        gstin: gstinController.text,
                        address: addressController.text,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PdfPreviewScreen(
                            client: client,
                            items: items,
                            gstPercent: double.tryParse(gstPercentController.text) ?? 18.0,
                            invoiceNumber: invoiceNoController.text,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}