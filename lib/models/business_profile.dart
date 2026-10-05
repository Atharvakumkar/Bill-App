import 'package:hive/hive.dart';

class BusinessProfile {
  String businessName;
  String ownerName;
  String businessAddress;
  String phoneNumber;
  String upiId;
  String defaultPaymentMethod;

  BusinessProfile({
    this.businessName = '',
    this.ownerName = '',
    this.businessAddress = '',
    this.phoneNumber = '',
    this.upiId = '',
    this.defaultPaymentMethod = 'Cash',
  });
}

class BusinessProfileAdapter extends TypeAdapter<BusinessProfile> {
  @override
  final int typeId = 0;

  @override
  BusinessProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BusinessProfile(
      businessName: fields[0] as String? ?? '',
      ownerName: fields[1] as String? ?? '',
      businessAddress: fields[2] as String? ?? '',
      phoneNumber: fields[3] as String? ?? '',
      upiId: fields[4] as String? ?? '',
      defaultPaymentMethod: fields[5] as String? ?? 'Cash',
    );
  }

  @override
  void write(BinaryWriter writer, BusinessProfile obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.businessName)
      ..writeByte(1)
      ..write(obj.ownerName)
      ..writeByte(2)
      ..write(obj.businessAddress)
      ..writeByte(3)
      ..write(obj.phoneNumber)
      ..writeByte(4)
      ..write(obj.upiId)
      ..writeByte(5)
      ..write(obj.defaultPaymentMethod);
  }
}
