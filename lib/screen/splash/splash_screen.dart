import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaarigarhaat/main_nav_screen.dart';
import 'package:kaarigarhaat/screen/artisan/artisan_dashboard_screen.dart';
import 'package:kaarigarhaat/screen/onboarding/onboarding_screen.dart';
import 'package:kaarigarhaat/utils/auth_service.dart';
import '../../utils/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  void _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // No user is logged in, go to Onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    } else {
      // User is logged in, check their type and redirect
      Map<String, dynamic>? userData = await _authService.getUserData(user.uid);
      String userType = userData?['userType'] ?? 'Buyer';

      if (!mounted) return;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
              ),
              child: const Icon(Icons.handshake_outlined, size: 80, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            const Text(
              'KAARIGAR HAAT',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AppColors.primary,
                fontFamily: 'Playfair Display',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '“Connecting Artisans to the World”',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.accent,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
