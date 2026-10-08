import 'package:hive_flutter/hive_flutter.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/bill_item.dart';
import '../models/bill.dart';
import '../models/vendor.dart';
import '../models/purchase_bill.dart';
import 'notification_service.dart';

class StorageService {
  static const String _settingsBoxName = 'settings';
  static const String _billsBoxName = 'bills';
  static const String _purchaseBillsBoxName = 'purchase_bills';

  Box? _settingsBox;
  Box<Bill>? _billsBox;
  Box<PurchaseBill>? _purchaseBillsBox;

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(BusinessProfileAdapter());
    Hive.registerAdapter(CustomerAdapter());
    Hive.registerAdapter(BillItemAdapter());
    Hive.registerAdapter(BillAdapter());
    Hive.registerAdapter(VendorAdapter());
    Hive.registerAdapter(PurchaseBillAdapter());

    _settingsBox = await Hive.openBox(_settingsBoxName);
    _billsBox = await Hive.openBox<Bill>(_billsBoxName);
    _purchaseBillsBox = await Hive.openBox<PurchaseBill>(_purchaseBillsBoxName);
  }

  Box get box => _settingsBox!;

  // --- Business Profile ---
  BusinessProfile getBusinessProfile() {
    final map = _settingsBox?.get('businessProfile');
    if (map != null) {
      return BusinessProfile.fromMap(map);
    }
    return BusinessProfile();
  }

  Future<void> saveBusinessProfile(BusinessProfile profile) async {
    await _settingsBox?.put('businessProfile', profile.toMap());
  }

  // --- Settings ---
  String getInvoicePrefix() {
    return _settingsBox?.get('invoicePrefix', defaultValue: 'INV-') as String;
  }

  Future<void> saveInvoicePrefix(String prefix) async {
    await _settingsBox?.put('invoicePrefix', prefix);
  }

  int getNextInvoiceNumber() {
    return _settingsBox?.get('nextInvoiceNumber', defaultValue: 1) as int;
  }

  Future<void> saveNextInvoiceNumber(int number) async {
    await _settingsBox?.put('nextInvoiceNumber', number);
  }
  
  String getGeneratedInvoiceNumber() {
    final prefix = getInvoicePrefix();
    final number = getNextInvoiceNumber();
    return '$prefix${number.toString().padLeft(4, '0')}';
  }

  Future<void> incrementInvoiceNumber() async {
    final current = getNextInvoiceNumber();
    await saveNextInvoiceNumber(current + 1);
  }

  // --- Bills ---
  List<Bill> getBills() {
    if (_billsBox == null) return [];
    final bills = _billsBox!.values.toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  Future<void> saveBill(Bill bill) async {
    await _billsBox?.put(bill.id, bill);
    await notificationService.updateDailyReminder();
  }

  Future<void> deleteBill(String id) async {
    await _billsBox?.delete(id);
    await notificationService.updateDailyReminder();
  }

  // --- Purchase Bills ---
  List<PurchaseBill> getPurchaseBills() {
    if (_purchaseBillsBox == null) return [];
    final bills = _purchaseBillsBox!.values.toList();
    bills.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return bills;
  }

  Future<void> savePurchaseBill(PurchaseBill bill) async {
    await _purchaseBillsBox?.put(bill.id, bill);
  }

  Future<void> deletePurchaseBill(String id) async {
    await _purchaseBillsBox?.delete(id);
  }

  // --- Reset ---
  Future<void> resetAllData() async {
    await _settingsBox?.clear();
    await _billsBox?.clear();
    await _purchaseBillsBox?.clear();
  }
}
