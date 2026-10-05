import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../services/storage_service.dart';
import '../utils/currency_formatter.dart';
import 'preview_screen.dart';

class BillHistoryScreen extends StatefulWidget {
  const BillHistoryScreen({super.key});

  @override
  State<BillHistoryScreen> createState() => _BillHistoryScreenState();
}

class _BillHistoryScreenState extends State<BillHistoryScreen> {
  List<Bill> _allBills = [];
  List<Bill> _filteredBills = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  void _loadBills() {
    setState(() {
      _allBills = StorageService.getAllBills();
      _filterBills(_searchQuery);
    });
  }

  void _filterBills(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredBills = _allBills;
    } else {
      _filteredBills = _allBills.where((b) => 
        b.invoiceNumber.toLowerCase().contains(query.toLowerCase()) ||
        b.customer.name.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    setState(() {});
  }

  void _deleteBill(Bill bill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bill'),
        content: Text('Are you sure you want to delete ${bill.invoiceNumber}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService.deleteBill(bill.id);
              if (!mounted) return;
              Navigator.pop(ctx);
              _loadBills();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search by Invoice Number or Customer',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: _filterBills,
          ),
        ),
        Expanded(
          child: _filteredBills.isEmpty
              ? const Center(child: Text('No bills found.'))
              : ListView.builder(
                  itemCount: _filteredBills.length,
                  itemBuilder: (context, index) {
                    final bill = _filteredBills[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: ListTile(
                        title: Text(bill.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${bill.customer.name}\n${DateFormat('dd MMM yyyy').format(bill.invoiceDate)}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(CurrencyFormatter.format(bill.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(bill.paymentStatus, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: bill.paymentStatus == 'PAID' ? Colors.green : Colors.red)),
                              ],
                            ),
                            PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'view') {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(bill: bill)));
                                } else if (value == 'delete') {
                                  _deleteBill(bill);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'view', child: Text('View / Print')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                              ],
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () {
                           Navigator.push(context, MaterialPageRoute(builder: (context) => PreviewScreen(bill: bill)));
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
