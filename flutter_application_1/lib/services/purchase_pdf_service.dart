import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/purchase_bill.dart';
import '../models/business_profile.dart';
import '../utils/number_to_words.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class PurchasePdfService {
  static Future<Uint8List> generatePdf(PurchaseBill bill, BusinessProfile profile) async {
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
            _buildVendorInfo(bill),
            pw.SizedBox(height: 20),
            _buildItemTable(bill, font, fontBold),
            pw.SizedBox(height: 20),
            _buildTotals(bill, fontBold),
            pw.SizedBox(height: 20),
            _buildFooter(bill, profile, fontBold),
          ];
        },
        footer: (context) {
          final websiteUrl = profile.website.isNotEmpty ? profile.website : 'www.chaarusfoods.in';
          return pw.Container(
            alignment: pw.Alignment.center,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(websiteUrl, style: const pw.TextStyle(color: PdfColors.blueGrey, fontSize: 10)),
          );
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
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (profile.logoPath.isNotEmpty)
              pw.Container(
                width: 60,
                height: 60,
                child: pw.Image(
                  pw.MemoryImage(File(profile.logoPath).readAsBytesSync()),
                  fit: pw.BoxFit.contain,
                ),
              )
            else
              pw.Container(
                width: 60,
                height: 60,
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey400),
                ),
                child: pw.Center(child: pw.Text('LOGO', style: const pw.TextStyle(color: PdfColors.grey600, fontSize: 12))),
              ),
            pw.SizedBox(width: 16),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(profile.businessName, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                if (profile.ownerName.isNotEmpty) pw.Text(profile.ownerName),
                if (profile.address.isNotEmpty) pw.Text(profile.address),
                if (profile.phone.isNotEmpty) pw.Text('Phone: ${profile.phone}'),
                if (profile.email.isNotEmpty) pw.Text('Email: ${profile.email}'),
                if (profile.fssaiNumber.isNotEmpty) pw.Text('FSSAI: ${profile.fssaiNumber}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ]
        ),
        pw.Text('Purchase Bill', style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
      ],
    );
  }

  static pw.Widget _buildInvoiceInfo(PurchaseBill bill) {
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
              pw.Text('Status: ${bill.paymentStatus}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: bill.paymentStatus == 'Paid' ? PdfColors.green700 : PdfColors.red700)),
            ],
          ),
        )
      ],
    );
  }

  static pw.Widget _buildVendorInfo(PurchaseBill bill) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
        pw.SizedBox(height: 4),
        pw.Text(bill.vendor.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        if (bill.vendor.address.isNotEmpty) pw.Text(bill.vendor.address),
        if (bill.vendor.phone.isNotEmpty) pw.Text('Phone: ${bill.vendor.phone}'),
        if (bill.vendor.email.isNotEmpty) pw.Text('Email: ${bill.vendor.email}'),
      ],
    );
  }

  static pw.Widget _buildItemTable(PurchaseBill bill, pw.Font font, pw.Font fontBold) {
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

  static pw.Widget _buildTotals(PurchaseBill bill, pw.Font fontBold) {
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
                    pw.Text(CurrencyFormatter.format(bill.totalAmount).replaceAll('₹', 'Rs ')),
                  ],
                ),
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Total Discount:'),
                    pw.Text(CurrencyFormatter.format(0.0).replaceAll('₹', 'Rs ')),
                  ],
                ),
                pw.Divider(color: PdfColors.grey300),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text(CurrencyFormatter.format(bill.totalAmount).replaceAll('₹', 'Rs '), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(PurchaseBill bill, BusinessProfile profile, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Amount in Words:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Text(NumberToWords.convert(bill.totalAmount)),
        pw.SizedBox(height: 20),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            // Left: Payment Method
            pw.Expanded(
              flex: 1,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Payment Method: ${bill.paymentMethod}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ),
            
            // Middle Spacer
            pw.Spacer(flex: 1),

            // Right: Signature
            pw.Expanded(
              flex: 1,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  if (profile.signaturePath.isNotEmpty && File(profile.signaturePath).existsSync())
                    pw.Container(
                      width: 100,
                      height: 50,
                      child: pw.Image(
                        pw.MemoryImage(File(profile.signaturePath).readAsBytesSync()),
                        fit: pw.BoxFit.contain,
                        alignment: pw.Alignment.centerRight,
                      ),
                    )
                  else
                    pw.SizedBox(height: 50),
                  pw.Container(width: 120, height: 1, color: PdfColors.black),
                  pw.SizedBox(height: 4),
                  pw.Container(
                    width: 120,
                    alignment: pw.Alignment.center,
                    child: pw.Text('Authorized Signature', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static Future<void> sharePdf(Uint8List bytes, PurchaseBill bill) async {
    final String sanitizedVendorName = bill.vendor.name.replaceAll(RegExp(r'[^\w\s]+'), '').trim().replaceAll(' ', '_');
    final String fileName = '${bill.invoiceNumber}_$sanitizedVendorName.pdf';
    await Printing.sharePdf(bytes: bytes, filename: fileName);
  }

  static Future<void> printPdf(Uint8List bytes) async {
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }
}



