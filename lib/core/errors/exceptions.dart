/// Custom exceptions untuk network layer
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  ApiException(
    this.message, {
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() {
    return 'ApiException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
  }
}

/// Network connectivity exception
class NoInternetException extends ApiException {
  NoInternetException()
      : super(
          'Tidak ada koneksi internet. Periksa jaringan Anda.',
          statusCode: null,
        );
}

/// Timeout exception
class TimeoutException extends ApiException {
  TimeoutException()
      : super(
          'Request timeout. Server tidak merespon dalam waktu yang ditentukan.',
          statusCode: null,
        );
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException()
      : super(
          'Sesi sudah berakhir. Silakan login ulang.',
          statusCode: 401,
        );
}

/// Server error exception (5xx)
class ServerException extends ApiException {
  ServerException(String message, {int? statusCode})
      : super(
          message,
          statusCode: statusCode,
        );
}
