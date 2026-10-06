import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../models/purchase_bill.dart';
import '../models/bill_item.dart';
import '../models/vendor.dart';
import '../utils/calculations.dart';
import '../utils/currency_formatter.dart';
import '../widgets/glass_container.dart';
import 'purchase_preview_screen.dart';

class CreatePurchaseBillScreen extends StatefulWidget {
  final PurchaseBill? existingBill;

  const CreatePurchaseBillScreen({Key? key, this.existingBill}) : super(key: key);

  @override
  State<CreatePurchaseBillScreen> createState() => _CreatePurchaseBillScreenState();
}

class _CreatePurchaseBillScreenState extends State<CreatePurchaseBillScreen> {
  final _formKey = GlobalKey<FormState>();

  // Bill Details
  late TextEditingController _invoiceNoCtrl;
  DateTime _invoiceDate = DateTime.now();
  String _paymentStatus = 'Paid';
  String _paymentMethod = 'Cash';

  // Vendor Details
  final _vendorNameCtrl = TextEditingController();
  final _vendorPhoneCtrl = TextEditingController();
  final _vendorEmailCtrl = TextEditingController();
  final _vendorAddressCtrl = TextEditingController();

  // Items
  List<BillItem> _items = [];
  

  @override
  void initState() {
    super.initState();
    final profile = storageService.getBusinessProfile();
    _paymentMethod = profile.defaultPaymentMethod;

    if (widget.existingBill != null) {
      final b = widget.existingBill!;
      _invoiceNoCtrl = TextEditingController(text: b.invoiceNumber);
      _invoiceDate = b.invoiceDate;
      _paymentStatus = b.paymentStatus;
      _paymentMethod = b.paymentMethod;

      _vendorNameCtrl.text = b.vendor.name;
      _vendorPhoneCtrl.text = b.vendor.phone;
      _vendorEmailCtrl.text = b.vendor.email;
      _vendorAddressCtrl.text = b.vendor.address;

      _items = List.from(b.items);
      
    } else {
      _invoiceNoCtrl = TextEditingController(
        text: '',
      );
    }
  }

  @override
  void dispose() {
    _invoiceNoCtrl.dispose();
    _vendorNameCtrl.dispose();
    _vendorPhoneCtrl.dispose();
    _vendorEmailCtrl.dispose();
    _vendorAddressCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(
        BillItem(
          id: const Uuid().v4(),
          name: 'New Item',
          quantity: 1,
          unitPrice: 0,
        ),
      );
    });
    _editItem(_items.length - 1);
  }

  void _editItem(int index) {
    final item = _items[index];
    final nameCtrl = TextEditingController(text: item.name);
    final descCtrl = TextEditingController(text: item.description);
    final qtyCtrl = TextEditingController(text: item.quantity.toString());
    final priceCtrl = TextEditingController(text: item.unitPrice.toString());
    final discCtrl = TextEditingController(text: item.discount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(item.name == 'New Item' ? 'Add Item' : 'Edit Item'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Unit Price'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: discCtrl,
                  decoration: const InputDecoration(labelText: 'Discount'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item.name = nameCtrl.text.isEmpty
                      ? 'Unnamed Item'
                      : nameCtrl.text;
                  item.description = descCtrl.text;
                  item.quantity = double.tryParse(qtyCtrl.text) ?? 1;
                  item.unitPrice = double.tryParse(priceCtrl.text) ?? 0;
                  item.discount = 0;
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deleteItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _invoiceDate = picked;
      });
    }
  }

  void _previewBill() async {
    if (!_formKey.currentState!.validate()) return;

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Add at least one item')));
      return;
    }

    final bill = _buildPurchaseBillObject();

    // Check if new and we should increment counter
    if (widget.existingBill == null &&
        _invoiceNoCtrl.text == '') {
      await storageService.incrementInvoiceNumber();
    }

    await storageService.savePurchaseBill(bill);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PurchasePreviewScreen(bill: bill)),
      );
    }
  }

  PurchaseBill _buildPurchaseBillObject() {
    double subtotal = Calculations.calculateSubtotal(_items);

    return PurchaseBill(
      id: widget.existingBill?.id ?? const Uuid().v4(),
      invoiceNumber: _invoiceNoCtrl.text,
      invoiceDate: _invoiceDate,
      vendor: Vendor(
        name: _vendorNameCtrl.text,
        phone: _vendorPhoneCtrl.text,
        email: _vendorEmailCtrl.text,
        address: _vendorAddressCtrl.text,
      ),
      items: _items,
      totalAmount: subtotal,
      paymentStatus: _paymentStatus,
      paymentMethod: _paymentMethod,
      createdAt: widget.existingBill?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = Calculations.calculateSubtotal(_items);
    double grandTotal = subtotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingBill == null ? 'Create Purchase Bill' : 'Edit Purchase Bill'),
        actions: [
          IconButton(
            icon: const Icon(Icons.remove_red_eye),
            onPressed: _previewBill,
            tooltip: 'Preview',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Invoice Details
            const Text(
              'Invoice Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _invoiceNoCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Invoice Number',
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Invoice Date',
                        ),
                        child: Text(
                          DateFormat('dd MMM yyyy').format(_invoiceDate),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _paymentStatus,
                            decoration: const InputDecoration(
                              labelText: 'Payment Status',
                            ),
                            isExpanded: true,
                            items: ['Paid', 'Unpaid', 'Partial']
                                .map(
                                  (s) => DropdownMenuItem(
                                    value: s,
                                    child: Text(s, overflow: TextOverflow.ellipsis),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _paymentStatus = val!),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _paymentMethod,
                            decoration: const InputDecoration(
                              labelText: 'Payment Method',
                            ),
                            isExpanded: true,
                            items:
                                [
                                      'Cash',
                                      'UPI',
                                      'Card',
                                      'Bank Transfer',
                                      'Other',
                                    ]
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s, overflow: TextOverflow.ellipsis),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (val) =>
                                setState(() => _paymentMethod = val!),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Vendor Details
            const Text(
              'Vendor Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _vendorNameCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Vendor Name *',
                      ),
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vendorPhoneCtrl,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vendorEmailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _vendorAddressCtrl,
                      decoration: const InputDecoration(labelText: 'Address'),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Items',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            if (_items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No items added. Tap "Add Item" to start.'),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, index) {
                  final item = _items[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GlassContainer(
                      child: ListTile(
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              CurrencyFormatter.format(item.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () => _editItem(index),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _deleteItem(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),

            // Calculation Summary
            GlassContainer(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Subtotal'),
                        Text(CurrencyFormatter.format(subtotal)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(grandTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _previewBill,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: const Text('PREVIEW & SAVE'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}


