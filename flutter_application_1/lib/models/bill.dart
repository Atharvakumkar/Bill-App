import 'package:hive/hive.dart';
import 'customer.dart';
import 'bill_item.dart';

class Bill {
  String id;
  String invoiceNumber;
  DateTime invoiceDate;
  DateTime dueDate;
  Customer customer;
  List<BillItem> items;
  double subtotal;
  double discount;
  double grandTotal;
  String paymentStatus;
  String paymentMethod;
  String notes;
  DateTime createdAt;
  DateTime updatedAt;

  Bill({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.dueDate,
    required this.customer,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
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
      'dueDate': dueDate.toIso8601String(),
      'customer': customer.toMap(),
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'grandTotal': grandTotal,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Bill.fromMap(Map<dynamic, dynamic> map) {
    return Bill(
      id: map['id'] ?? '',
      invoiceNumber: map['invoiceNumber'] ?? '',
      invoiceDate: DateTime.tryParse(map['invoiceDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(map['dueDate'] ?? '') ?? DateTime.now(),
      customer: Customer.fromMap(map['customer'] ?? {}),
      items: (map['items'] as List?)?.map((i) => BillItem.fromMap(i)).toList() ?? [],
      subtotal: (map['subtotal'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      grandTotal: (map['grandTotal'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? 'Unpaid',
      paymentMethod: map['paymentMethod'] ?? 'Cash',
      notes: map['notes'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 3;

  @override
  Bill read(BinaryReader reader) {
    return Bill.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer.writeMap(obj.toMap());
  }
}
