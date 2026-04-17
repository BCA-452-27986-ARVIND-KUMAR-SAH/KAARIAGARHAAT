import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';
import '../../widgets/product_card.dart';

class ProductListingScreen extends StatelessWidget {
  final String categoryName;

  const ProductListingScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        title: Text(
          categoryName,
          style: TextStyle(
            fontFamily: 'Playfair Display', 
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : AppColors.textDark,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search in $categoryName...",
                hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : AppColors.primary),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.background.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: firestoreService.getProductsByCategory(categoryName),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.red)));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      "No products found in this category.",
                      style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.62,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      title: product.title,
                      price: product.price,
                      artisan: product.artisan,
                      rating: product.rating,
                      productId: product.id,
                      artisanId: product.artisanId,
                      imageUrls: product.imageUrls,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
