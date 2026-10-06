import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/purchase_bill.dart';
import '../utils/currency_formatter.dart';
import '../widgets/glass_container.dart';
import 'create_purchase_bill_screen.dart';
import 'purchase_preview_screen.dart';

class PurchaseHistoryScreen extends StatefulWidget {
  const PurchaseHistoryScreen({Key? key}) : super(key: key);

  @override
  State<PurchaseHistoryScreen> createState() => _PurchaseHistoryScreenState();
}

class _PurchaseHistoryScreenState extends State<PurchaseHistoryScreen> {
  List<PurchaseBill> _bills = [];
  List<PurchaseBill> _filteredBills = [];
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchCtrl.addListener(_filterBills);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadBills() {
    setState(() {
      _bills = storageService.getPurchaseBills();
      _filteredBills = _bills;
    });
  }

  void _filterBills() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredBills = _bills.where((bill) {
        return bill.invoiceNumber.toLowerCase().contains(query) ||
            bill.vendor.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _deletePurchaseBill(PurchaseBill bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text(
          'Are you sure you want to delete invoice ${bill.invoiceNumber}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await storageService.deletePurchaseBill(bill.id);
              if (mounted) {
                Navigator.pop(context);
                _loadBills();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBillOptions(BuildContext context, PurchaseBill bill) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.remove_red_eye),
              title: const Text('View / Print'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PurchasePreviewScreen(bill: bill)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreatePurchaseBillScreen(existingBill: bill),
                  ),
                );
                _loadBills();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePurchaseBill(bill);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Purchase History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                labelText: 'Search bills...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: _filteredBills.isEmpty
                ? const Center(child: Text('No purchase bills found.'))
                : ListView.builder(
                    itemCount: _filteredBills.length,
                    itemBuilder: (context, index) {
                      final bill = _filteredBills[index];
                      return GlassContainer(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PurchasePreviewScreen(bill: bill),
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            bill.invoiceNumber,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bill.vendor.name),
                              Text(
                                DateFormat('dd MMM yyyy')
                                    .format(bill.invoiceDate),
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    CurrencyFormatter.format(bill.totalAmount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    bill.paymentStatus,
                                    style: TextStyle(
                                      color: bill.paymentStatus == 'Paid'
                                          ? Colors.green
                                          : Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert),
                                onPressed: () =>
                                    _showBillOptions(context, bill),
                              ),
                            ],
                          ),
                          onLongPress: () => _showBillOptions(context, bill),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


