import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:dairyops/main.dart';
import 'package:dairyops/services/api_service.dart';

void main() {
  testWidgets('Shows login screen when token is absent', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(FarmApp(apiService: ApiService()));
    await tester.pumpAndSettle();

    expect(find.text('DairyOps'), findsWidgets);
    expect(find.text('Sign in to DairyOps'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
