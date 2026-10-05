import 'package:flutter/material.dart';
import '../main.dart';
import '../models/business_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late BusinessProfile _profile;
  late TextEditingController _prefixCtrl;
  late TextEditingController _nextNoCtrl;

  @override
  void initState() {
    super.initState();
    _profile = storageService.getBusinessProfile();
    _prefixCtrl = TextEditingController(text: storageService.getInvoicePrefix());
    _nextNoCtrl = TextEditingController(text: storageService.getNextInvoiceNumber().toString());
  }

  @override
  void dispose() {
    _prefixCtrl.dispose();
    _nextNoCtrl.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await storageService.saveBusinessProfile(_profile);
    await storageService.saveInvoicePrefix(_prefixCtrl.text);
    await storageService.saveNextInvoiceNumber(int.parse(_nextNoCtrl.text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved successfully')));
    }
  }

  void _resetData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Application Data'),
        content: const Text('Are you sure you want to delete all bills and settings? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await storageService.resetAllData();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data reset.')));
                // Reload app or just setState
                setState(() {
                  _profile = BusinessProfile();
                  _prefixCtrl.text = 'INV-';
                  _nextNoCtrl.text = '1';
                });
              }
            },
            child: const Text('Reset All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings, tooltip: 'Save'),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Business Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _profile.businessName,
                      decoration: const InputDecoration(labelText: 'Business Name *'),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                      onSaved: (val) => _profile.businessName = val ?? '',
                    ),
                    TextFormField(
                      initialValue: _profile.ownerName,
                      decoration: const InputDecoration(labelText: 'Owner Name'),
                      onSaved: (val) => _profile.ownerName = val ?? '',
                    ),
                    TextFormField(
                      initialValue: _profile.address,
                      decoration: const InputDecoration(labelText: 'Business Address'),
                      maxLines: 2,
                      onSaved: (val) => _profile.address = val ?? '',
                    ),
                    TextFormField(
                      initialValue: _profile.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number'),
                      keyboardType: TextInputType.phone,
                      onSaved: (val) => _profile.phone = val ?? '',
                    ),
                    TextFormField(
                      initialValue: _profile.email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      onSaved: (val) => _profile.email = val ?? '',
                    ),
                    TextFormField(
                      initialValue: _profile.upiId,
                      decoration: const InputDecoration(labelText: 'UPI ID'),
                      onSaved: (val) => _profile.upiId = val ?? '',
                    ),
                    DropdownButtonFormField<String>(
                      value: _profile.defaultPaymentMethod,
                      decoration: const InputDecoration(labelText: 'Default Payment Method'),
                      items: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Other']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (val) => setState(() => _profile.defaultPaymentMethod = val!),
                      onSaved: (val) => _profile.defaultPaymentMethod = val ?? 'Cash',
                    ),
                    TextFormField(
                      initialValue: _profile.termsAndConditions,
                      decoration: const InputDecoration(labelText: 'Terms & Conditions'),
                      maxLines: 3,
                      onSaved: (val) => _profile.termsAndConditions = val ?? '',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Invoice Settings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _prefixCtrl,
                      decoration: const InputDecoration(labelText: 'Invoice Prefix'),
                    ),
                    TextFormField(
                      controller: _nextNoCtrl,
                      decoration: const InputDecoration(labelText: 'Next Invoice Number'),
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (int.tryParse(val) == null) return 'Must be a number';
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              child: const Text('SAVE SETTINGS'),
            ),
            const SizedBox(height: 32),
            OutlinedButton(
              onPressed: _resetData,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('RESET ALL APPLICATION DATA'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
