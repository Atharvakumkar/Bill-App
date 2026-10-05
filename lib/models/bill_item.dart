import 'package:hive/hive.dart';

class BillItem {
  String itemName;
  double quantity;
  double unitPrice;

  BillItem({
    required this.itemName,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => quantity * unitPrice;
}

class BillItemAdapter extends TypeAdapter<BillItem> {
  @override
  final int typeId = 2;

  @override
  BillItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BillItem(
      itemName: fields[0] as String,
      quantity: fields[1] as double,
      unitPrice: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, BillItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.itemName)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitPrice);
  }
}
