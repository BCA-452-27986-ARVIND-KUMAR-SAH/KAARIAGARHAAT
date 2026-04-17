import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/screen/home/about_us_screen.dart';
import 'package:kaarigarhaat/screen/home/address_list_screen.dart';
import 'package:kaarigarhaat/screen/home/edit_profile_screen.dart';
import 'package:kaarigarhaat/screen/home/help_support_screen.dart';
import 'package:kaarigarhaat/screen/home/orders_screen.dart';
import 'package:kaarigarhaat/screen/home/payment_methods_screen.dart';
import 'package:kaarigarhaat/screen/home/settings_screen.dart';
import 'package:kaarigarhaat/screen/home/wishlist_screen.dart';
import 'package:kaarigarhaat/utils/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/colors.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final User? _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_user == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: Text("Please login")),
      );
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(_user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(child: Text("User data not found")),
          );
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        String userName = userData['name'] ?? "User";
        String userEmail = userData['email'] ?? _user.email ?? "";
        String? profileImageUrl = userData['profileImageUrl'];

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text(
              "My Profile",
              style: TextStyle(
                fontFamily: 'Playfair Display', 
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(
                        currentName: userName,
                        currentEmail: userEmail,
                        currentImageUrl: profileImageUrl,
                      ),
                    ),
                  );
                },
                icon: Icon(Icons.edit_outlined, color: isDarkMode ? Colors.white70 : AppColors.primary),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Profile Header
                Center(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: isDarkMode ? Colors.white10 : AppColors.background, width: 4),
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: isDarkMode ? Colors.grey[900] : AppColors.background,
                          backgroundImage: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                              ? NetworkImage(profileImageUrl)
                              : null,
                          onBackgroundImageError: (profileImageUrl != null && profileImageUrl.isNotEmpty)
                              ? (exception, stackTrace) {
                                  debugPrint("Image load error: $exception");
                                }
                              : null,
                          child: (profileImageUrl == null || profileImageUrl.isEmpty)
                              ? Icon(Icons.person, size: 70, color: isDarkMode ? Colors.white24 : AppColors.primary)
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EditProfileScreen(
                                  currentName: userName,
                                  currentEmail: userEmail,
                                  currentImageUrl: profileImageUrl,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  userName,
                  style: TextStyle(
                    fontSize: 24, 
                    fontWeight: FontWeight.bold, 
                    color: isDarkMode ? Colors.white : AppColors.textDark,
                  ),
                ),
                Text(
                  userEmail,
                  style: TextStyle(
                    fontSize: 14, 
                    color: isDarkMode ? Colors.white54 : Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),

                // Profile Options
                _profileOption(
                  Icons.shopping_bag_outlined,
                  "My Orders",
                  "View your order history",
                  isDarkMode,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrdersScreen())),
                ),
                _profileOption(
                  Icons.favorite_border,
                  "Wishlist",
                  "Items you've saved",
                  isDarkMode,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WishlistScreen())),
                ),
                _profileOption(
                  Icons.location_on_outlined, 
                  "Shipping Address", 
                  "Manage locations", 
                  isDarkMode,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddressListScreen())),
                ),
                _profileOption(
                  Icons.payment_outlined, 
                  "Payment Methods", 
                  "Cards, UPI, etc.", 
                  isDarkMode, 
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PaymentMethodsScreen())),
                ),
                _profileOption(Icons.help_outline, "Help & Support", "FAQs", isDarkMode, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpSupportScreen()))),
                _profileOption(Icons.info_outline, "About Us", "Our mission", isDarkMode, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen()))),
                _profileOption(Icons.settings_outlined, "Settings", "Preferences", isDarkMode, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()))),

                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _authService.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _profileOption(IconData icon, String title, String subtitle, bool isDarkMode, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[900] : AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: isDarkMode ? Colors.white70 : AppColors.primary),
        ),
        title: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          subtitle, 
          style: TextStyle(
            fontSize: 12, 
            color: isDarkMode ? Colors.white38 : Colors.grey,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDarkMode ? Colors.white24 : Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
