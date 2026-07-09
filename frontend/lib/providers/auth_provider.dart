import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._apiService);

  final ApiService _apiService;
  String? _accessToken;
  bool _isLoading = false;

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isLoading => _isLoading;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    notifyListeners();
  }

  Future<void> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.login(
        username: username,
        password: password,
      );
      _accessToken = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String farmName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.register(
        username: username,
        email: email,
        password: password,
        farmName: farmName,
      );
      final token = await _apiService.login(
        username: username,
        password: password,
      );
      _accessToken = token;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }
}
