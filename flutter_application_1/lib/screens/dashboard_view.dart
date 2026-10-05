import 'package:flutter/material.dart';
import '../main.dart';
import '../models/bill.dart';
import '../utils/currency_formatter.dart';
import 'create_bill_screen.dart';
import 'preview_screen.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Bill> _bills = [];
  double _totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bills = storageService.getBills();
      _totalAmount = _bills.fold(0, (sum, bill) => sum + bill.grandTotal);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recentBills = _bills.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Maker'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateBillScreen()),
                );
                _loadData();
              },
              icon: const Icon(Icons.add),
              label: const Text('CREATE NEW BILL'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Bills Created',
                    _bills.length.toString(),
                    Icons.receipt,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryCard(
                    'Total Amount',
                    CurrencyFormatter.format(_totalAmount),
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Recent Bills',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (recentBills.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No bills created yet.'),
                ),
              )
            else
              ...recentBills.map((bill) => Card(
                    child: ListTile(
                      title: Text(bill.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(bill.customer.name),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(CurrencyFormatter.format(bill.grandTotal),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(bill.paymentStatus,
                              style: TextStyle(
                                  color: bill.paymentStatus == 'Paid' ? Colors.green : Colors.red,
                                  fontSize: 12)),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => PreviewScreen(bill: bill)),
                        );
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
