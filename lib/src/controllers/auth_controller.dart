import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cenah_news/src/models/auth_model.dart';

class AuthService {
  static const String _baseUrl = 'https://rest-api-berita.vercel.app/api/v1';

  Future<AuthModel> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  Future<AuthModel> register(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return AuthModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }
}
