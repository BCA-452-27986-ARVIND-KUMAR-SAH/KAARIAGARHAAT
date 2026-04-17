import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/order.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import 'package:kaarigarhaat/utils/pdf_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../models/review.dart';
import '../../utils/colors.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _reviewController = TextEditingController();
  double _userRating = 5.0;

  void _showRatingDialog(BuildContext context, String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Rate $productName"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemSize: 30,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) => _userRating = rating,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _reviewController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Share your experience...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                ReviewModel newReview = ReviewModel(
                  id: '',
                  userId: user.uid,
                  userName: user.displayName ?? "Customer",
                  userImageUrl: user.photoURL ?? "",
                  productId: productId,
                  rating: _userRating,
                  comment: _reviewController.text,
                  createdAt: DateTime.now(),
                );
                await _firestoreService.addReview(newReview);
                _reviewController.clear();
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Review submitted successfully!")),
                  );
                }
              }
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Orders",
          style: TextStyle(
            fontFamily: 'Playfair Display', 
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text("Please login to see your orders", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)))
          : StreamBuilder<List<OrderModel>>(
              stream: _firestoreService.getUserOrders(user.uid),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Error loading orders: ${snapshot.error}",
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final orders = snapshot.data ?? [];
                
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shopping_bag_outlined, size: 100, color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          "No orders yet",
                          style: TextStyle(
                            fontSize: 18, 
                            color: isDarkMode ? Colors.white54 : Colors.grey, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Support artisans by placing your first order!",
                          style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final String displayId = order.id.length > 5 
                        ? order.id.substring(0, 5).toUpperCase() 
                        : order.id.toUpperCase();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.02), 
                            blurRadius: 10, 
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Order #$displayId", 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              _statusBadge(order.status),
                            ],
                          ),
                          const Divider(height: 24),
                          Column(
                            children: order.items.map((item) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: Row(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 50,
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.grey[900] : AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: item.imageUrl.isNotEmpty
                                          ? Image.network(item.imageUrl, fit: BoxFit.cover)
                                          : Icon(Icons.handshake_outlined, color: isDarkMode ? Colors.white70 : AppColors.primary, size: 24),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title, 
                                          style: TextStyle(
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        if (order.status == 'Delivered')
                                          GestureDetector(
                                            onTap: () => _showRatingDialog(context, item.productId, item.title),
                                            child: const Text(
                                              "Rate this product",
                                              style: TextStyle(
                                                color: AppColors.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                decoration: TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "₹${item.price}",
                                    style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black),
                                  ),
                                ],
                              ),
                            )).toList(),
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Total: ₹${order.totalAmount}", 
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                  Text(
                                    "${order.createdAt.day} ${_getMonth(order.createdAt.month)} ${order.createdAt.year}",
                                    style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  if (order.status == 'Delivered')
                                    IconButton(
                                      onPressed: () => PdfService.generateReceipt(order),
                                      icon: const Icon(Icons.download_outlined, color: AppColors.accent),
                                      tooltip: "Download Bill",
                                    ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                      elevation: 0,
                                    ),
                                    child: const Text("Track Order", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _getMonth(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    if (month < 1 || month > 12) return "N/A";
    return months[month - 1];
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status) {
      case 'Delivered':
        color = Colors.green;
        break;
      case 'Shipped':
        color = Colors.blue;
        break;
      case 'Processing':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
