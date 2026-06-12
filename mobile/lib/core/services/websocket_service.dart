// lib/core/services/websocket_service.dart

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../constants/app_constants.dart';

/// Reverb connection config
class _ReverbConfig {
  static const host   = 'localhost';
  static const port   = 8080;
  static const appKey = 'p5xfspi3nsmwcmprm56c';
  static const scheme = 'ws';
}

final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final svc = WebSocketService();
  ref.onDispose(svc.dispose);
  return svc;
});

/// Thin Pusher-protocol client for Laravel Reverb.
/// Handles connection, subscriptions, and event delivery.
class WebSocketService {
  WebSocketChannel? _channel;
  Timer? _pingTimer;
  bool _connected = false;

  // Map of channel → event → list of handlers
  final _handlers = <String, Map<String, List<void Function(Map<String, dynamic>)>>>{};

  final _storage = const FlutterSecureStorage(
    webOptions: WebOptions(dbName: 'smart_campus_db', publicKey: 'smart_campus_key'),
  );

  /// Connect to Reverb and send Pusher handshake.
  Future<void> connect() async {
    if (_connected) return;

    final uri = Uri(
      scheme: _ReverbConfig.scheme,
      host:   _ReverbConfig.host,
      port:   _ReverbConfig.port,
      path:   '/app/${_ReverbConfig.appKey}',
      queryParameters: {
        'protocol': '7',
        'client':   'flutter',
        'version':  '8.0.0',
      },
    );

    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      _onMessage,
      onDone: _onDone,
      onError: _onError,
    );

    _startPing();
    _connected = true;
    debugPrint('[WS] Connected to Reverb');
  }

  void _onMessage(dynamic raw) {
    try {
      final msg = jsonDecode(raw as String) as Map<String, dynamic>;
      final event   = msg['event'] as String? ?? '';
      final channel = msg['channel'] as String? ?? '';
      final dataRaw = msg['data'];

      Map<String, dynamic> data = {};
      if (dataRaw is String) {
        data = jsonDecode(dataRaw) as Map<String, dynamic>;
      } else if (dataRaw is Map<String, dynamic>) {
        data = dataRaw;
      }

      if (event == 'pusher:connection_established') {
        debugPrint('[WS] Connection established');
        _resubscribeAll();
        return;
      }
      if (event == 'pusher_internal:subscription_succeeded') return;

      // Route to registered handlers
      final channelHandlers = _handlers[channel];
      if (channelHandlers != null) {
        final stripped = event.startsWith('App\\Events\\')
            ? event.split('\\').last.toLowerCase()
            : event;

        for (final key in channelHandlers.keys) {
          if (key == event || key == stripped) {
            for (final fn in channelHandlers[key]!) {
              fn(data);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('[WS] Parse error: $e');
    }
  }

  void _onDone() {
    _connected = false;
    debugPrint('[WS] Disconnected — will reconnect');
    Future.delayed(const Duration(seconds: 3), connect);
  }

  void _onError(Object err) {
    debugPrint('[WS] Error: $err');
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _send({'event': 'pusher:ping', 'data': {}});
    });
  }

  void _send(Map<String, dynamic> payload) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(payload));
    }
  }

  /// Subscribe to a Pusher private channel, authenticating via Reverb.
  Future<void> subscribePrivate(String channelName) async {
    final token    = await _storage.read(key: AppConstants.tokenKey);
    final fullName = 'private-$channelName';

    _send({
      'event': 'pusher:subscribe',
      'data': {
        'channel': fullName,
        'auth':    'Bearer $token',
      },
    });
    debugPrint('[WS] Subscribed to $fullName');
  }

  void unsubscribe(String channelName) {
    final fullName = 'private-$channelName';
    _send({'event': 'pusher:unsubscribe', 'data': {'channel': fullName}});
    _handlers.remove(fullName);
  }

  void _resubscribeAll() {
    for (final ch in List.of(_handlers.keys)) {
      _send({'event': 'pusher:subscribe', 'data': {'channel': ch}});
    }
  }

  /// Register a handler for an event on a private channel.
  void on(String channel, String event, void Function(Map<String, dynamic>) handler) {
    final fullName = 'private-$channel';
    _handlers.putIfAbsent(fullName, () => {});
    _handlers[fullName]!.putIfAbsent(event, () => []);
    _handlers[fullName]![event]!.add(handler);
  }

  void off(String channel, String event, void Function(Map<String, dynamic>) handler) {
    final fullName = 'private-$channel';
    _handlers[fullName]?[event]?.remove(handler);
  }

  void dispose() {
    _pingTimer?.cancel();
    _channel?.sink.close();
    _connected = false;
  }
}
