import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import 'package:kaarigarhaat/widgets/product_card.dart';
import '../../utils/colors.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : AppColors.textDark,
        elevation: 0,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            hintText: "Search crafts...",
            hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
            border: InputBorder.none,
          ),
          onChanged: (val) {
            setState(() {
              _query = val;
            });
          },
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _query = "");
              },
              icon: Icon(Icons.clear, color: isDarkMode ? Colors.white70 : AppColors.textDark),
            ),
        ],
      ),
      body: _query.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "Search for authentic Indian handicrafts", 
                    style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                  ),
                ],
              ),
            )
          : StreamBuilder<List<Product>>(
              stream: _firestoreService.searchProducts(_query),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      "No products found.",
                      style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.65,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return ProductCard(
                      productId: product.id,
                      title: product.title,
                      price: product.price,
                      artisan: product.artisan,
                      artisanId: product.artisanId,
                      rating: product.rating,
                      imageUrls: product.imageUrls, // Added this line to fix missing images
                    );
                  },
                );
              },
            ),
    );
  }
}
