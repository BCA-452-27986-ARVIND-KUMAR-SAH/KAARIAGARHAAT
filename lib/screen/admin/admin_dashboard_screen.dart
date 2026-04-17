import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/utils/auth_service.dart';
import '../../utils/colors.dart';
import '../auth/login_screen.dart';
import '../../utils/pdf_service.dart';
import '../../models/order.dart';
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;



  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text(
            "Admin Control Center",
            style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () {
                _authService.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, color: AppColors.accent),
            ),
          ],
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Users", icon: Icon(Icons.people_outline)),
              Tab(text: "Orders", icon: Icon(Icons.receipt_long_outlined)),
              Tab(text: "Products", icon: Icon(Icons.inventory_2_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildUsersTab(isDarkMode),
            _buildOrdersTab(isDarkMode),
            _buildProductsTab(isDarkMode),
          ],
        ),
      ),
    );
  }


  Widget _buildUsersTab(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final users = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            var userData = users[index].data() as Map<String, dynamic>;
            String role = userData['userType'] ?? 'Buyer';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: role == 'Artisan' ? Colors.orange.shade100 : AppColors.background,
                  child: Icon(Icons.person, color: role == 'Artisan' ? Colors.orange : AppColors.primary),
                ),
                title: Text(userData['name'] ?? 'Unknown User', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("${userData['email']}\nRole: $role", style: const TextStyle(fontSize: 12)),
                isThreeLine: true,
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(users[index].id, "users"),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildOrdersTab(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('orders').orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            // Convert Firestore Doc to OrderModel so we can print it
            final order = OrderModel.fromFirestore(docs[index]);

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: ListTile(
                title: Text("Order #${order.id.substring(0, 8).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Total: ₹${order.totalAmount}\nStatus: ${order.status}"),
                trailing: IconButton(
                  icon: const Icon(Icons.print_outlined, color: AppColors.primary),
                  onPressed: () => PdfService.generateReceipt(order),
                ),
                onTap: () {},
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProductsTab(bool isDarkMode) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data?.docs ?? [];

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          itemBuilder: (context, index) {
            var productData = products[index].data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
              child: ListTile(
                leading: Container(width: 50, height: 50, color: AppColors.background, child: const Icon(Icons.image_outlined)),
                title: Text(productData['title'] ?? 'Product', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Price: ₹${productData['price']}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteDialog(products[index].id, "products"),
                ),
              ),
            );
          },
        );
      },
    );
  }


  void _showDeleteDialog(String id, String collection) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: Text("Are you sure you want to permanently remove this item from $collection?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection(collection).doc(id).delete();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

