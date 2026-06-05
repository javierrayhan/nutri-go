import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DailyLogService {
  final String baseUrl = 'https://api-nutrigo.vercel.app/api/dailylogs';

  // Fungsi untuk mengirim 1 log makanan ke server Damar
  Future<bool> createDailyLog(Map<String, dynamic> logData) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(logData),
      );

      if (response.statusCode == 201) {
        print('Sukses mencatat makanan: ${response.body}');
        return true;
      } else {
        print(
          'Gagal mencatat makanan: HTTP ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error exception saat mencatat makanan: $e');
      return false;
    }
  }

  Future<List<dynamic>> getDailyLogs(String date) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      // Tembak API GET /api/dailylogs/{date} sesuai Swagger Damar
      final response = await http.get(
        Uri.parse('$baseUrl/$date'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'] ?? [];
      } else {
        print('Gagal tarik log harian: HTTP ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error exception tarik log: $e');
      return [];
    }
  }

  Future<bool> deleteDailyLog(int id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      // Tembak API DELETE sesuai Swagger Damar
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print(
          'Gagal hapus log: HTTP ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error exception saat hapus log: $e');
      return false;
    }
  }
}
