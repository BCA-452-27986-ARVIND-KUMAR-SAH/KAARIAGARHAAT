import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kaarigarhaat/models/cart_item.dart';
import 'package:flutter/foundation.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<CartItem> items;
  final List<String> artisanIds; // Added for efficient server-side filtering
  final double totalAmount;
  final String status;
  final String address;
  final String paymentMethod;
  final String? paymentId;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.artisanIds,
    required this.totalAmount,
    required this.status,
    required this.address,
    required this.paymentMethod,
    this.paymentId,
    required this.createdAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
      
      var itemsList = data['items'] as List? ?? [];
      List<CartItem> parsedItems = itemsList.map<CartItem>((item) {
        if (item is Map) {
          return CartItem.fromMap(Map<String, dynamic>.from(item));
        }
        return CartItem(
          productId: '', 
          title: 'Invalid', 
          price: 0, 
          quantity: 1, 
          artisanId: '',
          imageUrl: '',
        );
      }).toList();

      return OrderModel(
        id: doc.id,
        userId: data['userId']?.toString() ?? '',
        items: parsedItems,
        artisanIds: List<String>.from(data['artisanIds'] ?? []),
        totalAmount: double.tryParse(data['totalAmount']?.toString() ?? '0') ?? 0.0,
        status: data['status']?.toString() ?? 'Processing',
        address: data['address']?.toString() ?? '',
        paymentMethod: data['paymentMethod']?.toString() ?? '',
        paymentId: data['paymentId']?.toString(),
        createdAt: data['createdAt'] is Timestamp 
            ? (data['createdAt'] as Timestamp).toDate() 
            : DateTime.now(),
      );
    } catch (e) {
      debugPrint("Error parsing OrderModel: $e");
      return OrderModel(
        id: doc.id, userId: '', items: [], artisanIds: [],
        totalAmount: 0, status: 'Error', address: '', 
        paymentMethod: '', createdAt: DateTime.now()
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'artisanIds': artisanIds,
      'totalAmount': totalAmount,
      'status': status,
      'address': address,
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'createdAt': createdAt,
    };
  }
}
