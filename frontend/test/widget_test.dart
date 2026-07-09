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

  test('Offline store counts normal daily milk and manual override', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = LocalFarmStore();
    final today = DateTime.now().toIso8601String().split('T').first;

    await store.createAnimal(
      animalIdNumber: 'COW-1',
      name: 'Maya',
      type: 'Cow',
      defaultDailyMilk: 10,
    );

    var snapshot = await store.loadSnapshot();
    expect(snapshot.dashboard['milk_production']['total_liters'], 10);

    await store.createMilkProduction(
      animalId: snapshot.animals.first.id,
      productionDate: today,
      morningMilk: 7,
      eveningMilk: 0,
    );

    snapshot = await store.loadSnapshot();
    expect(snapshot.dashboard['milk_production']['total_liters'], 7);
  });

  test(
    'Offline cow profile milk change updates automatic production',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = LocalFarmStore();

      await store.createAnimal(
        animalIdNumber: 'COW-2',
        name: 'Jui',
        type: 'Cow',
        defaultDailyMilk: 8,
      );
      var snapshot = await store.loadSnapshot();
      final animal = snapshot.animals.first;

      await store.updateAnimal(
        animalId: animal.id,
        animalIdNumber: animal.animalIdNumber,
        name: animal.name,
        type: animal.type,
        breed: animal.breed ?? '',
        gender: animal.gender ?? '',
        healthStatus: animal.healthStatus,
        defaultDailyMilk: 11,
        vaccinated: animal.vaccinated,
        pregnancyStatus: animal.pregnancyStatus,
        notes: animal.notes ?? '',
      );

      snapshot = await store.loadSnapshot();
      expect(snapshot.dashboard['milk_production']['total_liters'], 11);

      final updated = snapshot.animals.first;
      await store.updateAnimal(
        animalId: updated.id,
        animalIdNumber: updated.animalIdNumber,
        name: updated.name,
        type: updated.type,
        breed: updated.breed ?? '',
        gender: updated.gender ?? '',
        healthStatus: updated.healthStatus,
        defaultDailyMilk: 0,
        vaccinated: updated.vaccinated,
        pregnancyStatus: updated.pregnancyStatus,
        notes: updated.notes ?? '',
      );

      snapshot = await store.loadSnapshot();
      expect(snapshot.dashboard['milk_production']['total_liters'], 0);
    },
  );

  test(
    'Offline same-day milk input updates instead of double counting',
    () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final store = LocalFarmStore();
      final today = DateTime.now().toIso8601String().split('T').first;

      await store.createAnimal(
        animalIdNumber: 'COW-3',
        name: 'Tara',
        type: 'Cow',
        defaultDailyMilk: 10,
      );
      var snapshot = await store.loadSnapshot();
      final animalId = snapshot.animals.first.id;

      await store.createMilkProduction(
        animalId: animalId,
        productionDate: today,
        morningMilk: 8,
        eveningMilk: 0,
      );
      await store.createMilkProduction(
        animalId: animalId,
        productionDate: today,
        morningMilk: 6,
        eveningMilk: 0,
      );

      snapshot = await store.loadSnapshot();
      expect(snapshot.milkRecords.length, 1);
      expect(snapshot.dashboard['milk_production']['total_liters'], 6);
    },
  );

  test('Offline milk record can be deleted with reason', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final store = LocalFarmStore();
    final today = DateTime.now().toIso8601String().split('T').first;

    await store.createAnimal(
      animalIdNumber: 'COW-4',
      name: 'Bela',
      type: 'Cow',
      defaultDailyMilk: 10,
    );
    var snapshot = await store.loadSnapshot();
    await store.createMilkProduction(
      animalId: snapshot.animals.first.id,
      productionDate: today,
      morningMilk: 8,
      eveningMilk: 0,
    );
    snapshot = await store.loadSnapshot();

    await store.deleteMilkProduction(
      recordId: snapshot.milkRecords.first['id'] as int,
      reason: 'Wrong cow selected',
    );

    snapshot = await store.loadSnapshot();
    expect(snapshot.milkRecords.length, 0);
    expect(snapshot.dashboard['milk_production']['total_liters'], 10);
  });
}
