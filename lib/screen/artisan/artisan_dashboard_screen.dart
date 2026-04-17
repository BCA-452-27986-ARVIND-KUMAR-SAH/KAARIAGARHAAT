import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/order.dart';
import 'package:kaarigarhaat/models/product.dart';
import 'package:kaarigarhaat/utils/auth_service.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import 'package:kaarigarhaat/utils/pdf_service.dart';
import '../../utils/colors.dart';
import '../auth/login_screen.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'edit_profile_screen.dart';

class ArtisanDashboardScreen extends StatefulWidget {
  const ArtisanDashboardScreen({super.key});

  @override
  State<ArtisanDashboardScreen> createState() => _ArtisanDashboardScreenState();
}

class _ArtisanDashboardScreenState extends State<ArtisanDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();
  Map<String, dynamic>? _artisanData;

  @override
  void initState() {
    super.initState();
    _loadArtisanData();
  }

  void _loadArtisanData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? data = await _authService.getUserData(user.uid);
      if (!mounted) return;
      setState(() {
        _artisanData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            "Welcome, ${_artisanData?['name'] ?? 'Artisan'}",
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isDarkMode ? Colors.white : AppColors.textDark,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.primary),
            onPressed: () async {
              if (_artisanData != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArtisanEditProfileScreen(artisanData: _artisanData!),
                  ),
                );
                if (result == true) {
                  _loadArtisanData();
                }
              }
            },
          ),
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
              Tab(text: "Products", icon: Icon(Icons.inventory_2_outlined)),
              Tab(text: "Orders", icon: Icon(Icons.shopping_bag_outlined)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildProductsTab(currentUser, isDarkMode),
            _buildOrdersTab(currentUser, isDarkMode),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddProductScreen()));
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildProductsTab(User? user, bool isDarkMode) {
    return StreamBuilder<List<Product>>(
      stream: _firestoreService.getArtisanProducts(user?.uid ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));

        final products = snapshot.data ?? [];
        if (products.isEmpty) return const Center(child: Text("No products listed yet."));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _productCard(products[index], isDarkMode);
          },
        );
      },
    );
  }

  Widget _productCard(Product product, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDarkMode ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), bottomLeft: Radius.circular(16)),
              child: product.imageUrls.isNotEmpty
                  ? Image.network(
                product.imageUrls.first,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => _placeholderImage(isDarkMode),
              )
                  : _placeholderImage(isDarkMode),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("₹${product.price}", style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                      child: Text(product.category, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditProductScreen(product: product))),
                  icon: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                ),
                IconButton(
                  onPressed: () => _firestoreService.deleteProduct(product.id),
                  icon: const Icon(Icons.delete_outline, color: AppColors.accent, size: 20),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImage(bool isDarkMode) {
    return Container(
      width: 100, height: 100,
      color: isDarkMode ? Colors.grey[900] : AppColors.background,
      child: const Icon(Icons.image_outlined, color: AppColors.primary, size: 30),
    );
  }

  Widget _buildOrdersTab(User? user, bool isDarkMode) {
    return StreamBuilder<List<OrderModel>>(
      stream: _firestoreService.getArtisanOrders(user?.uid ?? ""),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));

        final orders = snapshot.data ?? [];
        if (orders.isEmpty) return const Center(child: Text("No orders received yet."));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: orders.length,
          itemBuilder: (context, index) => _orderCard(orders[index], isDarkMode),
        );
      },
    );
  }

  Widget _orderCard(OrderModel order, bool isDarkMode) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Order #${order.id.substring(0, 5).toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  IconButton(onPressed: () => PdfService.generateReceipt(order), icon: const Icon(Icons.print_outlined, size: 20, color: AppColors.primary)),
                  _buildStatusDropdown(order),
                ],
              ),
            ],
          ),
          const Divider(height: 24),
          ...order.items.map((item) => Text("• ${item.title}", style: const TextStyle(fontSize: 14))),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total: ₹${order.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
              Text("${order.createdAt.day}/${order.createdAt.month}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(OrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: DropdownButton<String>(
        value: order.status,
        underline: const SizedBox(),
        items: ["Processing", "Shipped", "Delivered"].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12, color: AppColors.primary)))).toList(),
        onChanged: (newStatus) {
          if (newStatus != null) {
            _firestoreService.updateOrderStatus(order, newStatus);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Order updated to $newStatus")));
          }
        },
      ),
    );
  }
}
