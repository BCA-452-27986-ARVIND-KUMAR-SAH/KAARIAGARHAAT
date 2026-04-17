import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/shipping_address.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';
import 'add_edit_address_screen.dart';

class AddressListScreen extends StatelessWidget {
  const AddressListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "My Addresses",
          style: TextStyle(
            fontFamily: 'Playfair Display', 
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : AppColors.textDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: user == null
          ? Center(child: Text("Please login to manage addresses", style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black)))
          : StreamBuilder<List<ShippingAddress>>(
              stream: firestoreService.getAddresses(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final addresses = snapshot.data ?? [];

                if (addresses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_outlined, size: 100, color: isDarkMode ? Colors.white10 : Colors.grey.shade300),
                        const SizedBox(height: 20),
                        Text(
                          "No addresses saved yet",
                          style: TextStyle(
                            fontSize: 18, 
                            color: isDarkMode ? Colors.white54 : Colors.grey, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: address.isDefault 
                              ? AppColors.primary 
                              : (isDarkMode ? Colors.white10 : Colors.grey.shade200),
                          width: address.isDefault ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                address.name, 
                                style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              if (address.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    "Default", 
                                    style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${address.houseNumber}, ${address.area}", 
                            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "${address.city}, ${address.state} - ${address.pincode}", 
                            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, fontSize: 14),
                          ),
                          Text(
                            "Phone: ${address.phoneNumber}", 
                            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.grey, fontSize: 14),
                          ),
                          Divider(height: 24, color: isDarkMode ? Colors.white10 : Colors.grey.shade200),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => AddEditAddressScreen(address: address)),
                                  );
                                },
                                icon: const Icon(Icons.edit_outlined, size: 18),
                                label: const Text("Edit"),
                                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                              ),
                              TextButton.icon(
                                onPressed: () => firestoreService.deleteAddress(user.uid, address.id),
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text("Delete"),
                                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                              ),
                              if (!address.isDefault)
                                TextButton(
                                  onPressed: () => firestoreService.setDefaultAddress(user.uid, address.id),
                                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                                  child: const Text("Set as Default"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditAddressScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add New Address", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
