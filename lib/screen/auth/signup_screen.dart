import 'package:flutter/material.dart';
import 'package:kaarigarhaat/utils/auth_service.dart';
import '../../utils/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // Artisan specific controllers
  final TextEditingController _storeController = TextEditingController();
  final TextEditingController _craftController = TextEditingController();
  final TextEditingController _aadharController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String _selectedUserType = 'Buyer'; 
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty || _nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all required fields")));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    Map<String, dynamic>? artisanDetails;
    if (_selectedUserType == 'Artisan') {
      artisanDetails = {
        'storeName': _storeController.text,
        'craftType': _craftController.text,
        'aadharId': _aadharController.text,
        'location': _locationController.text,
      };
    }

    String? error = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      userType: _selectedUserType,
      artisanDetails: artisanDetails,
    );

    setState(() => _isLoading = false);

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Registration Successful! Please login.")));
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.light(), // FORCES light theme data for this subtree
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                ),
                const SizedBox(height: 30),
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Join the community of handicraft lovers.",
                  style: TextStyle(fontSize: 16, color: AppColors.textLight),
                ),
                const SizedBox(height: 40),

                _label("Full Name"),
                _buildTextField(_nameController, "Enter your full name", Icons.person_outline),
                const SizedBox(height: 20),

                _label("Email / Phone"),
                _buildTextField(_emailController, "Enter your email or phone", Icons.email_outlined),
                const SizedBox(height: 20),

                _label("I am a:"),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _userTypeCard('Buyer', Icons.shopping_bag_outlined)),
                    const SizedBox(width: 16),
                    Expanded(child: _userTypeCard('Artisan', Icons.handyman_outlined)),
                  ],
                ),
                const SizedBox(height: 20),

                if (_selectedUserType == 'Artisan') ...[
                  _label("Business/Store Name"),
                  _buildTextField(_storeController, "Enter your store name", Icons.store_outlined),
                  const SizedBox(height: 20),

                  _label("Craft Type"),
                  _buildTextField(_craftController, "What do you create?", Icons.brush_outlined),
                  const SizedBox(height: 20),

                  _label("Aadhar / Business ID"),
                  _buildTextField(_aadharController, "For verification purpose", Icons.badge_outlined),
                  const SizedBox(height: 20),

                  _label("Address / Workshop Location"),
                  _buildTextField(_locationController, "City, State", Icons.location_on_outlined),
                  const SizedBox(height: 20),
                ],

                _label("Password"),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscured,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Create a password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.primary),
                      onPressed: () => setState(() => _isObscured = !_isObscured),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _label("Confirm Password"),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmObscured,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "Repeat your password",
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.lock_reset_outlined, color: AppColors.primary),
                    suffixIcon: IconButton(
                      icon: Icon(_isConfirmObscured ? Icons.visibility_off : Icons.visibility, color: AppColors.primary),
                      onPressed: () => setState(() => _isConfirmObscured = !_isConfirmObscured),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign Up", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: AppColors.textDark)),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text("Login", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark));

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        prefixIcon: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _userTypeCard(String type, IconData icon) {
    bool isSelected = _selectedUserType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 32),
            const SizedBox(height: 8),
            Text(type, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? Colors.white : AppColors.textDark)),
          ],
        ),
      ),
    );
  }
}
