import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/screen/home/categories_screen.dart';
import 'package:kaarigarhaat/screen/home/notifications_screen.dart';
import 'package:kaarigarhaat/screen/home/search_screen.dart';
import 'package:kaarigarhaat/screen/home/product_listing_screen.dart';
import 'package:kaarigarhaat/screen/home/profile_screen.dart';
import 'package:kaarigarhaat/screen/home/filter_modal.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import 'package:kaarigarhaat/widgets/product_card.dart';
import '../../utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _bannerController = PageController();
  final FirestoreService _firestoreService = FirestoreService();
  int _currentBannerIndex = 0;
  
  late final Stream<List<Product>> _productsStream = _firestoreService.getProducts();

  final List<Map<String, dynamic>> _banners = [
    {
      "title": "Festive Craft Sale!",
      "subtitle": "Support local artisans & get\nup to 30% off on first order.",
      "image": "https://images.unsplash.com/photo-1513519245088-0e12902e5a38?q=80&w=2070&auto=format&fit=crop",
      "color": AppColors.primary,
      "category": "Paintings",
    },
    {
      "title": "New Arrivals!",
      "subtitle": "Explore the latest collection of\nauthentic handmade jewelry.",
      "image": "https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=2070&auto=format&fit=crop",
      "color": AppColors.accent,
      "category": "Jewelry",
    },
    {
      "title": "Eco-Friendly Decor",
      "subtitle": "Decorate your home with sustainable\nand beautiful terracotta pottery.",
      "image": "https://images.unsplash.com/photo-1594910411241-00030aa16df2?q=80&w=2070&auto=format&fit=crop",
      "color": const Color(0xFF2E8B57), 
      "category": "Pottery",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            backgroundColor: isDarkMode ? const Color(0xFF121212) : Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Kaarigar Haat",
                style: TextStyle(
                  fontFamily: 'Playfair Display', 
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: isDarkMode ? Colors.white : AppColors.textDark,
                ),
              ),
            ),
            actions: [
              _buildNotificationIcon(user, isDarkMode),
              _buildProfileIcon(user, isDarkMode),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchBar(isDarkMode),
                _buildBannerSlider(isDarkMode),
                const SizedBox(height: 32),
                _buildSectionHeader("Shop by Category", () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen()));
                }, isDarkMode),
                _buildCategoryList(isDarkMode),
                const SizedBox(height: 32),
                _buildSectionHeader("Handpicked for You", null, isDarkMode),
                _buildProductGrid(isDarkMode),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon(User? user, bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: user != null ? _firestoreService.getNotifications(user.uid) : const Stream.empty(),
      builder: (context, snapshot) {
        bool hasUnread = snapshot.hasData && snapshot.data!.docs.any((doc) => (doc.data() as Map<String, dynamic>)['isRead'] == false);
        return Stack(
          children: [
            IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
              icon: Icon(Icons.notifications_none_rounded, color: isDarkMode ? Colors.white : AppColors.textDark),
            ),
            if (hasUnread)
              Positioned(
                right: 12, top: 12,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildProfileIcon(User? user, bool isDarkMode) {
    return StreamBuilder<DocumentSnapshot>(
      stream: user != null ? FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots() : const Stream.empty(),
      builder: (context, snapshot) {
        String? profileImageUrl;
        if (snapshot.hasData && snapshot.data!.exists) {
          profileImageUrl = (snapshot.data!.data() as Map<String, dynamic>)['profileImageUrl'];
        }
        return Padding(
          padding: const EdgeInsets.only(right: 16.0, left: 8.0),
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: isDarkMode ? Colors.grey[800] : AppColors.background,
              backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty) ? NetworkImage(profileImageUrl) : null,
              child: (profileImageUrl == null || profileImageUrl.isEmpty) ? Icon(Icons.person_rounded, size: 20, color: isDarkMode ? Colors.white : AppColors.primary) : null,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen())),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: isDarkMode ? Colors.white54 : Colors.grey[600]),
                    const SizedBox(width: 12),
                    Text("Discover unique crafts...", style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey[500], fontSize: 15)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const FilterModal()),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerSlider(bool isDarkMode) {
    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _bannerController,
            onPageChanged: (index) => setState(() => _currentBannerIndex = index),
            itemCount: _banners.length,
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: DecorationImage(image: NetworkImage(banner['image']), fit: BoxFit.cover, colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.darken)),
                  boxShadow: [BoxShadow(color: (banner['color'] as Color).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(banner['title'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(banner['subtitle'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Fixed Null safety check
                          String category = (banner['category'] ?? "Paintings").toString();
                          Navigator.push(context, MaterialPageRoute(builder: (c) => ProductListingScreen(categoryName: category)));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
                        child: const Text("Explore Now", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentBannerIndex == index ? 20 : 8,
            height: 6,
            decoration: BoxDecoration(color: _currentBannerIndex == index ? AppColors.primary : Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(3)),
          )),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onSeeAll, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : AppColors.textDark, fontFamily: 'Playfair Display')),
          if (onSeeAll != null)
            TextButton(onPressed: onSeeAll, child: const Text("See All", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildCategoryList(bool isDarkMode) {
    final categories = [
      {"name": "Paintings", "icon": Icons.palette_rounded, "color": Colors.orange[50]},
      {"name": "Pottery", "icon": Icons.bakery_dining_rounded, "color": Colors.brown[50]},
      {"name": "Jewelry", "icon": Icons.diamond_rounded, "color": Colors.blue[50]},
      {"name": "Handloom", "icon": Icons.texture_rounded, "color": Colors.green[50]},
      {"name": "Woodcraft", "icon": Icons.handyman_rounded, "color": Colors.red[50]},
    ];
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductListingScreen(categoryName: cat['name'] as String))),
              child: Column(
                children: [
                  Container(
                    width: 70, height: 70,
                    decoration: BoxDecoration(color: isDarkMode ? const Color(0xFF1E1E1E) : cat['color'] as Color, shape: BoxShape.circle),
                    child: Icon(cat['icon'] as IconData, color: isDarkMode ? Colors.white70 : AppColors.primary, size: 30),
                  ),
                  const SizedBox(height: 8),
                  Text(cat['name'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDarkMode ? Colors.white70 : Colors.black87)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(bool isDarkMode) {
    return StreamBuilder<List<Product>>(
      stream: _productsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data ?? [];
        if (products.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("Coming Soon...")));

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 20, childAspectRatio: 0.62),
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
          ),
        );
      },
    );
  }
}
