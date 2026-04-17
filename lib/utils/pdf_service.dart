import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/order.dart';

class PdfService {
  static Future<void> generateReceipt(OrderModel order) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // --- Header ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("KAARIGAR HAAT",
                          style: pw.TextStyle(
                              fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.brown800)),
                      pw.Text("Official Order Receipt", style: const pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Order ID: #${order.id.toUpperCase().substring(0, 8)}"),
                      pw.Text("Date: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}"),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 10),

              // --- Customer & Status Info ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("BILL TO:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(order.userId), // Assuming OrderModel has userName
                      pw.Text("Status: ${order.status.toUpperCase()}",
                          style: pw.TextStyle(color: PdfColors.green700, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ],
              ),

              pw.SizedBox(height: 30),

              // --- Items Table ---
              pw.TableHelper.fromTextArray(
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.brown700),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerRight,
                },
                headerAlignment: pw.Alignment.centerLeft,
                headers: ['Product Name', 'Price (INR)'],
                data: order.items.map((item) => [
                  item.title,
                  "Rs. ${item.price}",
                ]).toList(),
              ),

              pw.Divider(thickness: 1),

              // --- Summary ---
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.SizedBox(height: 10),
                      pw.Row(
                        children: [
                          pw.Text("Total Amount: ", style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                          pw.Text("Rs. ${order.totalAmount}",
                              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColors.brown900)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              pw.Spacer(),

              // --- Footer ---
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Divider(),
                    pw.Text("Thank you for shopping at Kaarigar Haat!",
                        style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
                    pw.Text("Handcrafted with love by local artisans."),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    // This opens the Native Print Preview dialog
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Receipt_${order.id.substring(0, 5)}',
    );
  }
}