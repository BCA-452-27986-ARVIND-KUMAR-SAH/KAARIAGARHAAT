import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:kaarigarhaat/models/review.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';
import '../../models/cart_item.dart';
import '../../utils/cart_data.dart';
import 'artisan_profile_screen.dart';
import 'reviews_list_widget.dart';
import 'checkout_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _reviewController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  double _userRating = 5.0;

  void _showAddReviewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Write a Review"),
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
                  productId: widget.product.id,
                  rating: _userRating,
                  comment: _reviewController.text,
                  createdAt: DateTime.now(),
                );
                await _firestoreService.addReview(newReview);
                _reviewController.clear();
                if (mounted) Navigator.pop(context);
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
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    bool hasRating = widget.product.rating != "0.0" && widget.product.rating != "0";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppColors.textDark),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    color: isDarkMode ? Colors.grey[900] : AppColors.background,
                    child: widget.product.imageUrls.isNotEmpty
                        ? PageView.builder(
                            controller: _pageController,
                            itemCount: widget.product.imageUrls.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                widget.product.imageUrls[index],
                                fit: BoxFit.cover,
                                width: double.infinity,
                              );
                            },
                          )
                        : Center(
                            child: Icon(Icons.handshake_outlined,
                                size: 120, color: isDarkMode ? Colors.white24 : AppColors.primary),
                          ),
                  ),
                  if (widget.product.imageUrls.length > 1)
                    Positioned(
                      bottom: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          widget.product.imageUrls.length,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 12 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index ? AppColors.primary : Colors.white.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹${widget.product.price}",
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                      if (hasRating)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 20),
                            const SizedBox(width: 4),
                            Text(widget.product.rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    widget.product.title,
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                        color: isDarkMode ? Colors.white : AppColors.textDark),
                  ),
                  const SizedBox(height: 25),
                  const Text("Description", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description.isNotEmpty
                        ? widget.product.description
                        : "This authentic handmade product directly supports local artisans. Crafted with precision and traditional techniques.",
                    style: TextStyle(fontSize: 15, color: isDarkMode ? Colors.white70 : AppColors.textLight, height: 1.6),
                  ),
                  const SizedBox(height: 30),
                  StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc(widget.product.artisanId).snapshots(),
                    builder: (context, snapshot) {
                      Map<String, dynamic> artisanData = {};
                      if (snapshot.hasData && snapshot.data!.exists) {
                        artisanData = snapshot.data!.data() as Map<String, dynamic>;
                      }

                      String artisanName = artisanData['name'] ?? widget.product.artisan;
                      String? artisanPic = artisanData['profileImageUrl'];
                      String experience = artisanData['experience'] ?? "Master Artisan";

                      return GestureDetector(
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ArtisanProfileScreen(
                                    artisanId: widget.product.artisanId, artisanName: artisanName))),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.background.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 25, 
                                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                backgroundImage: artisanPic != null ? NetworkImage(artisanPic) : null,
                                child: artisanPic == null ? Icon(Icons.person, color: isDarkMode ? Colors.white54 : AppColors.primary) : null,
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text(artisanName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(experience, style: const TextStyle(fontSize: 12))
                              ])),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("User Reviews", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      // TextButton(onPressed: _showAddReviewDialog, child: const Text("Write a Review")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ReviewsListWidget(productId: widget.product.id),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomButtons(isDarkMode),
    );
  }

  Widget _buildBottomButtons(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                double priceValue = double.tryParse(widget.product.price) ?? 0.0;
                CartData.addItem(
                  CartItem(
                    productId: widget.product.id,
                    title: widget.product.title,
                    price: priceValue,
                    quantity: 1,
                    artisanId: widget.product.artisanId,
                    imageUrl: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
                  ),
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Added to cart")),
                );
              },
              child: const Text("ADD TO CART"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: ElevatedButton(
                  onPressed: () {
                    double priceValue = double.tryParse(widget.product.price) ?? 0.0;
                    CartData.items.clear();
                    CartData.addItem(
                      CartItem(
                        productId: widget.product.id,
                        title: widget.product.title,
                        price: priceValue,
                        quantity: 1,
                        artisanId: widget.product.artisanId,
                        imageUrl: widget.product.imageUrls.isNotEmpty ? widget.product.imageUrls.first : '',
                      ),
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CheckoutScreen(totalAmount: priceValue + 50.0),
                      ),
                    );
                  },
                  child: const Text("BUY NOW"))),
        ],
      ),
    );
  }
}
