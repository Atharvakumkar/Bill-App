import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/bill.dart';
import '../models/business_profile.dart';
import '../utils/number_to_words.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<Uint8List> generatePdf(Bill bill, BusinessProfile profile) async {
    final pdf = pw.Document();

    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData(
          defaultTextStyle: pw.TextStyle(font: font, fontSize: 10),
        ),
        build: (context) {
          return [
            _buildHeader(profile),
            pw.SizedBox(height: 20),
            _buildInvoiceInfo(bill),
            pw.SizedBox(height: 20),
            _buildCustomerInfo(bill),
            pw.SizedBox(height: 20),
            _buildItemTable(bill, font, fontBold),
            pw.SizedBox(height: 20),
            _buildTotals(bill, fontBold),
            pw.SizedBox(height: 20),
            _buildFooter(bill, profile, fontBold),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(BusinessProfile profile) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(profile.businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              if (profile.ownerName.isNotEmpty) pw.Text(profile.ownerName),
              if (profile.address.isNotEmpty) pw.Text(profile.address),
              if (profile.phone.isNotEmpty) pw.Text('Phone: ${profile.phone}'),
              if (profile.email.isNotEmpty) pw.Text('Email: ${profile.email}'),
            ],
          ),
        ),
        pw.Text('INVOICE', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(Bill bill) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice No: ${bill.invoiceNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text('Date: ${DateFormat('dd MMM yyyy').format(bill.invoiceDate)}'),
              pw.Text('Due Date: ${DateFormat('dd MMM yyyy').format(bill.dueDate)}'),
              pw.Text('Status: ${bill.paymentStatus}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: bill.paymentStatus == 'Paid' ? PdfColors.green700 : PdfColors.red700)),
            ],
          ),
        )
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(Bill bill) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Text(bill.customer.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        if (bill.customer.address.isNotEmpty) pw.Text(bill.customer.address),
        if (bill.customer.phone.isNotEmpty) pw.Text('Phone: ${bill.customer.phone}'),
        if (bill.customer.email.isNotEmpty) pw.Text('Email: ${bill.customer.email}'),
      ],
    );
  }

  static pw.Widget _buildItemTable(Bill bill, pw.Font font, pw.Font fontBold) {
    return pw.TableHelper.fromTextArray(
      headers: ['S.No', 'Item', 'Qty', 'Rate', 'Discount', 'Amount'],
      data: List.generate(bill.items.length, (index) {
        final item = bill.items[index];
        return [
          (index + 1).toString(),
          item.name + (item.description.isNotEmpty ? '\n${item.description}' : ''),
          item.quantity.toString(),
          CurrencyFormatter.format(item.unitPrice).replaceAll('₹', 'Rs '),
          CurrencyFormatter.format(item.discount).replaceAll('₹', 'Rs '),
          CurrencyFormatter.format(item.total).replaceAll('₹', 'Rs '),
        ];
      }),
      border: pw.TableBorder.all(color: PdfColors.grey300),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: fontBold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey200),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerRight,
        3: pw.Alignment.centerRight,
        4: pw.Alignment.centerRight,
        5: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotals(Bill bill, pw.Font fontBold) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        children: [
          pw.Spacer(flex: 6),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Subtotal:'),
                    pw.Text(CurrencyFormatter.format(bill.subtotal).replaceAll('₹', 'Rs ')),
                  ],
                ),
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Discount:'),
                    pw.Text(CurrencyFormatter.format(bill.discount).replaceAll('₹', 'Rs ')),
                  ],
                ),
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text(CurrencyFormatter.format(bill.grandTotal).replaceAll('₹', 'Rs '), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(Bill bill, BusinessProfile profile, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Amount in Words:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(NumberToWords.convert(bill.grandTotal)),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Payment Method: ${bill.paymentMethod}'),
                  if (profile.upiId.isNotEmpty) pw.Text('UPI ID: ${profile.upiId}'),
                  pw.SizedBox(height: 10),
                  pw.Text('Terms & Conditions:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(profile.termsAndConditions),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.SizedBox(height: 40),
                pw.Container(width: 120, height: 1, color: PdfColors.black),
                pw.SizedBox(height: 4),
                pw.Text('Authorized Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> sharePdf(Uint8List bytes, Bill bill) async {
    final String sanitizedCustomerName = bill.customer.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_');
    final String fileName = '${bill.invoiceNumber}_$sanitizedCustomerName.pdf';
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}
