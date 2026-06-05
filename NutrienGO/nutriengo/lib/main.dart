import 'package:flutter/material.dart';
import 'onboarding.dart';
import 'login.dart';
import 'signup.dart';
import 'assesment.dart';
import 'home.dart';
import 'tracking.dart';
import 'profile.dart';
import 'dailylogs.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NutrienGo',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF8B9B82),
      ),
      // Definisikan rute awal
      initialRoute: '/',
      // Map rute sebagai perantara modular
      routes: {
        '/': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const RegisterScreen(),
        '/assessment': (context) => const AssessmentScreen(),
        '/home': (context) => const HomeScreen(),
        '/track': (context) => const TrackingScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/laporan': (context) => const LaporanScreen(),
        // Nanti tinggal tambah '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
