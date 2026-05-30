import 'package:flutter/material.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  // Controllers for our text inputs
  final TextEditingController _ageController = TextEditingController(
    text: '67',
  );
  final TextEditingController _heightController = TextEditingController(
    text: '167',
  );
  final TextEditingController _weightController = TextEditingController(
    text: '67',
  );
  final TextEditingController _targetWeightController = TextEditingController(
    text: '69',
  );

  // State variables for interactive elements
  String _selectedGender = 'Laki-Laki';
  double _activityLevel = 0.0; // 0.0 = Jarang, 0.5 = Cukup Aktif, 1.0 = Aktif
  String _selectedTarget = 'Bulking';

  // Core thematic colors extracted from the design
  final Color primaryGreen = const Color(0xFF8B9B82);
  final Color bgLight = const Color(0xFFF8F9F7);
  final Color textDark = const Color(0xFF2D3748);
  final Color textLight = const Color(0xFF718096);
  final Color cardBorder = const Color(0xFFE2E8F0);

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  // Smart logic: Sync target weight if maintenance is selected
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
              // 1. Header Section
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

              // 2. Metrics Grid (2x2)
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

              // 3. Gender Selection
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

              // 4. Activity Level Slider
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
                            // Snap to nearest 0.5 step
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

              // 5. Target Selection
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

              // 6. Bottom Navigation Actions
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC7CEC3),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, '/login'),
                        child: const Text(
                          'KEMBALI',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
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
                        onPressed: () {
                          Navigator.pushNamed(context, '/home');
                        },
                        child: const Text(
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

  // --- HELPER WIDGETS ---

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
    // Slightly differentiate target weight background to imply it's a goal
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
