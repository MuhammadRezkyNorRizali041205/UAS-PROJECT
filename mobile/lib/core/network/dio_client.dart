import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../constants/app_constants.dart';
import '../errors/exceptions.dart';

part 'dio_client.g.dart';

@riverpod
DioClient dioClient(Ref ref) => DioClient();

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: kIsWeb ? 'http://localhost:9000/api/v1' : AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      const _AuthInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'), // ignore: avoid_print
      ),
    ]);
  }

  Dio get dio => _dio;

  /// Generic GET request.
  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.get(path, queryParameters: queryParameters);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic POST request.
  Future<T> post<T>(
    String path, {
    Object? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.post(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic PUT request.
  Future<T> put<T>(
    String path, {
    Object? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.put(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic PATCH request.
  Future<T> patch<T>(
    String path, {
    Object? data,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final res = await _dio.patch(path, data: data);
      return fromJson != null ? fromJson(res.data) : res.data as T;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Generic DELETE request.
  Future<void> delete(String path) async {
    try {
      await _dio.delete(path);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const NetworkException(
          'Koneksi timeout. Periksa jaringan Anda.',
        );

      case DioExceptionType.connectionError:
        if (kIsWeb &&
            (e.message?.toLowerCase().contains('xmlhttprequest') ?? false)) {
          return const NetworkException(
            'Request diblokir browser (CORS). Pastikan backend mengizinkan origin http://localhost:* dan server berjalan di port 9000.',
          );
        }
        return const NetworkException('Tidak dapat terhubung ke server.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final body = e.response?.data as Map<String, dynamic>? ?? {};
        final message = body['message'] as String? ?? 'Terjadi kesalahan.';
        final code = body['code'] as String?;
        final errors = body['errors'];

        if (statusCode == 401) {
          return AuthException(message);
        }

        if (statusCode == 422 && errors is Map) {
          final fieldErrors = errors.map<String, List<String>>(
            (k, v) => MapEntry(
              k.toString(),
              List<String>.from(v is List ? v : [v.toString()]),
            ),
          );
          return ValidationException(message, fieldErrors: fieldErrors);
        }

        return ServerException(message, code: code, statusCode: statusCode);

      default:
        return ServerException(
          e.message ?? 'Terjadi kesalahan tidak diketahui.',
        );
    }
  }
}

/// Interceptor to inject Bearer token on every request.
class _AuthInterceptor extends Interceptor {
  static const _storage = FlutterSecureStorage(
    webOptions:
        WebOptions(dbName: 'smart_campus_db', publicKey: 'smart_campus_key'),
  );

  const _AuthInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Storage read failure (e.g. web crypto error) — proceed without token
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 is handled at the provider/usecase layer — just pass through
    handler.next(err);
  }
}
