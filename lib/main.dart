import 'package:flutter/material.dart';
import 'package:pixelhu/pages/home_page.dart';
import 'package:pixelhu/services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Google Mobile Ads SDK
  await AdMobService.initialize();

  // Preload ads
  await AdMobService().loadInterstitialAd();
  await AdMobService().loadRewardedAd();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PixelHu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme:
            ColorScheme.fromSeed(
              seedColor: const Color(0xFF007AFF),
              brightness: Brightness.light,
            ).copyWith(
              primary: const Color(0xFF007AFF),
              secondary: const Color(0xFF5AC8FA),
              surface: Colors.white,
              background: Colors.grey.shade50,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onSurface: Colors.grey.shade800,
              onBackground: Colors.grey.shade800,
            ),
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade800,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF007AFF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF007AFF)),
        ),
      ),
      home: const HomePage(),
    );
  }
}
