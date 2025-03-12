import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import '../models/user_response.dart';

class AuthService {
  final String apiUrl = dotenv.env['API_URL'] ?? 'http://10.0.2.2:5146/api/v1';

  // Login and store token
  Future<bool> login(String email, String password) async {
    final fullUrl = '$apiUrl/auth/login';

    try {
      final response = await http.post(
        Uri.parse(fullUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        if (loginResponse != null) {
          await _saveToken(loginResponse);
          return true; // Login successful
        }
      }
    } catch (e) {
      throw Exception("Failed to connect to server: $e");
    }
    return false; // Login failed
  }

  // Store token in local storage
  Future<void> _saveToken(LoginResponse token) async {
    final box = GetStorage();
    box.write('jwt_token', token.token);
    box.write('user_id', token.userId.toString());
    final i = box.read<String>('user_id');
    print('$i');
  }

  // Get stored token
  Future<String?> getToken() async {
    final box = GetStorage();
    String? token = box.read<String>('jwt_token');
  }

  // Logout: Remove token
  Future<void> logout() async {
    final box = GetStorage();
    box.remove('jwt_token');
  }
}
