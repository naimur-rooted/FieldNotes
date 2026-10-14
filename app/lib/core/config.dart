/// Central config.
///
/// Priority for the API base URL:
/// 1. --dart-define=API_BASE_URL=https://your-api.onrender.com (Vercel build)
/// 2. Vercel/local default below for web
/// 3. Android emulator / device defaults for mobile
class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Vercel: set API_BASE_URL via build command below.
    // Local emulator default (Android):
    defaultValue: 'http://10.0.2.2:8080',
  );
}

