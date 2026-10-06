import 'package:hive/hive.dart';

class Vendor {
  String name;
  String phone;
  String email;
  String address;

  Vendor({
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

  factory Vendor.fromMap(Map<dynamic, dynamic> map) {
    return Vendor(
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
    );
  }
}

class VendorAdapter extends TypeAdapter<Vendor> {
  @override
  final int typeId = 4;

  @override
  Vendor read(BinaryReader reader) {
    return Vendor.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, Vendor obj) {
    writer.writeMap(obj.toMap());
  }
}

