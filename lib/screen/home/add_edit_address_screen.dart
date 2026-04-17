import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/models/shipping_address.dart';
import 'package:kaarigarhaat/utils/firestore_service.dart';
import '../../utils/colors.dart';

class AddEditAddressScreen extends StatefulWidget {
  final ShippingAddress? address;

  const AddEditAddressScreen({super.key, this.address});

  @override
  State<AddEditAddressScreen> createState() => _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends State<AddEditAddressScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _houseController;
  late TextEditingController _areaController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _pincodeController;
  bool _isDefault = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?.name ?? "");
    _phoneController = TextEditingController(text: widget.address?.phoneNumber ?? "");
    _houseController = TextEditingController(text: widget.address?.houseNumber ?? "");
    _areaController = TextEditingController(text: widget.address?.area ?? "");
    _cityController = TextEditingController(text: widget.address?.city ?? "");
    _stateController = TextEditingController(text: widget.address?.state ?? "");
    _pincodeController = TextEditingController(text: widget.address?.pincode ?? "");
    _isDefault = widget.address?.isDefault ?? false;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        ShippingAddress newAddress = ShippingAddress(
          id: widget.address?.id ?? "",
          name: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          houseNumber: _houseController.text.trim(),
          area: _areaController.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          pincode: _pincodeController.text.trim(),
          isDefault: _isDefault,
        );

        await _firestoreService.saveAddress(user.uid, newAddress);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Address saved!")));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.address == null ? "Add Address" : "Edit Address",
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
      body: _isLoading 
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(_nameController, "Full Name", Icons.person_outline, isDarkMode),
              const SizedBox(height: 16),
              _buildTextField(_phoneController, "Phone Number", Icons.phone_outlined, isDarkMode, keyboardType: TextInputType.phone),
              const SizedBox(height: 16),
              _buildTextField(_houseController, "House No. / Flat / Building", Icons.home_outlined, isDarkMode),
              const SizedBox(height: 16),
              _buildTextField(_areaController, "Area / Street / Sector", Icons.map_outlined, isDarkMode),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, "City", Icons.location_city_outlined, isDarkMode)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTextField(_stateController, "State", Icons.public_outlined, isDarkMode)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(_pincodeController, "Pincode", Icons.pin_drop_outlined, isDarkMode, keyboardType: TextInputType.number),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(
                  "Set as Default Address", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white70 : Colors.black,
                  ),
                ),
                value: _isDefault,
                activeThumbColor: AppColors.primary,
                onChanged: (val) => setState(() => _isDefault = val),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("SAVE ADDRESS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isDarkMode, {TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      validator: (val) => val!.isEmpty ? "Required field" : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.grey),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[900] : AppColors.background.withOpacity(0.5),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: isDarkMode ? Colors.white70 : AppColors.primary),
      ),
    );
  }
}
