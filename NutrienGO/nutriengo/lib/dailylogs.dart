import 'package:flutter/material.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  // Constants Colors
  final Color sageGreen = const Color(0xFF90A58D);
  final Color bgLight = const Color(0xFFF4F7F4);
  final Color textDark = const Color(0xFF2D3748);
  final Color textLight = const Color(0xFF718096);
  final Color cardBorder = const Color(0xFFE2E8F0);
  final Color warningColor = const Color(0xFFE53E3E);

  // State
  int _selectedDate = 5; // Default hari ini
  final String _currentMonthYear = "Juni 2026";

  // Data Mock (Sesuai skema database: waktu_makan, kalori_hitung, dll)
  final List<Map<String, dynamic>> _dailyLogs = [
    {
      'waktu_makan': 'SARAPAN',
      'items': [
        {
          'nama': 'Oatmeal Buah',
          'gramasi': 150,
          'karbo': 27.0,
          'protein': 5.0,
          'lemak': 3.0,
          'kalori': 155,
        },
        {
          'nama': 'Susu Almond',
          'gramasi': 200,
          'karbo': 2.0,
          'protein': 1.0,
          'lemak': 2.5,
          'kalori': 30,
        },
      ],
    },
    {
      'waktu_makan': 'MAKAN SIANG',
      'items': [
        {
          'nama': 'Dada Ayam Bakar',
          'gramasi': 150,
          'karbo': 0.0,
          'protein': 46.0,
          'lemak': 5.0,
          'kalori': 240,
        },
      ],
    },
  ];

  void _showToast(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: Color(0xFF90A58D)),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: textDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          // Background Header
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(height: 280, color: sageGreen),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar with Date Picker Trigger
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Laporan',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Tanggal Button
                          GestureDetector(
                            onTap: _showDatePickerSheet,
                            child: Row(
                              children: [
                                Text(
                                  '$_selectedDate $_currentMonthYear',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: _showDatePickerSheet,
                        icon: const Icon(
                          Icons.calendar_today_rounded,
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
                        const SizedBox(height: 16),
                        _buildWeeklyChart(),
                        const SizedBox(height: 32),
                        _buildDailyLogsSection(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RATA-RATA HARIAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textLight,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '1,850',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Chart Graphic
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Target Line (Dashed via custom layout)
                Positioned(
                  top: 30,
                  left: 0,
                  right: 0,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const dashWidth = 5.0;
                      const dashSpace = 5.0;
                      final dashCount =
                          (constraints.constrainWidth() /
                                  (dashWidth + dashSpace))
                              .floor();
                      return Flex(
                        direction: Axis.horizontal,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(dashCount, (_) {
                          return Container(
                            width: dashWidth,
                            height: 1,
                            color: Colors.grey.shade300,
                          );
                        }),
                      );
                    },
                  ),
                ),

                // Bars Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildChartBar('Sen', 0.85, sageGreen),
                    _buildChartBar('Sel', 0.95, sageGreen),
                    _buildChartBar('Rab', 1.0, warningColor), // Overshoot!
                    _buildChartBar('Kam', 0.90, sageGreen),
                    _buildChartBar('Jum', 1.0, sageGreen, isToday: true),
                    _buildChartBar('Sab', 0.0, sageGreen, isFuture: true),
                    _buildChartBar('Min', 0.0, sageGreen, isFuture: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartBar(
    String day,
    double percentage,
    Color color, {
    bool isToday = false,
    bool isFuture = false,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: isFuture ? Colors.transparent : color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.bold,
            color: isToday
                ? textDark
                : (isFuture ? Colors.grey.shade400 : textLight),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'DETAIL LOG ($_selectedDate $_currentMonthYear)'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textLight,
              letterSpacing: 1.0,
            ),
          ),
        ),

        // Loop Through Groups
        ..._dailyLogs.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (e.g. SARAPAN)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xFFF1F5F9), width: 2),
                    ),
                  ),
                  child: Text(
                    group['waktu_makan'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Group Wrapper
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: cardBorder),
                  ),
                  child: Column(
                    children: List.generate(group['items'].length, (index) {
                      final item = group['items'][index];
                      final isLast = index == group['items'].length - 1;

                      return Column(
                        children: [
                          _buildLogItemRow(item),
                          if (!isLast)
                            const Divider(
                              height: 1,
                              color: Color(0xFFF1F5F9),
                              indent: 16,
                              endIndent: 16,
                            ),
                        ],
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildLogItemRow(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['nama'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['gramasi']}g',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textLight,
                  ),
                ),
                const SizedBox(height: 4),
                // Text K P L Minimalis
                Text(
                  'Karbo ${item['karbo']}g • Protein ${item['protein']}g • Lemak ${item['lemak']}g',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFA0AEC0),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item['kalori']}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: textDark,
                ),
              ),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDatePickerSheet() {
    // We use a temporary variable so we don't update the UI until 'Terapkan' is pressed
    int tempSelectedDate = _selectedDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.only(bottom: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  // Header Modal
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pilih Tanggal',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),

                  // Calendar Navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_left_rounded),
                        ),
                        Text(
                          _currentMonthYear,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textDark,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.chevron_right_rounded),
                        ),
                      ],
                    ),
                  ),

                  // Days Header
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'].map(
                            (day) {
                              return Expanded(
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: textLight,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ).toList(),
                    ),
                  ),

                  // Calendar Grid
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 30, // Mock 30 days
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        final day = index + 1;
                        final isSelected = day == tempSelectedDate;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              tempSelectedDate = day;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? sageGreen
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$day',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected ? Colors.white : textDark,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: sageGreen,
                              side: BorderSide(color: sageGreen, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Batal',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Apply the date and simulate API fetch
                              setState(() {
                                _selectedDate = tempSelectedDate;
                              });
                              Navigator.pop(context);
                              _showToast(
                                'Menarik data untuk $_selectedDate $_currentMonthYear...',
                              );

                              // TODO: Call your service here
                              // DailyLogService().getDailyLogs('2026-06-${_selectedDate.toString().padLeft(2, '0')}');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sageGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Terapkan',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav() {
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
          _buildNavItem(Icons.home_rounded, 'Home', false, '/home'),
          _buildNavItem(Icons.note_alt_rounded, 'Tracking', false, '/track'),
          _buildNavItem(Icons.bar_chart_rounded, 'Laporan', true, '/laporan'),
          _buildNavItem(Icons.person_rounded, 'Profil', false, '/profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    String route,
  ) {
    final color = isActive ? sageGreen : Colors.grey[400];
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
