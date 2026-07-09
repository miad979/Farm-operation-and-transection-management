import 'package:flutter/foundation.dart';

import '../models/animal_model.dart';
import '../services/api_service.dart';
import '../services/local_farm_store.dart';

class FarmProvider extends ChangeNotifier {
  FarmProvider(this._apiService, this._localStore);

  final ApiService _apiService;
  final LocalFarmStore _localStore;
  bool _isLoading = false;
  String? _error;
  bool _sessionExpired = false;
  List<AnimalModel> _animals = <AnimalModel>[];
  Map<String, dynamic> _dashboard = <String, dynamic>{};
  Map<String, dynamic> _monthly = <String, dynamic>{};
  Map<String, dynamic> _cashFlow = <String, dynamic>{};
  Map<String, dynamic> _animalStats = <String, dynamic>{};
  Map<String, dynamic> _salesReport = <String, dynamic>{};
  Map<String, dynamic> _expenseReport = <String, dynamic>{};
  Map<String, dynamic> _loanSummary = <String, dynamic>{};
  Map<String, dynamic> _capitalSummary = <String, dynamic>{};
  Map<String, dynamic> _personalMoneySummary = <String, dynamic>{};
  Map<String, dynamic> _monthlyReport = <String, dynamic>{};
  Map<String, dynamic> _financialReport = <String, dynamic>{};
  List<dynamic> _insights = <dynamic>[];
  List<dynamic> _lowStock = <dynamic>[];
  List<dynamic> _sales = <dynamic>[];
  List<dynamic> _expenses = <dynamic>[];
  List<dynamic> _withdrawals = <dynamic>[];
  List<dynamic> _capitalContributions = <dynamic>[];
  List<dynamic> _personalTransactions = <dynamic>[];
  List<dynamic> _loans = <dynamic>[];
  List<dynamic> _notifications = <dynamic>[];
  List<dynamic> _inventory = <dynamic>[];
  List<dynamic> _milkRecords = <dynamic>[];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get sessionExpired => _sessionExpired;
  List<AnimalModel> get animals => _animals;
  Map<String, dynamic> get dashboard => _dashboard;
  Map<String, dynamic> get monthly => _monthly;
  Map<String, dynamic> get cashFlow => _cashFlow;
  Map<String, dynamic> get animalStats => _animalStats;
  Map<String, dynamic> get salesReport => _salesReport;
  Map<String, dynamic> get expenseReport => _expenseReport;
  Map<String, dynamic> get loanSummary => _loanSummary;
  Map<String, dynamic> get capitalSummary => _capitalSummary;
  Map<String, dynamic> get personalMoneySummary => _personalMoneySummary;
  Map<String, dynamic> get monthlyReport => _monthlyReport;
  Map<String, dynamic> get financialReport => _financialReport;
  List<dynamic> get insights => _insights;
  List<dynamic> get lowStock => _lowStock;
  List<dynamic> get sales => _sales;
  List<dynamic> get expenses => _expenses;
  List<dynamic> get withdrawals => _withdrawals;
  List<dynamic> get capitalContributions => _capitalContributions;
  List<dynamic> get personalTransactions => _personalTransactions;
  List<dynamic> get loans => _loans;
  List<dynamic> get notifications => _notifications;
  List<dynamic> get inventory => _inventory;
  List<dynamic> get milkRecords => _milkRecords;

  int get totalAnimals => _animals.length;
  int get healthyAnimals =>
      _animals.where((animal) => animal.healthStatus == 'Healthy').length;
  int get attentionAnimals => _animals
      .where((animal) => animal.healthStatus != 'Healthy' || !animal.vaccinated)
      .length;

  Future<void> loadAll(String token) async {
    _isLoading = true;
    _error = null;
    _sessionExpired = false;
    notifyListeners();

    try {
      if (_isOffline(token)) {
        final snapshot = await _localStore.loadSnapshot();
        _animals = snapshot.animals;
        _dashboard = snapshot.dashboard;
        _monthly = snapshot.monthly;
        _cashFlow = snapshot.cashFlow;
        _animalStats = snapshot.animalStats;
        _salesReport = snapshot.salesReport;
        _expenseReport = snapshot.expenseReport;
        _loanSummary = snapshot.loanSummary;
        _capitalSummary = snapshot.capitalSummary;
        _personalMoneySummary = snapshot.personalMoneySummary;
        _monthlyReport = snapshot.monthlyReport;
        _financialReport = snapshot.financialReport;
        _insights = snapshot.insights;
        _lowStock = snapshot.lowStock;
        _sales = snapshot.sales;
        _expenses = snapshot.expenses;
        _withdrawals = snapshot.withdrawals;
        _capitalContributions = snapshot.capitalContributions;
        _personalTransactions = snapshot.personalTransactions;
        _loans = snapshot.loans;
        _notifications = snapshot.notifications;
        _inventory = snapshot.inventory;
        _milkRecords = snapshot.milkRecords;
        return;
      }

      final results = await Future.wait<dynamic>([
        _apiService.getAnimals(token),
        _apiService.getTodayDashboard(token),
        _apiService.getMonthlyDashboard(token),
        _apiService.getCashFlow(token),
        _apiService.getAnimalStats(token),
        _apiService.getSalesReport(token),
        _apiService.getExpenseReport(token),
        _apiService.getLoanSummary(token),
        _apiService.getCapitalSummary(token),
        _apiService.getPersonalMoneySummary(token),
        _apiService.getMonthlyReport(token),
        _apiService.getFinancialReport(token),
        _apiService.getLoans(token),
        _apiService.getNotifications(token),
        _apiService.getInsights(token),
        _apiService.getLowStock(token),
        _apiService.getSales(token),
        _apiService.getExpenses(token),
        _apiService.getWithdrawals(token),
        _apiService.getCapitalContributions(token),
        _apiService.getPersonalTransactions(token),
        _apiService.getInventory(token),
        _apiService.getMilkProduction(token),
      ]);

      _animals = results[0] as List<AnimalModel>;
      _dashboard = results[1] as Map<String, dynamic>;
      _monthly = results[2] as Map<String, dynamic>;
      _cashFlow = results[3] as Map<String, dynamic>;
      _animalStats = results[4] as Map<String, dynamic>;
      _salesReport = results[5] as Map<String, dynamic>;
      _expenseReport = results[6] as Map<String, dynamic>;
      _loanSummary = results[7] as Map<String, dynamic>;
      _capitalSummary = results[8] as Map<String, dynamic>;
      _personalMoneySummary = results[9] as Map<String, dynamic>;
      _monthlyReport = results[10] as Map<String, dynamic>;
      _financialReport = results[11] as Map<String, dynamic>;
      _loans = results[12] as List<dynamic>;
      _notifications = results[13] as List<dynamic>;
      _insights = results[14] as List<dynamic>;
      _lowStock = results[15] as List<dynamic>;
      _sales = results[16] as List<dynamic>;
      _expenses = results[17] as List<dynamic>;
      _withdrawals = results[18] as List<dynamic>;
      _capitalContributions = results[19] as List<dynamic>;
      _personalTransactions = results[20] as List<dynamic>;
      _inventory = results[21] as List<dynamic>;
      _milkRecords = results[22] as List<dynamic>;
    } catch (e) {
      final message = e.toString();
      _sessionExpired =
          message.contains('token_not_valid') ||
          message.contains('Token is invalid or expired') ||
          message.contains('Given token not valid');
      _error = _sessionExpired
          ? 'Session expired. Please login again.'
          : message;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAnimal({
    required String token,
    required String animalIdNumber,
    required String name,
    required String type,
    String? breed,
    String? gender,
    String? healthStatus,
    String? notes,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createAnimal(
        animalIdNumber: animalIdNumber,
        name: name,
        type: type,
        breed: breed,
        gender: gender,
        healthStatus: healthStatus,
        notes: notes,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createAnimal(
      token: token,
      animalIdNumber: animalIdNumber,
      name: name,
      type: type,
      breed: breed,
      gender: gender,
      healthStatus: healthStatus,
      notes: notes,
    );
    await loadAll(token);
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
    required bool vaccinated,
    required String pregnancyStatus,
    required String notes,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateAnimal(
        animalId: animalId,
        animalIdNumber: animalIdNumber,
        name: name,
        type: type,
        breed: breed,
        gender: gender,
        healthStatus: healthStatus,
        vaccinated: vaccinated,
        pregnancyStatus: pregnancyStatus,
        notes: notes,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateAnimal(
      token: token,
      animalId: animalId,
      animalIdNumber: animalIdNumber,
      name: name,
      type: type,
      breed: breed,
      gender: gender,
      healthStatus: healthStatus,
      vaccinated: vaccinated,
      pregnancyStatus: pregnancyStatus,
      notes: notes,
    );
    await loadAll(token);
  }

  Future<void> addSale({
    required String token,
    required String saleType,
    required String description,
    required double amount,
    int? referenceAnimalId,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createSale(
        saleType: saleType,
        saleDate: _today(),
        description: description,
        totalAmount: amount,
        referenceAnimalId: referenceAnimalId,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createSale(
      token: token,
      saleType: saleType,
      saleDate: _today(),
      description: description,
      totalAmount: amount,
      referenceAnimalId: referenceAnimalId,
    );
    await loadAll(token);
  }

  Future<void> updateSale({
    required String token,
    required int saleId,
    required String saleType,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateSale(
        saleId: saleId,
        saleType: saleType,
        description: description,
        totalAmount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateSale(
      token: token,
      saleId: saleId,
      saleType: saleType,
      description: description,
      totalAmount: amount,
    );
    await loadAll(token);
  }

  Future<void> sellAnimal({
    required String token,
    required int animalId,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createSale(
        saleType: 'cattle',
        saleDate: _today(),
        description: description,
        totalAmount: amount,
        referenceAnimalId: animalId,
      );
      await _localStore.updateAnimalActive(animalId: animalId, isActive: false);
      await loadAll(token);
      return;
    }
    await _apiService.createSale(
      token: token,
      saleType: 'cattle',
      saleDate: _today(),
      description: description,
      totalAmount: amount,
      referenceAnimalId: animalId,
    );
    await _apiService.updateAnimalActive(
      token: token,
      animalId: animalId,
      isActive: false,
    );
    await loadAll(token);
  }

  Future<void> addExpense({
    required String token,
    required String category,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createExpense(
        category: category,
        expenseDate: _today(),
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createExpense(
      token: token,
      category: category,
      expenseDate: _today(),
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> updateExpense({
    required String token,
    required int expenseId,
    required String category,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateExpense(
        expenseId: expenseId,
        category: category,
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateExpense(
      token: token,
      expenseId: expenseId,
      category: category,
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> addFamilyWithdrawal({
    required String token,
    required String reason,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createFamilyWithdrawal(
        withdrawalDate: _today(),
        reason: reason,
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createFamilyWithdrawal(
      token: token,
      withdrawalDate: _today(),
      reason: reason,
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> updateFamilyWithdrawal({
    required String token,
    required int withdrawalId,
    required String reason,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateFamilyWithdrawal(
        withdrawalId: withdrawalId,
        reason: reason,
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateFamilyWithdrawal(
      token: token,
      withdrawalId: withdrawalId,
      reason: reason,
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> addPersonalTransaction({
    required String token,
    required String transactionType,
    required String category,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createPersonalTransaction(
        transactionDate: _today(),
        transactionType: transactionType,
        category: category,
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createPersonalTransaction(
      token: token,
      transactionDate: _today(),
      transactionType: transactionType,
      category: category,
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> addLoan({
    required String token,
    required String loanSource,
    required double loanAmount,
    required double interestRate,
    required int tenureMonths,
    required double monthlyInstallment,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createLoan(
        loanDate: _today(),
        loanSource: loanSource,
        loanAmount: loanAmount,
        interestRate: interestRate,
        tenureMonths: tenureMonths,
        monthlyInstallment: monthlyInstallment,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createLoan(
      token: token,
      loanDate: _today(),
      loanSource: loanSource,
      loanAmount: loanAmount,
      interestRate: interestRate,
      tenureMonths: tenureMonths,
      monthlyInstallment: monthlyInstallment,
    );
    await loadAll(token);
  }

  Future<void> payLoan({
    required String token,
    required int loanId,
    required double principalAmount,
    required double interestAmount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createLoanPayment(
        loanId: loanId,
        principalAmount: principalAmount,
        interestAmount: interestAmount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createLoanPayment(
      token: token,
      loanId: loanId,
      paymentDate: _today(),
      principalAmount: principalAmount,
      interestAmount: interestAmount,
    );
    await loadAll(token);
  }

  Future<void> addCapitalContribution({
    required String token,
    required String sourceType,
    required String contributorName,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createCapitalContribution(
        contributionDate: _today(),
        sourceType: sourceType,
        contributorName: contributorName,
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createCapitalContribution(
      token: token,
      contributionDate: _today(),
      sourceType: sourceType,
      contributorName: contributorName,
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> updateCapitalContribution({
    required String token,
    required int contributionId,
    required String sourceType,
    required String contributorName,
    required String description,
    required double amount,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateCapitalContribution(
        contributionId: contributionId,
        sourceType: sourceType,
        contributorName: contributorName,
        description: description,
        amount: amount,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateCapitalContribution(
      token: token,
      contributionId: contributionId,
      sourceType: sourceType,
      contributorName: contributorName,
      description: description,
      amount: amount,
    );
    await loadAll(token);
  }

  Future<void> addInventoryItem({
    required String token,
    required String itemType,
    required String itemName,
    required double quantity,
    required String unit,
    required double reorderLevel,
    double dailyUsageQuantity = 0,
    bool autoDeductEnabled = false,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createInventoryItem(
        itemType: itemType,
        itemName: itemName,
        quantity: quantity,
        unit: unit,
        reorderLevel: reorderLevel,
        dailyUsageQuantity: dailyUsageQuantity,
        autoDeductEnabled: autoDeductEnabled,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createInventoryItem(
      token: token,
      itemType: itemType,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      reorderLevel: reorderLevel,
      dailyUsageQuantity: dailyUsageQuantity,
      autoDeductEnabled: autoDeductEnabled,
    );
    await loadAll(token);
  }

  Future<void> updateInventoryItem({
    required String token,
    required int itemId,
    required String itemType,
    required String itemName,
    required double quantity,
    required String unit,
    required double reorderLevel,
    double dailyUsageQuantity = 0,
    bool autoDeductEnabled = false,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateInventoryItem(
        itemId: itemId,
        itemType: itemType,
        itemName: itemName,
        quantity: quantity,
        unit: unit,
        reorderLevel: reorderLevel,
        dailyUsageQuantity: dailyUsageQuantity,
        autoDeductEnabled: autoDeductEnabled,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateInventoryItem(
      token: token,
      itemId: itemId,
      itemType: itemType,
      itemName: itemName,
      quantity: quantity,
      unit: unit,
      reorderLevel: reorderLevel,
      dailyUsageQuantity: dailyUsageQuantity,
      autoDeductEnabled: autoDeductEnabled,
    );
    await loadAll(token);
  }

  Future<void> moveInventoryStock({
    required String token,
    required int itemId,
    required double quantity,
    required bool stockIn,
  }) async {
    if (_isOffline(token)) {
      await _localStore.moveInventoryStock(
        itemId: itemId,
        quantity: quantity,
        stockIn: stockIn,
      );
      await loadAll(token);
      return;
    }
    await _apiService.moveInventoryStock(
      token: token,
      itemId: itemId,
      quantity: quantity,
      stockIn: stockIn,
    );
    await loadAll(token);
  }

  Future<void> addMilkRecord({
    required String token,
    required int animalId,
    required double morningMilk,
    required double eveningMilk,
  }) async {
    if (_isOffline(token)) {
      await _localStore.createMilkProduction(
        animalId: animalId,
        productionDate: _today(),
        morningMilk: morningMilk,
        eveningMilk: eveningMilk,
      );
      await loadAll(token);
      return;
    }
    await _apiService.createMilkProduction(
      token: token,
      animalId: animalId,
      productionDate: _today(),
      morningMilk: morningMilk,
      eveningMilk: eveningMilk,
    );
    await loadAll(token);
  }

  Future<void> updateMilkRecord({
    required String token,
    required int recordId,
    required int animalId,
    required double morningMilk,
    required double eveningMilk,
  }) async {
    if (_isOffline(token)) {
      await _localStore.updateMilkProduction(
        recordId: recordId,
        animalId: animalId,
        morningMilk: morningMilk,
        eveningMilk: eveningMilk,
      );
      await loadAll(token);
      return;
    }
    await _apiService.updateMilkProduction(
      token: token,
      recordId: recordId,
      animalId: animalId,
      morningMilk: morningMilk,
      eveningMilk: eveningMilk,
    );
    await loadAll(token);
  }

  String _today() => DateTime.now().toIso8601String().split('T').first;

  bool _isOffline(String token) => LocalFarmStore.isOfflineToken(token);
}
