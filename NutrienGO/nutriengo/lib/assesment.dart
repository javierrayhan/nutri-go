import 'package:flutter/material.dart';
import 'services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  String _selectedGender = 'Laki-Laki';
  double _activityLevel = 0.0;
  String _selectedTarget = 'Bulking';
  bool _isLoading = false;

  final Color primaryGreen = const Color(0xFF8B9B82);
  final Color bgLight = const Color(0xFFF8F9F7);
  final Color textDark = const Color(0xFF2D3748);
  final Color textLight = const Color(0xFF718096);
  final Color cardBorder = const Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    // Memantau inputan untuk mengaktifkan/menonaktifkan tombol Lanjut
    _ageController.addListener(_updateFormState);
    _heightController.addListener(_updateFormState);
    _weightController.addListener(_updateFormState);
    _targetWeightController.addListener(_updateFormState);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  void _updateFormState() {
    setState(() {});
  }

  bool get _isFormValid {
    return _ageController.text.isNotEmpty &&
        _heightController.text.isNotEmpty &&
        _weightController.text.isNotEmpty &&
        _targetWeightController.text.isNotEmpty;
  }

  void _updateTarget(String target) {
    setState(() {
      _selectedTarget = target;
      if (target == 'Maintenance') {
        _targetWeightController.text = _weightController.text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bantu kami mengenal\nkondisi badan kamu!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Data ini membantu kami meracik rencana nutrisi yang optimal untuk tubuhmu.',
                style: TextStyle(fontSize: 16, color: textLight, height: 1.4),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: _buildMetricInput(
                      label: 'Umur',
                      unit: 'thn',
                      controller: _ageController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricInput(
                      label: 'Tinggi Badan',
                      unit: 'cm',
                      controller: _heightController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricInput(
                      label: 'Berat Badan',
                      unit: 'kg',
                      controller: _weightController,
                      onChanged: (val) {
                        if (_selectedTarget == 'Maintenance') {
                          _targetWeightController.text = val;
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricInput(
                      label: 'Target Berat Badan',
                      unit: 'kg',
                      controller: _targetWeightController,
                      isTarget: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Jenis Kelamin Biologis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildGenderButton('Laki-Laki')),
                  const SizedBox(width: 16),
                  Expanded(child: _buildGenderButton('Perempuan')),
                ],
              ),
              const SizedBox(height: 32),

              Text(
                'Tingkat Aktivitas Harian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder, width: 2),
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: const Color(0xFFD3D8D0),
                        inactiveTrackColor: const Color(0xFFE2E8F0),
                        thumbColor: primaryGreen,
                        overlayColor: primaryGreen.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 10,
                        ),
                      ),
                      child: Slider(
                        value: _activityLevel,
                        onChanged: (val) {
                          setState(() {
                            _activityLevel = (val * 2).round() / 2;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('JARANG', style: _sliderLabelStyle()),
                        Text('CUKUP AKTIF', style: _sliderLabelStyle()),
                        Text('AKTIF', style: _sliderLabelStyle()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              Text(
                'Apa target kamu?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 12),
              _buildTargetCard(
                title: 'Bulking',
                subtitle: 'Surplus kalori untuk pertumbuhan massa tubuh',
              ),
              const SizedBox(height: 12),
              _buildTargetCard(title: 'Cutting', subtitle: 'Defisit Kalori'),
              const SizedBox(height: 12),
              _buildTargetCard(
                title: 'Maintenance',
                subtitle: 'Mempertahankan berat badan',
              ),
              const SizedBox(height: 40),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        // Tombol dinonaktifkan jika loading atau form belum terisi penuh
                        onPressed: (_isLoading || !_isFormValid)
                            ? null
                            : () async {
                                final int umur =
                                    int.tryParse(_ageController.text) ?? 0;
                                final double tinggi =
                                    double.tryParse(_heightController.text) ??
                                    0;
                                final double berat =
                                    double.tryParse(_weightController.text) ??
                                    0;
                                final double targetBerat =
                                    double.tryParse(
                                      _targetWeightController.text,
                                    ) ??
                                    0;

                                if (umur == 0 ||
                                    tinggi == 0 ||
                                    berat == 0 ||
                                    targetBerat == 0) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Pastikan Umur, Tinggi, Berat, dan Target diisi!',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedTarget == 'Cutting' &&
                                    targetBerat >= berat) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Untuk Cutting, Target Berat harus LEBIH KECIL dari Berat Badan!',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedTarget == 'Bulking' &&
                                    targetBerat <= berat) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Untuk Bulking, Target Berat harus LEBIH BESAR dari Berat Badan!',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                if (_selectedTarget == 'Maintenance' &&
                                    targetBerat != berat) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Untuk Maintenance, Target Berat harus SAMA dengan Berat Badan!',
                                      ),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  // Auto-koreksi angkanya ke user
                                  setState(() {
                                    _targetWeightController.text = berat
                                        .toString();
                                  });
                                  return;
                                }

                                String apiGender =
                                    _selectedGender == 'Laki-Laki'
                                    ? 'MALE'
                                    : 'FEMALE';

                                String apiActivity;
                                if (_activityLevel == 0.0) {
                                  apiActivity = 'SEDENTARY';
                                } else if (_activityLevel == 0.5) {
                                  apiActivity = 'MODERATE';
                                } else {
                                  apiActivity = 'VERY_ACTIVE';
                                }

                                String apiGoal;
                                if (_selectedTarget == 'Bulking') {
                                  apiGoal = 'BULKING';
                                } else if (_selectedTarget == 'Cutting') {
                                  apiGoal = 'CUTTING';
                                } else {
                                  apiGoal = 'MAINTAINING';
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                ProfileService profileService =
                                    ProfileService();
                                bool isSuccess = await profileService
                                    .createProfile(
                                      age: umur,
                                      height: tinggi,
                                      weight: berat,
                                      weightGoal: targetBerat,
                                      gender: apiGender,
                                      activityLevel: apiActivity,
                                      goal: apiGoal,
                                    );

                                if (!mounted) return;
                                setState(() {
                                  _isLoading = false;
                                });

                                if (isSuccess) {
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.setBool(
                                    'is_profile_completed',
                                    true,
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Profil berhasil disimpan!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  Navigator.pushReplacementNamed(
                                    context,
                                    '/home',
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Gagal menyimpan profil. Coba lagi.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Text(
                                'SIMPAN DAN LANJUTKAN!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  TextStyle _sliderLabelStyle() {
    return const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.bold,
      color: Color(0xFFA0AEC0),
      letterSpacing: 0.5,
    );
  }

  Widget _buildMetricInput({
    required String label,
    required String unit,
    required TextEditingController controller,
    bool isTarget = false,
    Function(String)? onChanged,
  }) {
    Color bgColor = isTarget ? const Color(0xFFF1F3F0) : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cardBorder, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: textLight,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String title) {
    bool isSelected = _selectedGender == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFFE2E8E4),
          borderRadius: BorderRadius.circular(27),
          border: Border.all(
            color: isSelected ? cardBorder : Colors.transparent,
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isSelected ? textDark : const Color(0xFF8B9B82),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetCard({required String title, required String subtitle}) {
    bool isSelected = _selectedTarget == title;
    return GestureDetector(
      onTap: () => _updateTarget(title),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEBEFE9) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryGreen : cardBorder,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textLight,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
