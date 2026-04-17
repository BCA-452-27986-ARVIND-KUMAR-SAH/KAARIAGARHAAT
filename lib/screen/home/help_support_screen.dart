import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Help & Support",
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "How can we help you?",
              style: TextStyle(
                fontSize: 24, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            
            // Adaptive Search Bar
            TextField(
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Search FAQs...",
                hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : AppColors.primary),
                filled: true,
                fillColor: isDarkMode ? Colors.grey[900] : AppColors.background.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            
            const SizedBox(height: 30),
            
            Text(
              "Frequently Asked Questions",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white70 : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            _faqTile("How to track my order?", "You can track your order in the 'My Orders' section of your profile.", isDarkMode),
            _faqTile("What is the return policy?", "Most handmade products can be returned within 7 days of delivery if damaged.", isDarkMode),
            _faqTile("How do I contact an artisan?", "You can use the 'Chat with Artisan' feature on the product details page.", isDarkMode),
            _faqTile("Is international shipping available?", "Currently, we ship within India, but international shipping is coming soon!", isDarkMode),
            
            const SizedBox(height: 40),
            
            Text(
              "Contact Us",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold, 
                color: isDarkMode ? Colors.white70 : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            
            _contactCard(Icons.email_outlined, "Email Support", "support@kaarigarhaat.com", isDarkMode),
            _contactCard(Icons.phone_outlined, "Phone Support", "+91 98765 43210", isDarkMode),
            _contactCard(Icons.chat_bubble_outline, "Live Chat", "Available 9 AM - 6 PM", isDarkMode),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer, bool isDarkMode) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent), // Remove border
      child: ExpansionTile(
        iconColor: AppColors.primary,
        collapsedIconColor: isDarkMode ? Colors.white70 : Colors.grey,
        title: Text(
          question, 
          style: TextStyle(
            fontWeight: FontWeight.w500, 
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              answer, 
              style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.background.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.white10 : AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDarkMode ? Colors.white70 : AppColors.primary),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title, 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              Text(
                subtitle, 
                style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
