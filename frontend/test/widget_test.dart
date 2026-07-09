import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dairyops/main.dart';
import 'package:dairyops/services/api_service.dart';
import 'package:dairyops/services/local_farm_store.dart';

void main() {
  testWidgets('Shows login screen when token is absent', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      FarmApp(apiService: ApiService(), localFarmStore: LocalFarmStore()),
    );
    await tester.pumpAndSettle();

    expect(find.text('DairyOps'), findsWidgets);
    expect(find.text('Sign in to DairyOps'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  test('Offline store matches personal money transfer rules', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = LocalFarmStore();
    final today = DateTime.now().toIso8601String().split('T').first;

    await store.createFamilyWithdrawal(
      withdrawalDate: today,
      reason: 'household',
      description: 'Owner draw',
      amount: 3000,
    );
    await store.createPersonalTransaction(
      transactionDate: today,
      transactionType: 'income',
      category: 'other',
      description: 'Other income',
      amount: 500,
    );
    await store.createPersonalTransaction(
      transactionDate: today,
      transactionType: 'expense',
      category: 'food',
      description: 'Family shopping',
      amount: 800,
    );

    final snapshot = await store.loadSnapshot();

    expect(snapshot.personalMoneySummary['farm_to_pocket'], 3000);
    expect(snapshot.personalMoneySummary['personal_income'], 500);
    expect(snapshot.personalMoneySummary['personal_expenses'], 800);
    expect(snapshot.personalMoneySummary['personal_balance'], 2700);
    expect(
      snapshot.personalTransactions.firstWhere(
        (item) => item['linked_withdrawal'] != null,
      )['transaction_type'],
      'farm_transfer',
    );
  });
}
