import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bill.dart';
import '../models/purchase_bill.dart';
import '../models/business_profile.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import '../main.dart'; // To access storageService instance

class DataSyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription? _billsSubscription;
  StreamSubscription? _purchaseBillsSubscription;

  DataSyncService() {
    authService.authStateChanges.listen((User? user) {
      if (user != null) {
        _startSyncing(user.uid);
      } else {
        _stopSyncing();
      }
    });
  }

  void _startSyncing(String userId) {
    // 1. Push all local data to cloud first (in case they created bills offline before logging in)
    _pushLocalDataToCloud(userId);

    // 2. Listen for remote changes and update local Hive
    _billsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        try {
          final bill = Bill.fromMap(doc.data());
          storageService.saveBillLocalOnly(bill);
        } catch (e) {
          print("Error syncing bill from cloud: \$e");
        }
      }
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.removed) {
          storageService.deleteBillLocalOnly(docChange.doc.id);
        }
      }
    });

    _purchaseBillsSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('purchase_bills')
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        try {
          final bill = PurchaseBill.fromMap(doc.data());
          storageService.savePurchaseBillLocalOnly(bill);
        } catch (e) {
          print("Error syncing purchase bill from cloud: \$e");
        }
      }
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.removed) {
          storageService.deletePurchaseBillLocalOnly(docChange.doc.id);
        }
      }
    });

    _firestore.collection('users').doc(userId).snapshots().listen((doc) {
      if (doc.exists && doc.data() != null) {
        if (doc.data()!.containsKey('businessProfile')) {
          try {
            final profile = BusinessProfile.fromMap(doc.data()!['businessProfile']);
            storageService.saveBusinessProfileLocalOnly(profile);
          } catch(e) {
            print("Error syncing profile: \$e");
          }
        }
      }
    });
  }

  Future<void> _pushLocalDataToCloud(String userId) async {
    final localBills = storageService.getBills();
    for (var bill in localBills) {
      await pushBill(bill, userId: userId);
    }

    final localPurchaseBills = storageService.getPurchaseBills();
    for (var bill in localPurchaseBills) {
      await pushPurchaseBill(bill, userId: userId);
    }

    final profile = storageService.getBusinessProfile();
    if (profile.businessName.isNotEmpty) {
      await pushProfile(profile, userId: userId);
    }
  }

  void _stopSyncing() {
    _billsSubscription?.cancel();
    _purchaseBillsSubscription?.cancel();
  }

  // --- Outgoing Sync Methods ---

  Future<void> pushBill(Bill bill, {String? userId}) async {
    final uid = userId ?? authService.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(bill.id)
          .set(bill.toMap(), SetOptions(merge: true));
      print("Successfully pushed bill: ${bill.id}");
    } catch (e) {
      print("Error pushing bill ${bill.id}: $e");
    }
  }

  Future<void> deleteBill(String id, {String? userId}) async {
    final uid = userId ?? authService.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(id)
          .delete();
    } catch (e) {
      print("Error deleting bill $id: $e");
    }
  }

  Future<void> pushPurchaseBill(PurchaseBill bill, {String? userId}) async {
    final uid = userId ?? authService.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchase_bills')
          .doc(bill.id)
          .set(bill.toMap(), SetOptions(merge: true));
      print("Successfully pushed purchase bill: ${bill.id}");
    } catch (e) {
      print("Error pushing purchase bill ${bill.id}: $e");
    }
  }

  Future<void> deletePurchaseBill(String id, {String? userId}) async {
    final uid = userId ?? authService.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('purchase_bills')
          .doc(id)
          .delete();
    } catch (e) {
      print("Error deleting purchase bill $id: $e");
    }
  }

  Future<void> pushProfile(BusinessProfile profile, {String? userId}) async {
    final uid = userId ?? authService.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .set({'businessProfile': profile.toMap()}, SetOptions(merge: true));
      print("Successfully pushed profile");
    } catch (e) {
      print("Error pushing profile: $e");
    }
  }
}

final dataSyncService = DataSyncService();
