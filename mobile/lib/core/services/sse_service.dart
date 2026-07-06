// lib/core/services/sse_service.dart
//
// Server-Sent Events client menggunakan Dio ResponseType.stream.
// Format SSE standar: field "id:", "event:", "data:" dipisah baris kosong.

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

final sseServiceProvider = Provider<SseService>((ref) {
  final svc = SseService();
  ref.onDispose(svc.dispose);
  return svc;
});

class SseEvent {
  final String id;
  final String event;
  final Map<String, dynamic> data;

  const SseEvent({required this.id, required this.event, required this.data});
}

class SseService {
  static const _storage = FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'smart_campus_db', publicKey: 'smart_campus_key'),
  );

  final _controller = StreamController<SseEvent>.broadcast();
  CancelToken? _cancelToken;
  bool _disposed = false;
  String? _lastEventId;

  Stream<SseEvent> get events => _controller.stream;

  /// Sambungkan ke SSE endpoint. Otomatis reconnect saat koneksi putus.
  Future<void> connect() async {
    if (_disposed) return;
    _cancelToken?.cancel();
    _cancelToken = CancelToken();

    final token = await _storage.read(key: 'auth_token');
    if (token == null) return;

    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(minutes: 10),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        if (_lastEventId != null) 'Last-Event-ID': _lastEventId!,
      },
    ));

    try {
      final response = await dio.get<ResponseBody>(
        '/notifications/stream',
        options: Options(responseType: ResponseType.stream),
        cancelToken: _cancelToken,
      );

      final stream = response.data!.stream;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        if (_disposed) break;
        final text = utf8.decode(chunk);
        buffer.write(text);

        // SSE events dipisah oleh baris kosong ganda (\n\n)
        final raw = buffer.toString();
        final parts = raw.split('\n\n');

        // Bagian terakhir mungkin belum lengkap — simpan kembali ke buffer
        buffer.clear();
        buffer.write(parts.removeLast());

        for (final part in parts) {
          _parseAndEmit(part.trim());
        }
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || _disposed) return;
      debugPrint('[SSE] Koneksi terputus: ${e.message}');
    } catch (e) {
      debugPrint('[SSE] Error: $e');
    }

    // Reconnect setelah 5 detik jika belum di-dispose
    if (!_disposed) {
      await Future.delayed(const Duration(seconds: 5));
      connect();
    }
  }

  void _parseAndEmit(String raw) {
    if (raw.isEmpty || raw.startsWith(':')) return; // komentar/heartbeat

    String id = '';
    String event = 'message';
    final dataLines = <String>[];

    for (final line in raw.split('\n')) {
      if (line.startsWith('id:')) {
        id = line.substring(3).trim();
      } else if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        dataLines.add(line.substring(5).trim());
      }
    }

    if (dataLines.isEmpty) return;

    final rawData = dataLines.join('\n');
    try {
      final json = jsonDecode(rawData) as Map<String, dynamic>;
      if (id.isNotEmpty) _lastEventId = id;

      // Abaikan event system (connected, heartbeat)
      if (event == 'connected') return;

      _controller.add(SseEvent(id: id, event: event, data: json));
    } catch (_) {
      // data bukan JSON valid, abaikan
    }
  }

  void disconnect() {
    _cancelToken?.cancel();
    _cancelToken = null;
  }

  void dispose() {
    _disposed = true;
    _cancelToken?.cancel();
    _controller.close();
  }
}
