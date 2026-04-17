import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';
import 'product_details_screen.dart';
import 'chat_screen.dart';

class ArtisanProfileScreen extends StatefulWidget {
  final String artisanId;
  final String artisanName;

  const ArtisanProfileScreen({
    super.key, 
    required this.artisanId, 
    required this.artisanName
  });

  @override
  State<ArtisanProfileScreen> createState() => _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends State<ArtisanProfileScreen> {
  final FirestoreService _firestoreService = _firestoreService_init();
  final User? _user = FirebaseAuth.instance.currentUser;

  static FirestoreService _firestoreService_init() => FirestoreService();

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(widget.artisanId).snapshots(),
      builder: (context, userSnapshot) {
        Map<String, dynamic> artisanData = {};
        if (userSnapshot.hasData && userSnapshot.data!.exists) {
          artisanData = userSnapshot.data!.data() as Map<String, dynamic>;
        }

        String location = artisanData['location'] ?? "India";
        String bio = artisanData['bio'] ?? "Traditional artisan dedicated to preserving cultural heritage through handcrafted masterpieces.";
        String? profilePic = artisanData['profileImageUrl'];
        String experience = artisanData['experience'] ?? "Master Artisan";

        return StreamBuilder<List<Product>>(
          stream: _firestoreService.getArtisanProducts(widget.artisanId),
          builder: (context, productsSnapshot) {
            final products = productsSnapshot.data ?? [];
            
            // Calculate artisan average rating and total ratings count
            double totalRatingSum = 0;
            int totalRatingsCount = 0;
            
            for (var p in products) {
              double r = double.tryParse(p.rating) ?? 0.0;
              // If reviewCount is 0 but rating is > 0, it's legacy data; treat as 1 review
              int count = p.reviewCount;
              if (r > 0 && count == 0) count = 1;

              if (count > 0) {
                totalRatingSum += (r * count);
                totalRatingsCount += count;
              }
            }
            
            String avgRating = totalRatingsCount > 0 
                ? (totalRatingSum / totalRatingsCount).toStringAsFixed(1) 
                : "0.0";

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 280,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        artisanData['name'] ?? widget.artisanName,
                        style: const TextStyle(
                          fontFamily: 'Playfair Display', 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black45, blurRadius: 10)],
                        ),
                      ),
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (profilePic != null)
                            Image.network(
                              profilePic, 
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => _fallbackHeaderImage(),
                            )
                          else
                            _fallbackHeaderImage(),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _infoBadge(Icons.location_on_outlined, location, isDarkMode),
                              _infoBadge(Icons.workspace_premium_outlined, "$experience Exp", isDarkMode),
                              _infoBadge(Icons.star, "$avgRating ($totalRatingsCount)", isDarkMode),
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "About the Artisan",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            bio,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white70 : Colors.grey.shade700,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            "Artisan's Creations",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),

                  if (productsSnapshot.connectionState == ConnectionState.waiting)
                    const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()))
                  else if (products.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text("No products listed yet."),
                      )),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            return _buildProductCard(context, product, isDarkMode);
                          },
                          childCount: products.length,
                        ),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
              bottomNavigationBar: _buildContactBar(isDarkMode),
            );
          },
        );
      },
    );
  }

  Widget _fallbackHeaderImage() {
    return Image.network(
      "https://images.unsplash.com/photo-1459411552884-841db9b3cc2a?q=80&w=1000&auto=format&fit=crop",
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: AppColors.primary),
    );
  }

  Widget _infoBadge(IconData icon, String label, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white10 : AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isDarkMode) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  image: product.imageUrls.isNotEmpty 
                    ? DecorationImage(
                        image: NetworkImage(product.imageUrls.first),
                        fit: BoxFit.cover,
                      )
                    : null,
                ),
                child: product.imageUrls.isEmpty 
                  ? const Center(child: Icon(Icons.image_outlined, color: Colors.grey))
                  : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "₹${product.price}",
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactBar(bool isDarkMode) {
    if (_user == null) return const SizedBox.shrink();

    return StreamBuilder<bool>(
      stream: _firestoreService.isFollowingArtisan(_user.uid, widget.artisanId),
      builder: (context, snapshot) {
        bool isFollowing = snapshot.data ?? false;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(artisanName: widget.artisanName),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("MESSAGE"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    _firestoreService.toggleFollowArtisan(_user.uid, widget.artisanId, widget.artisanName);
                  },
                  icon: Icon(
                    isFollowing ? Icons.check : Icons.favorite_border, 
                    color: Colors.white,
                  ),
                  label: Text(
                    isFollowing ? "FOLLOWING" : "FOLLOW", 
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing ? Colors.grey : AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
