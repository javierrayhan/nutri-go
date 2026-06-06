import 'package:flutter/material.dart';
import 'services/daily_log_service.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  List<double> _weeklyCalories = List.filled(7, 0.0);
  List<String> _weeklyDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
  int _todayIndex = 0; // Untuk mendeteksi hari ini letaknya di bar mana
  double _calorieGoal = 2500.0; // Angka target untuk batas atas grafik
  // Constants Colors
  final Color sageGreen = const Color(0xFF90A58D);
  final Color bgLight = const Color(0xFFF4F7F4);
  final Color textDark = const Color(0xFF2D3748);
  final Color textLight = const Color(0xFF718096);
  final Color cardBorder = const Color(0xFFE2E8F0);
  final Color warningColor = const Color(0xFFE53E3E);

  // State Management
  DateTime _currentDate = DateTime.now(); // Gunakan DateTime asli agar akurat
  bool _isLoading = true;
  double _dailyTotalCals = 0.0;

  // Data Asli dari Server
  List<Map<String, dynamic>> _dailyLogs = [];

  @override
  void initState() {
    super.initState();
    _fetchDailyLogs(_currentDate);
    _fetchWeeklyData();
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  // --- FUNGSI UTAMA: MENARIK DATA DARI SERVER ---
  Future<void> _fetchDailyLogs(DateTime date) async {
    setState(() => _isLoading = true);

    // Format tanggal ke YYYY-MM-DD
    String formattedDate = date.toIso8601String().split('T')[0];

    DailyLogService logService = DailyLogService();
    List<dynamic> logs = await logService.getDailyLogs(formattedDate);

    // Keranjang pengelompokan berdasarkan Waktu Makan
    Map<String, List<dynamic>> groupedLogs = {
      'BREAKFAST': [],
      'LUNCH': [],
      'SNACK': [],
      'DINNER': [],
    };

    double tempTotalCals = 0;

    // Looping dan kelompokkan data
    for (var log in logs) {
      String time = log['mealTime'] ?? 'SNACK';

      // Ambil nama makanan (Join Table Damar)
      String foodName = (log['food'] != null && log['food']['name'] != null)
          ? log['food']['name']
          : 'Makanan Tdk Diketahui';

      Map<String, dynamic> item = {
        'nama': foodName,
        'gramasi': log['consumtionGram'] ?? 0,
        'karbo': _safeDouble(log['totalCarbs']),
        'protein': _safeDouble(log['totalProtein']),
        'lemak': _safeDouble(log['totalFat']),
        'kalori': _safeDouble(log['totalCalories']).toInt(),
      };

      if (groupedLogs.containsKey(time)) {
        groupedLogs[time]!.add(item);
      } else {
        groupedLogs['SNACK']!.add(item); // Default fallback
      }

      tempTotalCals += _safeDouble(log['totalCalories']);
    }

    // Susun ulang ke format yang dimengerti oleh UI buatan Jev
    List<Map<String, dynamic>> finalDisplayLogs = [];

    if (groupedLogs['BREAKFAST']!.isNotEmpty) {
      finalDisplayLogs.add({
        'waktu_makan': 'SARAPAN',
        'items': groupedLogs['BREAKFAST'],
      });
    }
    if (groupedLogs['LUNCH']!.isNotEmpty) {
      finalDisplayLogs.add({
        'waktu_makan': 'MAKAN SIANG',
        'items': groupedLogs['LUNCH'],
      });
    }
    if (groupedLogs['SNACK']!.isNotEmpty) {
      finalDisplayLogs.add({
        'waktu_makan': 'CEMILAN',
        'items': groupedLogs['SNACK'],
      });
    }
    if (groupedLogs['DINNER']!.isNotEmpty) {
      finalDisplayLogs.add({
        'waktu_makan': 'MAKAN MALAM',
        'items': groupedLogs['DINNER'],
      });
    }

    setState(() {
      _dailyLogs = finalDisplayLogs;
      _dailyTotalCals = tempTotalCals;
      _isLoading = false;
    });
  }

  // --- FUNGSI SIHIR: PARALLEL FETCH 7 HARI ---
  Future<void> _fetchWeeklyData() async {
    DailyLogService logService = DailyLogService();
    List<Future<void>> futures = [];
    List<double> tempWeeklyCals = List.filled(7, 0.0);
    List<String> tempDays = List.filled(7, '');

    // Cari hari ini ada di index ke berapa (1 = Senin, 7 = Minggu)
    int currentWeekday = _currentDate.weekday;
    _todayIndex = currentWeekday - 1; // Array mulai dari 0

    // Kita looping 7 hari dari Senin sampai Minggu di minggu ini
    for (int i = 0; i < 7; i++) {
      // Hitung selisih hari (mundur/maju) dari hari ini
      DateTime dayInWeek = _currentDate.subtract(
        Duration(days: _todayIndex - i),
      );

      // Ambil singkatan nama harinya (Sen, Sel, Rab, dll)
      const hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
      tempDays[i] = hari[i];

      // Format YYYY-MM-DD
      String formattedDate = dayInWeek.toIso8601String().split('T')[0];

      // Tembak API barengan!
      futures.add(
        logService.getDailyLogs(formattedDate).then((logs) {
          double totalCalDay = 0;
          for (var log in logs) {
            totalCalDay += _safeDouble(log['totalCalories']);
          }
          tempWeeklyCals[i] = totalCalDay; // Masukkan ke wadah sesuai harinya
        }),
      );
    }

    // Tunggu SEMUA 7 API selesai loading
    await Future.wait(futures);

    setState(() {
      _weeklyCalories = tempWeeklyCals;
      _weeklyDays = tempDays;
    });
  }

  // --- HELPER UNTUK NAMA BULAN ---
  String _getMonthName(int month) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[month - 1];
  }

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
    String displayMonthYear =
        '${_getMonthName(_currentDate.month)} ${_currentDate.year}';

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
                          GestureDetector(
                            onTap: _showDatePickerSheet,
                            child: Row(
                              children: [
                                Text(
                                  '${_currentDate.day} $displayMonthYear',
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

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildWeeklyChart(),
                        const SizedBox(height: 32),

                        // AREA LOG HARIAN
                        _isLoading
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(40),
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF90A58D),
                                  ),
                                ),
                              )
                            : _dailyLogs.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(40),
                                  child: Text(
                                    'Belum ada catatan makanan di hari ini.',
                                    style: TextStyle(color: textLight),
                                  ),
                                ),
                              )
                            : _buildDailyLogsSection(displayMonthYear),

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
            'TOTAL KALORI HARIAN',
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
              // MENAMPILKAN TOTAL KALORI ASLI DARI DATABASE
              Text(
                '${_dailyTotalCals.toInt()}',
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

          // Chart Graphic (Sementara Dibiarkan Statis dari Jev)
          SizedBox(
            height: 120,
            child: Stack(
              children: [
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
                        children: List.generate(
                          dashCount,
                          (_) => Container(
                            width: dashWidth,
                            height: 1,
                            color: Colors.grey.shade300,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(7, (index) {
                    // Hitung persentase kalori (max 1.0 supaya bar tidak keluar batas)
                    double percentage = _calorieGoal > 0
                        ? (_weeklyCalories[index] / _calorieGoal).clamp(
                            0.0,
                            1.0,
                          )
                        : 0.0;

                    // Kalau over target, kasih warna merah peringatan
                    Color barColor = percentage >= 1.0
                        ? warningColor
                        : sageGreen;

                    bool isToday = index == _todayIndex;
                    bool isFuture = index > _todayIndex; // Hari esok abu-abu

                    return _buildChartBar(
                      _weeklyDays[index],
                      percentage,
                      barColor,
                      isToday: isToday,
                      isFuture: isFuture,
                    );
                  }),
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

  Widget _buildDailyLogsSection(String displayMonthYear) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'DETAIL LOG (${_currentDate.day} $displayMonthYear)'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textLight,
              letterSpacing: 1.0,
            ),
          ),
        ),
        ..._dailyLogs.map((group) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                Text(
                  'Karbo ${item['karbo'].toStringAsFixed(1)}g • Pro ${item['protein'].toStringAsFixed(1)}g • Fat ${item['lemak'].toStringAsFixed(1)}g',
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
    int tempSelectedDate = _currentDate.day;

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
                  Container(
                    margin: const EdgeInsets.only(top: 16, bottom: 16),
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
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
                          '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children:
                          ['SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN']
                              .map(
                                (day) => Expanded(
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
                                ),
                              )
                              .toList(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 30,
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
                              Navigator.pop(context);
                              // SET TANGGAL BARU DAN TARIK ULANG DARI SERVER
                              setState(() {
                                _currentDate = DateTime(
                                  _currentDate.year,
                                  _currentDate.month,
                                  tempSelectedDate,
                                );
                              });
                              _fetchDailyLogs(_currentDate);
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
