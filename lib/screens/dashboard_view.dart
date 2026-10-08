import 'package:flutter/material.dart';
import '../main.dart';
import '../models/bill.dart';
import '../utils/currency_formatter.dart';
import '../widgets/glass_container.dart';
import 'create_bill_screen.dart';
import 'create_purchase_bill_screen.dart';
import '../models/purchase_bill.dart';
import 'package:intl/intl.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Bill> _bills = [];
  List<PurchaseBill> _purchaseBills = [];
  
  int _selectedYear = DateTime.now().year;
  int _selectedMonth = DateTime.now().month;

  double _salesTotal = 0;
  double _salesPaid = 0;
  double _salesUnpaid = 0;
  
  double _purchaseTotal = 0;
  double _purchasePaid = 0;
  double _purchaseUnpaid = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _bills = storageService.getBills();
      _purchaseBills = storageService.getPurchaseBills();
      _calculateStats();
    });
  }

  void _calculateStats() {
    _salesTotal = 0;
    _salesPaid = 0;
    _salesUnpaid = 0;
    
    _purchaseTotal = 0;
    _purchasePaid = 0;
    _purchaseUnpaid = 0;

    for (var bill in _bills) {
      if (bill.invoiceDate.year == _selectedYear && bill.invoiceDate.month == _selectedMonth) {
        _salesTotal += bill.grandTotal;
        if (bill.paymentStatus == 'Paid') {
          _salesPaid += bill.grandTotal;
        } else {
          _salesUnpaid += bill.grandTotal;
        }
      }
    }

    for (var bill in _purchaseBills) {
      if (bill.invoiceDate.year == _selectedYear && bill.invoiceDate.month == _selectedMonth) {
        _purchaseTotal += bill.totalAmount;
        if (bill.paymentStatus == 'Paid') {
          _purchasePaid += bill.totalAmount;
        } else {
          _purchaseUnpaid += bill.totalAmount;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ValueListenableBuilder(
        valueListenable: storageService.listenToBills(),
        builder: (context, _, __) {
          return ValueListenableBuilder(
            valueListenable: storageService.listenToPurchaseBills(),
            builder: (context, _, __) {
              _bills = storageService.getBills();
              _purchaseBills = storageService.getPurchaseBills();
              _calculateStats();

              final availableYears = <int>{
                DateTime.now().year,
                ..._bills.map((b) => b.invoiceDate.year),
                ..._purchaseBills.map((b) => b.invoiceDate.year),
              }.toList()..sort((a, b) => b.compareTo(a));

              final months = List.generate(12, (i) {
                final date = DateTime(2000, i + 1, 1);
                return {'value': i + 1, 'name': DateFormat('MMMM').format(date)};
              });

              return RefreshIndicator(
                onRefresh: () async => _loadData(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateBillScreen()),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('SALE'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreatePurchaseBillScreen()),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('PURCHASE'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedMonth,
                                items: months.map((m) {
                                  return DropdownMenuItem<int>(
                                    value: m['value'] as int,
                                    child: Text(m['name'] as String),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedMonth = value;
                                      _calculateStats();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GlassContainer(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: _selectedYear,
                                items: availableYears.map((year) {
                                  return DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedYear = value;
                                      _calculateStats();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildAnalyticsCard(
                            'Total Sales',
                            _salesTotal,
                            _salesPaid,
                            _salesUnpaid,
                            Icons.account_balance_wallet,
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildAnalyticsCard(
                            'Total Purchases',
                            _purchaseTotal,
                            _purchasePaid,
                            _purchaseUnpaid,
                            Icons.shopping_bag,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAnalyticsCard(String title, double total, double paid, double unpaid, IconData icon, Color color) {
    return GlassContainer(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7), fontSize: 13)),
          const SizedBox(height: 4),
          Text(CurrencyFormatter.format(total), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          _buildStatRow('Paid', paid, Colors.green),
          const SizedBox(height: 8),
          _buildStatRow('Unpaid', unpaid, Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(CurrencyFormatter.format(amount), style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
