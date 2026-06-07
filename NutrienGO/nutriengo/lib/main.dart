import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      initialRoute: '/',
      routes: {
        '/': (context) => const RootController(),
        '/onboarding': (context) =>
            const AuthGuard(isProtected: false, child: OnboardingScreen()),
        '/login': (context) =>
            const AuthGuard(isProtected: false, child: LoginScreen()),
        '/signup': (context) =>
            const AuthGuard(isProtected: false, child: RegisterScreen()),

        '/assessment': (context) => const AuthGuard(
          isProtected: true,
          allowedRoles: ['USER'],
          child: AssessmentScreen(),
        ),
        '/home': (context) => const AuthGuard(
          isProtected: true,
          allowedRoles: ['USER'],
          child: HomeScreen(),
        ),
        '/track': (context) => const AuthGuard(
          isProtected: true,
          allowedRoles: ['USER'],
          child: TrackingScreen(),
        ),
        '/laporan': (context) => const AuthGuard(
          isProtected: true,
          allowedRoles: ['USER'],
          child: LaporanScreen(),
        ),
        '/profile': (context) => const AuthGuard(
          isProtected: true,
          allowedRoles: ['USER', 'ADMIN'],
          child: ProfileScreen(),
        ),

        '/admin': (context) => const AuthGuard(
          isProtected: true,
          allowedRoles: ['ADMIN'],
          child: AdminPanelScreen(),
        ),
      },
    );
  }
}

// =========================================================================
// UPGRADE: ROOT CONTROLLER MENJADI SPLASH SCREEN RESMI (TAHAN LAYAR 3 DETIK)
// =========================================================================
class RootController extends StatefulWidget {
  const RootController({super.key});

  @override
  State<RootController> createState() => _RootControllerState();
}

class _RootControllerState extends State<RootController> {
  @override
  void initState() {
    super.initState();
    _checkInitialRoute();
  }

  Future<void> _checkInitialRoute() async {
    // Menahan layar selama 3 detik untuk memunculkan logo NutriGo
    await Future.delayed(const Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    String? role = prefs.getString('user_role');
    bool isProfileCompleted = prefs.getBool('is_profile_completed') ?? true;

    if (!mounted) return;

    if (token != null) {
      if (role == 'ADMIN') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        if (!isProfileCompleted) {
          Navigator.pushReplacementNamed(context, '/assessment');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      Navigator.pushReplacementNamed(context, '/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png',
              width: 180,
              height: 180,
              fit: BoxFit.contain,
              // Fallback aman jika file gambar belum dimasukkan ke folder assets
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.gpp_good_rounded,
                  size: 100,
                  color: Color(0xFF8B9B82),
                );
              },
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(color: Color(0xFF90A58D)),
          ],
        ),
      ),
    );
  }
}

class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool isProtected;
  final List<String>? allowedRoles;

  const AuthGuard({
    Key? key,
    required this.child,
    required this.isProtected,
    this.allowedRoles,
  }) : super(key: key);

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    String? role = prefs.getString('user_role') ?? 'USER';
    bool isProfileCompleted = prefs.getBool('is_profile_completed') ?? true;

    if (!mounted) return;

    if (widget.isProtected) {
      if (token == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }

      if (widget.allowedRoles != null && !widget.allowedRoles!.contains(role)) {
        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
        return;
      }

      if (role == 'USER' &&
          !isProfileCompleted &&
          ModalRoute.of(context)?.settings.name != '/assessment') {
        Navigator.pushReplacementNamed(context, '/assessment');
        return;
      }
    } else {
      if (token != null) {
        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          if (!isProfileCompleted) {
            Navigator.pushReplacementNamed(context, '/assessment');
          } else {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
        return;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7F4),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF90A58D)),
        ),
      );
    }
    return widget.child;
  }
}
