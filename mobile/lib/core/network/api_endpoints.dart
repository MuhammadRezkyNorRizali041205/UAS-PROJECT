class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Schedule
  static const String schedules = '/schedules';
  static const String schedulesToday = '/schedules/today';
  static const String schedulesWeek = '/schedules/week';

  // Task
  static const String tasks = '/tasks';
  static const String tasksUpcoming = '/tasks/upcoming';
  static const String tasksOverdue = '/tasks/overdue';
  static const String taskCategories = '/task-categories';

  // Attendance
  static const String attendanceSessions = '/attendance/sessions';
  static const String attendanceScan = '/attendance/scan';
  static const String attendanceHistory = '/attendance/history';
  static const String attendanceStats = '/attendance/stats';

  // Announcements
  static const String announcements = '/announcements';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsUnreadCount = '/notifications/unread-count';
  static const String notificationsReadAll = '/notifications/read-all';

  // Analytics
  static const String analyticsDashboard = '/analytics/dashboard';
  static const String analyticsHeatmap = '/analytics/heatmap';
  static const String analyticsSummary = '/analytics/summary';

  // Profile
  static const String profile = '/profile';
  static const String profileAvatar = '/profile/avatar';
  static const String profileNotifications = '/profile/notifications';

  // Gamification
  static const String gamificationProfile      = '/gamification/profile';
  static const String gamificationQuests       = '/gamification/quests';
  static const String gamificationAchievements = '/gamification/achievements';
  static const String gamificationHistory      = '/gamification/history';

  // Leaderboard
  static const String leaderboard = '/leaderboard';
}
