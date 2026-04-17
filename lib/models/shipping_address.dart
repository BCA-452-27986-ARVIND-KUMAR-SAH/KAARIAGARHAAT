import 'package:cloud_firestore/cloud_firestore.dart';

class ShippingAddress {
  final String id;
  final String name;
  final String phoneNumber;
  final String houseNumber;
  final String area;
  final String city;
  final String state;
  final String pincode;
  final bool isDefault;

  ShippingAddress({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.houseNumber,
    required this.area,
    required this.city,
    required this.state,
    required this.pincode,
    this.isDefault = false,
  });

  factory ShippingAddress.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return ShippingAddress(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      houseNumber: data['houseNumber'] ?? '',
      area: data['area'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      pincode: data['pincode'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'houseNumber': houseNumber,
      'area': area,
      'city': city,
      'state': state,
      'pincode': pincode,
      'isDefault': isDefault,
    };
  }
}
