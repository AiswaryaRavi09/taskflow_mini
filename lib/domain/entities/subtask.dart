import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'subtask.g.dart';

@HiveType(typeId: 4)
class Subtask extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String taskId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final bool completed;

  @HiveField(4)
  final String? assigneeId;

  const Subtask({
    required this.id,
    required this.taskId,
    required this.title,
    this.completed = false,
    this.assigneeId,
  });

  Subtask copyWith({
    String? title,
    bool? completed,
    String? assigneeId,
  }) {
    return Subtask(
      id: id,
      taskId: taskId,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      assigneeId: assigneeId ?? this.assigneeId,
    );
  }

  @override
  List<Object?> get props => [id, taskId, title, completed, assigneeId];
}