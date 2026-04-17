import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/cart_item.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/screen/home/product_details_screen.dart';
import 'package:kaarigarhaat/utils/cart_data.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../utils/colors.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final String price;
  final String rating;
  final String artisan;
  final String productId;
  final String artisanId;
  final List<String> imageUrls;

  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    required this.artisanId,
    this.rating = "0.0",
    this.artisan = "Local Artisan",
    this.productId = "",
    this.imageUrls = const [],
  });

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Determine if we should show the rating
    bool hasRating = rating != "0.0" && rating != "0";

    return InkWell(
      onTap: () {
        // Create a product object with the correct data
        Product product = Product(
          id: productId,
          title: title,
          price: price,
          artisan: artisan,
          artisanId: artisanId,
          description: "",
          category: "",
          rating: rating,
          imageUrls: imageUrls,
          createdAt: DateTime.now(),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2C2C2C) : AppColors.background,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: imageUrls.isNotEmpty
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                imageUrls.first,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 40,
                                    color: isDarkMode ? Colors.white24 : AppColors.primary),
                              ),
                            )
                          : Icon(Icons.handshake_outlined,
                              size: 40, color: isDarkMode ? Colors.white70 : AppColors.primary),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: user == null || productId.isEmpty
                          ? const SizedBox()
                          : StreamBuilder<bool>(
                              stream: firestoreService.isInWishlist(user.uid, productId),
                              builder: (context, snapshot) {
                                bool isFavorite = snapshot.data ?? false;
                                return GestureDetector(
                                  onTap: () {
                                    Product product = Product(
                                      id: productId,
                                      title: title,
                                      price: price,
                                      artisan: artisan,
                                      artisanId: artisanId,
                                      description: "",
                                      category: "",
                                      imageUrls: imageUrls,
                                      rating: rating,
                                      createdAt: DateTime.now(),
                                    );
                                    firestoreService.toggleWishlist(user.uid, product);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isDarkMode ? Colors.black26 : Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      size: 18,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasRating)
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          rating,
                          style: TextStyle(
                            fontSize: 10, 
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white70 : AppColors.textDark,
                          ),
                        ),
                      ],
                    )
                  else
                    const SizedBox(height: 14), // Placeholder to maintain alignment
                  const SizedBox(height: 1),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isDarkMode ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  Text(
                    "by $artisan",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9, 
                      color: isDarkMode ? Colors.white54 : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "₹$price",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          double priceValue = double.tryParse(price) ?? 0.0;

                          CartData.addItem(
                            CartItem(
                              productId: productId,
                              title: title,
                              price: priceValue,
                              quantity: 1,
                              artisanId: artisanId,
                              imageUrl: imageUrls.isNotEmpty ? imageUrls.first : '',
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart")),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
