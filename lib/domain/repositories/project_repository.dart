import '../entities/project.dart';

abstract class ProjectRepository {
  Future<List<Project>> fetchProjects({bool includeArchived = false});
  Future<Project?> getProjectById(String id);
  Future<Project> createProject(String name, String description);
  Future<Project> updateProject(Project project);
  Future<void> archiveProject(String id);
}