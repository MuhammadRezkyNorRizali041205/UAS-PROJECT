// lib/features/task/domain/entities/task.dart

class TaskCategoryEntity {
  final int id;
  final String name;
  final String color;
  final String? icon;

  const TaskCategoryEntity({
    required this.id,
    required this.name,
    required this.color,
    this.icon,
  });
}

class TaskEntity {
  final int id;
  final String title;
  final String? description;
  final String priority;        // low | medium | high | critical
  final String priorityLabel;
  final String status;          // pending | in_progress | completed | overdue
  final String statusLabel;
  final DateTime? deadline;
  final String? deadlineFormatted;
  final DateTime? completedAt;
  final bool isOverdue;
  final int? daysUntilDue;
  final TaskCategoryEntity? category;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.priorityLabel,
    required this.status,
    required this.statusLabel,
    this.deadline,
    this.deadlineFormatted,
    this.completedAt,
    required this.isOverdue,
    this.daysUntilDue,
    this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  TaskEntity copyWith({
    int? id,
    String? title,
    String? description,
    String? priority,
    String? priorityLabel,
    String? status,
    String? statusLabel,
    DateTime? deadline,
    String? deadlineFormatted,
    DateTime? completedAt,
    bool? isOverdue,
    int? daysUntilDue,
    TaskCategoryEntity? category,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) =>
      TaskEntity(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        priority: priority ?? this.priority,
        priorityLabel: priorityLabel ?? this.priorityLabel,
        status: status ?? this.status,
        statusLabel: statusLabel ?? this.statusLabel,
        deadline: deadline ?? this.deadline,
        deadlineFormatted: deadlineFormatted ?? this.deadlineFormatted,
        completedAt: completedAt ?? this.completedAt,
        isOverdue: isOverdue ?? this.isOverdue,
        daysUntilDue: daysUntilDue ?? this.daysUntilDue,
        category: category ?? this.category,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isInProgress => status == 'in_progress';
}
