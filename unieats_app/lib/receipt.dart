
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'order_history_page.dart'; 

Future<void> generateReceipt(Order order) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(order.vendorName, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text("Order ID: ${order.id.substring(0,10)}"),
            pw.Text("Date: ${DateTime.fromMillisecondsSinceEpoch(order.createdAt)}"),
            pw.Text("Payment Method: ${order.paymentMethod}"), // NEW
            pw.SizedBox(height: 10),
            pw.Divider(),
            pw.SizedBox(height: 10),

            // Items
            ...order.items.map((item) {
              final price = (item['price'] as num) * (item['quantity'] as num);
              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("${item['quantity']}x ${item['name']}"),
                  pw.Text("RM ${price.toStringAsFixed(2)}"),
                ],
              );
            }),

            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text("Total", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Text("RM ${order.total.toStringAsFixed(2)}", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (format) => pdf.save());
}
