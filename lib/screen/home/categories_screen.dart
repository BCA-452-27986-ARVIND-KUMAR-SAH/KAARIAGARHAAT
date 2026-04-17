import 'package:flutter/material.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';
import 'product_listing_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  final List<Map<String, dynamic>> categoriesData = const [
    {
      "name": "Paintings",
      "icon": Icons.palette_rounded,
      "image": "https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=1945&auto=format&fit=crop",
    },
    {
      "name": "Pottery",
      "icon": Icons.bakery_dining_rounded,
      "image": "https://images.unsplash.com/photo-1565191999001-551c187427bb?q=80&w=2070&auto=format&fit=crop",
    },
    {
      "name": "Jewelry",
      "icon": Icons.diamond_rounded,
      "image": "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=2070&auto=format&fit=crop",
    },
    {
      "name": "Handloom",
      "icon": Icons.texture_rounded,
      "image": "https://images.unsplash.com/photo-1610116306796-6fea9f4fae38?q=80&w=2070&auto=format&fit=crop",
    },
    {
      "name": "Woodcraft",
      "icon": Icons.handyman_rounded,
      "image": "https://images.unsplash.com/photo-1533090161767-e6ffed986c88?q=80&w=2069&auto=format&fit=crop",
    },
    {
      "name": "Home Decor",
      "icon": Icons.home_rounded,
      "image": "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=2070&auto=format&fit=crop",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Explore Collections",
                style: TextStyle(
                  fontFamily: 'Playfair Display', 
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
              background: Opacity(
                opacity: 0.05,
                child: Icon(Icons.category_rounded, size: 200, color: AppColors.primary),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildCategoryCard(context, categoriesData[index], isDarkMode);
                },
                childCount: categoriesData.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, Map<String, dynamic> data, bool isDarkMode) {
    final FirestoreService firestoreService = FirestoreService();
    final String categoryName = (data['name'] ?? "Category").toString();

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListingScreen(categoryName: categoryName))),
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.1), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                (data['image'] ?? "").toString(), 
                width: double.infinity, 
                height: double.infinity, 
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey[300]),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  colors: [Colors.black.withOpacity(0.8), Colors.black.withOpacity(0.2), Colors.transparent],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.9), shape: BoxShape.circle),
                    child: Icon((data['icon'] as IconData? ?? Icons.category), color: Colors.white, size: 24),
                  ),
                  const SizedBox(height: 12),
                  Text(categoryName, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  StreamBuilder<List>(
                    stream: firestoreService.getProductsByCategory(categoryName),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error loading count", style: TextStyle(color: Colors.red[200], fontSize: 12));
                      }
                      int count = snapshot.hasData ? snapshot.data!.length : 0;
                      return Text(
                        "$count Items Available",
                        style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14, fontWeight: FontWeight.w500),
                      );
                    },
                  ),
                ],
              ),
            ),
            Positioned(
              right: 20, bottom: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
