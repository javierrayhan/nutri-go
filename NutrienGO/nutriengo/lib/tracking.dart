import 'package:flutter/material.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({Key? key}) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  // Dummy data for meal schedules
  final List<Map<String, dynamic>> mealSchedules = [
    {
      'title': 'Makan Pagi',
      'cals': 670,
      'fat': 11.57,
      'carbs': 12.00,
      'protein': 39.02,
    },
    {
      'title': 'Makan Siang',
      'cals': 0,
      'fat': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
    },
    {
      'title': 'Makan Malam',
      'cals': 0,
      'fat': 0.0,
      'carbs': 0.0,
      'protein': 0.0,
    },
    {'title': 'Cemilan', 'cals': 0, 'fat': 0.0, 'carbs': 0.0, 'protein': 0.0},
  ];

  // Dummy data for search items (now with stateful 'checked' properties)
  final List<Map<String, dynamic>> makananItems = [
    {
      'name': 'Nasi Putih',
      'desc': '1 mangkok (200g) AKG 10% - 204 kkal',
      'checked': false,
    },
    {
      'name': 'Ayam Goreng',
      'desc': '1 potong (100g) AKG 15% - 246 kkal',
      'checked': false,
    },
    {
      'name': 'Telur Ceplok',
      'desc': '1 butir (50g) AKG 5% - 92 kkal',
      'checked': false,
    },
  ];

  final List<Map<String, dynamic>> minumanItems = [
    {
      'name': 'Susu UHT Full Cream',
      'desc': '1 pak (250ml) AKG 5% - 150 kkal',
      'checked': false,
    },
    {
      'name': 'Es Teh Manis',
      'desc': '1 gelas (200ml) AKG 4% - 90 kkal',
      'checked': false,
    },
  ];

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
                const Padding(
                  padding: EdgeInsets.only(left: 24.0, top: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, User!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Sabtu, 6 Juli',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    itemCount: mealSchedules.length,
                    itemBuilder: (context, index) {
                      return _buildExpandableMealCard(mealSchedules[index]);
                    },
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

  // --- COMPONENT: EXPANDABLE MEAL CARD ---
  Widget _buildExpandableMealCard(Map<String, dynamic> meal) {
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
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
                    '${meal['cals']}',
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
                      _buildMacroInfo('LEMAK', '${meal['fat']}g'),
                      _buildMacroInfo('KARB', '${meal['carbs']}g'),
                      _buildMacroInfo('PROTEIN', '${meal['protein']}g'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => _showSearchModal(context, meal['title']),
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
    );
  }

  Widget _buildMacroInfo(String label, String value) {
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ],
    );
  }

  // --- COMPONENT: SEARCH MODAL ---
  void _showSearchModal(BuildContext context, String mealName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // StatefulBuilder is CRITICAL here to manage state specifically inside the modal
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
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        // Modal Header
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
                                    mealName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Text(
                                    'Sabtu, 6 Juli',
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

                        // Tab Bar
                        const TabBar(
                          labelColor: Color(0xFF90A58D),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Color(0xFF90A58D),
                          labelStyle: TextStyle(fontWeight: FontWeight.bold),
                          tabs: [
                            Tab(text: 'MAKANAN'),
                            Tab(text: 'MINUMAN'),
                          ],
                        ),

                        // Search Bar
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cari...',
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.grey,
                              ),
                              suffixIcon: const Icon(
                                Icons.cancel_rounded,
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

                        // Tab Views & Interactive Lists
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildInteractiveSearchList(
                                makananItems,
                                controller,
                                setModalState,
                              ),
                              _buildInteractiveSearchList(
                                minumanItems,
                                controller,
                                setModalState,
                              ),
                            ],
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
      },
    );
  }

  // Changed to handle dynamic state updates
  Widget _buildInteractiveSearchList(
    List<Map<String, dynamic>> items,
    ScrollController controller,
    StateSetter setModalState,
  ) {
    return ListView.separated(
      controller: controller,
      itemCount: items.length,
      separatorBuilder: (context, index) =>
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
      itemBuilder: (context, index) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 8,
          ),
          title: Text(
            items[index]['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Text(
            items[index]['desc'],
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          trailing: Checkbox(
            value: items[index]['checked'],
            onChanged: (bool? newValue) {
              // We trigger setModalState to strictly rebuild the bottom sheet UI
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
            // Optional: Makes the whole list tile clickable to toggle the checkbox
            setModalState(() {
              items[index]['checked'] = !(items[index]['checked'] as bool);
            });
          },
        );
      },
    );
  }

  // --- BOTTOM NAV ---
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
          _buildNavItem(Icons.note_alt_rounded, 'Tracking', true, '/Tracking'),
          _buildNavItem(Icons.bar_chart_rounded, 'Laporan', false, '/laporan'),
          _buildNavItem(Icons.person_rounded, 'Profile', false, '/profile'),
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

// --- CUSTOM CLIPPER ---
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
