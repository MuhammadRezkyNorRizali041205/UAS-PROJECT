// lib/core/services/sse_notification_provider.dart
//
// Provider yang memulai koneksi SSE setelah login dan meneruskan event
// ke flutter_local_notifications + refresh unread-count.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/notification/presentation/providers/notification_provider.dart';
import 'local_notification_service.dart';
import 'sse_service.dart';

/// Autorun provider — aktif selama ProviderScope hidup.
/// Mulai koneksi SSE dan tampilkan local notification saat event masuk.
final sseNotificationListenerProvider = Provider<void>((ref) {
  final sseService = ref.watch(sseServiceProvider);
  StreamSubscription? sub;

  void start() {
    sseService.connect();
    sub = sseService.events.listen((event) {
      if (event.event != 'notification') return;

      final title = event.data['title'] as String? ?? 'Notifikasi Baru';
      final body  = event.data['body']  as String? ?? '';
      final id    = int.tryParse(event.id) ?? DateTime.now().millisecondsSinceEpoch & 0x7FFFFFFF;

      // Tampilkan local notification
      LocalNotificationService.show(id: id, title: title, body: body);

      // Refresh badge unread-count di UI
      ref.invalidate(notificationUnreadCountProvider);
    });
  }

  start();

  ref.onDispose(() {
    sub?.cancel();
    sseService.disconnect();
  });
});
