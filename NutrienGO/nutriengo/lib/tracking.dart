import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/food_service.dart';
import 'services/daily_log_service.dart';
import 'services/auth_service.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  String _firstName = 'User';

  List<Map<String, dynamic>> mealSchedules = [
    {
      'title': 'Makan Pagi',
      'mealTime': 'BREAKFAST',
      'cals': 0.0,
      'fat': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
      'items': [],
    },
    {
      'title': 'Makan Siang',
      'mealTime': 'LUNCH',
      'cals': 0.0,
      'fat': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
      'items': [],
    },
    {
      'title': 'Makan Malam',
      'mealTime': 'DINNER',
      'cals': 0.0,
      'fat': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
      'items': [],
    },
    {
      'title': 'Cemilan',
      'mealTime': 'SNACK',
      'cals': 0.0,
      'fat': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
      'items': [],
    },
  ];

  List<dynamic> _allFoods = [];
  List<dynamic> _filteredFoods = [];

  bool _isLoadingLogs = true;

  double _dailyTotalCals = 0;
  double _dailyTotalPro = 0;
  double _dailyTotalCarbs = 0;
  double _dailyTotalFat = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayLogs();
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Future<void> _loadTodayLogs() async {
    setState(() => _isLoadingLogs = true);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? fullName = prefs.getString('user_fullname');
    String fName = 'User';

    if (fullName != null && fullName.trim().isNotEmpty) {
      fName = fullName.trim().split(' ')[0];
    } else {
      // JIKA BRANKAS KOSONG (Karena baru install & Login)
      AuthService authService = AuthService();
      final userData = await authService.getUserMe();
      if (userData != null && userData['email'] != null) {
        String emailStr = userData['email'].split(
          '@',
        )[0]; // Ambil nama depan dari email
        // Buat huruf pertama jadi Kapital
        fName = emailStr[0].toUpperCase() + emailStr.substring(1);
      }
    }

    DailyLogService logService = DailyLogService();
    String todayDate = DateTime.now().toIso8601String().split('T')[0];
    List<dynamic> logs = await logService.getDailyLogs(todayDate);

    Map<String, Map<String, dynamic>> grouped = {
      'BREAKFAST': {
        'title': 'Makan Pagi',
        'mealTime': 'BREAKFAST',
        'cals': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
        'protein': 0.0,
        'items': [],
      },
      'LUNCH': {
        'title': 'Makan Siang',
        'mealTime': 'LUNCH',
        'cals': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
        'protein': 0.0,
        'items': [],
      },
      'DINNER': {
        'title': 'Makan Malam',
        'mealTime': 'DINNER',
        'cals': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
        'protein': 0.0,
        'items': [],
      },
      'SNACK': {
        'title': 'Cemilan',
        'mealTime': 'SNACK',
        'cals': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
        'protein': 0.0,
        'items': [],
      },
    };

    double tempDailyCals = 0;
    double tempDailyPro = 0;
    double tempDailyCarbs = 0;
    double tempDailyFat = 0;

    for (var log in logs) {
      String time = log['mealTime'] ?? 'SNACK';
      log['foodName'] = (log['food'] != null && log['food']['name'] != null)
          ? log['food']['name']
          : 'Makanan Tdk Diketahui';

      if (grouped.containsKey(time)) {
        grouped[time]!['cals'] += _safeDouble(log['totalCalories']);
        grouped[time]!['fat'] += _safeDouble(log['totalFat']);
        grouped[time]!['carbs'] += _safeDouble(log['totalCarbs']);
        grouped[time]!['protein'] += _safeDouble(log['totalProtein']);
        grouped[time]!['items'].add(log);
      }

      tempDailyCals += _safeDouble(log['totalCalories']);
      tempDailyPro += _safeDouble(log['totalProtein']);
      tempDailyCarbs += _safeDouble(log['totalCarbs']);
      tempDailyFat += _safeDouble(log['totalFat']);
    }

    if (!mounted) return;
    setState(() {
      _firstName = fName;
      mealSchedules = [
        grouped['BREAKFAST']!,
        grouped['LUNCH']!,
        grouped['DINNER']!,
        grouped['SNACK']!,
      ];
      _dailyTotalCals = tempDailyCals;
      _dailyTotalPro = tempDailyPro;
      _dailyTotalCarbs = tempDailyCarbs;
      _dailyTotalFat = tempDailyFat;
      _isLoadingLogs = false;
    });
  }

  Future<void> _fetchFoods() async {
    FoodService foodService = FoodService();
    List<dynamic> foods = await foodService.getFoods();
    for (var food in foods) {
      food['checked'] = false;
    }
    setState(() {
      _allFoods = foods;
    });
  }

  void _runClientFilter(String enteredKeyword, StateSetter setModalState) {
    List<dynamic> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allFoods.take(10).toList();
    } else {
      results = _allFoods
          .where(
            (food) => food["name"].toString().toLowerCase().contains(
              enteredKeyword.toLowerCase(),
            ),
          )
          .take(10)
          .toList();
    }
    setModalState(() {
      _filteredFoods = results;
    });
  }

  Future<void> _deleteLogItemBackground(int id, String foodName) async {
    DailyLogService logService = DailyLogService();
    bool success = await logService.deleteDailyLog(id);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Koneksi terputus. Gagal menghapus $foodName'),
          backgroundColor: Colors.red,
        ),
      );
      _loadTodayLogs();
    }
  }

  // =========================================================================
  // SERANGAN PART B: FITUR EDIT GRAMASI
  // =========================================================================
  Future<void> _editLogItem(dynamic item, Map<String, dynamic> meal) async {
    double oldGram = _safeDouble(item['consumtionGram']);
    if (oldGram == 0) oldGram = 1; // Mencegah error dibagi nol

    final TextEditingController gramController = TextEditingController(
      text: oldGram.toInt().toString(),
    );

    double? newGram = await showDialog<double>(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Ubah Porsi: ${item['foodName']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan gramasi baru:'),
            const SizedBox(height: 12),
            TextField(
              controller: gramController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'gram',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, null),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF90A58D),
            ),
            onPressed: () {
              double val = double.tryParse(gramController.text) ?? 0;
              if (val > 0) Navigator.pop(c, val);
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Jika user memasukkan angka baru yang berbeda dari angka lama
    if (newGram != null && newGram != oldGram) {
      double oldCals = _safeDouble(item['totalCalories']);
      double oldPro = _safeDouble(item['totalProtein']);
      double oldCarbs = _safeDouble(item['totalCarbs']);
      double oldFat = _safeDouble(item['totalFat']);

      // KALKULASI RUMUS MATEMATIKA DI FLUTTER
      double newCals = (oldCals / oldGram) * newGram;
      double newPro = (oldPro / oldGram) * newGram;
      double newCarbs = (oldCarbs / oldGram) * newGram;
      double newFat = (oldFat / oldGram) * newGram;

      // 1. OPTIMISTIC UI: LANGSUNG UBAH TAMPILAN TANPA LOADING!
      setState(() {
        // Update data makanan itu sendiri
        item['consumtionGram'] = newGram.toInt();
        item['totalCalories'] = newCals;
        item['totalProtein'] = newPro;
        item['totalCarbs'] = newCarbs;
        item['totalFat'] = newFat;

        // Update total di Card Makan (Pagi/Siang/Malam)
        meal['cals'] += (newCals - oldCals);
        meal['protein'] += (newPro - oldPro);
        meal['carbs'] += (newCarbs - oldCarbs);
        meal['fat'] += (newFat - oldFat);

        // Update Rekap Total Paling Atas
        _dailyTotalCals += (newCals - oldCals);
        _dailyTotalPro += (newPro - oldPro);
        _dailyTotalCarbs += (newCarbs - oldCarbs);
        _dailyTotalFat += (newFat - oldFat);
      });

      // 2. KIRIM DATA KE BACKEND DI BELAKANG LAYAR (SILENT BACKGROUND)
      DailyLogService logService = DailyLogService();
      Map<String, dynamic> patchPayload = {
        "consumtionGram": newGram.toInt(),
        "totalCalories": newCals,
        "totalProtein": newPro,
        "totalCarbs": newCarbs,
        "totalFat": newFat,
      };

      bool success = await logService.updateDailyLogGram(
        item['id'],
        patchPayload,
      );

      // Jika ternyata internet putus / gagal, kita kembalikan datanya (Rollback)
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi gagal. Perubahan tidak tersimpan.'),
            backgroundColor: Colors.red,
          ),
        );
        _loadTodayLogs(); // Tarik ulang data lama dari server
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: Stack(
        children: [
          ClipPath(
            clipper: HeaderClipper(),
            child: Container(height: 280, color: const Color(0xFF90A58D)),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $_firstName!',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Jurnal Harian',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isLoadingLogs
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              _buildDailySummaryCard(),
                              const SizedBox(height: 24),
                              ...mealSchedules
                                  .map((meal) => _buildExpandableMealCard(meal))
                                  .toList(),
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

  Widget _buildDailySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Asupan Hari Ini',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${_dailyTotalCals.toInt()}',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF90A58D),
                ),
              ),
              const Text(
                ' kcal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFFEEEEEE), height: 30, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroInfo(
                'LEMAK',
                '${_dailyTotalFat.toStringAsFixed(1)}g',
                color: const Color(0xFFFFD93D),
              ),
              _buildMacroInfo(
                'KARB',
                '${_dailyTotalCarbs.toStringAsFixed(1)}g',
                color: const Color(0xFF4D96FF),
              ),
              _buildMacroInfo(
                'PROTEIN',
                '${_dailyTotalPro.toStringAsFixed(1)}g',
                color: const Color(0xFFFF6B6B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandableMealCard(Map<String, dynamic> meal) {
    int totalCals = (meal['cals'] as double).toInt();
    List<dynamic> items = meal['items'] ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Material(
        color: Colors.transparent,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            leading: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: Color(0xFF90A58D),
                shape: BoxShape.circle,
              ),
            ),
            title: Text(
              meal['title'],
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$totalCals',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Kalori',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.black,
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMacroInfo(
                          'LEMAK',
                          '${(meal['fat'] as double).toStringAsFixed(1)}g',
                        ),
                        _buildMacroInfo(
                          'KARB',
                          '${(meal['carbs'] as double).toStringAsFixed(1)}g',
                        ),
                        _buildMacroInfo(
                          'PROTEIN',
                          '${(meal['protein'] as double).toStringAsFixed(1)}g',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (items.isNotEmpty) ...[
                      const Divider(color: Color(0xFFEEEEEE), thickness: 1),
                      const SizedBox(height: 8),
                      ...items.map((item) {
                        return Dismissible(
                          key: ValueKey(item['id'].toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.delete_sweep_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          onDismissed: (direction) {
                            double itemCals = _safeDouble(
                              item['totalCalories'],
                            );
                            double itemPro = _safeDouble(item['totalProtein']);
                            double itemCarbs = _safeDouble(item['totalCarbs']);
                            double itemFat = _safeDouble(item['totalFat']);

                            setState(() {
                              items.remove(item);
                              meal['cals'] -= itemCals;
                              meal['protein'] -= itemPro;
                              meal['carbs'] -= itemCarbs;
                              meal['fat'] -= itemFat;
                              _dailyTotalCals -= itemCals;
                              _dailyTotalPro -= itemPro;
                              _dailyTotalCarbs -= itemCarbs;
                              _dailyTotalFat -= itemFat;
                            });
                            _deleteLogItemBackground(
                              item['id'],
                              item['foodName'],
                            );
                          },
                          // MEMBUAT ITEM BISA DIKLIK UNTUK DI-EDIT
                          child: InkWell(
                            onTap: () => _editLogItem(item, meal),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['foodName'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${item['consumtionGram']} gram (Ketuk untuk ubah)',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${_safeDouble(item['totalCalories']).toInt()} kcal',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF90A58D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 16),
                    ],
                    TextButton.icon(
                      onPressed: () async {
                        if (_allFoods.isEmpty) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF90A58D),
                              ),
                            ),
                          );
                          await _fetchFoods();
                          if (mounted) Navigator.pop(context);
                        }
                        setState(() {
                          _filteredFoods = _allFoods.take(10).toList();
                        });
                        _showSearchModal(
                          context,
                          meal['title'],
                          meal['mealTime'],
                        );
                      },
                      icon: const Icon(
                        Icons.add_circle_outline,
                        color: Color(0xFF90A58D),
                      ),
                      label: const Text(
                        'Tambah Makanan',
                        style: TextStyle(
                          color: Color(0xFF90A58D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMacroInfo(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showSearchModal(
    BuildContext context,
    String mealTitle,
    String mealTimeEnum,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (_, controller) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: Color(0xFF90A58D),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(30),
                          ),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mealTitle,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  'Cari dari Database',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: TextField(
                          onChanged: (value) =>
                              _runClientFilter(value, setModalState),
                          decoration: InputDecoration(
                            hintText: 'Cari dada ayam, nasi, dll...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: _filteredFoods.isEmpty
                            ? const Center(
                                child: Text(
                                  'Makanan tidak ditemukan',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : _buildInteractiveSearchList(
                                _filteredFoods,
                                controller,
                                setModalState,
                              ),
                      ),
                      if (_filteredFoods.any((food) => food['checked'] == true))
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF90A58D),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              onPressed: () {
                                final selectedFoods = _filteredFoods
                                    .where((f) => f['checked'] == true)
                                    .toList();
                                Navigator.pop(context);
                                Future.delayed(
                                  const Duration(milliseconds: 300),
                                  () {
                                    if (selectedFoods.isNotEmpty)
                                      _processSelectedFoods(
                                        selectedFoods,
                                        mealTimeEnum,
                                      );
                                  },
                                );
                              },
                              child: const Text(
                                'Lanjut Atur Porsi',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveSearchList(
    List<dynamic> items,
    ScrollController controller,
    StateSetter setModalState,
  ) {
    return ListView.separated(
      controller: controller,
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        final cals = _safeDouble(items[index]['calories']).toInt();
        final pro = _safeDouble(items[index]['protein']);

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          title: Text(
            items[index]['name'] ?? 'Unknown',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Text(
            '100g = $cals kkal | Protein: ${pro}g',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Checkbox(
            value: items[index]['checked'] == true,
            onChanged: (bool? newValue) {
              setModalState(() {
                items[index]['checked'] = newValue ?? false;
              });
            },
            activeColor: const Color(0xFF90A58D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          onTap: () {
            setModalState(() {
              items[index]['checked'] = !(items[index]['checked'] == true);
            });
          },
        );
      },
    );
  }

  Future<void> _processSelectedFoods(
    List<dynamic> selectedFoods,
    String mealTimeEnum,
  ) async {
    // 1. Munculkan Dialog Kolektif
    Map<int, double>? inputtedGrams = await _showCollectiveGramDialog(
      context,
      selectedFoods,
    );

    // 2. Jika user menekan "Catat Semua" dan datanya ada
    if (inputtedGrams != null && inputtedGrams.isNotEmpty) {
      if (!mounted) return;

      // Tampilkan Loading Screen
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => const Center(
          child: CircularProgressIndicator(color: Color(0xFF90A58D)),
        ),
      );

      DailyLogService logService = DailyLogService();

      // ==========================================
      // FIX TIMEZONE BUG: Paksa pakai Tanggal Lokal
      // ==========================================
      String todayDate = DateTime.now().toIso8601String().split('T')[0];
      String todayIso = "${todayDate}T00:00:00.000Z";
      // ==========================================

      // Buat List Future untuk Parallel Fetching
      List<Future<bool>> futures = [];

      inputtedGrams.forEach((index, gram) {
        var food = selectedFoods[index];
        double cals = (_safeDouble(food['calories']) / 100) * gram;
        double pro = (_safeDouble(food['protein']) / 100) * gram;
        double carbs = (_safeDouble(food['carbs']) / 100) * gram;
        double fat = (_safeDouble(food['fat']) / 100) * gram;
        double sugar = (_safeDouble(food['sugar']) / 100) * gram;
        double natrium = (_safeDouble(food['natrium']) / 100) * gram;

        Map<String, dynamic> payload = {
          "foodId": food['id'],
          "date": todayIso,
          "mealTime": mealTimeEnum,
          "consumtionGram": gram.toInt(),
          "totalCalories": cals > 0 ? cals : 0.01,
          "totalProtein": pro > 0 ? pro : 0.01,
          "totalCarbs": carbs > 0 ? carbs : 0.01,
          "totalFat": fat > 0 ? fat : 0.01,
          "totalSugar": sugar > 0 ? sugar : 0.01,
          "totalNatrium": natrium > 0 ? natrium : 0.01,
        };

        // Kumpulkan semua request ke dalam List
        futures.add(logService.createDailyLog(payload));
      });

      // 3. Tembak Semua API Bersamaan! (Sangat Cepat)
      List<bool> results = await Future.wait(futures);

      if (!mounted) return;
      Navigator.pop(context); // Tutup Loading

      // Jika minimal ada 1 yang berhasil
      if (results.contains(true)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Semua makanan berhasil dicatat!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Koneksi terputus. Gagal mencatat.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // Bersihkan centang dan refresh UI
    setState(() {
      for (var f in _allFoods) f['checked'] = false;
    });
    _loadTodayLogs();
  }

  // WIDGET POP-UP KOLEKTIF
  Future<Map<int, double>?> _showCollectiveGramDialog(
    BuildContext context,
    List<dynamic> foods,
  ) {
    // Siapkan Controller sejumlah makanan yang dipilih
    List<TextEditingController> controllers = List.generate(
      foods.length,
      (_) => TextEditingController(),
    );

    return showDialog<Map<int, double>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Atur Porsi Makanan',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            // Bungkus dengan Scroll agar aman walau user pilih 10 makanan
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: foods.length,
              separatorBuilder: (c, i) => const SizedBox(height: 12),
              itemBuilder: (c, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        foods[index]['name'] ?? 'Makanan',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: controllers[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: 'gram',
                          isDense: true,
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF90A58D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Map<int, double> results = {};
                for (int i = 0; i < foods.length; i++) {
                  double val = double.tryParse(controllers[i].text) ?? 0;
                  if (val > 0) {
                    results[i] = val; // Simpan index dan nilai gram-nya
                  }
                }
                Navigator.pop(context, results);
              },
              child: const Text(
                'Catat Semua',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
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
          _buildNavItem(Icons.note_alt_rounded, 'Tracking', true, '/track'),
          _buildNavItem(Icons.bar_chart_rounded, 'Laporan', false, '/laporan'),
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
    final color = isActive ? const Color(0xFF90A58D) : Colors.grey[400];
    return GestureDetector(
      onTap: () {
        if (!isActive) Navigator.pushReplacementNamed(context, route);
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
