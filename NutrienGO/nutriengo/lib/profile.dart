import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _userData;
  final ProfileService _profileService = ProfileService();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    // Also fetch user data by calling /api/auth/me inline or using a service
    final data = await _profileService.getProfile();

    // Quick inline fetch for user info
    Map<String, dynamic>? userData;
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      if (token != null) {
        final response = await http.get(
          Uri.parse('https://api-nutrigo.vercel.app/api/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          final json = jsonDecode(response.body);
          if (json['data'] != null) userData = json['data'];
        }
      }
    } catch (e) {
      debugPrint('Error get me: $e');
    }

    setState(() {
      _profileData = data;
      _userData = userData;
      _isLoading = false;
    });
  }

  String _formatGender(String? raw) {
    if (raw == 'MALE') return 'Laki-Laki';
    if (raw == 'FEMALE') return 'Perempuan';
    return raw ?? '-';
  }

  String _formatGoal(String? raw) {
    if (raw == 'LOSE_WEIGHT') return 'Turunkan BB';
    if (raw == 'MAINTAIN_WEIGHT') return 'Jaga BB';
    if (raw == 'GAIN_WEIGHT') return 'Naikkan BB';
    return raw ?? '-';
  }

  // Helper method for native-feeling toasts
  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF90A58D)),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: const Color(0xFF2D3748),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color sageGreen = Color(0xFF90A58D);
    const Color bgLight = Color(0xFFF4F7F4);
    const Color textDark = Color(0xFF2D3748);
    const Color textLight = Color(0xFF718096);
    const Color cardBorder = Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          // Curved Green Header Background
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(height: 280, color: sageGreen),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            _showToast(context, 'Membuka pengaturan...'),
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),

                        // Profile Card with Overlapping Avatar
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
                            // The White Card
                            Container(
                              margin: const EdgeInsets.only(top: 48),
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                60,
                                24,
                                24,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: cardBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    'Hi, ${_userData?['email']?.split('@').first ?? 'User'}!',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                      color: textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _isLoading
                                        ? 'Memuat data...'
                                        : (_profileData != null
                                              ? '${_formatGender(_profileData!['gender'])} • ${_formatGoal(_profileData!['goal'])}'
                                              : (_userData?['email'] ??
                                                    'Membuat profil...')),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: textLight,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  const SizedBox(height: 24),
                                  const Divider(
                                    color: Color(0xFFF1F5F9),
                                    thickness: 1.5,
                                  ),
                                  const SizedBox(height: 20),

                                  // Mini Stats
                                  _isLoading
                                      ? const Padding(
                                          padding: EdgeInsets.all(20.0),
                                          child: CircularProgressIndicator(
                                            color: sageGreen,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            _buildMiniStat(
                                              'BERAT AWAL',
                                              _profileData?['weight']
                                                      ?.toString() ??
                                                  '-',
                                              textLight,
                                              textDark,
                                            ),
                                            Container(
                                              width: 1.5,
                                              height: 40,
                                              color: const Color(0xFFF1F5F9),
                                            ),
                                            _buildMiniStat(
                                              'TARGET',
                                              _profileData?['weightGoal']
                                                      ?.toString() ??
                                                  '-',
                                              textLight,
                                              textDark,
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),

                            // Overlapping Avatar
                            Positioned(
                              top: 0,
                              child: Container(
                                width: 96,
                                height: 96,
                                decoration: BoxDecoration(
                                  color: sageGreen,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 48,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),

                        // Account Settings Menu
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            'PENGATURAN AKUN',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder),
                          ),
                          child: Column(
                            children: [
                              _buildMenuTile(
                                context,
                                title: 'Edit Data Diri',
                                onTap: () => _showToast(
                                  context,
                                  'Menu Edit Profil di-klik',
                                ),
                              ),
                              const Divider(
                                height: 1,
                                color: Color(0xFFF1F5F9),
                                indent: 16,
                                endIndent: 16,
                              ),
                              _buildMenuTile(
                                context,
                                title: 'Ubah Target Nutrisi',
                                onTap: () => _showToast(
                                  context,
                                  'Menu Target Nutrisi di-klik',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Others Menu
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, bottom: 12.0),
                          child: Text(
                            'LAINNYA',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textLight,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(bottom: 40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: cardBorder),
                          ),
                          child: _buildMenuTile(
                            context,
                            title: 'Keluar (Log Out)',
                            textColor: Colors.redAccent,
                            onTap: () async {
                              _showToast(context, 'Proses Log Out...');
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('jwt_token');
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // --- COMPONENT BUILDERS ---

  Widget _buildMiniStat(
    String label,
    String value,
    Color labelColor,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              'kg',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    Color textColor = const Color(0xFF2D3748),
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // --- BOTTOM NAV ---
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
          _buildNavItem(context, Icons.home_rounded, 'Home', false, '/home'),
          _buildNavItem(
            context,
            Icons.note_alt_rounded,
            'Tracking',
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
          _buildNavItem(
            context,
            Icons.person_rounded,
            'Profil',
            true,
            '/profile',
          ),
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
        if (!isActive) Navigator.pushReplacementNamed(context, route);
      },
      child: Container(
        color: Colors.transparent, // Increases tap target area
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM CLIPPER ---
// Reused from your previous screens to keep it self-contained
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
