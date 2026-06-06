import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/profile_service.dart';
import 'services/auth_service.dart';

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
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => _isLoading = true);

    final profileResponse = await _profileService.getProfile();
    final userResponse = await _authService.getUserMe();

    setState(() {
      _profileData = profileResponse;
      _userData = userResponse;
      _isLoading = false;
    });
  }

  Future<void> _performLogOut() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Color(0xFF90A58D)),
      ),
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');

    if (!mounted) return;
    Navigator.pop(context);
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // Mapper UI agar berbahasa Indonesia
  String _mapGenderToUI(String? apiGender) {
    if (apiGender == 'FEMALE') return 'Perempuan';
    if (apiGender == 'MALE') return 'Laki-Laki';
    return apiGender ?? '-';
  }

  String _mapGoalToUI(String? apiGoal) {
    if (apiGoal == 'CUTTING') return 'Cutting';
    if (apiGoal == 'BULKING') return 'Bulking';
    if (apiGoal == 'MAINTAINING') return 'Maintain';
    return apiGoal ?? '-';
  }

  void _showEditProfileModal() {
    if (_profileData == null) return;

    int age = _profileData!['age'] ?? 25;
    double height = _safeDouble(_profileData!['height']);
    double weight = _safeDouble(_profileData!['weight']);
    double weightGoal = _safeDouble(_profileData!['weightGoal']);
    String gender = _profileData!['gender'] == 'FEMALE' ? 'FEMALE' : 'MALE';
    String activityLevel = _profileData!['activityLevel'] ?? 'MODERATE';

    String currentGoal = (_profileData!['goal'] ?? '').toString().toUpperCase();
    String goal = 'MAINTAINING';
    if (currentGoal == 'BULKING') goal = 'BULKING';
    if (currentGoal == 'CUTTING') goal = 'CUTTING';

    bool isModalSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Update Profil & Target',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: age.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Umur',
                            ),
                            onChanged: (val) => age = int.tryParse(val) ?? age,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: height.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Tinggi (cm)',
                            ),
                            onChanged: (val) =>
                                height = double.tryParse(val) ?? height,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: weight.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Berat (kg)',
                            ),
                            onChanged: (val) =>
                                weight = double.tryParse(val) ?? weight,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            initialValue: weightGoal.toString(),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Target (kg)',
                              labelStyle: TextStyle(
                                color: Color(0xFF90A58D),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onChanged: (val) =>
                                weightGoal = double.tryParse(val) ?? weightGoal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: gender,
                      decoration: const InputDecoration(
                        labelText: 'Jenis Kelamin',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'MALE',
                          child: Text('Laki-Laki'),
                        ),
                        DropdownMenuItem(
                          value: 'FEMALE',
                          child: Text('Perempuan'),
                        ),
                      ],
                      onChanged: (val) => setModalState(() => gender = val!),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: activityLevel,
                      decoration: const InputDecoration(
                        labelText: 'Level Aktivitas',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'SEDENTARY',
                          child: Text('Jarang Bergerak'),
                        ),
                        DropdownMenuItem(
                          value: 'MODERATE',
                          child: Text('Cukup Aktif'),
                        ),
                        DropdownMenuItem(
                          value: 'VERY_ACTIVE',
                          child: Text('Sangat Aktif'),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => activityLevel = val!),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: goal,
                      decoration: const InputDecoration(
                        labelText: 'Target Tubuh',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'CUTTING',
                          child: Text('Cutting (Turun Berat)'),
                        ),
                        DropdownMenuItem(
                          value: 'MAINTAINING',
                          child: Text('Maintain (Jaga Berat)'),
                        ),
                        DropdownMenuItem(
                          value: 'BULKING',
                          child: Text('Bulking (Naik Berat)'),
                        ),
                      ],
                      onChanged: (val) => setModalState(() => goal = val!),
                    ),
                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF90A58D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: isModalSaving
                            ? null
                            : () async {
                                // Validasi Logika Target
                                if (goal == 'CUTTING' && weightGoal >= weight) {
                                  _showToast(
                                    context,
                                    'Untuk Cutting, target berat harus lebih kecil dari berat saat ini!',
                                  );
                                  return;
                                }
                                if (goal == 'BULKING' && weightGoal <= weight) {
                                  _showToast(
                                    context,
                                    'Untuk Bulking, target berat harus lebih besar dari berat saat ini!',
                                  );
                                  return;
                                }

                                setModalState(() {
                                  isModalSaving = true;
                                });

                                bool success = await _profileService
                                    .updateProfile({
                                      "age": age,
                                      "height": height,
                                      "weight": weight,
                                      "weightGoal": weightGoal,
                                      "gender": gender,
                                      "activityLevel": activityLevel,
                                      "goal": goal,
                                    });

                                if (!mounted) return;

                                if (success) {
                                  Navigator.pop(context);
                                  _showToast(
                                    context,
                                    'Profil berhasil diupdate!',
                                  );
                                  _fetchAllData();
                                } else {
                                  setModalState(() {
                                    isModalSaving = false;
                                  });
                                  _showToast(
                                    context,
                                    'Gagal mengupdate profil. Cek koneksi server.',
                                  );
                                }
                              },
                        child: isModalSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'SIMPAN PERUBAHAN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  void _showToast(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF90A58D)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
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
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(height: 280, color: sageGreen),
          ),
          SafeArea(
            child: Column(
              children: [
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.topCenter,
                          children: [
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
                                    _userData != null
                                        ? _userData!['email']
                                              .split('@')[0]
                                              .toUpperCase()
                                        : 'Rian',
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
                                              ? '${_mapGenderToUI(_profileData!['gender'])} • ${_mapGoalToUI(_profileData!['goal'])}'
                                              : (_userData != null
                                                    ? _userData!['email']
                                                    : 'user@nutriengo.com')),
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
                                title: 'Update Profil & Target',
                                onTap: _showEditProfileModal,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
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
                            onTap: _performLogOut,
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
        color: Colors.transparent,
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
