import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get user => _user;
  String? get userRole => _user?['role'];

  Future<void> checkAuthStatus() async {
    final isAuthenticated = await _authRepository.isAuthenticated();
    if (isAuthenticated) {
      try {
        final profileData = await _authRepository.getProfile();
        _user = profileData;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userKey, json.encode(_user));
      } catch (e) {
        // Token is stale or user deleted - force logout to clear bad state
        await _authRepository.logout();
        _user = null;
      }
    } else {
      _user = null;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authRepository.login(email, password);
      _user = response['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String role,
    required String city,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.register(
        name: name,
        email: email,
        password: password,
        role: role,
        city: city,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _user = null;
    notifyListeners();
  }
}
