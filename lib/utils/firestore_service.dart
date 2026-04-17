import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart';
import '../models/shipping_address.dart';
import '../models/review.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- Product Backend ---
  Stream<List<Product>> getProducts() {
    return _db
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getProductsByCategory(String category) {
    return _db
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> getArtisanProducts(String artisanId) {
    return _db
        .collection('products')
        .where('artisanId', isEqualTo: artisanId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) return Stream.value([]);
    String searchKey = query.toLowerCase();

    return _db
        .collection('products')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .where((product) => product.title.toLowerCase().contains(searchKey))
              .toList();
        });
  }

  Future<void> addProduct(Product product) {
    return _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(Product product) {
    return _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) {
    return _db.collection('products').doc(productId).delete();
  }

  // --- Order Backend ---
  Future<DocumentReference> placeOrder(OrderModel order) {
    return _db.collection('orders').add(order.toMap());
  }

  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _db.collection('orders').where('userId', isEqualTo: userId).snapshots().map((snapshot) {
      List<OrderModel> orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Server-side filtering to avoid PERMISSION_DENIED
  Stream<List<OrderModel>> getArtisanOrders(String artisanId) {
    return _db
        .collection('orders')
        .where('artisanIds', arrayContains: artisanId)
        .snapshots()
        .map((snapshot) {
      List<OrderModel> orders = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  Future<void> updateOrderStatus(OrderModel order, String newStatus) async {
    await _db.collection('orders').doc(order.id).update({'status': newStatus});
    await sendNotification(
      userId: order.userId,
      title: 'Order Status Updated!',
      body: 'Your order #${order.id.substring(0, 5).toUpperCase()} is now $newStatus.',
    );
  }

  // --- Shipping Address Backend ---
  Future<void> saveAddress(String userId, ShippingAddress address) {
    if (address.id.isEmpty) {
      return _db.collection('users').doc(userId).collection('addresses').add(address.toMap());
    } else {
      return _db.collection('users').doc(userId).collection('addresses').doc(address.id).update(address.toMap());
    }
  }

  Future<void> deleteAddress(String userId, String addressId) {
    return _db.collection('users').doc(userId).collection('addresses').doc(addressId).delete();
  }

  Stream<List<ShippingAddress>> getAddresses(String userId) {
    return _db.collection('users').doc(userId).collection('addresses').snapshots().map((snapshot) => snapshot.docs.map((doc) => ShippingAddress.fromFirestore(doc)).toList());
  }

  Future<void> setDefaultAddress(String userId, String addressId) async {
    final addressesRef = _db.collection('users').doc(userId).collection('addresses');
    final snapshots = await addressesRef.get();
    final batch = _db.batch();
    for (var doc in snapshots.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == addressId});
    }
    return batch.commit();
  }

  // --- Notifications Backend ---
  Future<void> sendNotification({required String userId, required String title, required String body}) async {
    await _db.collection('users').doc(userId).collection('notifications').add({
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  Stream<QuerySnapshot> getNotifications(String userId) {
    return _db.collection('users').doc(userId).collection('notifications').orderBy('timestamp', descending: true).snapshots();
  }

  Future<void> markNotificationsAsRead(String userId) async {
    final notificationsRef = _db.collection('users').doc(userId).collection('notifications');
    final unreadNotifications = await notificationsRef.where('isRead', isEqualTo: false).get();
    
    final batch = _db.batch();
    for (var doc in unreadNotifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    return batch.commit();
  }

  // --- Reviews Backend ---
  Future<void> addReview(ReviewModel review) async {
    // 1. Add the review to the sub-collection
    await _db.collection('products').doc(review.productId).collection('reviews').add(review.toMap());

    // 2. Update the average rating and review count in the product document
    final productRef = _db.collection('products').doc(review.productId);
    final reviewsSnapshot = await productRef.collection('reviews').get();

    if (reviewsSnapshot.docs.isNotEmpty) {
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] ?? 0).toDouble();
      }
      double averageRating = totalRating / reviewsSnapshot.docs.length;
      
      await productRef.update({
        'rating': averageRating.toStringAsFixed(1),
        'reviewCount': reviewsSnapshot.docs.length,
      });
    }
  }

  Stream<List<ReviewModel>> getProductReviews(String productId) {
    return _db.collection('products').doc(productId).collection('reviews').orderBy('createdAt', descending: true).snapshots().map((snapshot) => snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList());
  }

  // --- Wishlist Backend ---
  Future<void> toggleWishlist(String userId, Product product) async {
    DocumentReference wishlistRef = _db.collection('users').doc(userId).collection('wishlist').doc(product.id);
    DocumentSnapshot doc = await wishlistRef.get();
    if (doc.exists) {
      await wishlistRef.delete();
    } else {
      await wishlistRef.set(product.toMap());
    }
  }

  Stream<List<Product>> getWishlist(String userId) {
    return _db.collection('users').doc(userId).collection('wishlist').snapshots().map((snapshot) => snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  Stream<bool> isInWishlist(String userId, String productId) {
    return _db.collection('users').doc(userId).collection('wishlist').doc(productId).snapshots().map((doc) => doc.exists);
  }

  // --- Follow Artisan Backend ---
  Future<void> toggleFollowArtisan(String userId, String artisanId, String artisanName) async {
    DocumentReference followRef = _db
        .collection('users')
        .doc(userId)
        .collection('followed_artisans')
        .doc(artisanId);

    DocumentSnapshot doc = await followRef.get();

    if (doc.exists) {
      await followRef.delete();
    } else {
      await followRef.set({
        'artisanId': artisanId,
        'artisanName': artisanName,
        'followedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Stream<bool> isFollowingArtisan(String userId, String artisanId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('followed_artisans')
        .doc(artisanId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}
