import 'package:hive/hive.dart';

class Customer {
  String name;
  String phone;
  String address;

  Customer({
    required this.name,
    this.phone = '',
    this.address = '',
  });
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Customer(
      name: fields[0] as String,
      phone: fields[1] as String? ?? '',
      address: fields[2] as String? ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.phone)
      ..writeByte(2)
      ..write(obj.address);
  }
}
