import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';
import '../network/api_service.dart';
import 'dart:convert';

class AuthRepository {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiService.post(AppConstants.loginEndpoint, {
      'email': email,
      'password': password,
    });
    await _saveAuthData(response);
    return response;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String city,
  }) async {
    final response = await _apiService.post(AppConstants.registerEndpoint, {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
      'city': city,
    });
    // Note: The backend register route might not return a token.
    // Assuming the user needs to login after registering.
    return response;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
    await prefs.remove(AppConstants.roleKey);
  }

  Future<void> _saveAuthData(Map<String, dynamic> response) async {
    if (response.containsKey('token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.tokenKey, response['token']);

      if (response.containsKey('user')) {
        await prefs.setString(
          AppConstants.userKey,
          json.encode(response['user']),
        );
        await prefs.setString(AppConstants.roleKey, response['user']['role']);
      }
    }
  }

  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(AppConstants.tokenKey);
  }

  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.roleKey);
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiService.get(AppConstants.profileEndpoint);
    return response as Map<String, dynamic>;
  }
}
