/// Centralized logging untuk aplikasi
/// Debug mode: semua logs terlihat
/// Release mode: hanya error logs
import 'package:flutter/foundation.dart';

class AppLogger {
  /// Debug level - hanya muncul di development
  static void d(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
      print('[$timestamp] [DEBUG]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// Info level - hanya muncul di development
  static void i(String message, {String? tag}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
      print('[$timestamp] [INFO]${tag != null ? '[$tag]' : ''} $message');
    }
  }

  /// Warning - muncul di semua mode
  static void w(String message, {String? tag, Error? error}) {
    final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
    print('[$timestamp] [WARN]${tag != null ? '[$tag]' : ''} $message${error != null ? '\n$error' : ''}');
  }

  /// Error - selalu muncul (critical)
  static void e(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
    print('[$timestamp] [ERROR]${tag != null ? '[$tag]' : ''} $message${error != null ? '\n$error' : ''}');
    if (kDebugMode && stackTrace != null) {
      print('Stack trace:\n$stackTrace');
    }
  }

  /// Log request (HTTP/network)
  static void request(String method, String url, {Map<String, dynamic>? headers, dynamic body}) {
    if (!kDebugMode) return;
    d('$method $url', tag: 'HTTP');
    if (headers != null) {
      d('Headers: $headers', tag: 'HTTP');
    }
    if (body != null) {
      d('Body: $body', tag: 'HTTP');
    }
  }

  /// Log response (HTTP/network)
  static void response(int statusCode, String url, {dynamic data, String? error}) {
    if (!kDebugMode && statusCode < 400) return; // Only show errors in production
    if (statusCode >= 200 && statusCode < 300) {
      i('$statusCode $url', tag: 'HTTP');
    } else if (statusCode >= 400) {
      e('$statusCode $url${error != null ? ' - $error' : ''}', tag: 'HTTP');
    }
  }
}
