import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7), // Clean off-white background
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Placeholder for the main illustration
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(4), // Subtle rounding
                ),
              ),

              const SizedBox(height: 48),

              // Headline text
              const Text(
                'Siap kendalikan nutrisi\nharianmu?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(
                    0xFF1E293B,
                  ), // Slate 800 - better than pure black
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 16),

              // Subtitle text
              const Text(
                'Capai target kesehatanmu dengan tracking makro\ndan kalori yang seamless.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B), // Slate 500
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Primary CTA (Call to Action)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B9B82), // Sage green vibe
                    foregroundColor: Colors.white,
                    elevation: 0, // Flat design for modern UI
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'DAFTAR SEKARANG',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Divider Text
              const Text(
                'ATAU',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF94A3B8), // Slate 400
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              // Secondary CTA
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF94A3B8),
                    side: const BorderSide(
                      color: Color(0xFFCBD5E1), // Slate 300
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27),
                    ),
                  ),
                  child: const Text(
                    'MASUK KE AKUN',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
