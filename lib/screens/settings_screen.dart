import 'package:flutter/material.dart';
import '../models/business_profile.dart';
import '../services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _businessNameCtrl = TextEditingController();
  final _ownerNameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  
  String _defaultPayment = 'Cash';

  final _invoicePrefixCtrl = TextEditingController();
  final _nextInvoiceNumCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    final profile = StorageService.getProfile();
    _businessNameCtrl.text = profile.businessName;
    _ownerNameCtrl.text = profile.ownerName;
    _addressCtrl.text = profile.businessAddress;
    _phoneCtrl.text = profile.phoneNumber;
    _upiCtrl.text = profile.upiId;
    if (profile.defaultPaymentMethod.isNotEmpty) {
      _defaultPayment = profile.defaultPaymentMethod;
    }

    _invoicePrefixCtrl.text = StorageService.settingsBox.get('invoicePrefix', defaultValue: 'INV-') as String;
    _nextInvoiceNumCtrl.text = (StorageService.settingsBox.get('nextInvoiceNumber', defaultValue: 1) as int).toString();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = BusinessProfile(
      businessName: _businessNameCtrl.text.trim(),
      ownerName: _ownerNameCtrl.text.trim(),
      businessAddress: _addressCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      upiId: _upiCtrl.text.trim(),
      defaultPaymentMethod: _defaultPayment,
    );
    await StorageService.saveProfile(profile);

    await StorageService.settingsBox.put('invoicePrefix', _invoicePrefixCtrl.text.trim());
    await StorageService.settingsBox.put('nextInvoiceNumber', int.tryParse(_nextInvoiceNumCtrl.text.trim()) ?? 1);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully!')));
  }

  void _resetData() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Application Data'),
        content: const Text('Are you sure you want to delete all bills and settings? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await StorageService.clearAllData();
              if (!mounted) return;
              Navigator.pop(ctx);
              _loadSettings();
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data has been reset')));
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text('Business Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextFormField(controller: _businessNameCtrl, decoration: const InputDecoration(labelText: 'Business Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _ownerNameCtrl, decoration: const InputDecoration(labelText: 'Owner Name', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextFormField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Business Address', border: OutlineInputBorder()), maxLines: 2),
          const SizedBox(height: 12),
          TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          TextFormField(controller: _upiCtrl, decoration: const InputDecoration(labelText: 'UPI ID', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _defaultPayment,
            decoration: const InputDecoration(labelText: 'Default Payment Method', border: OutlineInputBorder()),
            items: ['Cash', 'UPI', 'Bank Transfer', 'Card'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (s) => setState(() => _defaultPayment = s!),
          ),
          const SizedBox(height: 24),
          const Text('Invoice Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(controller: _invoicePrefixCtrl, decoration: const InputDecoration(labelText: 'Invoice Prefix', border: OutlineInputBorder())),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(controller: _nextInvoiceNumCtrl, decoration: const InputDecoration(labelText: 'Next Number', border: OutlineInputBorder()), keyboardType: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('SAVE SETTINGS', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _resetData,
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            label: const Text('RESET APPLICATION DATA', style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
