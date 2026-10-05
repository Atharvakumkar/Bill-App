import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/bill.dart';
import '../models/customer.dart';
import '../models/bill_item.dart';
import '../services/storage_service.dart';
import '../widgets/customer_form.dart';
import '../widgets/bill_item_card.dart';
import '../widgets/bill_summary.dart';
import '../utils/calculations.dart';
import 'preview_screen.dart';

class CreateBillScreen extends StatefulWidget {
  const CreateBillScreen({super.key});

  @override
  State<CreateBillScreen> createState() => _CreateBillScreenState();
}

class _CreateBillScreenState extends State<CreateBillScreen> {
  final _formKey = GlobalKey<FormState>();

  final _invoiceNumberController = TextEditingController();
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _discountController = TextEditingController(text: '0');

  DateTime _invoiceDate = DateTime.now();
  String _paymentStatus = 'UNPAID';
  String _paymentMethod = 'Cash';

  List<BillItem> _items = [];
  double _subtotal = 0;
  double _discount = 0;
  double _grandTotal = 0;

  @override
  void initState() {
    super.initState();
    _invoiceNumberController.text = StorageService.getNextInvoiceNumber();
    final profile = StorageService.getProfile();
    if (profile.defaultPaymentMethod.isNotEmpty) {
      _paymentMethod = profile.defaultPaymentMethod;
    }
  }

  void _calculateTotals() {
    _subtotal = Calculations.calculateSubtotal(_items);
    _grandTotal = Calculations.calculateGrandTotal(_subtotal, _discount);
    setState(() {});
  }

  void _showItemDialog([BillItem? existingItem, int? index]) {
    final nameCtrl = TextEditingController(text: existingItem?.itemName ?? '');
    final qtyCtrl = TextEditingController(text: existingItem?.quantity.toString() ?? '1');
    final priceCtrl = TextEditingController(text: existingItem?.unitPrice.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existingItem == null ? 'Add Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item Name *'),
                ),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Unit Price *'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final name = nameCtrl.text.trim();
                final qty = double.tryParse(qtyCtrl.text) ?? 0;
                final price = double.tryParse(priceCtrl.text) ?? 0;

                if (name.isEmpty || qty <= 0 || price < 0) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter valid item details')));
                  return;
                }

                final newItem = BillItem(itemName: name, quantity: qty, unitPrice: price);

                setState(() {
                  if (existingItem != null && index != null) {
                    _items[index] = newItem;
                  } else {
                    _items.add(newItem);
                  }
                });
                _calculateTotals();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            )
          ],
        );
      }
    );
  }

  void _generatePreview() {
    if (!_formKey.currentState!.validate()) return;
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one item')));
      return;
    }

    final bill = Bill(
      id: const Uuid().v4(),
      invoiceNumber: _invoiceNumberController.text,
      invoiceDate: _invoiceDate,
      customer: Customer(
        name: _customerNameController.text.trim(),
        phone: _customerPhoneController.text.trim(),
        address: _customerAddressController.text.trim(),
      ),
      items: _items,
      subtotal: _subtotal,
      discount: _discount,
      grandTotal: _grandTotal,
      paymentStatus: _paymentStatus,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PreviewScreen(bill: bill)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Bill'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Invoice Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _invoiceNumberController,
                      decoration: const InputDecoration(labelText: 'Invoice Number', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final d = await showDatePicker(
                                context: context,
                                initialDate: _invoiceDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (d != null) {
                                setState(() => _invoiceDate = d);
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Date', border: OutlineInputBorder()),
                              child: Text(DateFormat('dd MMM yyyy').format(_invoiceDate)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _paymentStatus,
                            decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                            items: ['UNPAID', 'PAID'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (s) => setState(() => _paymentStatus = s!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _paymentMethod,
                      decoration: const InputDecoration(labelText: 'Payment Method', border: OutlineInputBorder()),
                      items: ['Cash', 'UPI', 'Bank Transfer', 'Card'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (s) => setState(() => _paymentMethod = s!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            CustomerForm(
              nameController: _customerNameController,
              phoneController: _customerPhoneController,
              addressController: _customerAddressController,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  onPressed: _showItemDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                )
              ],
            ),
            const SizedBox(height: 8),
            if (_items.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Center(child: Text('No items added')),
                ),
              )
            else
              ..._items.asMap().entries.map((entry) => BillItemCard(
                index: entry.key,
                item: entry.value,
                onEdit: () => _showItemDialog(entry.value, entry.key),
                onDelete: () {
                  setState(() => _items.removeAt(entry.key));
                  _calculateTotals();
                },
              )),
            const SizedBox(height: 16),
            BillSummary(
              subtotal: _subtotal,
              grandTotal: _grandTotal,
              discountController: _discountController,
              onDiscountChanged: (val) {
                _discount = val;
                _calculateTotals();
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _generatePreview,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('PREVIEW & GENERATE BILL'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
