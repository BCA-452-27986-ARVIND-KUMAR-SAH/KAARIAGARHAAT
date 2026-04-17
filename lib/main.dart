import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:kaarigarhaat/screen/splash/splash_screen.dart';
import 'package:kaarigarhaat/utils/notification_service.dart';
import 'package:kaarigarhaat/utils/theme_provider.dart';
import 'package:provider/provider.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Initialize App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  // Initialize Push Notifications
  NotificationService notificationService = NotificationService();
  await notificationService.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const KaarigarHaatApp(),
    ),
  );
}

class KaarigarHaatApp extends StatelessWidget {
  const KaarigarHaatApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaarigar Haat',
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // Light Theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme).copyWith(
          titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: AppColors.textDark),
          bodyLarge: const TextStyle(color: AppColors.textDark),
          bodyMedium: const TextStyle(color: AppColors.textLight),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textDark,
          titleTextStyle: GoogleFonts.playfairDisplay(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.background,
          onSurface: AppColors.textDark,
        ),
      ),

      // Optimized Dark Theme
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: const Color(0xFF121212),
        // Ensure text theme defaults to white/light grey in dark mode
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme).copyWith(
          titleLarge: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold, color: Colors.white),
          bodyLarge: const TextStyle(color: Colors.white),
          bodyMedium: const TextStyle(color: Colors.white70),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          titleTextStyle: GoogleFonts.playfairDisplay(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: const Color(0xFF121212),
          onSurface: Colors.white,
        ),
      ),

      home: const SplashScreen(),
    );
  }
}
