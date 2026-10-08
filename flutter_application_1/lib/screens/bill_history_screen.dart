import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../main.dart';
import '../models/bill.dart';
import '../utils/currency_formatter.dart';
import '../widgets/glass_container.dart';
import 'create_bill_screen.dart';
import 'preview_screen.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({Key? key}) : super(key: key);

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  List<Bill> _bills = [];
  List<Bill> _filteredBills = [];
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
      _bills = storageService.getBills();
      _filteredBills = _bills;
    });
  }

  void _filterBills() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      _filteredBills = _bills.where((bill) {
        return bill.invoiceNumber.toLowerCase().contains(query) ||
            bill.customer.name.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _deleteBill(Bill bill) {
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
              await storageService.deleteBill(bill.id);
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

  void _showBillOptions(BuildContext context, Bill bill) {
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
                  MaterialPageRoute(builder: (_) => PreviewScreen(bill: bill)),
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
                    builder: (_) => CreateBillScreen(existingBill: bill),
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
                _deleteBill(bill);
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
      appBar: AppBar(title: const Text('Bill History')),
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
            child: ValueListenableBuilder(
              valueListenable: storageService.listenToBills(),
              builder: (context, _, __) {
                // Re-fetch and re-filter bills on change
                _bills = storageService.getBills();
                final query = _searchCtrl.text.toLowerCase();
                final currentFiltered = _bills.where((bill) {
                  return bill.invoiceNumber.toLowerCase().contains(query) ||
                      bill.customer.name.toLowerCase().contains(query);
                }).toList();
                
                if (currentFiltered.isEmpty) {
                  return const Center(child: Text('No bills found.'));
                }
                
                return ListView.builder(
                    itemCount: currentFiltered.length,
                    itemBuilder: (context, index) {
                      final bill = currentFiltered[index];
                      return GlassContainer(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PreviewScreen(bill: bill),
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
                              Text(bill.customer.name),
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
                                    CurrencyFormatter.format(bill.grandTotal),
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
                  );
              },
            ),
          ),
        ],
      ),
    );
  }
}
