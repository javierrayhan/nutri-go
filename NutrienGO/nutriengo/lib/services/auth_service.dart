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

  // FUNGSI 2: LOGIN
  // --- FUNGSI LOGIN DI auth_service.dart ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$baseUrl/login',
        ), // Pastikan baseUrl ini mengarah ke /api/auth
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Status 200 OK dari Damar
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // PENTING: Tangkap Token JWT dari dalam map 'data'
        if (jsonResponse['data'] != null &&
            jsonResponse['data']['token'] != null) {
          String token = jsonResponse['data']['token'];

          // Simpan token ke brankas HP
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', token);

          print('Login Berhasil, Token disimpan!');
          return true; // <-- Ini yang akan membuat UI memunculkan warna hijau dan pindah halaman
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
}
