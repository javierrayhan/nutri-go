import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dynamic variables - Hook these up to your state management later (Provider/Riverpod/GetX)
    final int currentCalories = 670;
    final int maxCalories = 1200;

    final double proteinCurrent = 67;
    final double proteinMax = 150;

    final double carbsCurrent = 12;
    final double carbsMax = 200;

    final double fatCurrent = 11;
    final double fatMax = 60;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4), // Off-white background
      body: Stack(
        children: [
          // Curved Green Header Background
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(
              height: 280,
              color: const Color(0xFF90A58D), // Sage green
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Hi, User!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Sabtu, 6 Juli',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Calorie Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dimakan Hari Ini',
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '$currentCalories',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            Text(
                              ' / $maxCalories kcal',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Macro Card with Dynamic Progress Bars
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF2D9CDB),
                        width: 2,
                      ), // The Jarring Blue Border
                    ),
                    child: Column(
                      children: [
                        _buildDynamicProgressBar(
                          'PROTEIN',
                          proteinCurrent,
                          proteinMax,
                          const Color(0xFFFF6B6B),
                        ),
                        const SizedBox(height: 20),
                        _buildDynamicProgressBar(
                          'KARBOHIDRAT',
                          carbsCurrent,
                          carbsMax,
                          const Color(0xFF4D96FF),
                        ),
                        const SizedBox(height: 20),
                        _buildDynamicProgressBar(
                          'LEMAK',
                          fatCurrent,
                          fatMax,
                          const Color(0xFFFFD93D),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF90A58D),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Routing to tracking screen
                        Navigator.pushNamed(context, '/track');
                      },
                      child: const Text(
                        'LOG MAKANAN BARU',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
      // Pass the context down to the nav builder
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildDynamicProgressBar(
    String label,
    double current,
    double max,
    Color color,
  ) {
    double percentage = (current / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.grey,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              '${current.toInt()}g / ${max.toInt()}g',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                // Background Track
                Container(
                  height: 10,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                // Dynamic Fill
                Container(
                  height: 10,
                  width: constraints.maxWidth * percentage,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  // Added BuildContext requirement here
  Widget _buildBottomNav(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Passed context and specific routes
          _buildNavItem(context, Icons.home_rounded, 'Home', true, '/home'),
          _buildNavItem(
            context,
            Icons.note_alt_rounded,
            'Catatan',
            false,
            '/track',
          ),
          _buildNavItem(
            context,
            Icons.bar_chart_rounded,
            'Laporan',
            false,
            '/laporan',
          ),
          _buildNavItem(context, Icons.info_rounded, 'About', false, '/about'),
        ],
      ),
    );
  }

  // Added context, route string, and GestureDetector functionality
  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String label,
    bool isActive,
    String route,
  ) {
    final color = isActive ? const Color(0xFF90A58D) : Colors.grey[400];
    return GestureDetector(
      onTap: () {
        // Only push route if it's not the currently active tab
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// --- CUSTOM CLIPPER ---
class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
    // Smooth U-shape curve dropping down slightly in the middle
    var controlPoint = Offset(size.width / 2, size.height);
    var endPoint = Offset(size.width, size.height - 60);

    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
