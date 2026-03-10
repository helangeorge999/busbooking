import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../../core/api_config.dart';

class AuthRemoteDataSource {
  static String get baseUrl => ApiConfig.authUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_getErrorMessage(response));
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(_getErrorMessage(response));
    }
  }

  String _getErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      return decoded['message'] ?? "Authentication failed";
    } catch (_) {
      return "Server error (${response.statusCode})";
    }
  }
}
