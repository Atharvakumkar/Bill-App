import 'package:hive/hive.dart';

class Customer {
  String name;
  String phone;
  String email;
  String address;

  Customer({
    required this.name,
    this.phone = '',
    this.email = '',
    this.address = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
    };
  }

  factory Customer.fromMap(Map<dynamic, dynamic> map) {
    return Customer(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }
}

class CustomerAdapter extends TypeAdapter<Customer> {
  @override
  final int typeId = 1;

  @override
  Customer read(BinaryReader reader) {
    return Customer.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, Customer obj) {
    writer.writeMap(obj.toMap());
  }
}
