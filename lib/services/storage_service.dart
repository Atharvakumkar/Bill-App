import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/bill_item.dart';
import '../models/bill.dart';

class StorageService {
  static const String _billsBoxName = 'billsBox';
  static const String _profileBoxName = 'profileBox';
  static const String _settingsBoxName = 'settingsBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(BusinessProfileAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(BillItemAdapter());
    Hive.registerAdapter(BillAdapter());

    await Hive.openBox<Bill>(_billsBoxName);
    await Hive.openBox<BusinessProfile>(_profileBoxName);
    await Hive.openBox<dynamic>(_settingsBoxName);
  }

  static Box<Bill> get billsBox => Hive.box<Bill>(_billsBoxName);
  static Box<BusinessProfile> get profileBox => Hive.box<BusinessProfile>(_profileBoxName);
  static Box<dynamic> get settingsBox => Hive.box<dynamic>(_settingsBoxName);

  static BusinessProfile getProfile() {
    return profileBox.get('profile') ?? BusinessProfile();
  }

  static Future<void> saveProfile(BusinessProfile profile) async {
    await profileBox.put('profile', profile);
  }

  static String getNextInvoiceNumber() {
    int nextNumber = settingsBox.get('nextInvoiceNumber', defaultValue: 1) as int;
    String prefix = settingsBox.get('invoicePrefix', defaultValue: 'INV-') as String;
    return '$prefix${nextNumber.toString().padLeft(4, '0')}';
  }

  static Future<void> incrementInvoiceNumber() async {
    int nextNumber = settingsBox.get('nextInvoiceNumber', defaultValue: 1) as int;
    await settingsBox.put('nextInvoiceNumber', nextNumber + 1);
  }

  static Future<void> saveBill(Bill bill) async {
    await billsBox.put(bill.id, bill);
    await incrementInvoiceNumber();
  }

  static Future<void> updateBill(Bill bill) async {
    await billsBox.put(bill.id, bill);
  }

  static Future<void> deleteBill(String id) async {
    await billsBox.delete(id);
  }

  static List<Bill> getAllBills() {
    final bills = billsBox.values.toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  static Future<void> clearAllData() async {
    await billsBox.clear();
    await profileBox.clear();
    await settingsBox.clear();
  }
}
