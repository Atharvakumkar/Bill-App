import 'package:flutter/material.dart';
import '../main.dart';
import '../models/bill.dart';
import '../utils/currency_formatter.dart';
import '../widgets/glass_container.dart';
import 'preview_screen.dart';
import 'package:intl/intl.dart';

class PendingPaymentsScreen extends StatefulWidget {
  const PendingPaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PendingPaymentsScreen> createState() => _PendingPaymentsScreenState();
}

class _PendingPaymentsScreenState extends State<PendingPaymentsScreen> {
  List<Bill> _unpaidBills = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      final bills = storageService.getBills();
      _unpaidBills = bills.where((b) => b.paymentStatus == 'Unpaid').toList();
      _unpaidBills.sort((a, b) => b.invoiceDate.compareTo(a.invoiceDate));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Payments (Sales)'),
      ),
      body: _unpaidBills.isEmpty
          ? const Center(child: Text('No pending payments!'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _unpaidBills.length,
              itemBuilder: (context, index) {
                final bill = _unpaidBills[index];
                return GlassContainer(
                  margin: const EdgeInsets.only(bottom: 12),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PreviewScreen(bill: bill)),
                    );
                    _loadData();
                  },
                  child: ListTile(
                    title: Text('${bill.customer.name} - ${bill.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('dd MMM yyyy').format(bill.invoiceDate)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(CurrencyFormatter.format(bill.grandTotal),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.redAccent)),
                        const Text('Unpaid', style: TextStyle(color: Colors.red, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

