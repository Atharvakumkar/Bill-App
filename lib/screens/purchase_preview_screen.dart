import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../main.dart';
import '../models/purchase_bill.dart';
import '../services/purchase_pdf_service.dart';
import 'create_purchase_bill_screen.dart';

class PurchasePreviewScreen extends StatefulWidget {
  final PurchaseBill bill;

  const PurchasePreviewScreen({Key? key, required this.bill}) : super(key: key);

  @override
  State<PurchasePreviewScreen> createState() => _PurchasePreviewScreenState();
}

class _PurchasePreviewScreenState extends State<PurchasePreviewScreen> {
  Uint8List? _pdfBytes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    final profile = storageService.getBusinessProfile();
    try {
      final bytes = await PurchasePdfService.generatePdf(widget.bill, profile);
      setState(() {
        _pdfBytes = bytes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Bill Preview'),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Bill',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePurchaseBillScreen(existingBill: widget.bill),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => PurchasePdfService.sharePdf(_pdfBytes!, widget.bill),
              tooltip: 'Share',
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => PurchasePdfService.printPdf(_pdfBytes!),
              tooltip: 'Print',
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfBytes == null
          ? const Center(child: Text('Failed to generate PDF'))
          : PdfPreview(
              build: (format) => _pdfBytes!,
              allowPrinting: true,
              allowSharing: true,
              canChangeOrientation: false,
              canChangePageFormat: false,
            ),
    );
  }
}



