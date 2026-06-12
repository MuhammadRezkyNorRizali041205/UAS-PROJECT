// lib/features/task/data/models/task_model.dart
import '../../domain/entities/task.dart';

class TaskCategoryModel extends TaskCategoryEntity {
  const TaskCategoryModel({
    required super.id,
    required super.name,
    required super.color,
    super.icon,
  });

  factory TaskCategoryModel.fromJson(Map<String, dynamic> json) =>
      TaskCategoryModel(
        id: json['id'] as int,
        name: json['name'] as String,
        color: json['color'] as String,
        icon: json['icon'] as String?,
      );
}

class TaskModel extends TaskEntity {
  const TaskModel({
    required super.id,
    required super.title,
    super.description,
    required super.priority,
    required super.priorityLabel,
    required super.status,
    required super.statusLabel,
    super.deadline,
    super.deadlineFormatted,
    super.completedAt,
    required super.isOverdue,
    super.daysUntilDue,
    super.category,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) => TaskModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        priority: json['priority'] as String,
        priorityLabel: json['priority_label'] as String? ?? json['priority'] as String,
        status: json['status'] as String,
        statusLabel: json['status_label'] as String? ?? json['status'] as String,
        deadline: json['deadline'] != null
            ? DateTime.parse(json['deadline'] as String)
            : null,
        deadlineFormatted: json['deadline_formatted'] as String?,
        completedAt: json['completed_at'] != null
            ? DateTime.parse(json['completed_at'] as String)
            : null,
        isOverdue: json['is_overdue'] as bool? ?? false,
        daysUntilDue: json['days_until_due'] as int?,
        category: json['category'] != null
            ? TaskCategoryModel.fromJson(
                json['category'] as Map<String, dynamic>)
            : null,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (description != null) 'description': description,
        'priority': priority,
        'status': status,
        if (deadline != null) 'deadline': deadline!.toIso8601String(),
      };
}
