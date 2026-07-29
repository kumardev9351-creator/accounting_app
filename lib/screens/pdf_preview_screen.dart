import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/firm_details.dart';

class PdfPreviewScreen extends StatelessWidget {
  final ClientDetails client;
  final List<InvoiceItem> items;
  final double gstPercent;
  final String invoiceNumber;

  const PdfPreviewScreen({
    super.key,
    required this.client,
    required this.items,
    required this.gstPercent,
    required this.invoiceNumber,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.amount);
  double get gstAmount => subtotal * (gstPercent / 100);
  double get grandTotal => subtotal + gstAmount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: PdfPreview(
        build: (format) => _generatePdf(format),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format) async {
    final pdf = pw.Document();

    pw.MemoryImage? logoImage;
    if (FirmDetails.logoBytes != null) {
      logoImage = pw.MemoryImage(FirmDetails.logoBytes!);
    }

    // Fixed 5-Row Table Structure
    List<List<String>> tableData = [];
    for (int i = 0; i < 5; i++) {
      if (i < items.length) {
        double itemGst = items[i].amount * (gstPercent / 100);
        double itemTotal = items[i].amount + itemGst;
        tableData.add([
          '${i + 1}',
          items[i].description,
          'Rs. ${items[i].amount.toStringAsFixed(2)}',
          '$gstPercent%',
          'Rs. ${itemGst.toStringAsFixed(2)}',
          'Rs. ${itemTotal.toStringAsFixed(2)}',
        ]);
      } else {
        tableData.add(['', '', '', '', '', '']);
      }
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // HEADER - FIRM DETAILS
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (logoImage != null) ...[
                        pw.Container(width: 70, height: 50, child: pw.Image(logoImage)),
                        pw.SizedBox(height: 6),
                      ],
                      pw.Text(
                        FirmDetails.name,
                        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                      ),
                      pw.Text('Address: ${FirmDetails.address}', style: const pw.TextStyle(fontSize: 9)),
                      pw.Text('Contact: ${FirmDetails.phone}', style: const pw.TextStyle(fontSize: 9)),
                      if (FirmDetails.email.isNotEmpty)
                        pw.Text('Email: ${FirmDetails.email}', style: const pw.TextStyle(fontSize: 9)),
                      if (FirmDetails.gstin.isNotEmpty)
                        pw.Text('GSTIN: ${FirmDetails.gstin}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: PdfColors.indigo900),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text('Invoice No: $invoiceNumber', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}', style: const pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Divider(thickness: 1, color: PdfColors.indigo200),
              pw.SizedBox(height: 12),

              // BILLED TO - CLIENT DETAILS
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(6),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('BILLED TO (CLIENT DETAILS):', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.indigo800)),
                          pw.SizedBox(height: 4),
                          pw.Text('Client Name: ${client.name}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                          if (client.companyName.isNotEmpty)
                            pw.Text('Firm Name: ${client.companyName}', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Address: ${client.address}', style: const pw.TextStyle(fontSize: 9)),
                        ],
                      ),
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.SizedBox(height: 14),
                        if (client.gstin.isNotEmpty)
                          pw.Text('GSTIN: ${client.gstin}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Contact: ${client.phone}', style: const pw.TextStyle(fontSize: 9)),
                        if (client.email.isNotEmpty)
                          pw.Text('Email: ${client.email}', style: const pw.TextStyle(fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // INVOICE TABLE WITH LIGHT BORDER
              pw.TableHelper.fromTextArray(
                headers: ['S.No.', 'Service / Item Description', 'Amount', 'GST %', 'GST Amt', 'Total Amount'],
                data: tableData,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
                cellStyle: const pw.TextStyle(fontSize: 9),
                cellAlignment: pw.Alignment.centerLeft,
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5), // Light Table Border
                columnWidths: {
                  0: const pw.FixedColumnWidth(35),
                  1: const pw.FlexColumnWidth(3),
                  2: const pw.FixedColumnWidth(65),
                  3: const pw.FixedColumnWidth(45),
                  4: const pw.FixedColumnWidth(60),
                  5: const pw.FixedColumnWidth(70),
                },
              ),
              pw.SizedBox(height: 16),

              // SUMMARY & THANK YOU MESSAGE BOX
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Padding(
                      padding: const pw.EdgeInsets.only(top: 10.0, right: 16.0),
                      child: pw.Text(
                        'Thank you for choosing ${FirmDetails.name}!',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.indigo900,
                        ),
                      ),
                    ),
                  ),
                  pw.Container(
                    width: 200,
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300, width: 0.8),
                      borderRadius: pw.BorderRadius.circular(4),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Text('Subtotal:', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Rs. ${subtotal.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                        ]),
                        pw.SizedBox(height: 4),
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Text('GST Tax ($gstPercent%):', style: const pw.TextStyle(fontSize: 9)),
                          pw.Text('Rs. ${gstAmount.toStringAsFixed(2)}', style: const pw.TextStyle(fontSize: 9)),
                        ]),
                        pw.Divider(thickness: 0.5, color: PdfColors.grey300),
                        pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
                          pw.Text('Grand Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                          pw.Text('Rs. ${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10, color: PdfColors.indigo)),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              pw.Spacer(),

              // FOOTER
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('For ${FirmDetails.name}', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 30),
                      pw.Text('Authorized Signatory', style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}