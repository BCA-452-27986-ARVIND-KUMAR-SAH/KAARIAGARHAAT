import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/main_nav_screen.dart';
import 'package:kaarigarhaat/screen/artisan/artisan_dashboard_screen.dart';
import 'package:kaarigarhaat/utils/auth_service.dart';
import '../../utils/colors.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isObscured = true;
  bool _isLoading = false;

  Future<void> _handleSocialLogin(Future<String?> socialLoginFunction) async {
    setState(() => _isLoading = true);
    String? error = await socialLoginFunction;
    setState(() => _isLoading = false);

    if (error == null && mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavScreen()));
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error ?? "An unknown error occurred")));
    }
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => _isLoading = true);

    String? error = await _authService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (error == null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Map<String, dynamic>? userData = await _authService.getUserData(user.uid);
        String userType = userData?['userType'] ?? 'Buyer';

        setState(() => _isLoading = false);

        if (mounted) {
          if (userType == 'Artisan') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ArtisanDashboardScreen()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const MainNavScreen()),
            );
          }
        }
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          "Reset Password",
          style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold, color: Color(0xFF3B2F2F)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Enter your email to receive a password reset link:", style: TextStyle(color: Color(0xFF6B4F4F))),
            const SizedBox(height: 16),
            TextField(
              controller: resetEmailController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                hintText: "Email",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFFFAF3E0),
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12)), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B4513)),
            onPressed: () async {
              String email = resetEmailController.text.trim();
              if (email.isNotEmpty) {
                String? error = await _authService.resetPassword(email);
                if (mounted) {
                  Navigator.pop(context);
                  if (error == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Password reset email sent!")),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                  }
                }
              }
            },
            child: const Text("Send Link", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B4513),
                  fontFamily: 'Playfair Display',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Login to continue supporting Indian artisans.",
                style: TextStyle(fontSize: 16, color: Color(0xFF6B4F4F)),
              ),
              const SizedBox(height: 48),

              const Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B2F2F))),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Enter your email",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF8B4513)),
                ),
              ),
              const SizedBox(height: 24),

              const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3B2F2F))),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _isObscured,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Enter your password",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF8B4513)),
                  suffixIcon: IconButton(
                    icon: Icon(_isObscured ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8B4513)),
                    onPressed: () => setState(() => _isObscured = !_isObscured),
                  ),
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDialog,
                  child: const Text("Forgot Password?", style: TextStyle(color: Color(0xFFB22222))),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B4513),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Login", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),

              const SizedBox(height: 24),

              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Or login with", style: TextStyle(color: Color(0xFF6B4F4F))),
                  ),
                  Expanded(child: Divider(color: Colors.grey, thickness: 0.5)),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(
                    Icons.g_mobiledata, 
                    "Google", 
                    onTap: () => _handleSocialLogin(_authService.signInWithGoogle()),
                  ),
                  const SizedBox(width: 20),
                  _socialButton(
                    Icons.facebook, 
                    "Facebook",
                    onTap: () => _handleSocialLogin(_authService.signInWithFacebook()),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Color(0xFF3B2F2F))),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen()));
                    },
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(color: Color(0xFF8B4513), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _socialButton(IconData icon, String label, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF8B4513), size: 28),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
