import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../main.dart';
import '../models/business_profile.dart';
import '../widgets/glass_container.dart';
import '../services/notification_service.dart';

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
    
    // Update notification schedule with new settings
    await notificationService.updateDailyReminder();

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
            _buildSectionHeader('Business Profile'),
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(label: 'Business Name *', initialValue: _profile.businessName, isRequired: true, onSaved: (v) => _profile.businessName = v),
                  _buildTextField(label: 'Owner Name', initialValue: _profile.ownerName, onSaved: (v) => _profile.ownerName = v),
                  _buildTextField(label: 'Business Address', initialValue: _profile.address, maxLines: 2, onSaved: (v) => _profile.address = v),
                  _buildTextField(label: 'Phone Number', initialValue: _profile.phone, keyboardType: TextInputType.phone, onSaved: (v) => _profile.phone = v),
                  _buildTextField(label: 'Email', initialValue: _profile.email, keyboardType: TextInputType.emailAddress, onSaved: (v) => _profile.email = v),
                  _buildTextField(label: 'Website', initialValue: _profile.website, onSaved: (v) => _profile.website = v),
                  _buildTextField(label: 'FSSAI Number', initialValue: _profile.fssaiNumber, onSaved: (v) => _profile.fssaiNumber = v),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Payment Settings'),
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildTextField(label: 'UPI ID', initialValue: _profile.upiId, onSaved: (v) => _profile.upiId = v),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _profile.defaultPaymentMethod,
                    decoration: const InputDecoration(labelText: 'Default Payment Method'),
                    items: ['Cash', 'UPI', 'Card', 'Bank Transfer', 'Other'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) => setState(() => _profile.defaultPaymentMethod = val!),
                    onSaved: (val) => _profile.defaultPaymentMethod = val ?? 'Cash',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Images & Brand'),
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildImagePickerRow(title: 'Select Logo', path: _profile.logoPath, icon: Icons.store, onPick: _pickLogo, onRemove: _removeLogo),
                  const Divider(height: 32),
                  _buildImagePickerRow(title: 'Select UPI QR', path: _profile.qrCodePath, icon: Icons.qr_code, onPick: _pickQrCode, onRemove: _removeQrCode),
                  const Divider(height: 32),
                  _buildImagePickerRow(title: 'Select Signature', path: _profile.signaturePath, icon: Icons.draw, onPick: _pickSignature, onRemove: _removeSignature),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Notification Settings'),
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Daily Unpaid Reminder'),
                    subtitle: const Text('Get notified daily about pending payments'),
                    value: storageService.box.get('notifications_enabled', defaultValue: true),
                    onChanged: (val) async {
                      await storageService.box.put('notifications_enabled', val);
                      setState(() {});
                    },
                  ),
                  if (storageService.box.get('notifications_enabled', defaultValue: true))
                    ListTile(
                      title: const Text('Notification Time'),
                      subtitle: Text(TimeOfDay(
                        hour: storageService.box.get('notification_hour', defaultValue: 9),
                        minute: storageService.box.get('notification_minute', defaultValue: 0),
                      ).format(context)),
                      trailing: const Icon(Icons.access_time),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay(
                            hour: storageService.box.get('notification_hour', defaultValue: 9),
                            minute: storageService.box.get('notification_minute', defaultValue: 0),
                          ),
                        );
                        if (time != null) {
                          await storageService.box.put('notification_hour', time.hour);
                          await storageService.box.put('notification_minute', time.minute);
                          setState(() {});
                          await notificationService.updateDailyReminder();
                        }
                      },
                    ),

                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Invoice Settings'),
            GlassContainer(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _prefixCtrl,
                    decoration: const InputDecoration(labelText: 'Invoice Prefix'),
                  ),
                  const SizedBox(height: 16),
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
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('RESET ALL APPLICATION DATA'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onSaved,
    bool isRequired = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(labelText: label),
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: isRequired ? (val) => val == null || val.trim().isEmpty ? 'Required' : null : null,
        onSaved: (val) => onSaved(val ?? ''),
      ),
    );
  }

  Widget _buildImagePickerRow({
    required String title,
    required String path,
    required IconData icon,
    required VoidCallback onPick,
    required VoidCallback onRemove,
  }) {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: path.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(path), fit: BoxFit.cover),
                )
              : Center(child: Icon(icon, color: Colors.grey, size: 40)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton.icon(
                onPressed: onPick,
                icon: Icon(icon, size: 18),
                label: Text(title),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              if (path.isNotEmpty)
                TextButton(
                  onPressed: onRemove,
                  child: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
