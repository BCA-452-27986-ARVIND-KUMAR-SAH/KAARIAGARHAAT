import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/order.dart';
import '../../utils/colors.dart';

class OrderTrackingScreen extends StatelessWidget {
  final OrderModel order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define the tracking steps
    final List<Map<String, dynamic>> trackingSteps = [
      {"status": "Placed", "desc": "Order placed on ${order.createdAt.day}/${order.createdAt.month}", "icon": Icons.assignment_turned_in_outlined},
      {"status": "Processing", "desc": "Artisan is preparing your handicraft", "icon": Icons.handshake_outlined},
      {"status": "Shipped", "desc": "Handed over to delivery partner", "icon": Icons.local_shipping_outlined},
      {"status": "Delivered", "desc": "Handicraft reaching your doorstep", "icon": Icons.home_outlined},
    ];

    int currentStep = _getCurrentStep(order.status);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order ID Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDarkMode ? Colors.white10 : Colors.grey.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shopping_bag_outlined, color: AppColors.primary, size: 30),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Order #ID-${order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id.toUpperCase()}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        "Estimated Delivery: 7-10 Days",
                        style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            
            // Timeline
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: trackingSteps.length,
              itemBuilder: (context, index) {
                bool isCompleted = index <= currentStep;
                bool isLast = index == trackingSteps.length - 1;
                
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot and Line
                    Column(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: isCompleted ? AppColors.primary : (isDarkMode ? Colors.grey[800] : Colors.grey[200]),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : trackingSteps[index]['icon'],
                            color: isCompleted ? Colors.white : Colors.grey,
                            size: 16,
                          ),
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 60,
                            color: index < currentStep ? AppColors.primary : (isDarkMode ? Colors.white10 : Colors.grey[200]),
                          ),
                      ],
                    ),
                    const SizedBox(width: 20),
                    // Status Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trackingSteps[index]['status'],
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isCompleted ? (isDarkMode ? Colors.white : Colors.black) : Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            trackingSteps[index]['desc'],
                            style: TextStyle(
                              color: isCompleted ? (isDarkMode ? Colors.white54 : Colors.grey[600]) : Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text("Delivery Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 12),
            Text(order.address, style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey[700], height: 1.5)),
          ],
        ),
      ),
    );
  }

  int _getCurrentStep(String status) {
    switch (status) {
      case 'Delivered': return 3;
      case 'Shipped': return 2;
      case 'Processing': return 1;
      case 'Placed': return 0;
      default: return 0;
    }
  }
}
