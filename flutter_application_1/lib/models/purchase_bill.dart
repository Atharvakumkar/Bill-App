import 'package:hive/hive.dart';
import 'vendor.dart';
import 'bill_item.dart';

class PurchaseBill {
  String id;
  String invoiceNumber;
  DateTime invoiceDate;
  Vendor vendor;
  List<BillItem> items;
  double totalAmount;
  String paymentStatus;
  String paymentMethod;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;

  PurchaseBill({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.vendor,
    required this.items,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes = '',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoiceNumber': invoiceNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'vendor': vendor.toMap(),
      'items': items.map((i) => i.toMap()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory PurchaseBill.fromMap(Map<dynamic, dynamic> map) {
    return PurchaseBill(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      invoiceDate: DateTime.tryParse(map['invoiceDate'] ?? '') ?? DateTime.now(),
      vendor: Vendor.fromMap(map['vendor'] ?? {}),
      items: (map['items'] as List?)?.map((i) => BillItem.fromMap(i)).toList() ?? [],
      totalAmount: (map['totalAmount'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'Unpaid',
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class PurchaseBillAdapter extends TypeAdapter<PurchaseBill> {
  @override
  final int typeId = 5;

  @override
  PurchaseBill read(BinaryReader reader) {
    return PurchaseBill.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, PurchaseBill obj) {
    writer.writeMap(obj.toMap());
  }
}

