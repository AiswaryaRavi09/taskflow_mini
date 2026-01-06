import 'package:uuid/uuid.dart';
import '../../domain/entities/task.dart';
import '../../domain/entities/subtask.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/local/hive_data_source.dart';

class TaskRepositoryImpl implements TaskRepository {
  final HiveDataSource dataSource;
  final _uuid = const Uuid();

  TaskRepositoryImpl(this.dataSource);

  @override
  Future<List<Task>> fetchTasksByProject(String projectId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return dataSource.tasksBox.values
        .where((t) => t.projectId == projectId)
        .toList();
  }

  @override
  Future<Task?> getTaskById(String id) async {
    return dataSource.tasksBox.get(id);
  }

  @override
  Future<Task> createTask(Task task) async {
    final newTask = Task(
      id: _uuid.v4(),
      projectId: task.projectId,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      startDate: task.startDate,
      dueDate: task.dueDate,
      estimateHours: task.estimateHours,
      timeSpentHours: task.timeSpentHours,
      labels: task.labels,
      assigneeIds: task.assigneeIds,
      createdAt: DateTime.now(),
    );
    await dataSource.tasksBox.put(newTask.id, newTask);
    return newTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await dataSource.tasksBox.put(task.id, task);
    return task;
  }

  @override
  Future<void> deleteTask(String id) async {
    await dataSource.tasksBox.delete(id);
    // Also delete associated subtasks
    final subtasksToDelete =
        dataSource.subtasksBox.values.where((s) => s.taskId == id);
    for (var subtask in subtasksToDelete) {
      await dataSource.subtasksBox.delete(subtask.id);
    }
  }

  @override
  Future<Task> assignUsers(String taskId, List<String> userIds) async {
    final task = await getTaskById(taskId);
    if (task != null) {
      final updated = task.copyWith(assigneeIds: userIds);
      return await updateTask(updated);
    }
    throw Exception('Task not found');
  }

  @override
  Future<List<Subtask>> fetchSubtasksByTask(String taskId) async {
    return dataSource.subtasksBox.values
        .where((s) => s.taskId == taskId)
        .toList();
  }

  @override
  Future<Subtask> createSubtask(Subtask subtask) async {
    final newSubtask = Subtask(
      id: _uuid.v4(),
      taskId: subtask.taskId,
      title: subtask.title,
      completed: subtask.completed,
      assigneeId: subtask.assigneeId,
    );
    await dataSource.subtasksBox.put(newSubtask.id, newSubtask);
    return newSubtask;
  }

  @override
  Future<Subtask> updateSubtask(Subtask subtask) async {
    await dataSource.subtasksBox.put(subtask.id, subtask);
    return subtask;
  }

  @override
  Future<void> deleteSubtask(String id) async {
    await dataSource.subtasksBox.delete(id);
  }
}