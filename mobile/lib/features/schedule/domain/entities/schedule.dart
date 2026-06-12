// lib/features/schedule/domain/entities/schedule.dart

class ScheduleEntity {
  final int id;
  final String title;
  final String category;
  final int dayOfWeek;
  final String dayName;
  final String startTime;
  final String endTime;
  final int durationMinutes;
  final String? room;
  final String? lecturer;
  final String recurrence;
  final DateTime startDate;
  final DateTime? endDate;
  final String colorTag;
  final bool isActive;
  final bool isToday;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ScheduleEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.dayOfWeek,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.durationMinutes,
    this.room,
    this.lecturer,
    required this.recurrence,
    required this.startDate,
    this.endDate,
    required this.colorTag,
    required this.isActive,
    required this.isToday,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  ScheduleEntity copyWith({
    int? id,
    String? title,
    String? category,
    int? dayOfWeek,
    String? dayName,
    String? startTime,
    String? endTime,
    int? durationMinutes,
    String? room,
    String? lecturer,
    String? recurrence,
    DateTime? startDate,
    DateTime? endDate,
    String? colorTag,
    bool? isActive,
    bool? isToday,
    String? notes,
  }) =>
      ScheduleEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        category: category ?? this.category,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        dayName: dayName ?? this.dayName,
        startTime: startTime ?? this.startTime,
        endTime: endTime ?? this.endTime,
        durationMinutes: durationMinutes ?? this.durationMinutes,
        room: room ?? this.room,
        lecturer: lecturer ?? this.lecturer,
        recurrence: recurrence ?? this.recurrence,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        colorTag: colorTag ?? this.colorTag,
        isActive: isActive ?? this.isActive,
        isToday: isToday ?? this.isToday,
        notes: notes ?? this.notes,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
