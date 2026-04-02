/// App configuration - ubah sesuai environment
class AppConfig {
  // Production environment
  static const String _productionBase = "https://api.mibt.my.id";

  // Development environment (localhost atau staging)
  static const String _developmentBase = "http://10.10.10.225:3030";

  /// Set to true when running in development mode
  static bool get isDevelopment =>
      const bool.fromEnvironment("dart.vm.product") == false;

  /// Get base URL sesuai environment
  static final String apiBase = isDevelopment
      ? _developmentBase
      : _productionBase;
  static final String apiUrl = "$apiBase/api";

  // Feature flags
  static final bool enableLogging = isDevelopment;
  static const bool enableAnalytics = false;
}
