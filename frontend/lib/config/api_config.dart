class ApiConfig {
  // For production builds, pass:
  // --dart-define=API_BASE_URL=https://your-domain.com/api/v1
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );
}
