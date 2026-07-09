import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/language_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'services/api_service.dart';
import 'services/local_farm_store.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        _startupError = details.exceptionAsString();
      };

      final apiService = ApiService();
      final localFarmStore = LocalFarmStore();
      runApp(FarmApp(apiService: apiService, localFarmStore: localFarmStore));
    },
    (error, stack) {
      runApp(StartupErrorApp(message: error.toString()));
    },
  );
}

String? _startupError;

class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              message,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class FarmApp extends StatelessWidget {
  const FarmApp({
    super.key,
    required this.apiService,
    required this.localFarmStore,
  });

  final ApiService apiService;
  final LocalFarmStore localFarmStore;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(apiService)..loadToken(),
        ),
        ChangeNotifierProvider<FarmProvider>(
          create: (_) => FarmProvider(apiService, localFarmStore),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'DairyOps',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF147D64),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF5F7F8),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            surfaceTintColor: Colors.transparent,
            backgroundColor: Color(0xFFF5F7F8),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xFFE2E8EA)),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        home: const AuthGate(),
        builder: (context, child) {
          if (_startupError != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _startupError!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return child ?? const SizedBox.shrink();
        },
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    }
    return const LoginScreen();
  }
}
