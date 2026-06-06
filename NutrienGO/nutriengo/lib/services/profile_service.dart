import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  final String baseUrl = 'https://api-nutrigo.vercel.app/api/profile';

  Future<bool> createProfile({
    required int age,
    required double height,
    required double weight,
    required double weightGoal,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    try {
      // Ambil Token JWT dari brankas HP
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Pamerkan Gelang VIP ke Damar
        },
        body: jsonEncode({
          'age': age,
          'height': height,
          'weight': weight,
          'weightGoal': weightGoal,
          'gender': gender,
          'activityLevel': activityLevel,
          'goal': goal,
        }),
      );

      // Status 201 Created
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Gagal Simpan Profil: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Profile: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        // Mengambil isi dari dalam "data" sesuai struktur Swagger Damar
        return jsonResponse['data'];
      } else {
        print('Gagal Get Profil: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error Get Profil: $e');
      return null;
    }
  }

  // --- FUNGSI BARU: UPDATE PROFIL (PUT) ---
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.put(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Gagal Update Profil: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Update Profil: $e');
      return false;
    }
  }
}
