import '../../domain/entities/project_report.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/report_repository.dart';
import '../datasources/local/hive_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final HiveDataSource dataSource;

  ReportRepositoryImpl(this.dataSource);

  @override
  Future<ProjectReport> getProjectStatus(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final allTasks = dataSource.tasksBox.values.toList();
    final tasks = allTasks.where((t) => t.projectId == projectId).toList();

    final totalTasks = tasks.length;
    final doneTasks = tasks.where((t) => t.status == TaskStatus.done).length;
    final inProgressTasks =
        tasks.where((t) => t.status == TaskStatus.inProgress).length;
    final blockedTasks =
        tasks.where((t) => t.status == TaskStatus.blocked).length;
    final overdueTasks = tasks.where((t) => t.isOverdue).length;

    final completionPercentage =
        totalTasks > 0 ? (doneTasks / totalTasks) * 100 : 0.0;

    // Calculate open tasks by assignee
    final openTasksByAssignee = <String, int>{};
    final users = dataSource.usersBox.values.toList();

    for (final task in tasks.where((t) => t.isOpen)) {
      for (final assigneeId in task.assigneeIds) {
        openTasksByAssignee[assigneeId] =
            (openTasksByAssignee[assigneeId] ?? 0) + 1;
      }
    }

    // Convert user IDs to names
    final openTasksByName = <String, int>{};
    for (final entry in openTasksByAssignee.entries) {
      final user = users.firstWhere((u) => u.id == entry.key,
          orElse: () => throw Exception('User not found'));
      openTasksByName[user.name] = entry.value;
    }

    return ProjectReport(
      projectId: projectId,
      totalTasks: totalTasks,
      doneTasks: doneTasks,
      inProgressTasks: inProgressTasks,
      blockedTasks: blockedTasks,
      overdueTasks: overdueTasks,
      completionPercentage:
          double.parse(completionPercentage.toStringAsFixed(1)),
      openTasksByAssignee: openTasksByName,
    );
  }
}