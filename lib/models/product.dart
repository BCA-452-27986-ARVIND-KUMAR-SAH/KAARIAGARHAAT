import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String title;
  final String price;
  final String artisan;
  final String artisanId;
  final String description;
  final String category;
  final String rating;
  final int reviewCount; // Added reviewCount
  final List<String> imageUrls;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.artisan,
    required this.artisanId,
    required this.description,
    required this.category,
    this.rating = "0.0",
    this.reviewCount = 0, // Default to 0
    required this.imageUrls,
    required this.createdAt,
  });

  // Convert Firestore document to Product object
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      title: data['title'] ?? '',
      price: data['price'] ?? '0',
      artisan: data['artisan'] ?? 'Local Artisan',
      artisanId: data['artisanId'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      rating: data['rating']?.toString() ?? '0.0',
      reviewCount: data['reviewCount'] ?? 0, // Parse reviewCount
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: (data['createdAt'] is Timestamp) 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  // Convert Product object to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'price': price,
      'artisan': artisan,
      'artisanId': artisanId,
      'description': description,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount, // Include reviewCount
      'imageUrls': imageUrls,
      'createdAt': createdAt,
    };
  }
}
