import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/api_service.dart';
import '../services/local_farm_store.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._apiService);

  final ApiService _apiService;
  String? _accessToken;
  bool _isLoading = false;
  bool _isProfileLoading = false;
  Map<String, dynamic> _profile = const {};

  String? get accessToken => _accessToken;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;
  bool get isOfflineMode => LocalFarmStore.isOfflineToken(_accessToken);
  bool get isLoading => _isLoading;
  bool get isProfileLoading => _isProfileLoading;
  Map<String, dynamic> get profile => _profile;

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    if (kIsWeb && Uri.base.queryParameters['offline'] == '1') {
      _accessToken = LocalFarmStore.offlineToken;
      await prefs.setString('access_token', LocalFarmStore.offlineToken);
      notifyListeners();
      return;
    }
    if (kIsWeb && Uri.base.queryParameters['reset'] == '1') {
      _accessToken = null;
      await prefs.remove('access_token');
      notifyListeners();
      return;
    }
    _accessToken = prefs.getString('access_token');
    if (_accessToken != null && _accessToken!.isNotEmpty) {
      await loadProfile();
    }
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
      await loadProfile();
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
      await loadProfile();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> startOfflineMode() async {
    _accessToken = LocalFarmStore.offlineToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', LocalFarmStore.offlineToken);
    await loadProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    _accessToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    notifyListeners();
  }

  Future<void> loadProfile() async {
    final token = _accessToken;
    final prefs = await SharedPreferences.getInstance();
    _profile = _localProfile(prefs);
    if (token == null || token.isEmpty || isOfflineMode) {
      notifyListeners();
      return;
    }

    _isProfileLoading = true;
    notifyListeners();
    try {
      final remoteProfile = await _apiService.getProfile(token);
      _profile = {..._profile, ...remoteProfile};
      await _saveLocalProfile(prefs, _profile);
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String farmName,
    required String ownerName,
    required String phone,
    required String farmLocation,
    required String languagePreference,
    required String currency,
    required String milkUnit,
    required bool lowStockAlerts,
    required bool backupReminder,
  }) async {
    final token = _accessToken;
    _isProfileLoading = true;
    notifyListeners();
    try {
      var updated = <String, dynamic>{
        ..._profile,
        'farm_name': farmName,
        'owner_name': ownerName,
        'phone': phone,
        'farm_location': farmLocation,
        'language_preference': languagePreference,
        'currency': currency,
        'milk_unit': milkUnit,
        'low_stock_alerts': lowStockAlerts,
        'backup_reminder': backupReminder,
      };

      if (token != null && token.isNotEmpty && !isOfflineMode) {
        final remoteProfile = await _apiService.updateProfile(
          token: token,
          farmName: farmName,
          ownerName: ownerName,
          phone: phone,
          farmLocation: farmLocation,
          languagePreference: languagePreference,
        );
        updated = {...updated, ...remoteProfile};
      }

      final prefs = await SharedPreferences.getInstance();
      await _saveLocalProfile(prefs, updated);
      _profile = updated;
    } finally {
      _isProfileLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _localProfile(SharedPreferences prefs) {
    return {
      'farm_name': prefs.getString('profile_farm_name') ?? 'My Dairy Farm',
      'owner_name': prefs.getString('profile_owner_name') ?? '',
      'phone': prefs.getString('profile_phone') ?? '',
      'farm_location': prefs.getString('profile_farm_location') ?? '',
      'language_preference':
          prefs.getString('profile_language_preference') ?? 'en',
      'currency': prefs.getString('profile_currency') ?? 'BDT',
      'milk_unit': prefs.getString('profile_milk_unit') ?? 'L',
      'low_stock_alerts': prefs.getBool('profile_low_stock_alerts') ?? true,
      'backup_reminder': prefs.getBool('profile_backup_reminder') ?? true,
    };
  }

  Future<void> _saveLocalProfile(
    SharedPreferences prefs,
    Map<String, dynamic> profile,
  ) async {
    await prefs.setString('profile_farm_name', '${profile['farm_name'] ?? ''}');
    await prefs.setString(
      'profile_owner_name',
      '${profile['owner_name'] ?? ''}',
    );
    await prefs.setString('profile_phone', '${profile['phone'] ?? ''}');
    await prefs.setString(
      'profile_farm_location',
      '${profile['farm_location'] ?? ''}',
    );
    await prefs.setString(
      'profile_language_preference',
      '${profile['language_preference'] ?? 'en'}',
    );
    await prefs.setString(
      'profile_currency',
      '${profile['currency'] ?? 'BDT'}',
    );
    await prefs.setString(
      'profile_milk_unit',
      '${profile['milk_unit'] ?? 'L'}',
    );
    await prefs.setBool(
      'profile_low_stock_alerts',
      profile['low_stock_alerts'] == true,
    );
    await prefs.setBool(
      'profile_backup_reminder',
      profile['backup_reminder'] == true,
    );
  }
}
