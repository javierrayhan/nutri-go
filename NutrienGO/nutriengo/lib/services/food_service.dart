import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodService {
  final String baseUrl = 'https://api-nutrigo.vercel.app/api/foods';

  // 1. READ (Membaca semua makanan)
  Future<List<dynamic>> getFoods() async {
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
        return jsonResponse['data'] ?? [];
      } else {
        print('Gagal Get Foods: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error Get Foods: $e');
      return [];
    }
  }

  // 2. CREATE (Menambah Makanan Baru)
  Future<bool> createFood(Map<String, dynamic> foodData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(foodData),
      );

      return response.statusCode == 201; // Sesuai Swagger Damar (201 Created)
    } catch (e) {
      print('Error Create Food: $e');
      return false;
    }
  }

  // 3. UPDATE (Mengedit Makanan)
  Future<bool> updateFood(int id, Map<String, dynamic> foodData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(foodData),
      );

      return response.statusCode == 200; // Sesuai Swagger Damar
    } catch (e) {
      print('Error Update Food: $e');
      return false;
    }
  }

  // 4. DELETE (Menghapus Makanan)
  Future<bool> deleteFood(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return response.statusCode == 200; // Sesuai Swagger Damar
    } catch (e) {
      print('Error Delete Food: $e');
      return false;
    }
  }
}
