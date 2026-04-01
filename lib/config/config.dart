/// App configuration - ubah sesuai environment
class AppConfig {
  // Production environment
  static const String _productionBase = 'https://api.mibt.my.id';

  // Development environment (localhost atau staging)
  static const String _developmentBase = 'http://209.182.237.240:5005';

  /// Set to true when running in development mode
  static bool get isDevelopment =>
      const bool.fromEnvironment('dart.vm.product') == false;

  /// Get base URL sesuai environment
  static const String apiBase = isDevelopment ? _developmentBase : _productionBase;
  static const String apiUrl = '$apiBase/api';

  // Feature flags
  static const bool enableLogging = isDevelopment;
  static const bool enableAnalytics = false;
}
