import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('${AppConstants.baseUrl}$endpoint'),
        headers: headers,
        body: json.encode(body),
      );
      return _processResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.body.isEmpty) return null;
    final dynamic decoded = json.decode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded; // Can be List or Map
    } else {
      if (decoded is Map<String, dynamic>) {
        throw Exception(
          decoded['message'] ?? decoded['error'] ?? 'Unknown error occurred',
        );
      }
      throw Exception('Server error: ${response.statusCode}');
    }
  }
}
