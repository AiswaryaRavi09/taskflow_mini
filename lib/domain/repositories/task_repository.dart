import '../entities/task.dart';
import '../entities/subtask.dart';

abstract class TaskRepository {
  Future<List<Task>> fetchTasksByProject(String projectId);
  Future<Task?> getTaskById(String id);
  Future<Task> createTask(Task task);
  Future<Task> updateTask(Task task);
  Future<void> deleteTask(String id);
  Future<Task> assignUsers(String taskId, List<String> userIds);

  // Subtask operations
  Future<List<Subtask>> fetchSubtasksByTask(String taskId);
  Future<Subtask> createSubtask(Subtask subtask);
  Future<Subtask> updateSubtask(Subtask subtask);
  Future<void> deleteSubtask(String id);
}