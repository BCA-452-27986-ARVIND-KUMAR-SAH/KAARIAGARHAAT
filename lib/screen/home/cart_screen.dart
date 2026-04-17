import 'package:flutter/material.dart';
import '../../utils/cart_data.dart';
import '../../utils/colors.dart';
import 'checkout_screen.dart';

import 'package:kaarigarhaat/main_nav_screen.dart';



class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get totalAmount {
    double total = 0;
    for (var item in CartData.items) {
      // Robust parsing: handles "500", "500.0", and "₹500"
      String priceStr = item.price.toString().replaceAll('₹', '').replaceAll(',', '').trim();
      total += double.tryParse(priceStr) ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Shopping Cart",
          style: TextStyle(
            fontFamily: 'Playfair Display', 
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: CartData.items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 100, color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                  const SizedBox(height: 20),
                  Text(
                    "Your cart is empty",
                    style: TextStyle(
                      fontSize: 18, 
                      color: isDarkMode ? Colors.white54 : Colors.grey, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MainNavScreen())),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text("Start Shopping", style: TextStyle(color: Colors.white)),
                  )
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: CartData.items.length,
                    itemBuilder: (context, index) {
                      final item = CartData.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
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
                        child: Row(
                          children: [
                            Container(
                              height: 80,
                              width: 80,
                              decoration: BoxDecoration(
                                color: isDarkMode ? Colors.grey[900] : AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: item.imageUrl.isNotEmpty
                                    ? Image.network(
                                        item.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Icon(
                                          Icons.image_not_supported_outlined,
                                          color: isDarkMode ? Colors.white70 : AppColors.primary,
                                        ),
                                      )
                                    : Icon(
                                        Icons.handshake_outlined,
                                        color: isDarkMode ? Colors.white70 : AppColors.primary,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      fontSize: 16,
                                      color: isDarkMode ? Colors.white : AppColors.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Quantity: ${item.quantity}",
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white54 : Colors.grey, 
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "₹${item.price}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold, 
                                      color: AppColors.primary, 
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  CartData.items.removeAt(index);
                                });
                              },
                              icon: const Icon(Icons.delete_outline, color: AppColors.accent),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.05), 
                        blurRadius: 10, 
                        offset: const Offset(0, -5),
                      ),
                    ],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Subtotal", style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, fontSize: 16)),
                          Text(
                            "₹${totalAmount.toStringAsFixed(2)}", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Shipping", style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, fontSize: 16)),
                          Text(
                            "₹50.00", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 16,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total", 
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 20,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            "₹${(totalAmount + 50).toStringAsFixed(2)}", 
                            style: const TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 20, 
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (CartData.items.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutScreen(totalAmount: totalAmount + 50),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                          ),
                          child: const Text(
                            "PROCEED TO CHECKOUT", 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                          ),
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
