import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/business_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

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

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profile.logoPath = pickedFile.path;
      });
    }
  }

  void _removeLogo() {
    setState(() {
      _profile.logoPath = '';
    });
  }

  Future<void> _pickQrCode() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profile.qrCodePath = pickedFile.path;
      });
    }
  }

  void _removeQrCode() {
    setState(() {
      _profile.qrCodePath = '';
    });
  }

  Future<void> _pickSignature() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profile.signaturePath = pickedFile.path;
      });
    }
  }

  void _removeSignature() {
    setState(() {
      _profile.signaturePath = '';
    });
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
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _profile.logoPath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_profile.logoPath), fit: BoxFit.cover),
                                )
                              : const Center(child: Icon(Icons.store, color: Colors.grey, size: 40)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickLogo,
                                icon: const Icon(Icons.image),
                                label: const Text('Select Logo'),
                              ),
                              if (_profile.logoPath.isNotEmpty)
                                TextButton(
                                  onPressed: _removeLogo,
                                  child: const Text('Remove Logo', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                      initialValue: _profile.fssaiNumber,
                      decoration: const InputDecoration(labelText: 'FSSAI Number'),
                      onSaved: (val) => _profile.fssaiNumber = val ?? '',
                    ),
                    TextFormField(
                      initialValue: _profile.website,
                      decoration: const InputDecoration(labelText: 'Website'),
                      onSaved: (val) => _profile.website = val ?? '',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _profile.qrCodePath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_profile.qrCodePath), fit: BoxFit.cover),
                                )
                              : const Center(child: Icon(Icons.qr_code, color: Colors.grey, size: 40)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickQrCode,
                                icon: const Icon(Icons.qr_code),
                                label: const Text('Select UPI QR'),
                              ),
                              if (_profile.qrCodePath.isNotEmpty)
                                TextButton(
                                  onPressed: _removeQrCode,
                                  child: const Text('Remove UPI QR', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: _profile.signaturePath.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(File(_profile.signaturePath), fit: BoxFit.contain),
                                )
                              : const Center(child: Icon(Icons.draw, color: Colors.grey, size: 40)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _pickSignature,
                                icon: const Icon(Icons.draw),
                                label: const Text('Select Signature'),
                              ),
                              if (_profile.signaturePath.isNotEmpty)
                                TextButton(
                                  onPressed: _removeSignature,
                                  child: const Text('Remove Signature', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        ),
                      ],
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
