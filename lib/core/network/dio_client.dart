import "package:dio/dio.dart";
import "package:connectivity_plus/connectivity_plus.dart";
import "../errors/exceptions.dart";
import "../storage/secure_storage_service.dart";

/// Advanced HTTP client dengan interceptors, retry, dan error handling
class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal() {
    _initDio();
  }

  late final Dio _dio;
  final SecureStorageService _storage = SecureStorageService();
  final Connectivity _connectivity = Connectivity();

  /// Base URLs
  static const String _productionBase = "https://api.mibt.my.id";
  static const String _developmentBase = "http://209.182.237.240:5005";

  /// Environment flag - ubah sesuai kebutuhan
  static bool get isDevelopment =>
      const bool.fromEnvironment("dart.vm.product") == false;

  String get _baseUrl => isDevelopment ? _developmentBase : _productionBase;

  void _initDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.addAll([
      _AuthInterceptor(_dio, _storage),
      _LoggingInterceptor(isDevelopment),
      _RetryInterceptor(_dio),
      _ErrorInterceptor(),
    ]);
  }

  Dio get dio => _dio;

  /// Check internet connectivity
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        return false;
      }
      // Double-check dengan ping ke Google (opsional)
      // bisa juga ping ke own server
      return true;
    } catch (_) {
      return false;
    }
  }
}

/// Interceptor untuk inject & refresh token
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  final SecureStorageService _storage;

  _AuthInterceptor(this._dio, this._storage);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Inject token jika ada
    final token = await SecureStorageService.getToken();
    if (token != null) {
      options.headers["Authorization"] = "Bearer $token";
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Jika 401, coba refresh token sekali
    if (err.response?.statusCode == 401) {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken != null) {
        try {
          final refreshResponse = await _dio.post(
            "/auth/refresh", // endpoint refresh - sesuaikan dengan backend
            data: {"refresh_token": refreshToken},
          );

          if (refreshResponse.statusCode == 200) {
            final newToken = refreshResponse.data["token"];
            final newRefreshToken = refreshResponse.data["refresh_token"];

            // Simpan token baru
            await SecureStorageService.setToken(newToken);
            if (newRefreshToken != null) {
              await SecureStorageService.setRefreshToken(newRefreshToken);
            }

            // Retry request dengan token baru
            final requestOptions = err.requestOptions;
            requestOptions.headers["Authorization"] = "Bearer $newToken";

            final response = await _dio.fetch(requestOptions);
            return handler.resolve(response);
          }
        } catch (_) {
          // Refresh gagal, clear storage dan redirect ke login
          await _storage.clearAuth();
          // TODO: navigate to login - handled di UI layer
        }
      } else {
        // No refresh token, clear storage
        await _storage.clearAuth();
      }
    }
    handler.next(err);
  }
}

/// Interceptor untuk logging (dev only)
class _LoggingInterceptor extends Interceptor {
  final bool _isEnabled;
  _LoggingInterceptor(this._isEnabled);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_isEnabled) {
      print("➡️  ${options.method} ${options.uri}");
      print("Headers: ${options.headers}");
      if (options.data != null) {
        print("Body: ${options.data}");
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_isEnabled) {
      print("⬅️  ${response.statusCode} ${response.requestOptions.uri}");
      print("Response: ${response.data}");
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (_isEnabled) {
      print("❌ Error: ${err.message}");
      print("URI: ${err.requestOptions.uri}");
    }
    handler.next(err);
  }
}

/// Interceptor untuk retry dengan exponential backoff
class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);

  _RetryInterceptor(this._dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Hanya retry untuk network errors (timeout, connection refused)
    // Jangan retry untuk 4xx errors (kecuali 408 Request Timeout)
    if (_shouldRetry(err) && err.requestOptions.retryCount < _maxRetries) {
      final retryCount = err.requestOptions.retryCount + 1;
      final delay = _calculateDelay(retryCount);

      print(
        "🔄 Retrying ${err.requestOptions.uri} (attempt $retryCount) after $delay",
      );

      await Future.delayed(delay);

      final options = Options(
        method: err.requestOptions.method,
        headers: err.requestOptions.headers,
      );

      try {
        final response = await _dio.request<dynamic>(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: options,
          extra: err.requestOptions.extra,
          // Increment retry count
          retryCount: retryCount,
        );
        return handler.resolve(response);
      } catch (e) {
        handler.next(err);
      }
    } else {
      handler.next(err);
    }
  }

  bool _shouldRetry(DioException err) {
    // Retry untuk: timeout, connection error, socket exception
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;
      case DioExceptionType.badResponse:
        // Hanya retry untuk 408 (Request Timeout) atau 5xx (Server errors)
        final statusCode = err.response?.statusCode;
        return statusCode == 408 || (statusCode != null && statusCode >= 500);
      default:
        return false;
    }
  }

  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: 1s, 2s, 4s
    final exponential = _baseDelay * (1 << (retryCount - 1));
    // Jitter untuk menghindari thundering herd
    final jitter = Duration(milliseconds: (100 * retryCount).toInt());
    return exponential + jitter;
  }
}

/// Interceptor untuk convert Dio errors ke custom exceptions
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final exception = _convertError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        type: err.type,
        error: exception,
        response: err.response,
      ),
    );
  }

  ApiException _convertError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException();
      case DioExceptionType.connectionError:
        return NoInternetException();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 401:
            return UnauthorizedException();
          case 403:
            return ApiException(
              "Akses ditolak. Anda tidak memiliki izin.",
              statusCode: statusCode,
            );
          case 404:
            return ApiException(
              "Resource tidak ditemukan.",
              statusCode: statusCode,
            );
          case 500:
            return ServerException(
              "Server error. Silakan coba lagi nanti.",
              statusCode: statusCode,
            );
          default:
            return ApiException(
              'HTTP Error $statusCode: ${err.response?.statusMessage ?? 'Unknown'}',
              statusCode: statusCode,
            );
        }
      case DioExceptionType.cancel:
        return ApiException("Request dibatalkan.");
      case DioExceptionType.unknown:
      default:
        return NoInternetException();
    }
  }
}
