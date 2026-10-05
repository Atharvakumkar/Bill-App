import 'package:flutter/material.dart';
import 'create_bill_screen.dart';
import 'bill_history_screen.dart';
import 'settings_screen.dart';
import '../services/storage_service.dart';
import '../models/bill.dart';
import '../utils/currency_formatter.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bill Maker'),
        centerTitle: true,
      ),
      body: _selectedIndex == 0 
          ? const DashboardView() 
          : _selectedIndex == 1 
              ? const BillHistoryScreen() 
              : const SettingsScreen(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  List<Bill> recentBills = [];
  int totalBills = 0;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final bills = StorageService.getAllBills();
    double amount = 0;
    for (var b in bills) {
      amount += b.grandTotal;
    }
    
    setState(() {
      totalBills = bills.length;
      totalAmount = amount;
      recentBills = bills.take(5).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async { _loadData(); },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CreateBillScreen()),
              ).then((_) => _loadData());
            },
            icon: const Icon(Icons.add),
            label: const Text('CREATE NEW BILL'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(context, 'Bills Created', totalBills.toString(), Icons.receipt),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(context, 'Total Amount', CurrencyFormatter.format(totalAmount), Icons.account_balance_wallet),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text('Recent Bills', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (recentBills.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text('No bills created yet.'),
              ),
            )
          else
            ...recentBills.map((bill) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                title: Text(bill.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${bill.customer.name}\n${DateFormat('dd MMM yyyy').format(bill.invoiceDate)}'),
                trailing: Text(CurrencyFormatter.format(bill.grandTotal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
