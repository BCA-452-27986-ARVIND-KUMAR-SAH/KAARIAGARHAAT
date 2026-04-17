import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "About Us",
          style: TextStyle(
            fontFamily: 'Playfair Display', 
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : AppColors.textDark),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[900] : AppColors.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.handshake_outlined, size: 80, color: isDarkMode ? Colors.white70 : AppColors.primary),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                "KAARIGAR HAAT",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: isDarkMode ? Colors.white : AppColors.primary,
                  fontFamily: 'Playfair Display',
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "“Connecting Artisans to the World”",
                style: TextStyle(
                  fontSize: 16, 
                  fontStyle: FontStyle.italic, 
                  color: isDarkMode ? Colors.white54 : AppColors.textLight,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(
              "Our Mission",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Kaarigar Haat is a dedicated platform designed to bridge the gap between traditional Indian artisans and the global market. Our mission is to empower rural creators by providing them with a digital storefront to showcase their unique, handmade crafts directly to customers.",
              style: TextStyle(
                fontSize: 16, 
                color: isDarkMode ? Colors.white70 : AppColors.textLight, 
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Why We Exist",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Many of India's ancient art forms are fading away because artisans lack access to modern markets. We believe that by providing a fair and transparent platform, we can help preserve India's rich cultural heritage while ensuring a sustainable livelihood for the skilled 'Kaarigars'.",
              style: TextStyle(
                fontSize: 16, 
                color: isDarkMode ? Colors.white70 : AppColors.textLight, 
                height: 1.6,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              "Our Values",
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _valueItem(Icons.verified_outlined, "Authenticity", "Every product is 100% handmade and authentic.", isDarkMode),
            _valueItem(Icons.eco_outlined, "Sustainability", "We promote eco-friendly and sustainable practices.", isDarkMode),
            _valueItem(Icons.people_outline, "Community", "Empowering artisan communities across India.", isDarkMode),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _valueItem(IconData icon, String title, String description, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 16,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  description, 
                  style: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.grey, 
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
