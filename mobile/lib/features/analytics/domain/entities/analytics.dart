// lib/features/analytics/domain/entities/analytics.dart

class TaskStatsEntity {
  final int total;
  final int completed;
  final int pending;
  final int inProgress;
  final int overdue;
  final double completionRate;

  const TaskStatsEntity({
    required this.total,
    required this.completed,
    required this.pending,
    required this.inProgress,
    required this.overdue,
    required this.completionRate,
  });
}

class DashboardAnalyticsEntity {
  final TaskStatsEntity tasks;
  final Map<String, int> tasksByPriority;
  final Map<String, int> schedulesByCategory;
  final int attendanceThisMonth;

  const DashboardAnalyticsEntity({
    required this.tasks,
    required this.tasksByPriority,
    required this.schedulesByCategory,
    required this.attendanceThisMonth,
  });
}

class HeatmapDayEntity {
  final DateTime date;
  final int count;

  const HeatmapDayEntity({required this.date, required this.count});
}

class ChartDataPoint {
  final String label;
  final double value;
  const ChartDataPoint({required this.label, required this.value});
}

class SummaryAnalyticsEntity {
  final int thisWeekCompleted;
  final int lastWeekCompleted;
  final int weekChange;
  final String mostProductiveDay;
  final int activeSchedules;
  final String period;
  final List<ChartDataPoint> chartData;

  const SummaryAnalyticsEntity({
    required this.thisWeekCompleted,
    required this.lastWeekCompleted,
    required this.weekChange,
    required this.mostProductiveDay,
    required this.activeSchedules,
    this.period = 'week',
    this.chartData = const [],
  });
}
