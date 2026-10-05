import 'package:hive/hive.dart';
import 'customer.dart';
import 'bill_item.dart';

class Bill {
  String id;
  String invoiceNumber;
  DateTime invoiceDate;
  Customer customer;
  List<BillItem> items;
  double subtotal;
  double discount;
  double grandTotal;
  String paymentStatus;
  String paymentMethod;
  String notes;
  DateTime createdAt;

  Bill({
    required this.id,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customer,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes = '',
    required this.createdAt,
  });
}

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 3;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String,
      invoiceNumber: fields[1] as String,
      invoiceDate: fields[2] as DateTime,
      customer: fields[3] as Customer,
      items: (fields[4] as List).cast<BillItem>(),
      subtotal: fields[5] as double,
      discount: fields[6] as double,
      grandTotal: fields[7] as double,
      paymentStatus: fields[8] as String,
      paymentMethod: fields[9] as String,
      notes: fields[10] as String? ?? '',
      createdAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.invoiceNumber)
      ..writeByte(2)
      ..write(obj.invoiceDate)
      ..writeByte(3)
      ..write(obj.customer)
      ..writeByte(4)
      ..write(obj.items)
      ..writeByte(5)
      ..write(obj.subtotal)
      ..writeByte(6)
      ..write(obj.discount)
      ..writeByte(7)
      ..write(obj.grandTotal)
      ..writeByte(8)
      ..write(obj.paymentStatus)
      ..writeByte(9)
      ..write(obj.paymentMethod)
      ..writeByte(10)
      ..write(obj.notes)
      ..writeByte(11)
      ..write(obj.createdAt);
  }
}
