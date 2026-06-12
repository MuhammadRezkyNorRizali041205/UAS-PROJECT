/// Base class for all app exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  const AppException(this.message, {this.code});

  @override
  String toString() => 'AppException($code): $message';
}

/// Server / API errors (4xx, 5xx).
class ServerException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ServerException(
    super.message, {
    super.code,
    this.statusCode,
    this.errors,
  });
}

/// Network connectivity issues.
class NetworkException extends AppException {
  const NetworkException([super.message = 'Tidak ada koneksi internet.']);
}

/// Auth / unauthenticated.
class AuthException extends AppException {
  const AuthException([
    super.message = 'Sesi telah berakhir. Silakan login ulang.',
  ]) : super(code: 'UNAUTHENTICATED');
}

/// Validation errors from server.
class ValidationException extends AppException {
  final Map<String, List<String>> fieldErrors;

  const ValidationException(super.message, {required this.fieldErrors})
    : super(code: 'VALIDATION_ERROR');

  String? firstError(String field) => fieldErrors[field]?.firstOrNull;

  String get allErrors => fieldErrors.values.expand((v) => v).join('\n');
}

/// Cache miss.
class CacheException extends AppException {
  const CacheException([super.message = 'Cache tidak tersedia.']);
}
