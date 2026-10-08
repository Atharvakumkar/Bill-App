import 'package:hive/hive.dart';

class BillItem {
  String id;
  String name;
  String description;
  double quantity;
  double unitPrice;
  double discount;

  BillItem({
    required this.id,
    required this.name,
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
  });

  double get total => (quantity * unitPrice) - discount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'discount': discount,
    };
  }

  factory BillItem.fromMap(Map<dynamic, dynamic> map) {
    return BillItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      quantity: (map['quantity'] ?? 1).toDouble(),
      unitPrice: (map['unitPrice'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
    );
  }
}

class BillItemAdapter extends TypeAdapter<BillItem> {
  @override
  final int typeId = 2;

  @override
  BillItem read(BinaryReader reader) {
    return BillItem.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, BillItem obj) {
    writer.writeMap(obj.toMap());
  }
}
