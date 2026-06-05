import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FoodService {
  final String baseUrl = 'https://api-nutrigo.vercel.app/api/foods';

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
}
