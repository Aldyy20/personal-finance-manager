enum AppEnvironment { dev, staging, prod }

class EnvConfig {
  static const String productionDomain = 'keuangan.underdevelopment.web.id';
  static const String productionBaseUrl =
      'https://keuangan.underdevelopment.web.id/api/v1';

  const EnvConfig({
    required this.environment,
    required this.apiBaseUrl,
    this.connectTimeout = const Duration(seconds: 15),
    this.receiveTimeout = const Duration(seconds: 30),
    this.maxReceiptSizeBytes = 5 * 1024 * 1024,
  });

  final AppEnvironment environment;
  final String apiBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final int maxReceiptSizeBytes;

  factory EnvConfig.fromEnvironment() {
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'prod');
    const customBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

    final env = switch (rawEnv.toLowerCase()) {
      'dev' || 'local' || 'development' => AppEnvironment.dev,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.prod,
    };

    final defaultBaseUrl = switch (env) {
      AppEnvironment.prod => productionBaseUrl,
      AppEnvironment.staging => productionBaseUrl,
      // Uses 127.0.0.1 for USB debugging via `adb reverse tcp:8000 tcp:8000`
      // and local integration tests. Override with --dart-define=API_BASE_URL=...
      AppEnvironment.dev => 'http://127.0.0.1:8000/api/v1',
    };

    return EnvConfig(
      environment: env,
      apiBaseUrl: customBaseUrl.isNotEmpty ? customBaseUrl : defaultBaseUrl,
    );
  }
}

