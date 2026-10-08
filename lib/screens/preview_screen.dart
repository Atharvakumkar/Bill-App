import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../main.dart';
import '../models/bill.dart';
import '../services/pdf_service.dart';
import 'create_bill_screen.dart';

class PreviewScreen extends StatefulWidget {
  final Bill bill;

  const PreviewScreen({Key? key, required this.bill}) : super(key: key);

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
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
      final bytes = await PdfService.generatePdf(widget.bill, profile);
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
        title: const Text('Bill Preview'),
        actions: [
          if (_pdfBytes != null) ...[
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Bill',
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateBillScreen(existingBill: widget.bill),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () => PdfService.sharePdf(_pdfBytes!, widget.bill),
              tooltip: 'Share',
            ),
            IconButton(
              icon: const Icon(Icons.print),
              onPressed: () => PdfService.printPdf(_pdfBytes!),
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
