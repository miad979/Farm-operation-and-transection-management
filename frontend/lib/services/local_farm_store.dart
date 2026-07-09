import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/animal_model.dart';

class OfflineFarmSnapshot {
  const OfflineFarmSnapshot({
    required this.animals,
    required this.dashboard,
    required this.monthly,
    required this.cashFlow,
    required this.animalStats,
    required this.salesReport,
    required this.expenseReport,
    required this.loanSummary,
    required this.capitalSummary,
    required this.personalMoneySummary,
    required this.monthlyReport,
    required this.financialReport,
    required this.insights,
    required this.lowStock,
    required this.sales,
    required this.expenses,
    required this.withdrawals,
    required this.capitalContributions,
    required this.personalTransactions,
    required this.loans,
    required this.notifications,
    required this.inventory,
    required this.milkRecords,
  });

  final List<AnimalModel> animals;
  final Map<String, dynamic> dashboard;
  final Map<String, dynamic> monthly;
  final Map<String, dynamic> cashFlow;
  final Map<String, dynamic> animalStats;
  final Map<String, dynamic> salesReport;
  final Map<String, dynamic> expenseReport;
  final Map<String, dynamic> loanSummary;
  final Map<String, dynamic> capitalSummary;
  final Map<String, dynamic> personalMoneySummary;
  final Map<String, dynamic> monthlyReport;
  final Map<String, dynamic> financialReport;
  final List<dynamic> insights;
  final List<dynamic> lowStock;
  final List<dynamic> sales;
  final List<dynamic> expenses;
  final List<dynamic> withdrawals;
  final List<dynamic> capitalContributions;
  final List<dynamic> personalTransactions;
  final List<dynamic> loans;
  final List<dynamic> notifications;
  final List<dynamic> inventory;
  final List<dynamic> milkRecords;
}

class LocalFarmStore {
  static const offlineToken = 'offline-local-device';

  static const _animalsKey = 'offline_animals';
  static const _salesKey = 'offline_sales';
  static const _expensesKey = 'offline_expenses';
  static const _withdrawalsKey = 'offline_withdrawals';
  static const _capitalKey = 'offline_capital';
  static const _personalKey = 'offline_personal';
  static const _loansKey = 'offline_loans';
  static const _inventoryKey = 'offline_inventory';
  static const _milkKey = 'offline_milk';
  static const _milkRatesKey = 'offline_milk_rates';
  static const _idKey = 'offline_next_id';

  static bool isOfflineToken(String? token) => token == offlineToken;

  Future<OfflineFarmSnapshot> loadSnapshot() async {
    await _applyDailyInventoryUsage();
    final animals = await _list(_animalsKey);
    final sales = await _list(_salesKey);
    final expenses = await _list(_expensesKey);
    final withdrawals = await _list(_withdrawalsKey);
    final capital = await _list(_capitalKey);
    final personal = await _list(_personalKey);
    final loans = await _list(_loansKey);
    final inventory = await _list(_inventoryKey);
    final milk = await _list(_milkKey);
    final milkRates = await _list(_milkRatesKey);

    final activeAnimals = animals
        .where((item) => (item['is_active'] as bool?) ?? true)
        .toList();
    final today = _today();
    final now = DateTime.now();
    final month = now.month;
    final year = now.year;

    final todaySales = sales.where((item) => item['sale_date'] == today);
    final todayExpenses = expenses.where(
      (item) => item['expense_date'] == today,
    );
    final todayMilk = milk.where((item) => item['production_date'] == today);
    final monthSales = sales.where(
      (item) => _isSameMonth(item['sale_date'], year, month),
    );
    final monthExpenses = expenses.where(
      (item) => _isSameMonth(item['expense_date'], year, month),
    );
    final monthWithdrawals = withdrawals.where(
      (item) => _isSameMonth(item['withdrawal_date'], year, month),
    );
    final monthCapital = capital.where(
      (item) => _isSameMonth(item['contribution_date'], year, month),
    );
    final monthPersonal = personal.where(
      (item) => _isSameMonth(item['transaction_date'], year, month),
    );
    final monthMilk = milk.where(
      (item) => _isSameMonth(item['production_date'], year, month),
    );

    final income = _sum(monthSales, 'total_amount');
    final businessExpenses = _sum(monthExpenses, 'amount');
    final profit = income - businessExpenses;
    final farmToPocket = _sum(monthWithdrawals, 'amount');
    final capitalAdded = _sum(monthCapital, 'amount');
    final businessCash = profit + capitalAdded - farmToPocket;
    final personalIncome = _sum(
      monthPersonal.where((item) => item['transaction_type'] == 'income'),
      'amount',
    );
    final personalExpenses = _sum(
      monthPersonal.where((item) => item['transaction_type'] == 'expense'),
      'amount',
    );
    final personalFarmTransfers = _sum(
      monthPersonal.where(
        (item) => item['transaction_type'] == 'farm_transfer',
      ),
      'amount',
    );
    final personalBalance =
        personalIncome + personalFarmTransfers - personalExpenses;
    final monthlyMilk = _milkTotalWithDefaults(
      activeAnimals,
      monthMilk.toList(),
      milkRates,
      DateTime(year, month),
      DateTime(year, month, now.day),
    );
    final todayMilkLiters = _milkTotalWithDefaults(
      activeAnimals,
      todayMilk.toList(),
      milkRates,
      DateTime(now.year, now.month, now.day),
      DateTime(now.year, now.month, now.day),
    );
    final dailyAverageMilk = now.day == 0 ? 0 : monthlyMilk / now.day;
    final averagePerCow = activeAnimals.isEmpty
        ? 0
        : todayMilkLiters / activeAnimals.length;
    final lowStock = inventory.where((item) {
      return _num(item['quantity']) <= _num(item['reorder_level']);
    }).toList();
    final notifications = _buildNotifications(activeAnimals, lowStock, loans);

    final dashboard = <String, dynamic>{
      'income': _sum(todaySales, 'total_amount'),
      'expenses': _sum(todayExpenses, 'amount'),
      'profit':
          _sum(todaySales, 'total_amount') - _sum(todayExpenses, 'amount'),
      'milk_liters': todayMilkLiters,
      'milk_production': {
        'total_liters': todayMilkLiters,
        'average_per_cow': averagePerCow,
      },
      'business_cash': businessCash,
      'available_cash': businessCash,
    };
    final monthly = <String, dynamic>{
      'month': month,
      'year': year,
      'income': {'total': income},
      'business_expenses': businessExpenses,
      'expenses': {'total': businessExpenses},
      'profit': profit,
      'family_withdrawals': farmToPocket,
      'farm_to_pocket': farmToPocket,
      'capital_added': capitalAdded,
      'business_cash': businessCash,
      'available_cash': businessCash,
      'milk_liters': monthlyMilk,
      'daily_average': dailyAverageMilk,
      'milk_production': {
        'total_liters': monthlyMilk,
        'average_daily': dailyAverageMilk,
      },
    };
    final cashFlow = <String, dynamic>{
      'income': income,
      'expenses': businessExpenses,
      'net_profit': profit,
      'available_cash': businessCash,
      'business_cash': businessCash,
      'capital_added': capitalAdded,
      'farm_to_pocket': farmToPocket,
    };
    final animalStats = <String, dynamic>{
      'total': activeAnimals.length,
      'healthy': activeAnimals
          .where((item) => item['health_status'] == 'Healthy')
          .length,
      'attention': activeAnimals
          .where(
            (item) =>
                item['health_status'] != 'Healthy' ||
                item['vaccinated'] != true,
          )
          .length,
      'vaccinated': activeAnimals
          .where((item) => item['vaccinated'] == true)
          .length,
      'pregnant': activeAnimals
          .where(
            (item) => '${item['pregnancy_status']}'.toLowerCase().contains(
              'pregnant',
            ),
          )
          .length,
    };
    final loanOutstanding = _sum(
      loans.where((item) => item['status'] == 'active'),
      'outstanding_amount',
    );
    final loanSummary = <String, dynamic>{
      'total_outstanding': loanOutstanding,
      'active_loans': loans.where((item) => item['status'] == 'active').length,
    };
    final personalSummary = <String, dynamic>{
      'farm_to_pocket': personalFarmTransfers,
      'personal_income': personalIncome,
      'personal_expenses': personalExpenses,
      'personal_balance': personalBalance,
    };
    final monthlyReport = <String, dynamic>{
      ...monthly,
      'income': income,
      'expenses': businessExpenses,
      'business_expenses': businessExpenses,
      'farm_cash': businessCash,
      'animal_count': activeAnimals.length,
    };
    final financialReport = <String, dynamic>{
      'income': income,
      'business_expenses': businessExpenses,
      'profit': profit,
      'farm_cash': businessCash,
      'personal_balance': personalBalance,
      'loan_outstanding': loanOutstanding,
    };

    return OfflineFarmSnapshot(
      animals: activeAnimals.map(AnimalModel.fromJson).toList(),
      dashboard: dashboard,
      monthly: monthly,
      cashFlow: cashFlow,
      animalStats: animalStats,
      salesReport: {'total_sales': income, 'sales_count': sales.length},
      expenseReport: {
        'total_expenses': businessExpenses,
        'expense_count': expenses.length,
      },
      loanSummary: loanSummary,
      capitalSummary: {
        'total_capital': _sum(capital, 'amount'),
        'month_capital': capitalAdded,
      },
      personalMoneySummary: personalSummary,
      monthlyReport: monthlyReport,
      financialReport: financialReport,
      insights: _buildInsights(activeAnimals, lowStock, businessCash),
      lowStock: lowStock,
      sales: sales.reversed.toList(),
      expenses: expenses.reversed.toList(),
      withdrawals: withdrawals.reversed.toList(),
      capitalContributions: capital.reversed.toList(),
      personalTransactions: personal.reversed.toList(),
      loans: loans.reversed.toList(),
      notifications: notifications,
      inventory: inventory,
      milkRecords: milk.reversed.toList(),
    );
  }

  Future<void> createAnimal({
    required String animalIdNumber,
    required String name,
    required String type,
    String? breed,
    String? gender,
    String? healthStatus,
    double defaultDailyMilk = 0,
    String? notes,
  }) async {
    final animals = await _list(_animalsKey);
    animals.add({
      'id': await _nextId(),
      'animal_id_number': animalIdNumber,
      'name': name,
      'type': type,
      'breed': breed ?? '',
      'gender': gender ?? '',
      'health_status': healthStatus ?? 'Healthy',
      'default_daily_milk': defaultDailyMilk,
      'vaccinated': false,
      'pregnancy_status': 'Not Pregnant',
      'is_active': true,
      'created_on': _today(),
      'notes': notes ?? '',
    });
    final animalId = animals.last['id'] as int;
    await _saveList(_animalsKey, animals);
    await _setMilkRateIfNeeded(animalId, defaultDailyMilk);
  }

  Future<void> updateAnimal({
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
    var oldDailyMilk = 0.0;
    await _updateById(_animalsKey, animalId, (item) {
      oldDailyMilk = _num(item['default_daily_milk']);
      item.addAll({
        'animal_id_number': animalIdNumber,
        'name': name,
        'type': type,
        'breed': breed,
        'gender': gender,
        'health_status': healthStatus,
        'default_daily_milk': defaultDailyMilk,
        'vaccinated': vaccinated,
        'pregnancy_status': pregnancyStatus,
        'notes': notes,
      });
    });
    if (oldDailyMilk != defaultDailyMilk) {
      await _setMilkRateIfNeeded(animalId, defaultDailyMilk);
    }
  }

  Future<void> updateAnimalActive({
    required int animalId,
    required bool isActive,
  }) {
    return _updateById(_animalsKey, animalId, (item) {
      item['is_active'] = isActive;
    });
  }

  Future<void> createSale({
    required String saleType,
    required String saleDate,
    required String description,
    required double totalAmount,
    int? referenceAnimalId,
  }) async {
    final sales = await _list(_salesKey);
    final sale = <String, dynamic>{
      'id': await _nextId(),
      'sale_type': saleType,
      'sale_date': saleDate,
      'description': description,
      'total_amount': totalAmount,
      'payment_method': 'cash',
    };
    if (referenceAnimalId != null) {
      sale['reference_animal'] = referenceAnimalId;
    }
    sales.add(sale);
    await _saveList(_salesKey, sales);
  }

  Future<void> updateSale({
    required int saleId,
    required String saleType,
    required String description,
    required double totalAmount,
  }) {
    return _updateById(_salesKey, saleId, (item) {
      item.addAll({
        'sale_type': saleType,
        'description': description,
        'total_amount': totalAmount,
      });
    });
  }

  Future<void> createExpense({
    required String category,
    required String expenseDate,
    required String description,
    required double amount,
  }) async {
    final expenses = await _list(_expensesKey);
    expenses.add({
      'id': await _nextId(),
      'category': category,
      'expense_date': expenseDate,
      'description': description,
      'amount': amount,
      'payment_method': 'cash',
    });
    await _saveList(_expensesKey, expenses);
  }

  Future<void> updateExpense({
    required int expenseId,
    required String category,
    required String description,
    required double amount,
  }) {
    return _updateById(_expensesKey, expenseId, (item) {
      item.addAll({
        'category': category,
        'description': description,
        'amount': amount,
      });
    });
  }

  Future<void> createFamilyWithdrawal({
    required String withdrawalDate,
    required String reason,
    required String description,
    required double amount,
  }) async {
    final withdrawalId = await _nextId();
    final withdrawals = await _list(_withdrawalsKey);
    withdrawals.add({
      'id': withdrawalId,
      'withdrawal_date': withdrawalDate,
      'reason': reason,
      'description': description,
      'amount': amount,
    });
    await _saveList(_withdrawalsKey, withdrawals);

    final personal = await _list(_personalKey);
    personal.add({
      'id': await _nextId(),
      'linked_withdrawal': withdrawalId,
      'transaction_date': withdrawalDate,
      'transaction_type': 'farm_transfer',
      'category': 'farm_transfer',
      'description': description.isEmpty
          ? 'Money taken from farm'
          : description,
      'amount': amount,
    });
    await _saveList(_personalKey, personal);
  }

  Future<void> updateFamilyWithdrawal({
    required int withdrawalId,
    required String reason,
    required String description,
    required double amount,
  }) async {
    await _updateById(_withdrawalsKey, withdrawalId, (item) {
      item.addAll({
        'reason': reason,
        'description': description,
        'amount': amount,
      });
    });
    final personal = await _list(_personalKey);
    for (final item in personal) {
      if (item['linked_withdrawal'] == withdrawalId) {
        item.addAll({'description': description, 'amount': amount});
      }
    }
    await _saveList(_personalKey, personal);
  }

  Future<void> createPersonalTransaction({
    required String transactionDate,
    required String transactionType,
    required String category,
    required String description,
    required double amount,
  }) async {
    final personal = await _list(_personalKey);
    personal.add({
      'id': await _nextId(),
      'transaction_date': transactionDate,
      'transaction_type': transactionType,
      'category': category,
      'description': description,
      'amount': amount,
    });
    await _saveList(_personalKey, personal);
  }

  Future<void> createLoan({
    required String loanDate,
    required String loanSource,
    required double loanAmount,
    required double interestRate,
    required int tenureMonths,
    required double monthlyInstallment,
  }) async {
    final loans = await _list(_loansKey);
    loans.add({
      'id': await _nextId(),
      'loan_date': loanDate,
      'loan_source': loanSource,
      'loan_amount': loanAmount,
      'outstanding_amount': loanAmount,
      'paid_amount': 0,
      'interest_rate': interestRate,
      'interest_type': 'simple',
      'tenure_months': tenureMonths,
      'monthly_installment': monthlyInstallment,
      'repayment_start_date': loanDate,
      'status': 'active',
    });
    await _saveList(_loansKey, loans);
  }

  Future<void> createLoanPayment({
    required int loanId,
    required double principalAmount,
    required double interestAmount,
  }) {
    return _updateById(_loansKey, loanId, (item) {
      final paid = _num(item['paid_amount']) + principalAmount + interestAmount;
      final outstanding = (_num(item['outstanding_amount']) - principalAmount)
          .clamp(0, double.infinity);
      item['paid_amount'] = paid;
      item['outstanding_amount'] = outstanding;
      item['status'] = outstanding <= 0 ? 'closed' : 'active';
    });
  }

  Future<void> createCapitalContribution({
    required String contributionDate,
    required String sourceType,
    required String contributorName,
    required String description,
    required double amount,
  }) async {
    final capital = await _list(_capitalKey);
    capital.add({
      'id': await _nextId(),
      'contribution_date': contributionDate,
      'source_type': sourceType,
      'contributor_name': contributorName,
      'description': description,
      'amount': amount,
      'payment_method': 'cash',
    });
    await _saveList(_capitalKey, capital);
  }

  Future<void> updateCapitalContribution({
    required int contributionId,
    required String sourceType,
    required String contributorName,
    required String description,
    required double amount,
  }) {
    return _updateById(_capitalKey, contributionId, (item) {
      item.addAll({
        'source_type': sourceType,
        'contributor_name': contributorName,
        'description': description,
        'amount': amount,
      });
    });
  }

  Future<void> createInventoryItem({
    required String itemType,
    required String itemName,
    required double quantity,
    required String unit,
    required double reorderLevel,
    required double dailyUsageQuantity,
    required bool autoDeductEnabled,
  }) async {
    final inventory = await _list(_inventoryKey);
    inventory.add({
      'id': await _nextId(),
      'item_type': itemType,
      'item_name': itemName,
      'quantity': quantity,
      'unit': unit,
      'reorder_level': reorderLevel,
      'daily_usage_quantity': dailyUsageQuantity,
      'auto_deduct_enabled': autoDeductEnabled,
      'last_updated': _today(),
      'last_auto_deducted': _today(),
    });
    await _saveList(_inventoryKey, inventory);
  }

  Future<void> updateInventoryItem({
    required int itemId,
    required String itemType,
    required String itemName,
    required double quantity,
    required String unit,
    required double reorderLevel,
    required double dailyUsageQuantity,
    required bool autoDeductEnabled,
  }) {
    return _updateById(_inventoryKey, itemId, (item) {
      item.addAll({
        'item_type': itemType,
        'item_name': itemName,
        'quantity': quantity,
        'unit': unit,
        'reorder_level': reorderLevel,
        'daily_usage_quantity': dailyUsageQuantity,
        'auto_deduct_enabled': autoDeductEnabled,
        'last_updated': _today(),
        'last_auto_deducted': _today(),
      });
    });
  }

  Future<void> moveInventoryStock({
    required int itemId,
    required double quantity,
    required bool stockIn,
  }) {
    return _updateById(_inventoryKey, itemId, (item) {
      final current = _num(item['quantity']);
      item['quantity'] = stockIn
          ? current + quantity
          : (current - quantity).clamp(0, double.infinity);
      item['last_updated'] = _today();
      item['last_auto_deducted'] = _today();
    });
  }

  Future<void> createMilkProduction({
    required int animalId,
    required String productionDate,
    required double morningMilk,
    required double eveningMilk,
  }) async {
    final milk = await _list(_milkKey);
    final animals = await _list(_animalsKey);
    final animal = animals.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == animalId,
      orElse: () => null,
    );
    final existingIndex = milk.indexWhere(
      (item) =>
          item['animal'] == animalId &&
          item['production_date'] == productionDate,
    );
    final record = {
      'animal': animalId,
      'animal_name': animal?['name'] ?? 'Animal',
      'production_date': productionDate,
      'morning_milk': morningMilk,
      'evening_milk': eveningMilk,
      'total_milk': morningMilk + eveningMilk,
      'quality_grade': 'A',
    };
    if (existingIndex >= 0) {
      milk[existingIndex].addAll(record);
    } else {
      milk.add({'id': await _nextId(), ...record});
    }
    await _saveList(_milkKey, milk);
  }

  Future<void> updateMilkProduction({
    required int recordId,
    required int animalId,
    required double morningMilk,
    required double eveningMilk,
  }) async {
    final animals = await _list(_animalsKey);
    final animal = animals.cast<Map<String, dynamic>?>().firstWhere(
      (item) => item?['id'] == animalId,
      orElse: () => null,
    );
    await _updateById(_milkKey, recordId, (item) {
      item.addAll({
        'animal': animalId,
        'animal_name': animal?['name'] ?? 'Animal',
        'morning_milk': morningMilk,
        'evening_milk': eveningMilk,
        'total_milk': morningMilk + eveningMilk,
      });
    });
  }

  Future<void> _applyDailyInventoryUsage() async {
    final inventory = await _list(_inventoryKey);
    final today = DateTime.now();
    var changed = false;
    for (final item in inventory) {
      if (item['auto_deduct_enabled'] != true ||
          _num(item['daily_usage_quantity']) <= 0) {
        continue;
      }
      final lastText =
          item['last_auto_deducted']?.toString() ??
          item['last_updated']?.toString();
      final lastDate = lastText == null
          ? today
          : DateTime.tryParse(lastText) ?? today;
      final days = DateTime(today.year, today.month, today.day)
          .difference(DateTime(lastDate.year, lastDate.month, lastDate.day))
          .inDays;
      if (days <= 0) continue;
      item['quantity'] =
          (_num(item['quantity']) - (_num(item['daily_usage_quantity']) * days))
              .clamp(0, double.infinity);
      item['last_auto_deducted'] = _today();
      item['last_updated'] = _today();
      changed = true;
    }
    if (changed) {
      await _saveList(_inventoryKey, inventory);
    }
  }

  List<Map<String, dynamic>> _buildNotifications(
    List<Map<String, dynamic>> animals,
    List<Map<String, dynamic>> lowStock,
    List<Map<String, dynamic>> loans,
  ) {
    final alerts = <Map<String, dynamic>>[];
    final today = DateTime.now();
    final todayText = _today();
    final soon = today.add(const Duration(days: 30));
    for (final animal in animals) {
      if (animal['health_status'] != 'Healthy') {
        alerts.add({
          'type': 'animal_health',
          'title': '${animal['name']} needs attention',
          'message': 'Health status: ${animal['health_status']}',
          'due_date': todayText,
        });
      }
      if (animal['vaccinated'] != true) {
        alerts.add({
          'type': 'vaccination_due',
          'title': 'Vaccination not recorded for ${animal['name']}',
          'message': 'Add vaccination details when done.',
          'due_date': todayText,
        });
      }
      final due = DateTime.tryParse(
        '${animal['expected_delivery_date'] ?? ''}',
      );
      if (due != null && !due.isAfter(soon)) {
        alerts.add({
          'type': 'pregnancy_checkup',
          'title': 'Delivery/checkup near for ${animal['name']}',
          'message': 'Expected date: ${animal['expected_delivery_date']}',
          'due_date': animal['expected_delivery_date'],
        });
      }
    }
    for (final item in lowStock) {
      alerts.add({
        'type': 'low_stock',
        'title': 'Low stock: ${item['item_name']}',
        'message': '${item['quantity']} ${item['unit'] ?? ''} left.',
        'due_date': todayText,
      });
    }
    for (final loan in loans.where((item) => item['status'] == 'active')) {
      final due = DateTime.tryParse('${loan['repayment_start_date'] ?? ''}');
      if (due != null && !due.isAfter(soon)) {
        alerts.add({
          'type': 'loan_payment_due',
          'title': 'Loan payment reminder: ${loan['loan_source'] ?? 'Loan'}',
          'message': 'Outstanding amount: ${loan['outstanding_amount']}',
          'due_date': loan['repayment_start_date'],
        });
      }
    }
    return alerts;
  }

  List<Map<String, dynamic>> _buildInsights(
    List<Map<String, dynamic>> animals,
    List<Map<String, dynamic>> lowStock,
    double businessCash,
  ) {
    final insights = <Map<String, dynamic>>[];
    if (animals.isEmpty) {
      insights.add({
        'status': 'info',
        'title': 'Ready for records',
        'message':
            'Add animals, milk, sales, expenses, and stock to unlock trend insights.',
      });
    }
    if (lowStock.isNotEmpty) {
      insights.add({
        'status': 'warning',
        'title': 'Stock needs attention',
        'message': '${lowStock.length} item(s) are at or below warning level.',
      });
    }
    if (businessCash < 0) {
      insights.add({
        'status': 'warning',
        'title': 'Farm cash is negative',
        'message': 'Review expenses, withdrawals, and sales for this month.',
      });
    }
    return insights;
  }

  Future<List<Map<String, dynamic>>> _list(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return <Map<String, dynamic>>[];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<void> _saveList(String key, List<Map<String, dynamic>> items) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(items));
  }

  Future<int> _nextId() async {
    final prefs = await SharedPreferences.getInstance();
    final next = prefs.getInt(_idKey) ?? 1;
    await prefs.setInt(_idKey, next + 1);
    return next;
  }

  Future<void> _updateById(
    String key,
    int id,
    void Function(Map<String, dynamic> item) update,
  ) async {
    final items = await _list(key);
    for (final item in items) {
      if (item['id'] == id) {
        update(item);
        break;
      }
    }
    await _saveList(key, items);
  }

  Future<void> _setMilkRateIfNeeded(int animalId, double dailyMilk) async {
    final rates = await _list(_milkRatesKey);
    final today = _today();
    var updated = false;
    for (final rate in rates) {
      if (rate['animal'] == animalId && rate['effective_date'] == today) {
        rate['daily_milk'] = dailyMilk;
        updated = true;
        break;
      }
    }
    if (!updated) {
      rates.add({
        'id': await _nextId(),
        'animal': animalId,
        'daily_milk': dailyMilk,
        'effective_date': today,
        'notes': 'Normal daily milk set from cow profile',
      });
    }
    await _saveList(_milkRatesKey, rates);
  }

  bool _isSameMonth(dynamic dateValue, int year, int month) {
    final date = DateTime.tryParse('$dateValue');
    return date != null && date.year == year && date.month == month;
  }

  double _sum(Iterable<Map<String, dynamic>> items, String key) {
    return items.fold<double>(0, (total, item) => total + _num(item[key]));
  }

  double _milkTotalWithDefaults(
    List<Map<String, dynamic>> animals,
    List<Map<String, dynamic>> records,
    List<Map<String, dynamic>> milkRates,
    DateTime startDate,
    DateTime endDate,
  ) {
    final manualTotal = _sum(records, 'total_milk');
    final manualPairs = records
        .map((item) => '${item['animal']}|${item['production_date']}')
        .toSet();
    var defaultTotal = 0.0;
    var day = DateTime(startDate.year, startDate.month, startDate.day);
    final lastDay = DateTime(endDate.year, endDate.month, endDate.day);
    while (!day.isAfter(lastDay)) {
      final dateText = day.toIso8601String().split('T').first;
      for (final animal in animals) {
        final dailyMilk = _dailyMilkForDay(animal, milkRates, dateText);
        if (dailyMilk <= 0) continue;
        if (!manualPairs.contains('${animal['id']}|$dateText')) {
          defaultTotal += dailyMilk;
        }
      }
      day = day.add(const Duration(days: 1));
    }
    return manualTotal + defaultTotal;
  }

  double _dailyMilkForDay(
    Map<String, dynamic> animal,
    List<Map<String, dynamic>> milkRates,
    String dateText,
  ) {
    final animalRates =
        milkRates.where((rate) => rate['animal'] == animal['id']).toList()
          ..sort(
            (a, b) =>
                '${a['effective_date']}'.compareTo('${b['effective_date']}'),
          );
    Map<String, dynamic>? current;
    for (final rate in animalRates) {
      if ('${rate['effective_date']}'.compareTo(dateText) <= 0) {
        current = rate;
      } else {
        break;
      }
    }
    if (current != null) return _num(current['daily_milk']);

    final createdOn = '${animal['created_on'] ?? dateText}';
    if (createdOn.compareTo(dateText) <= 0) {
      return _num(animal['default_daily_milk']);
    }
    return 0;
  }

  double _num(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  String _today() => DateTime.now().toIso8601String().split('T').first;
}
