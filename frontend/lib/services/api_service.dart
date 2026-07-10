import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/animal_model.dart';

class ApiService {
  Map<String, String> _jsonHeaders([String? token]) {
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    if (response.body.isEmpty) return <String, dynamic>{};
    return jsonDecode(response.body);
  }

  void _ensureSuccess(http.Response response, String message) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('$message: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> _getMap(String token, String path) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _jsonHeaders(token),
    );
    _ensureSuccess(response, 'Request failed');
    return _decode(response) as Map<String, dynamic>;
  }

  Future<List<dynamic>> _getList(String token, String path) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _jsonHeaders(token),
    );
    _ensureSuccess(response, 'Request failed');
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) {
      return (decoded['results'] ?? <dynamic>[]) as List<dynamic>;
    }
    return decoded as List<dynamic>;
  }

  Future<Map<String, dynamic>> _postMap(
    String token,
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    _ensureSuccess(response, 'Save failed');
    return _decode(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _patchMap(
    String token,
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    _ensureSuccess(response, 'Update failed');
    return _decode(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _deleteReason(
    String token,
    String path,
    String reason,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'reason': reason}),
    );
    _ensureSuccess(response, 'Delete failed');
    return _decode(response) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String farmName,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/register/'),
      headers: _jsonHeaders(),
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
        'farm_name': farmName,
      }),
    );

    _ensureSuccess(response, 'Registration failed');
    return _decode(response) as Map<String, dynamic>;
  }

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/auth/login/'),
      headers: _jsonHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );

    _ensureSuccess(response, 'Login failed');
    final data = _decode(response) as Map<String, dynamic>;
    return data['access'] as String;
  }

  Future<Map<String, dynamic>> getProfile(String token) {
    return _getMap(token, '/auth/profile/');
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    required String farmName,
    required String ownerName,
    required String phone,
    required String farmLocation,
    required String languagePreference,
  }) {
    return _patchMap(token, '/auth/profile/', {
      'farm_name': farmName,
      'owner_name': ownerName,
      'phone': phone,
      'farm_location': farmLocation,
      'language_preference': languagePreference,
    });
  }

  Future<List<AnimalModel>> getAnimals(String token) async {
    final results = await _getList(token, '/animals/');
    return results
        .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> createAnimal({
    required String token,
    required String animalIdNumber,
    required String name,
    required String type,
    String? breed,
    String? gender,
    String? healthStatus,
    double defaultDailyMilk = 0,
    String? notes,
  }) async {
    await _postMap(token, '/animals/', {
      'animal_id_number': animalIdNumber,
      'name': name,
      'type': type,
      if (breed != null && breed.isNotEmpty) 'breed': breed,
      if (gender != null && gender.isNotEmpty) 'gender': gender,
      if (healthStatus != null && healthStatus.isNotEmpty)
        'health_status': healthStatus,
      'default_daily_milk': defaultDailyMilk.toStringAsFixed(2),
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });
  }

  Future<void> updateAnimal({
    required String token,
    required int animalId,
    required String animalIdNumber,
    required String name,
    required String type,
    required String breed,
    required String gender,
    required String healthStatus,
    required double defaultDailyMilk,
    required bool vaccinated,
    required String pregnancyStatus,
    required String notes,
  }) async {
    await _patchMap(token, '/animals/$animalId/', {
      'animal_id_number': animalIdNumber,
      'name': name,
      'type': type,
      'breed': breed,
      'gender': gender,
      'health_status': healthStatus,
      'default_daily_milk': defaultDailyMilk.toStringAsFixed(2),
      'vaccinated': vaccinated,
      'pregnancy_status': pregnancyStatus,
      'notes': notes,
    });
  }

  Future<Map<String, dynamic>> getTodayDashboard(String token) async {
    return _getMap(token, '/dashboard/today/');
  }

  Future<Map<String, dynamic>> getMonthlyDashboard(String token) {
    return _getMap(token, '/dashboard/monthly/');
  }

  Future<Map<String, dynamic>> getCashFlow(String token) {
    return _getMap(token, '/dashboard/cash-flow/');
  }

  Future<List<dynamic>> getInsights(String token) async {
    final data = await _getMap(token, '/dashboard/insights/');
    return (data['insights'] ?? <dynamic>[]) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getMonthlyReport(String token) {
    return _getMap(token, '/reports/monthly/');
  }

  Future<Map<String, dynamic>> getFinancialReport(String token) {
    return _getMap(token, '/reports/financial/');
  }

  Future<List<dynamic>> getNotifications(String token) async {
    final data = await _getMap(token, '/notifications/');
    return (data['notifications'] ?? <dynamic>[]) as List<dynamic>;
  }

  Future<Map<String, dynamic>> getAnimalStats(String token) {
    return _getMap(token, '/animals/stats/');
  }

  Future<Map<String, dynamic>> getSalesReport(String token) {
    return _getMap(token, '/sales/report/');
  }

  Future<Map<String, dynamic>> getExpenseReport(String token) {
    return _getMap(token, '/expenses/report/');
  }

  Future<Map<String, dynamic>> getLoanSummary(String token) {
    return _getMap(token, '/loans/summary/');
  }

  Future<List<dynamic>> getLoans(String token) {
    return _getList(token, '/loans/');
  }

  Future<Map<String, dynamic>> getCapitalSummary(String token) {
    return _getMap(token, '/capital/summary/');
  }

  Future<Map<String, dynamic>> getPersonalMoneySummary(String token) {
    return _getMap(token, '/personal-transactions/summary/');
  }

  Future<List<dynamic>> getLowStock(String token) {
    return _getList(token, '/inventory/low-stock/');
  }

  Future<List<dynamic>> getSales(String token) {
    return _getList(token, '/sales/');
  }

  Future<List<dynamic>> getExpenses(String token) {
    return _getList(token, '/expenses/');
  }

  Future<List<dynamic>> getWithdrawals(String token) {
    return _getList(token, '/withdrawals/');
  }

  Future<List<dynamic>> getCapitalContributions(String token) {
    return _getList(token, '/capital/');
  }

  Future<List<dynamic>> getPersonalTransactions(String token) {
    return _getList(token, '/personal-transactions/');
  }

  Future<List<dynamic>> getInventory(String token) {
    return _getList(token, '/inventory/');
  }

  Future<List<dynamic>> getMilkProduction(String token) {
    return _getList(token, '/milk-production/');
  }

  Future<void> createSale({
    required String token,
    required String saleType,
    required String saleDate,
    required String description,
    required double totalAmount,
    String customerName = '',
    String customerPhone = '',
    double? paidAmount,
    String paymentMethod = 'cash',
    int? referenceAnimalId,
  }) async {
    final body = <String, dynamic>{
      'sale_type': saleType,
      'sale_date': saleDate,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'description': description,
      'total_amount': totalAmount.toStringAsFixed(2),
      'paid_amount': (paidAmount ?? totalAmount).toStringAsFixed(2),
      'payment_method': paymentMethod,
    };
    if (referenceAnimalId != null) {
      body['reference_animal'] = referenceAnimalId;
    }
    await _postMap(token, '/sales/', body);
  }

  Future<void> updateSale({
    required String token,
    required int saleId,
    required String saleType,
    required String description,
    required double totalAmount,
    String customerName = '',
    String customerPhone = '',
    double? paidAmount,
  }) async {
    await _patchMap(token, '/sales/$saleId/', {
      'sale_type': saleType,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'description': description,
      'total_amount': totalAmount.toStringAsFixed(2),
      'paid_amount': (paidAmount ?? totalAmount).toStringAsFixed(2),
    });
  }

  Future<void> updateAnimalActive({
    required String token,
    required int animalId,
    required bool isActive,
  }) async {
    final response = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/animals/$animalId/'),
      headers: _jsonHeaders(token),
      body: jsonEncode({'is_active': isActive}),
    );
    _ensureSuccess(response, 'Failed to update animal');
  }

  Future<void> createExpense({
    required String token,
    required String category,
    required String expenseDate,
    required String description,
    required double amount,
    String paymentMethod = 'cash',
  }) async {
    await _postMap(token, '/expenses/', {
      'category': category,
      'expense_date': expenseDate,
      'description': description,
      'amount': amount.toStringAsFixed(2),
      'payment_method': paymentMethod,
    });
  }

  Future<void> updateExpense({
    required String token,
    required int expenseId,
    required String category,
    required String description,
    required double amount,
  }) async {
    await _patchMap(token, '/expenses/$expenseId/', {
      'category': category,
      'description': description,
      'amount': amount.toStringAsFixed(2),
    });
  }

  Future<void> createFamilyWithdrawal({
    required String token,
    required String withdrawalDate,
    required String reason,
    required String description,
    required double amount,
  }) async {
    await _postMap(token, '/withdrawals/', {
      'withdrawal_date': withdrawalDate,
      'reason': reason,
      'description': description,
      'amount': amount.toStringAsFixed(2),
    });
  }

  Future<void> updateFamilyWithdrawal({
    required String token,
    required int withdrawalId,
    required String reason,
    required String description,
    required double amount,
  }) async {
    await _patchMap(token, '/withdrawals/$withdrawalId/', {
      'reason': reason,
      'description': description,
      'amount': amount.toStringAsFixed(2),
    });
  }

  Future<void> createPersonalTransaction({
    required String token,
    required String transactionDate,
    required String transactionType,
    required String category,
    required String description,
    required double amount,
  }) async {
    await _postMap(token, '/personal-transactions/', {
      'transaction_date': transactionDate,
      'transaction_type': transactionType,
      'category': category,
      'description': description,
      'amount': amount.toStringAsFixed(2),
    });
  }

  Future<void> createLoan({
    required String token,
    required String loanDate,
    required String loanSource,
    required double loanAmount,
    required double interestRate,
    required int tenureMonths,
    required double monthlyInstallment,
  }) async {
    await _postMap(token, '/loans/', {
      'loan_date': loanDate,
      'loan_source': loanSource,
      'loan_amount': loanAmount.toStringAsFixed(2),
      'outstanding_amount': loanAmount.toStringAsFixed(2),
      'interest_rate': interestRate.toStringAsFixed(2),
      'interest_type': 'simple',
      'tenure_months': tenureMonths,
      'monthly_installment': monthlyInstallment.toStringAsFixed(2),
      'repayment_start_date': loanDate,
      'status': 'active',
    });
  }

  Future<void> createLoanPayment({
    required String token,
    required int loanId,
    required String paymentDate,
    required double principalAmount,
    required double interestAmount,
  }) async {
    await _postMap(token, '/loans/$loanId/payment/', {
      'payment_date': paymentDate,
      'principal_amount': principalAmount.toStringAsFixed(2),
      'interest_amount': interestAmount.toStringAsFixed(2),
      'payment_method': 'cash',
    });
  }

  Future<void> createCapitalContribution({
    required String token,
    required String contributionDate,
    required String sourceType,
    required String contributorName,
    required String description,
    required double amount,
    String paymentMethod = 'cash',
  }) async {
    await _postMap(token, '/capital/', {
      'contribution_date': contributionDate,
      'source_type': sourceType,
      'contributor_name': contributorName,
      'description': description,
      'amount': amount.toStringAsFixed(2),
      'payment_method': paymentMethod,
    });
  }

  Future<void> updateCapitalContribution({
    required String token,
    required int contributionId,
    required String sourceType,
    required String contributorName,
    required String description,
    required double amount,
  }) async {
    await _patchMap(token, '/capital/$contributionId/', {
      'source_type': sourceType,
      'contributor_name': contributorName,
      'description': description,
      'amount': amount.toStringAsFixed(2),
    });
  }

  Future<void> createInventoryItem({
    required String token,
    required String itemType,
    required String itemName,
    required double quantity,
    required String unit,
    required double reorderLevel,
    required double dailyUsageQuantity,
    required bool autoDeductEnabled,
  }) async {
    await _postMap(token, '/inventory/', {
      'item_type': itemType,
      'item_name': itemName,
      'quantity': quantity.toStringAsFixed(2),
      'unit': unit,
      'reorder_level': reorderLevel.toStringAsFixed(2),
      'daily_usage_quantity': dailyUsageQuantity.toStringAsFixed(2),
      'auto_deduct_enabled': autoDeductEnabled,
      'last_updated': DateTime.now().toIso8601String().split('T').first,
      'last_auto_deducted': DateTime.now().toIso8601String().split('T').first,
    });
  }

  Future<void> updateInventoryItem({
    required String token,
    required int itemId,
    required String itemType,
    required String itemName,
    required double quantity,
    required String unit,
    required double reorderLevel,
    required double dailyUsageQuantity,
    required bool autoDeductEnabled,
  }) async {
    await _patchMap(token, '/inventory/$itemId/', {
      'item_type': itemType,
      'item_name': itemName,
      'quantity': quantity.toStringAsFixed(2),
      'unit': unit,
      'reorder_level': reorderLevel.toStringAsFixed(2),
      'daily_usage_quantity': dailyUsageQuantity.toStringAsFixed(2),
      'auto_deduct_enabled': autoDeductEnabled,
      'last_updated': DateTime.now().toIso8601String().split('T').first,
    });
  }

  Future<void> moveInventoryStock({
    required String token,
    required int itemId,
    required double quantity,
    required bool stockIn,
  }) async {
    await _postMap(
      token,
      '/inventory/$itemId/${stockIn ? 'stock-in' : 'stock-out'}/',
      {'quantity': quantity.toStringAsFixed(2)},
    );
  }

  Future<void> createMilkProduction({
    required String token,
    required int animalId,
    required String productionDate,
    required double morningMilk,
    required double eveningMilk,
    String qualityGrade = 'A',
  }) async {
    await _postMap(token, '/milk-production/', {
      'animal': animalId,
      'production_date': productionDate,
      'morning_milk': morningMilk.toStringAsFixed(2),
      'evening_milk': eveningMilk.toStringAsFixed(2),
      'quality_grade': qualityGrade,
    });
  }

  Future<void> updateMilkProduction({
    required String token,
    required int recordId,
    required int animalId,
    required double morningMilk,
    required double eveningMilk,
    String qualityGrade = 'A',
  }) async {
    await _patchMap(token, '/milk-production/$recordId/', {
      'animal': animalId,
      'morning_milk': morningMilk.toStringAsFixed(2),
      'evening_milk': eveningMilk.toStringAsFixed(2),
      'quality_grade': qualityGrade,
    });
  }

  Future<void> deleteMilkProduction({
    required String token,
    required int recordId,
    required String reason,
  }) async {
    await _deleteReason(
      token,
      '/milk-production/$recordId/delete-with-reason/',
      reason,
    );
  }
}
