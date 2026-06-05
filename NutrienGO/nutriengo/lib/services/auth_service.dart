import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Ganti dengan URL Vercel Damar
  final String baseUrl = 'https://api-nutrigo.vercel.app/api/auth';

  // FUNGSI 1: REGISTER
  // FUNGSI 1: REGISTER
  Future<bool> register(String fullName, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        // Tambahkan fullName sesuai permintaan Swagger Damar yang baru
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['data'] != null && data['data']['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['data']['token']);
          return true;
        }
        return false;
      } else {
        print('Gagal Register: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Register: $e');
      return false;
    }
  }

  // --- FUNGSI LOGIN DI auth_service.dart ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['data'] != null &&
            jsonResponse['data']['token'] != null) {
          String token = jsonResponse['data']['token'];

          // PENTING: Tangkap juga ROLE dari user yang sedang login
          String role =
              jsonResponse['data']['user']['role'] ??
              'USER'; // Default ke USER jika null

          // Simpan token DAN role ke brankas HP
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);
          await prefs.setString('user_role', role); // <-- Ini kuncinya!

          print('Login Berhasil, Token & Role ($role) disimpan!');
          return true;
        }

        print('Token tidak ditemukan di JSON response');
        return false;
      } else {
        print('Gagal Login: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Exception Login: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserMe() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      final response = await http.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['data'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
