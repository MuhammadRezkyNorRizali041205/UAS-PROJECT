import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  static const String appName = 'Smart Campus';

  static String get baseUrl {
    const envUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    // 10.0.2.2 is the Android emulator loopback to host; web needs localhost
    return kIsWeb
        ? 'http://localhost:9000/api/v1'
        : 'http://10.0.2.2:9000/api/v1';
  }

  // Token storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'auth_user';

  // Cache durations
  static const Duration cacheShort = Duration(minutes: 5);
  static const Duration cacheMedium = Duration(minutes: 30);
  static const Duration cacheLong = Duration(hours: 6);

  // Pagination
  static const int defaultPerPage = 20;

  // Task priorities
  static const List<String> taskPriorities = [
    'low',
    'medium',
    'high',
    'critical',
  ];

  // Schedule categories
  static const List<String> scheduleCategories = [
    'lecture',
    'practicum',
    'seminar',
    'organization',
    'task',
    'exam',
  ];

  // Announcement categories
  static const List<String> announcementCategories = [
    'academic',
    'event',
    'seminar',
    'urgent',
    'general',
  ];

  // Days of week (Indonesia)
  static const List<String> daysOfWeek = [
    'Minggu',
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
  ];
}
