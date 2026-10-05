import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import '../models/bill.dart';
import '../models/business_profile.dart';
import 'storage_service.dart';
import '../utils/number_to_words.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<File> generateBillPdf(Bill bill) async {
    final pdf = pw.Document();
    final profile = StorageService.getProfile();
    
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(
          base: font,
          bold: fontBold,
        ),
        header: (pw.Context context) {
          return _buildHeader(profile, bill);
        },
        footer: (pw.Context context) {
          return _buildFooter();
        },
        build: (pw.Context context) {
          return [
            pw.SizedBox(height: 20),
            _buildCustomerInfo(bill),
            pw.SizedBox(height: 20),
            _buildInvoiceTable(bill),
            pw.SizedBox(height: 20),
            _buildTotalSection(bill),
            pw.SizedBox(height: 30),
            _buildAmountInWords(bill),
            pw.SizedBox(height: 40),
            _buildSignatures(profile),
          ];
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final safeName = bill.customer.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_');
    final String fileName = '${bill.invoiceNumber}_$safeName.pdf';
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _buildHeader(BusinessProfile profile, Bill bill) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(profile.businessName.isNotEmpty ? profile.businessName : 'BUSINESS NAME', 
                    style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  if (profile.businessAddress.isNotEmpty)
                    pw.Text(profile.businessAddress, style: const pw.TextStyle(fontSize: 10)),
                  if (profile.phoneNumber.isNotEmpty)
                    pw.Text('Phone: ${profile.phoneNumber}', style: const pw.TextStyle(fontSize: 10)),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
                pw.SizedBox(height: 8),
                pw.Text('Invoice No: ${bill.invoiceNumber}'),
                pw.Text('Date: ${DateFormat('dd MMM yyyy').format(bill.invoiceDate)}'),
              ],
            )
          ],
        ),
        pw.SizedBox(height: 10),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(Bill bill) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text(bill.customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
        if (bill.customer.address.isNotEmpty) pw.Text(bill.customer.address),
        if (bill.customer.phone.isNotEmpty) pw.Text('Phone: ${bill.customer.phone}'),
      ]
    );
  }

  static pw.Widget _buildInvoiceTable(Bill bill) {
    return pw.TableHelper.fromTextArray(
      headers: ['S.No', 'Item', 'Qty', 'Rate', 'Amount'],
      data: List<List<String>>.generate(
        bill.items.length,
        (index) {
          final item = bill.items[index];
          return [
            '${index + 1}',
            item.itemName,
            item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 2),
            CurrencyFormatter.format(item.unitPrice),
            CurrencyFormatter.format(item.total),
          ];
        },
      ),
      border: const pw.TableBorder(
        top: pw.BorderSide(color: PdfColors.grey300),
        bottom: pw.BorderSide(color: PdfColors.grey300),
        horizontalInside: pw.BorderSide.none,
        verticalInside: pw.BorderSide.none,
      ),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotalSection(Bill bill) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:'),
                    pw.Text(CurrencyFormatter.format(bill.subtotal)),
                  ],
                ),
                if (bill.discount > 0) ...[
                  pw.SizedBox(height: 4),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Discount:'),
                      pw.Text('- ${CurrencyFormatter.format(bill.discount)}'),
                    ],
                  ),
                ],
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text(CurrencyFormatter.format(bill.grandTotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 8),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 8),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Status:'),
                    pw.Text(bill.paymentStatus, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: bill.paymentStatus == 'PAID' ? PdfColors.green700 : PdfColors.red700)),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Payment Method:'),
                    pw.Text(bill.paymentMethod),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildAmountInWords(Bill bill) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Amount in Words:', style: pw.TextStyle(color: PdfColors.grey700)),
        pw.SizedBox(height: 4),
        pw.Text('${NumberToWords.convert(bill.grandTotal.round())} Only', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ]
    );
  }

  static pw.Widget _buildSignatures(BusinessProfile profile) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (profile.upiId.isNotEmpty) ...[
              pw.Text('UPI ID: ${profile.upiId}'),
              pw.SizedBox(height: 20),
            ],
            pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.Text('1. Goods once sold will not be taken back.', style: const pw.TextStyle(fontSize: 10)),
            pw.Text('2. Subject to local jurisdiction.', style: const pw.TextStyle(fontSize: 10)),
          ]
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.SizedBox(height: 40),
            pw.Container(width: 150, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Authorized Signatory', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            if (profile.businessName.isNotEmpty)
              pw.Text('For ${profile.businessName}', style: const pw.TextStyle(fontSize: 10)),
          ],
        )
      ],
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text('Thank you for your business!', style: pw.TextStyle(color: PdfColors.grey700, fontStyle: pw.FontStyle.italic)),
      ],
    );
  }
}
