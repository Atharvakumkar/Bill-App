import 'package:hive/hive.dart';

class BusinessProfile {
  String businessName;
  String ownerName;
  String address;
  String phone;
  String email;
  String upiId;
  String logoPath;
  String defaultPaymentMethod;
  String termsAndConditions;

  BusinessProfile({
    this.businessName = '',
    this.ownerName = '',
    this.address = '',
    this.phone = '',
    this.email = '',
    this.upiId = '',
    this.logoPath = '',
    this.defaultPaymentMethod = 'Cash',
    this.termsAndConditions = 'Thank you for your business!',
  });

  Map<String, dynamic> toMap() {
    return {
      'businessName': businessName,
      'ownerName': ownerName,
      'address': address,
      'phone': phone,
      'email': email,
      'upiId': upiId,
      'logoPath': logoPath,
      'defaultPaymentMethod': defaultPaymentMethod,
      'termsAndConditions': termsAndConditions,
    };
  }

  factory BusinessProfile.fromMap(Map<dynamic, dynamic> map) {
    return BusinessProfile(
      businessName: map['businessName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      upiId: map['upiId'] ?? '',
      logoPath: map['logoPath'] ?? '',
      defaultPaymentMethod: map['defaultPaymentMethod'] ?? 'Cash',
      termsAndConditions: map['termsAndConditions'] ?? 'Thank you for your business!',
    );
  }
}

class BusinessProfileAdapter extends TypeAdapter<BusinessProfile> {
  @override
  final int typeId = 0;

  @override
  BusinessProfile read(BinaryReader reader) {
    return BusinessProfile.fromMap(reader.readMap());
  }

  @override
  void write(BinaryWriter writer, BusinessProfile obj) {
    writer.writeMap(obj.toMap());
  }
}
