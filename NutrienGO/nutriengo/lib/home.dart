import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'services/daily_log_service.dart'; // Tambahan Import Kurir Log

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  // Variabel Target Maksimal (Dari Profile)
  int maxCalories = 0;
  double proteinMax = 0;
  double carbsMax = 0;
  double fatMax = 0;

  // Variabel Progress Hari Ini (Dari Daily Logs)
  int currentCalories = 0;
  double proteinCurrent = 0;
  double carbsCurrent = 0;
  double fatCurrent = 0;

  @override
  void initState() {
    super.initState();
    _loadData(); // Panggil fungsi gabungan
  }

  // Fungsi pengaman angka
  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // --- FUNGSI GABUNGAN: TARIK PROFIL & TARIK LOG HARIAN ---
  Future<void> _loadData() async {
    ProfileService profileService = ProfileService();
    DailyLogService logService = DailyLogService();

    // 1. Tarik Data Profil Damar
    final profileData = await profileService.getProfile();

    // 2. Tarik Data Makanan Hari Ini
    String todayDate = DateTime.now().toIso8601String().split('T')[0];
    List<dynamic> logs = await logService.getDailyLogs(todayDate);

    // 3. Kalkulasi Total Dimakan Hari Ini
    double tempCals = 0;
    double tempPro = 0;
    double tempCarbs = 0;
    double tempFat = 0;

    for (var log in logs) {
      tempCals += _safeDouble(log['totalCalories']);
      tempPro += _safeDouble(log['totalProtein']);
      tempCarbs += _safeDouble(log['totalCarbs']);
      tempFat += _safeDouble(log['totalFat']);
    }

    if (profileData != null) {
      setState(() {
        // Set Data Target
        maxCalories =
            double.tryParse(profileData['calorieGoal'].toString())?.toInt() ??
            0;
        proteinMax =
            double.tryParse(profileData['proteinGoal'].toString()) ?? 0.0;
        carbsMax = double.tryParse(profileData['carbGoal'].toString()) ?? 0.0;
        fatMax = double.tryParse(profileData['fatGoal'].toString()) ?? 0.0;

        // Set Data Progress Bar
        currentCalories = tempCals.toInt();
        proteinCurrent = tempPro;
        carbsCurrent = tempCarbs;
        fatCurrent = tempFat;

        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      print("Data profil kosong atau gagal dimuat.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF90A58D)),
            )
          : Stack(
              children: [
                ClipPath(
                  clipper: HeaderClipper(),
                  child: Container(height: 280, color: const Color(0xFF90A58D)),
                ),
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Hi, Rian!',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          'Target Nutrisimu',
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
                            ),
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
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildDynamicProgressBar(
    String label,
    double current,
    double max,
    Color color,
  ) {
    double percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

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
                Container(
                  height: 10,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
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

class HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 60);
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
