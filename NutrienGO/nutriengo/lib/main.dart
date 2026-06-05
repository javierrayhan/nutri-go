import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // WAJIB: Import Brankas Token
import 'onboarding.dart';
import 'login.dart';
import 'signup.dart';
import 'assesment.dart';
import 'home.dart';
import 'tracking.dart';
import 'dailylogs.dart';
import 'profile.dart';
import 'admin_panel.dart';

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
      // Map rute yang SEKARANG DIJAGA KETAT OLEH SATPAM (AuthGuard)
      routes: {
        // --- JALUR PUBLIK (GUEST) ---
        // isProtected: false artinya hanya untuk yang BELUM login
        '/': (context) =>
            const AuthGuard(isProtected: false, child: OnboardingScreen()),
        '/login': (context) =>
            const AuthGuard(isProtected: false, child: LoginScreen()),
        '/signup': (context) =>
            const AuthGuard(isProtected: false, child: RegisterScreen()),

        // --- JALUR PRIVAT (AUTH) ---
        // isProtected: true artinya WAJIB punya Token JWT
        '/assessment': (context) =>
            const AuthGuard(isProtected: true, child: AssessmentScreen()),
        '/home': (context) =>
            const AuthGuard(isProtected: true, child: HomeScreen()),
        '/track': (context) =>
            const AuthGuard(isProtected: true, child: TrackingScreen()),
        '/laporan': (context) =>
            const AuthGuard(isProtected: true, child: LaporanScreen()),
        '/profile': (context) =>
            const AuthGuard(isProtected: true, child: ProfileScreen()),
        '/admin': (context) =>
            const AuthGuard(isProtected: true, child: AdminPanelScreen()),
      },
    );
  }
}

// ==========================================
// MIDDLEWARE / SATPAM APLIKASI (ROUTE GUARD)
// ==========================================
class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool
  isProtected; // Penentu apakah ini halaman rahasia atau halaman publik

  const AuthGuard({Key? key, required this.child, required this.isProtected})
    : super(key: key);

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isLoading =
      true; // Layar ditahan dulu (loading) saat satpam ngecek tiket

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    // Buka brankas untuk mencari tiket JWT
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    // Mencegah error jika widget keburu ditutup sebelum pengecekan selesai
    if (!mounted) return;

    // SKENARIO 1: Jalur Privat + Tidak Punya Tiket = TENDANG KE LOGIN
    if (widget.isProtected && token == null) {
      Navigator.pushReplacementNamed(context, '/login');
    }
    // SKENARIO 2: Jalur Publik + Sudah Punya Tiket = TENDANG BALIK KE HOME
    else if (!widget.isProtected && token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    }
    // SKENARIO 3: Kondisi Normal = IZINKAN MASUK
    else {
      setState(() {
        _isLoading = false; // Matikan loading, persilakan render halamannya
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan layar loading polos sementara Satpam sedang bekerja di belakang layar
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF90A58D)),
        ),
      );
    }

    // Jika lolos seleksi, tampilkan layarnya (misal: ProfileScreen atau HomeScreen)
    return widget.child;
  }
}
