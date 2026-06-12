// lib/features/schedule/data/models/schedule_model.dart
import '../../domain/entities/schedule.dart';

class ScheduleModel extends ScheduleEntity {
  const ScheduleModel({
    required super.id,
    required super.title,
    required super.category,
    required super.dayOfWeek,
    required super.dayName,
    required super.startTime,
    required super.endTime,
    required super.durationMinutes,
    super.room,
    super.lecturer,
    required super.recurrence,
    required super.startDate,
    super.endDate,
    required super.colorTag,
    required super.isActive,
    required super.isToday,
    super.notes,
    super.createdAt,
    super.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => ScheduleModel(
        id: json['id'] as int,
        title: json['title'] as String,
        category: json['category'] as String,
        dayOfWeek: json['day_of_week'] as int,
        dayName: json['day_name'] as String? ?? '',
        startTime: json['start_time'] as String,
        endTime: json['end_time'] as String,
        durationMinutes: json['duration_minutes'] as int? ?? 0,
        room: json['room'] as String?,
        lecturer: json['lecturer'] as String?,
        recurrence: json['recurrence'] as String? ?? 'weekly',
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        colorTag: json['color_tag'] as String? ?? '#6366F1',
        isActive: json['is_active'] as bool? ?? true,
        isToday: json['is_today'] as bool? ?? false,
        notes: json['notes'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
        updatedAt: json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category,
        'day_of_week': dayOfWeek,
        'start_time': startTime,
        'end_time': endTime,
        'room': room,
        'lecturer': lecturer,
        'recurrence': recurrence,
        'start_date': startDate.toIso8601String().substring(0, 10),
        'end_date': endDate?.toIso8601String().substring(0, 10),
        'color_tag': colorTag,
        'is_active': isActive,
        'notes': notes,
      };
}
