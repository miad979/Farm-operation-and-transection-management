# Dairy Farm Management System - Flutter Implementation Guide

## Project Setup

### 1. Create Flutter Project
```bash
flutter create dairy_farm_app
cd dairy_farm_app
```

### 2. Update pubspec.yaml
```yaml
name: dairy_farm_app
description: Dairy farm management application for family farms

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # State Management
  provider: ^6.0.0
  
  # API & Networking
  http: ^1.1.0
  dio: ^5.0.0
  
  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # JSON Serialization
  json_serializable: ^6.5.0
  build_runner: ^2.3.0
  
  # UI Components
  intl: ^0.18.0
  cached_network_image: ^3.2.0
  
  # Date & Time
  table_calendar: ^3.0.0
  
  # File Export
  pdf: ^3.10.0
  excel: ^2.0.0
  path_provider: ^2.0.0
  
  # Camera & Image Picker
  image_picker: ^0.8.7
  
  # Local Notifications
  flutter_local_notifications: ^14.0.0
  
  # Share
  share_plus: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0

flutter:
  uses-material-design: true
```

### 3. Generate Build Files
```bash
flutter pub get
flutter packages pub run build_runner build
```

---

## Project Structure

```
lib/
├── main.dart
├── config/
│   ├── constants.dart
│   ├── app_colors.dart
│   ├── api_config.dart
│   └── strings.dart
├── data/
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── animal_model.dart
│   │   ├── milk_production_model.dart
│   │   ├── sale_model.dart
│   │   ├── expense_model.dart
│   │   └── loan_model.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── local_storage_service.dart
│   │   └── sync_service.dart
│   └── repositories/
│       ├── animal_repository.dart
│       ├── milk_repository.dart
│       └── financial_repository.dart
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── animal_provider.dart
│   │   ├── milk_provider.dart
│   │   └── dashboard_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart
│   │   ├── cattle/
│   │   │   ├── cattle_list_screen.dart
│   │   │   ├── cattle_detail_screen.dart
│   │   │   └── add_cattle_screen.dart
│   │   ├── milk/
│   │   │   ├── milk_production_screen.dart
│   │   │   └── add_milk_screen.dart
│   │   ├── sales/
│   │   │   ├── sales_screen.dart
│   │   │   └── add_sale_screen.dart
│   │   ├── expenses/
│   │   │   ├── expenses_screen.dart
│   │   │   └── add_expense_screen.dart
│   │   ├── reports/
│   │   │   └── reports_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   └── widgets/
│       ├── metric_card.dart
│       ├── app_button.dart
│       ├── app_text_field.dart
│       └── loading_indicator.dart
└── utils/
    ├── formatters.dart
    ├── validators.dart
    └── extensions.dart
```

---

## Configuration Files

### constants.dart
```dart
class AppConstants {
  // API
  static const String baseUrl = 'http://192.168.1.100:8000/api/v1';
  static const Duration apiTimeout = Duration(seconds: 30);
  
  // Storage
  static const String hiveBoxUsers = 'users';
  static const String hiveBoxAnimals = 'animals';
  static const String hiveBoxMilk = 'milk_production';
  static const String tokenKey = 'auth_token';
  
  // App
  static const String appName = 'Dairy Farm Management';
  static const String appVersion = '1.0.0';
  
  // Pagination
  static const int pageSize = 20;
}

class AnimalTypes {
  static const String cow = 'Cow';
  static const String ox = 'Ox';
  static const String buffalo = 'Buffalo';
  static const String calf = 'Calf';
  static const String heifer = 'Heifer';
  static const String bull = 'Bull';
}

class ExpenseCategories {
  static const String feed = 'feed';
  static const String medicine = 'medicine';
  static const String veterinary = 'veterinary';
  static const String salary = 'salary';
  static const String transport = 'transport';
  static const String electricity = 'electricity';
  static const String maintenance = 'maintenance';
  static const String miscellaneous = 'miscellaneous';
}

class WithdrawalReasons {
  static const String household = 'household';
  static const String medical = 'medical';
  static const String education = 'education';
  static const String personal = 'personal';
  static const String other = 'other';
}
```

### app_colors.dart
```dart
import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF185FA5);
  static const Color primaryLight = Color(0xFFB5D4F4);
  static const Color primaryDark = Color(0xFF0C447C);
  
  // Status Colors
  static const Color success = Color(0xFF3B6D11);
  static const Color warning = Color(0xFFBA7517);
  static const Color danger = Color(0xFFA32D2D);
  static const Color info = Color(0xFF378ADD);
  
  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey = Color(0xFF888780);
  static const Color greyLight = Color(0xFFD3D1C7);
  static const Color greyDark = Color(0xFF444441);
  
  // Backgrounds
  static const Color bgPrimary = Color(0xFFFFFFFF);
  static const Color bgSecondary = Color(0xFFF5F5F5);
  static const Color bgTertiary = Color(0xFFF1EFE8);
}
```

### api_config.dart
```dart
class ApiConfig {
  static const String baseUrl = 'http://YOUR_API_URL/api/v1';
  
  // Authentication
  static const String login = '/auth/login/';
  static const String register = '/auth/register/';
  static const String refresh = '/auth/refresh/';
  
  // Dashboard
  static const String dashboardToday = '/dashboard/today/';
  static const String dashboardMonthly = '/dashboard/monthly/';
  static const String dashboardInsights = '/dashboard/insights/';
  
  // Animals
  static const String animals = '/animals/';
  static const String animalDetail = '/animals/{id}/';
  static const String animalVaccine = '/animals/{id}/vaccinate/';
  static const String animalPregnancy = '/animals/{id}/pregnancy/';
  
  // Milk
  static const String milkProduction = '/milk-production/';
  static const String milkDaily = '/milk-production/daily-report/';
  static const String milkMonthly = '/milk-production/monthly-report/';
  
  // Sales
  static const String sales = '/sales/';
  static const String salesReport = '/sales/report/';
  
  // Expenses
  static const String expenses = '/expenses/';
  static const String expensesReport = '/expenses/report/';
  
  // Withdrawals
  static const String withdrawals = '/withdrawals/';
  
  // Reports
  static const String reportExportPdf = '/reports/export/pdf/';
  static const String reportExportExcel = '/reports/export/excel/';
}
```

---

## Data Models

### user_model.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final int id;
  final String username;
  final String email;
  @JsonKey(name: 'farm_name')
  final String farmName;
  @JsonKey(name: 'farm_location')
  final String farmLocation;
  @JsonKey(name: 'owner_name')
  final String ownerName;
  final String? phone;
  @JsonKey(name: 'language_preference')
  final String languagePreference;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.farmName,
    required this.farmLocation,
    required this.ownerName,
    this.phone,
    this.languagePreference = 'bn',
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String access;
  final String refresh;
  final User user;

  AuthResponse({
    required this.access,
    required this.refresh,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
```

### animal_model.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'animal_model.g.dart';

@JsonSerializable()
class Animal {
  final int id;
  @JsonKey(name: 'animal_id_number')
  final String animalIdNumber;
  final String name;
  final String type; // Cow, Ox, Calf, etc.
  final String breed;
  final String gender;
  @JsonKey(name: 'purchase_date')
  final DateTime purchaseDate;
  @JsonKey(name: 'purchase_price')
  final double purchasePrice;
  @JsonKey(name: 'current_value')
  final double currentValue;
  @JsonKey(name: 'health_status')
  final String healthStatus; // Healthy, Sick, Treatment, Pregnant
  final bool vaccinated;
  @JsonKey(name: 'vaccination_date')
  final DateTime? vaccinationDate;
  @JsonKey(name: 'last_vaccination_type')
  final String? lastVaccinationType;
  @JsonKey(name: 'pregnancy_status')
  final String pregnancyStatus;
  @JsonKey(name: 'expected_delivery_date')
  final DateTime? expectedDeliveryDate;
  final String? notes;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  Animal({
    required this.id,
    required this.animalIdNumber,
    required this.name,
    required this.type,
    required this.breed,
    required this.gender,
    required this.purchaseDate,
    required this.purchasePrice,
    required this.currentValue,
    required this.healthStatus,
    required this.vaccinated,
    this.vaccinationDate,
    this.lastVaccinationType,
    required this.pregnancyStatus,
    this.expectedDeliveryDate,
    this.notes,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Animal.fromJson(Map<String, dynamic> json) => _$AnimalFromJson(json);
  Map<String, dynamic> toJson() => _$AnimalToJson(this);
}
```

### milk_production_model.dart
```dart
import 'package:json_annotation/json_annotation.dart';

part 'milk_production_model.g.dart';

@JsonSerializable()
class MilkProduction {
  final int id;
  @JsonKey(name: 'animal_id')
  final int animalId;
  @JsonKey(name: 'animal_name')
  final String? animalName;
  @JsonKey(name: 'production_date')
  final DateTime productionDate;
  @JsonKey(name: 'morning_milk')
  final double morningMilk;
  @JsonKey(name: 'evening_milk')
  final double eveningMilk;
  @JsonKey(name: 'total_milk')
  final double totalMilk;
  @JsonKey(name: 'quality_grade')
  final String? qualityGrade;
  final String? notes;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  MilkProduction({
    required this.id,
    required this.animalId,
    this.animalName,
    required this.productionDate,
    required this.morningMilk,
    required this.eveningMilk,
    required this.totalMilk,
    this.qualityGrade,
    this.notes,
    required this.createdAt,
  });

  factory MilkProduction.fromJson(Map<String, dynamic> json) =>
      _$MilkProductionFromJson(json);
  Map<String, dynamic> toJson() => _$MilkProductionToJson(this);
}
```

---

## API Service

### api_service.dart
```dart
import 'package:dio/dio.dart';
import 'package:dairy_farm_app/config/api_config.dart';
import 'package:dairy_farm_app/config/constants.dart';
import 'local_storage_service.dart';

class ApiService {
  late Dio _dio;
  final LocalStorageService _storageService = LocalStorageService();

  ApiService() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: AppConstants.apiTimeout,
        receiveTimeout: AppConstants.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptor for authentication
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Handle token refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Authentication
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String farmName,
    required String ownerName,
    String? phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'farm_name': farmName,
          'owner_name': ownerName,
          'phone': phone,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard
  Future<Map<String, dynamic>> getDashboardToday() async {
    try {
      final response = await _dio.get(ApiConfig.dashboardToday);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getDashboardMonthly({
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.dashboardMonthly,
        queryParameters: {
          'year': year,
          'month': month,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<dynamic>> getDashboardInsights() async {
    try {
      final response = await _dio.get(ApiConfig.dashboardInsights);
      return response.data['insights'] ?? [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Animals
  Future<Map<String, dynamic>> getAnimals({
    int page = 1,
    String? type,
    String? healthStatus,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.animals,
        queryParameters: {
          'page': page,
          'limit': AppConstants.pageSize,
          if (type != null) 'type': type,
          if (healthStatus != null) 'health_status': healthStatus,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addAnimal({
    required String name,
    required String type,
    required String breed,
    required String gender,
    required DateTime purchaseDate,
    required double purchasePrice,
    required double currentValue,
    String? animalIdNumber,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.animals,
        data: {
          'animal_id_number': animalIdNumber,
          'name': name,
          'type': type,
          'breed': breed,
          'gender': gender,
          'purchase_date': purchaseDate.toString().split(' ')[0],
          'purchase_price': purchasePrice,
          'current_value': currentValue,
          'notes': notes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateAnimal(
    int animalId, {
    String? healthStatus,
    String? notes,
  }) async {
    try {
      final response = await _dio.put(
        ApiConfig.animalDetail.replaceFirst('{id}', animalId.toString()),
        data: {
          if (healthStatus != null) 'health_status': healthStatus,
          if (notes != null) 'notes': notes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Milk Production
  Future<Map<String, dynamic>> recordMilk({
    required int animalId,
    required DateTime productionDate,
    required double morningMilk,
    required double eveningMilk,
    String? qualityGrade,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.milkProduction,
        data: {
          'animal_id': animalId,
          'production_date': productionDate.toString().split(' ')[0],
          'morning_milk': morningMilk,
          'evening_milk': eveningMilk,
          'quality_grade': qualityGrade,
          'notes': notes,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getMilkProduction({
    int page = 1,
    int? animalId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.milkProduction,
        queryParameters: {
          'page': page,
          'limit': AppConstants.pageSize,
          if (animalId != null) 'animal_id': animalId,
          if (startDate != null) 'start_date': startDate.toString().split(' ')[0],
          if (endDate != null) 'end_date': endDate.toString().split(' ')[0],
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handling
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server timeout. Please try again.';
      case DioExceptionType.badResponse:
        if (error.response?.data is Map) {
          final data = error.response?.data as Map;
          if (data.containsKey('detail')) {
            return data['detail'].toString();
          }
          return data.values.first.toString();
        }
        return 'An error occurred: ${error.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Request cancelled.';
      default:
        return 'An unexpected error occurred.';
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConfig.refresh,
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      await _storageService.saveToken(newAccessToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
```

### local_storage_service.dart
```dart
import 'package:hive_flutter/hive_flutter.dart';
import 'package:dairy_farm_app/config/constants.dart';

class LocalStorageService {
  late Box<String> _tokenBox;
  late Box<dynamic> _dataBox;

  Future<void> init() async {
    await Hive.initFlutter();
    _tokenBox = await Hive.openBox<String>('tokens');
    _dataBox = await Hive.openBox('app_data');
  }

  // Token Management
  Future<void> saveToken(String token) async {
    await _tokenBox.put(AppConstants.tokenKey, token);
  }

  Future<String?> getToken() async {
    return _tokenBox.get(AppConstants.tokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _tokenBox.put('refresh_token', token);
  }

  Future<String?> getRefreshToken() async {
    return _tokenBox.get('refresh_token');
  }

  Future<void> clearTokens() async {
    await _tokenBox.clear();
  }

  // Data Caching
  Future<void> saveData(String key, dynamic value) async {
    await _dataBox.put(key, value);
  }

  dynamic getData(String key) {
    return _dataBox.get(key);
  }

  Future<void> clearData(String key) async {
    await _dataBox.delete(key);
  }

  Future<void> clearAllData() async {
    await _dataBox.clear();
  }
}
```

---

## State Management (Provider)

### auth_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:dairy_farm_app/data/models/user_model.dart';
import 'package:dairy_farm_app/data/services/api_service.dart';
import 'package:dairy_farm_app/data/services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  // Register
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String farmName,
    required String ownerName,
    String? phone,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.register(
        username: username,
        email: email,
        password: password,
        farmName: farmName,
        ownerName: ownerName,
        phone: phone,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.login(username, password);
      
      final authResponse = AuthResponse.fromJson(response);
      
      await _storageService.saveToken(authResponse.access);
      await _storageService.saveRefreshToken(authResponse.refresh);

      _user = authResponse.user;
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _storageService.clearTokens();
      _user = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Check Authentication
  Future<bool> checkAuthentication() async {
    try {
      final token = await _storageService.getToken();
      _isAuthenticated = token != null;
      notifyListeners();
      return _isAuthenticated;
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

### dashboard_provider.dart
```dart
import 'package:flutter/material.dart';
import 'package:dairy_farm_app/data/services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  Map<String, dynamic>? _todayData;
  Map<String, dynamic>? _monthlyData;
  List<dynamic> _insights = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  Map<String, dynamic>? get todayData => _todayData;
  Map<String, dynamic>? get monthlyData => _monthlyData;
  List<dynamic> get insights => _insights;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get Today's Data
  Future<void> fetchTodayData() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _todayData = await _apiService.getDashboardToday();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get Monthly Data
  Future<void> fetchMonthlyData(int year, int month) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _monthlyData = await _apiService.getDashboardMonthly(
        year: year,
        month: month,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get Insights
  Future<void> fetchInsights() async {
    try {
      _insights = await _apiService.getDashboardInsights();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

---

## Widgets

### metric_card.dart
```dart
import 'package:flutter/material.dart';
import 'package:dairy_farm_app/config/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const MetricCard({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    this.backgroundColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withOpacity(0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: AppColors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### app_button.dart
```dart
import 'package:flutter/material.dart';
import 'package:dairy_farm_app/config/app_colors.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final double? width;
  final double? height;

  const AppButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          disabledBackgroundColor: AppColors.greyLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
```

### app_text_field.dart
```dart
import 'package:flutter/material.dart';
import 'package:dairy_farm_app/config/app_colors.dart';

class AppTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;

  const AppTextField({
    Key? key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.maxLines = 1,
    this.minLines,
  }) : super(key: key);

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: AppColors.greyLight),
            filled: true,
            fillColor: AppColors.bgSecondary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.greyLight,
                width: 0.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.greyLight,
                width: 0.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1,
              ),
            ),
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    child: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: AppColors.grey,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
```

---

## Main Entry Point

### main.dart
```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dairy_farm_app/config/app_colors.dart';
import 'package:dairy_farm_app/data/services/local_storage_service.dart';
import 'package:dairy_farm_app/presentation/providers/auth_provider.dart';
import 'package:dairy_farm_app/presentation/providers/dashboard_provider.dart';
import 'package:dairy_farm_app/presentation/screens/auth/login_screen.dart';
import 'package:dairy_farm_app/presentation/screens/dashboard/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageService = LocalStorageService();
  await storageService.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
      child: MaterialApp(
        title: 'Dairy Farm Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.primary,
          useMaterial3: true,
          fontFamily: 'Roboto',
          textTheme: const TextTheme(
            displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            displayMedium: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
            headlineMedium: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
            titleLarge: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
            bodyLarge: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.grey,
            ),
          ),
        ),
        home: const _Home(),
      ),
    );
  }
}

class _Home extends StatefulWidget {
  const _Home({Key? key}) : super(key: key);

  @override
  State<_Home> createState() => __HomeState();
}

class __HomeState extends State<_Home> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isAuthenticated = await authProvider.checkAuthentication();
    
    if (!mounted) return;
    
    if (!isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          return const DashboardScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
```

---

## Testing

### unit_test_example.dart
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:dairy_farm_app/data/models/animal_model.dart';

void main() {
  group('Animal Model', () {
    test('Animal creation works correctly', () {
      final animal = Animal(
        id: 1,
        animalIdNumber: 'LF001',
        name: 'Lakshmi',
        type: 'Cow',
        breed: 'Holstein',
        gender: 'Female',
        purchaseDate: DateTime(2022, 5, 15),
        purchasePrice: 45000,
        currentValue: 48000,
        healthStatus: 'Healthy',
        vaccinated: true,
        pregnancyStatus: 'Not Pregnant',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(animal.name, 'Lakshmi');
      expect(animal.type, 'Cow');
      expect(animal.healthStatus, 'Healthy');
    });

    test('Animal JSON serialization works', () {
      final json = {
        'id': 1,
        'animal_id_number': 'LF001',
        'name': 'Lakshmi',
        'type': 'Cow',
        'breed': 'Holstein',
        'gender': 'Female',
        'purchase_date': '2022-05-15',
        'purchase_price': 45000,
        'current_value': 48000,
        'health_status': 'Healthy',
        'vaccinated': true,
        'pregnancy_status': 'Not Pregnant',
        'is_active': true,
        'created_at': '2022-05-15T10:30:00Z',
        'updated_at': '2022-05-15T10:30:00Z',
      };

      final animal = Animal.fromJson(json);
      expect(animal.name, 'Lakshmi');
    });
  });
}
```

---

## Build and Deployment

### Android Build
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle for Play Store
flutter build appbundle --release
```

### iOS Build
```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release
```

### Signing Android APK
```bash
# Generate keystore
keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key

# Update build.gradle with keystore info
android {
  signingConfigs {
    release {
      keyAlias 'key'
      keyPassword 'your_key_password'
      storeFile file('/path/to/key.jks')
      storePassword 'your_keystore_password'
    }
  }
}
```

---

## Performance Optimization Tips

1. **Image Caching**: Use `CachedNetworkImage` for animal photos
2. **Lazy Loading**: Paginate lists instead of loading all at once
3. **State Management**: Only rebuild widgets that need updates
4. **Database**: Use indexes on frequently queried columns
5. **API**: Implement request debouncing for search
6. **Memory**: Dispose controllers and listeners properly

---

## Localization

### Create localization files
```dart
class AppStrings {
  static const String appName = 'Dairy Farm Management';
  static const String login = 'লগইন';
  static const String email = 'ইমেইল';
  static const String password = 'পাসওয়ার্ড';
  static const String register = 'নিবন্ধন করুন';
  static const String farmName = 'খামারের নাম';
  static const String addCattle = 'গাভী যোগ করুন';
  static const String recordMilk = 'দুধ রেকর্ড করুন';
  static const String dashboard = 'ড্যাশবোর্ড';
}
```

This comprehensive guide provides everything needed to build and deploy the dairy farm management application using Flutter and Django.
