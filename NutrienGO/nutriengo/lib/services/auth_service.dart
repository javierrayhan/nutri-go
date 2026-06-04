import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Ganti dengan URL Vercel Damar
  final String baseUrl = 'https://api-nutrigo.vercel.app/api/auth';

  // FUNGSI 1: REGISTER
  Future<bool> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Status 201 artinya Created (Berhasil sesuai docs Swagger Damar)
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Gagal Register: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Register: $e');
      return false;
    }
  }

  // FUNGSI 2: LOGIN
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Status 200 artinya Sukses
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Asumsi API Damar membalas dengan field 'token'
        // Kita simpan token ini ke brankas HP (Shared Preferences)
        if (data['token'] != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', data['token']);
          return true;
        }
        return false;
      } else {
        print('Gagal Login: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error Login: $e');
      return false;
    }
  }
}
