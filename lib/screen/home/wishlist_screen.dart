import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';
import '../../widgets/product_card.dart';
import 'package:kaarigarhaat/main_nav_screen.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "My Wishlist",
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text("Please login to see your wishlist"))
          : StreamBuilder<List<Product>>(
              stream: firestoreService.getWishlist(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final products = snapshot.data ?? [];
                
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 100, color: Colors.grey.shade300),
                        const SizedBox(height: 20),
                        const Text(
                          "Your wishlist is empty",
                          style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Save items you love to find them easily later.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MainNavScreen())),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: const Text("Explore Products", style: TextStyle(color: Colors.white)),
                        )
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(20),
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
                      title: product.title,
                      price: product.price,
                      productId: product.id,
                      artisan: product.artisan,
                      artisanId: product.artisanId,
                      rating: product.rating,
                    );
                  },
                );
              },
            ),
    );
  }
}
