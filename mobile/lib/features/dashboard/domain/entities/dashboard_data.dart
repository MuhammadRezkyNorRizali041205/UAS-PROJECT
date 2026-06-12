// lib/features/dashboard/domain/entities/dashboard_data.dart

class DashboardScheduleItem {
  final int id;
  final String title;
  final String category;
  final String startTime;
  final String endTime;
  final String? room;
  final String? lecturer;
  final String categoryColor;

  const DashboardScheduleItem({
    required this.id,
    required this.title,
    required this.category,
    required this.startTime,
    required this.endTime,
    this.room,
    this.lecturer,
    required this.categoryColor,
  });
}

class DashboardDeadlineItem {
  final int id;
  final String title;
  final String priority;
  final DateTime deadline;
  final String? deadlineFormatted;
  final int? daysUntilDue;

  const DashboardDeadlineItem({
    required this.id,
    required this.title,
    required this.priority,
    required this.deadline,
    this.deadlineFormatted,
    this.daysUntilDue,
  });
}

class WeeklyStats {
  final int totalTasks;
  final int completedTasks;
  final int overdueTasks;
  final double completionRate;

  const WeeklyStats({
    required this.totalTasks,
    required this.completedTasks,
    required this.overdueTasks,
    required this.completionRate,
  });
}

class DashboardData {
  final String greeting;
  final List<DashboardScheduleItem> todaySchedules;
  final List<DashboardDeadlineItem> upcomingDeadlines;
  final WeeklyStats weeklyStats;
  final int streak;
  final int totalSchedules;

  const DashboardData({
    required this.greeting,
    required this.todaySchedules,
    required this.upcomingDeadlines,
    required this.weeklyStats,
    required this.streak,
    required this.totalSchedules,
  });
}
