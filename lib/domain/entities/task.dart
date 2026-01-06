import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 1)
enum TaskStatus {
  @HiveField(0)
  todo,

  @HiveField(1)
  inProgress,

  @HiveField(2)
  blocked,

  @HiveField(3)
  inReview,

  @HiveField(4)
  done
}

@HiveType(typeId: 2)
enum Priority {
  @HiveField(0)
  low,

  @HiveField(1)
  medium,

  @HiveField(2)
  high,

  @HiveField(3)
  critical
}

@HiveType(typeId: 3)
class Task extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String projectId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final TaskStatus status;

  @HiveField(5)
  final Priority priority;

  @HiveField(6)
  final DateTime? startDate;

  @HiveField(7)
  final DateTime? dueDate;

  @HiveField(8)
  final num estimateHours;

  @HiveField(9)
  final num timeSpentHours;

  @HiveField(10)
  final List<String> labels;

  @HiveField(11)
  final List<String> assigneeIds;

  @HiveField(12)
  final DateTime createdAt;

  const Task({
    required this.id,
    required this.projectId,
    required this.title,
    required this.description,
    this.status = TaskStatus.todo,
    this.priority = Priority.medium,
    this.startDate,
    this.dueDate,
    this.estimateHours = 0,
    this.timeSpentHours = 0,
    this.labels = const [],
    this.assigneeIds = const [],
    required this.createdAt,
  });

  bool get isOverdue {
    if (dueDate == null || status == TaskStatus.done) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isOpen => status != TaskStatus.done;

  Task copyWith({
    String? title,
    String? description,
    TaskStatus? status,
    Priority? priority,
    DateTime? startDate,
    DateTime? dueDate,
    double? estimateHours,
    double? timeSpentHours,
    List<String>? labels,
    List<String>? assigneeIds,
  }) {
    return Task(
      id: id,
      projectId: projectId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      estimateHours: estimateHours ?? this.estimateHours,
      timeSpentHours: timeSpentHours ?? this.timeSpentHours,
      labels: labels ?? this.labels,
      assigneeIds: assigneeIds ?? this.assigneeIds,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    projectId,
    title,
    description,
    status,
    priority,
    startDate,
    dueDate,
    estimateHours,
    timeSpentHours,
    labels,
    assigneeIds,
    createdAt,
  ];
}