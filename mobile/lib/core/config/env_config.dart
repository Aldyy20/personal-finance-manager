enum AppEnvironment { dev, staging, prod }

class EnvConfig {
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
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    const customBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

    final env = switch (rawEnv.toLowerCase()) {
      'prod' || 'production' => AppEnvironment.prod,
      'staging' => AppEnvironment.staging,
      _ => AppEnvironment.dev,
    };

    final defaultBaseUrl = switch (env) {
      AppEnvironment.prod => 'https://your-domain.com/api/v1',
      AppEnvironment.staging => 'https://staging.your-domain.com/api/v1',
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

