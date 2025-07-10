import 'dart:io';

import 'package:dio/dio.dart';
import 'package:konfirmasi_wilkerstat/classes/app_config.dart';
import 'package:konfirmasi_wilkerstat/classes/services/dio_service.dart';
import 'package:konfirmasi_wilkerstat/classes/telegram_logger.dart';

/// Authentication types for 3rd party APIs
enum AuthType {
  bearer, // Bearer token (Authorization: Bearer token)
  apiKey, // API Key (X-API-Key: key)
  basicAuth, // Basic auth (Authorization: Basic base64)
  custom, // Custom authentication (provide your own headers)
}

/// Service for handling requests to 3rd party APIs
/// This service handles three main types of requests:
/// 1. Cloudflare requests (no auth)
/// 2. General domain requests (no auth)
/// 3. Authenticated domain requests (with auth)
class ThirdPartyApiService {
  static final ThirdPartyApiService _instance =
      ThirdPartyApiService._internal();
  factory ThirdPartyApiService() => _instance;

  ThirdPartyApiService._internal();

  late Dio dio;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        // logPrint: (obj) {
        //   // Only log in debug mode
        //   assert(() {
        //     print('ThirdPartyAPI: $obj');
        //     return true;
        //   }());
        // },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          _handleError(error);
          handler.reject(error);
        },
      ),
    );
  }

  void dispose() {
    dio.close();
  }

  void _handleError(DioException error, [String serviceType = 'External']) {
    // Determine user-friendly message
    String userMessage = 'Terjadi kesalahan pada layanan $serviceType';

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      userMessage = 'Timeout saat mengakses layanan $serviceType';
    } else if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode;
      userMessage = 'Layanan $serviceType error (${statusCode ?? 'Unknown'})';
    } else if (error.type == DioExceptionType.cancel) {
      userMessage = 'Request ke layanan $serviceType dibatalkan';
    } else if (error.type == DioExceptionType.unknown &&
        error.error is SocketException) {
      userMessage = 'Tidak dapat terhubung ke layanan $serviceType';
    }

    // Send log to Telegram for monitoring
    _safeSendLog(error, userMessage, serviceType);

    throw DataProviderException(userMessage);

    // Don't throw here, let the caller handle the exception
  }

  void _safeSendLog(
    DioException error,
    String userMessage, [
    String serviceType = 'External',
  ]) {
    try {
      final request = error.requestOptions;
      final statusCode = error.response?.statusCode ?? 'N/A';
      final responseBody = error.response?.data.toString() ?? 'null';
      final stackTrace = (error.stackTrace.toString()).trim();
      final trimmedStack =
          stackTrace.length > AppConfig.stackTraceLimitCharacter
              ? '${stackTrace.substring(0, AppConfig.stackTraceLimitCharacter)}...'
              : stackTrace;

      final logMessage = '''
🔗 *$serviceType API Error Report*

*Type:* `${error.type}`
*Message:* `${error.message}`
*URL:* `${request.uri}`
*Method:* `${request.method}`
*Status Code:* `$statusCode`
*User Message:* `$userMessage`

*Response Body:*
$responseBody

*Stack Trace:*
$trimmedStack
''';

      TelegramLogger.send(logMessage);
    } catch (_) {
      // Fail silently so it never blocks real error flow
    }
  }
}

/// Exception for 3rd party API errors
class ThirdPartyApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  const ThirdPartyApiException(this.message, {this.statusCode, this.response});

  @override
  String toString() => 'ThirdPartyApiException: $message';
}
