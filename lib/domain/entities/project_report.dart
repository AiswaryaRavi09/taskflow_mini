import 'package:equatable/equatable.dart';

class ProjectReport extends Equatable {
  final String projectId;
  final int totalTasks;
  final int doneTasks;
  final int inProgressTasks;
  final int blockedTasks;
  final int overdueTasks;
  final double completionPercentage;
  final Map<String, int> openTasksByAssignee;

  const ProjectReport({
    required this.projectId,
    required this.totalTasks,
    required this.doneTasks,
    required this.inProgressTasks,
    required this.blockedTasks,
    required this.overdueTasks,
    required this.completionPercentage,
    required this.openTasksByAssignee,
  });

  @override
  List<Object?> get props => [
    projectId,
    totalTasks,
    doneTasks,
    inProgressTasks,
    blockedTasks,
    overdueTasks,
    completionPercentage,
    openTasksByAssignee,
  ];
}