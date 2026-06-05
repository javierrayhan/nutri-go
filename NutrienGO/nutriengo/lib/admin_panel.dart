import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/food_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final FoodService _foodService = FoodService();

  // --- STATE UNTUK MANAJEMEN DATA & FILTER ---
  List<dynamic> _allFoods = []; // Menyimpan semua data asli dari server
  List<dynamic> _filteredFoods =
      []; // Menyimpan data yang sedang ditampilkan (hasil filter)
  bool _isLoading = true;

  String _searchQuery = '';
  String _selectedAlphabet = 'Semua';

  // Generate abjad A-Z secara otomatis
  final List<String> _alphabets = [
    'Semua',
    ...List.generate(26, (index) => String.fromCharCode(index + 65)),
  ];

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    final foods = await _foodService.getFoods();

    // Sortir data asli berdasarkan abjad agar rapi
    foods.sort(
      (a, b) => (a['name'] ?? '').toString().toLowerCase().compareTo(
        (b['name'] ?? '').toString().toLowerCase(),
      ),
    );

    setState(() {
      _allFoods = foods;
      _applyFilters(); // Langsung terapkan filter saat data masuk
      _isLoading = false;
    });
  }

  // --- FUNGSI FILTER CLIENT-SIDE (SUPER CEPAT) ---
  void _applyFilters() {
    List<dynamic> result = _allFoods;

    // 1. Saring berdasarkan Abjad
    if (_selectedAlphabet != 'Semua') {
      result = result.where((food) {
        String name = food['name']?.toString() ?? '';
        if (name.isEmpty) return false;
        // Cek apakah huruf pertama sama dengan abjad yang dipilih (Case Insensitive)
        return name.toUpperCase().startsWith(_selectedAlphabet);
      }).toList();
    }

    // 2. Saring berdasarkan Kata Kunci Pencarian
    if (_searchQuery.isNotEmpty) {
      result = result.where((food) {
        String name = food['name']?.toString() ?? '';
        return name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    setState(() {
      _filteredFoods = result;
    });
  }

  double _safeDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Future<void> _adminLogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('user_role');
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  void _showFoodFormModal({Map<String, dynamic>? existingFood}) {
    final bool isEdit = existingFood != null;

    final nameController = TextEditingController(
      text: isEdit ? existingFood['name'] : '',
    );
    final calController = TextEditingController(
      text: isEdit ? _safeDouble(existingFood['calories']).toString() : '',
    );
    final proController = TextEditingController(
      text: isEdit ? _safeDouble(existingFood['protein']).toString() : '',
    );
    final carbController = TextEditingController(
      text: isEdit ? _safeDouble(existingFood['carbs']).toString() : '',
    );
    final fatController = TextEditingController(
      text: isEdit ? _safeDouble(existingFood['fat']).toString() : '',
    );
    final sugarController = TextEditingController(
      text: isEdit ? _safeDouble(existingFood['sugar']).toString() : '',
    );
    final natController = TextEditingController(
      text: isEdit ? _safeDouble(existingFood['natrium']).toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? 'Edit Makanan' : 'Tambah Makanan Baru',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Makanan (Contoh: Nasi Goreng)',
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: calController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Kalori (per 100g)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: proController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Protein (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: carbController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Karbohidrat (g)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: fatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Lemak (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sugarController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Gula (g)',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: natController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Natrium (g)',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2D3748),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          calController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Nama dan Kalori wajib diisi!'),
                          ),
                        );
                        return;
                      }

                      Map<String, dynamic> payload = {
                        "name": nameController.text,
                        "calories": double.tryParse(calController.text) ?? 0.0,
                        "carbs": double.tryParse(carbController.text) ?? 0.0,
                        "fat": double.tryParse(fatController.text) ?? 0.0,
                        "protein": double.tryParse(proController.text) ?? 0.0,
                        "sugar": double.tryParse(sugarController.text) ?? 0.0,
                        "natrium": double.tryParse(natController.text) ?? 0.0,
                      };

                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (c) =>
                            const Center(child: CircularProgressIndicator()),
                      );

                      bool success = false;
                      if (isEdit) {
                        success = await _foodService.updateFood(
                          existingFood['id'],
                          payload,
                        );
                      } else {
                        success = await _foodService.createFood(payload);
                      }

                      Navigator.pop(context); // Tutup Loading
                      Navigator.pop(context); // Tutup Modal Form

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isEdit
                                  ? 'Sukses update!'
                                  : 'Makanan baru berhasil ditambah!',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadFoods();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal menghubungi server.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'SIMPAN',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        title: const Text(
          'Panel Administrator',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2D3748),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Keluar',
            onPressed: _adminLogOut,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF90A58D),
        onPressed: () => _showFoodFormModal(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Makanan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // --- BAGIAN HEADER PENCARIAN & FILTER ---
          Container(
            color: const Color(0xFF2D3748),
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Column(
              children: [
                // 1. Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _applyFilters();
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari nama makanan...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 2. Alphabet Filter Ribbon
                SizedBox(
                  height: 36,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _alphabets.length,
                    itemBuilder: (context, index) {
                      final alphabet = _alphabets[index];
                      final isSelected = _selectedAlphabet == alphabet;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(
                            alphabet,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedColor: const Color(0xFF90A58D),
                          backgroundColor: Colors.white,
                          onSelected: (bool selected) {
                            setState(() => _selectedAlphabet = alphabet);
                            _applyFilters();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // --- BAGIAN LIST DATA ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2D3748)),
                  )
                : _filteredFoods.isEmpty
                ? const Center(
                    child: Text(
                      "Data tidak ditemukan.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFoods.length,
                    itemBuilder: (context, index) {
                      final food = _filteredFoods[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          title: Text(
                            food['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            'Kalori: ${_safeDouble(food['calories'])} | P: ${_safeDouble(food['protein'])}g | K: ${_safeDouble(food['carbs'])}g | L: ${_safeDouble(food['fat'])}g',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.blueAccent,
                                ),
                                onPressed: () =>
                                    _showFoodFormModal(existingFood: food),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  bool confirm = await showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: const Text("Hapus Permanen?"),
                                      content: Text(
                                        "Yakin ingin menghapus ${food['name']} dari database global?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(c, false),
                                          child: const Text("Batal"),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.redAccent,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(c, true),
                                          child: const Text(
                                            "Hapus",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (c) => const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                    bool success = await _foodService
                                        .deleteFood(food['id']);
                                    Navigator.pop(context);

                                    if (success) {
                                      _loadFoods();
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Gagal menghapus.'),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
