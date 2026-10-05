import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../models/bill.dart';
import '../services/pdf_service.dart';
import '../services/storage_service.dart';

class PreviewScreen extends StatefulWidget {
  final Bill bill;

  const PreviewScreen({super.key, required this.bill});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  File? _pdfFile;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    final file = await PdfService.generateBillPdf(widget.bill);
    setState(() {
      _pdfFile = file;
    });
  }

  Future<void> _saveBill() async {
    await StorageService.saveBill(widget.bill);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bill saved successfully!')));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void _sharePdf() {
    if (_pdfFile != null) {
      Share.shareXFiles([XFile(_pdfFile!.path)], text: 'Invoice ${widget.bill.invoiceNumber}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Preview'),
        actions: [
          if (_pdfFile != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePdf,
            ),
        ],
      ),
      body: _pdfFile == null
          ? const Center(child: CircularProgressIndicator())
          : PdfPreview(
              build: (format) => _pdfFile!.readAsBytesSync(),
              allowSharing: false, 
              canChangeOrientation: false,
              canChangePageFormat: false,
              pdfFileName: _pdfFile!.path.split('/').last,
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            onPressed: _saveBill,
            icon: const Icon(Icons.save),
            label: const Text('SAVE BILL'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
