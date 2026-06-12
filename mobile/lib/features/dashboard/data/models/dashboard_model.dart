// lib/features/dashboard/data/models/dashboard_model.dart

import '../../domain/entities/dashboard_data.dart';

class DashboardScheduleItemModel extends DashboardScheduleItem {
  const DashboardScheduleItemModel({
    required super.id,
    required super.title,
    required super.category,
    required super.startTime,
    required super.endTime,
    super.room,
    super.lecturer,
    required super.categoryColor,
  });

  factory DashboardScheduleItemModel.fromJson(Map<String, dynamic> json) =>
      DashboardScheduleItemModel(
        id:            json['id'] as int,
        title:         json['title'] as String,
        category:      json['category'] as String,
        startTime:     json['start_time'] as String,
        endTime:       json['end_time'] as String,
        room:          json['room'] as String?,
        lecturer:      json['lecturer'] as String?,
        categoryColor: json['category_color'] as String? ?? '#6366F1',
      );
}

class DashboardDeadlineItemModel extends DashboardDeadlineItem {
  const DashboardDeadlineItemModel({
    required super.id,
    required super.title,
    required super.priority,
    required super.deadline,
    super.deadlineFormatted,
    super.daysUntilDue,
  });

  factory DashboardDeadlineItemModel.fromJson(Map<String, dynamic> json) =>
      DashboardDeadlineItemModel(
        id:                json['id'] as int,
        title:             json['title'] as String,
        priority:          json['priority'] as String,
        deadline:          DateTime.parse(json['deadline'] as String),
        deadlineFormatted: json['deadline_formatted'] as String?,
        daysUntilDue:      json['days_until_due'] as int?,
      );
}

class WeeklyStatsModel extends WeeklyStats {
  const WeeklyStatsModel({
    required super.totalTasks,
    required super.completedTasks,
    required super.overdueTasks,
    required super.completionRate,
  });

  factory WeeklyStatsModel.fromJson(Map<String, dynamic> json) =>
      WeeklyStatsModel(
        totalTasks:     json['total_tasks'] as int? ?? 0,
        completedTasks: json['completed_tasks'] as int? ?? 0,
        overdueTasks:   json['overdue_tasks'] as int? ?? 0,
        completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      );
}

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.greeting,
    required super.todaySchedules,
    required super.upcomingDeadlines,
    required super.weeklyStats,
    required super.streak,
    required super.totalSchedules,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final schedules = (json['today_schedules'] as List<dynamic>? ?? [])
        .map((e) => DashboardScheduleItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    final deadlines = (json['upcoming_deadlines'] as List<dynamic>? ?? [])
        .map((e) => DashboardDeadlineItemModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DashboardDataModel(
      greeting:          json['greeting'] as String? ?? '',
      todaySchedules:    schedules,
      upcomingDeadlines: deadlines,
      weeklyStats:       WeeklyStatsModel.fromJson(
          json['weekly_stats'] as Map<String, dynamic>? ?? {}),
      streak:            json['streak'] as int? ?? 0,
      totalSchedules:    json['total_schedules'] as int? ?? 0,
    );
  }
}
